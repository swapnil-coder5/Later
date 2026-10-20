import test, { after, before } from "node:test";
import assert from "node:assert/strict";
import http from "node:http";
import net from "node:net";
import { spawn } from "node:child_process";

let child;
let port;

async function freePort() {
  const socket = net.createServer();
  await new Promise((resolve, reject) => socket.listen(0, "127.0.0.1", resolve).once("error", reject));
  const selected = socket.address().port;
  await new Promise(resolve => socket.close(resolve));
  return selected;
}

function request(path, host, origin) {
  return new Promise((resolve, reject) => {
    const headers = { Host: host };
    if (origin) headers.Origin = origin;
    const req = http.get({ hostname: "127.0.0.1", port, path, headers }, res => {
      let body = "";
      res.setEncoding("utf8");
      res.on("data", chunk => { body += chunk; });
      res.on("end", () => resolve({ status: res.statusCode, body, headers: res.headers }));
    });
    req.on("error", reject);
  });
}

before(async () => {
  port = await freePort();
  child = spawn(process.execPath, ["server.mjs"], {
    cwd: new URL("..", import.meta.url),
    env: { ...process.env, PORT: String(port), RENDER: "true", RENDER_EXTERNAL_HOSTNAME: "later-test.onrender.com" },
    stdio: ["ignore", "pipe", "pipe"]
  });
  await new Promise((resolve, reject) => {
    const timer = setTimeout(() => reject(new Error("Test server did not start")), 5000);
    child.once("exit", code => reject(new Error(`Test server exited with ${code}`)));
    child.stdout.on("data", chunk => {
      if (String(chunk).includes("Later is ready")) { clearTimeout(timer); resolve(); }
    });
  });
});

after(() => { if (child && !child.killed) child.kill(); });

test("Render health check does not depend on its Host header", async () => {
  const response = await request("/healthz", "internal-render-check");
  assert.equal(response.status, 200);
  assert.equal(JSON.parse(response.body).status, "ok");
});

test("accepts the configured Render hostname", async () => {
  const response = await request("/", "later-test.onrender.com");
  assert.equal(response.status, 200);
  assert.match(response.body, /<title>Later/);
});

test("rejects unknown hostnames and cross-origin requests", async () => {
  const badHost = await request("/", "attacker.example");
  assert.equal(badHost.status, 403);
  const badOrigin = await request("/", "later-test.onrender.com", "https://attacker.example");
  assert.equal(badOrigin.status, 403);
});
