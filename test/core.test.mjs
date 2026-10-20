import test from "node:test";
import assert from "node:assert/strict";
import { validatePlan, calendar } from "../core.mjs";
const task = { title: "Reply", kind: "reply", effort: 5, source: "reply to Jo", reason: "Close loop", draft: "Hi Jo", date: "" };
test("accepts grounded tasks and strips unexpected properties", () => {
  const result = validatePlan({ summary: "One task", tasks: [{ ...task, command: "bad" }] }, "Please reply to Jo.");
  assert.equal(result.tasks[0].command, undefined);
});
test("rejects invented evidence", () => {
  assert.throws(() => validatePlan({ summary: "", tasks: [task] }, "Buy milk"), /traced/);
});
test("rejects unsupported actions and invalid dates", () => {
  for (const change of [{ kind: "shell" }, { effort: -2 }, { date: "2026-02-30" }]) {
    assert.throws(() => validatePlan({ summary: "", tasks: [{ ...task, ...change }] }, task.source));
  }
});
test("accepts notes with no obligations", () => {
  assert.deepEqual(validatePlan({ summary: "Nothing to do", tasks: [] }, "A nice day"), { summary: "Nothing to do", tasks: [] });
});
test("calendar escapes user content to prevent property injection", () => {
  const output = calendar({ title: "Meet\nATTENDEE:someone", draft: "a,b;c\\d", date: "2026-10-24" });
  assert.ok(output.includes("SUMMARY:Meet\\nATTENDEE:someone"));
  assert.ok(!output.includes("\r\nATTENDEE:"));
  assert.ok(output.includes("DTSTART;VALUE=DATE:20261024"));
  assert.ok(output.includes("DESCRIPTION:a\\,b\\;c\\\\d"));
});
test("calendar folds long Unicode lines within byte limit", () => {
  const output = calendar({ title: "🌿".repeat(80), draft: "hello", date: "2026-10-24" });
  assert.ok(output.split("\r\n").every(line => Buffer.byteLength(line) <= 75));
});
