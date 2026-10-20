const $ = s => document.querySelector(s);
const SAMPLE = `I still owe Maya a reply about her portfolio. Tell her I loved the case study, but the mobile screenshots could be bigger.
Need to get ready for the weekend hike: water, sunscreen, snacks, and check the weather.
Book some time on 2026-10-24 to finally sort my project screenshots and write a short LinkedIn update.`;
const fixture = {
  summary: "Three loose ends, with the first bit already prepared. Pick the one that matches your energy.",
  tasks: [
    { title: "Give Maya her portfolio feedback", kind: "reply", effort: 5, source: "Tell her I loved the case study, but the mobile screenshots could be bigger.", reason: "A short reply closes this loop.", draft: "Hey Maya! I loved the case study in your portfolio — it was great to read through. One small suggestion: the mobile screenshots could be a bit bigger so the details are easier to see. Hope that helps!", date: "" },
    { title: "Pack for your weekend hike", kind: "checklist", effort: 10, source: "Need to get ready for the weekend hike: water, sunscreen, snacks, and check the weather.", reason: "A ready-made packing list means less remembering.", draft: "☐ Pack water\n☐ Pack sunscreen\n☐ Pack snacks\n☐ Check the weather before leaving", date: "" },
    { title: "Give your project a moment in the sun", kind: "calendar", effort: 25, source: "Book some time on 2026-10-24 to finally sort my project screenshots and write a short LinkedIn update.", reason: "An all-day calendar reminder keeps the loose end visible.", draft: "Sort project screenshots and select the clearest examples.\nWrite a short LinkedIn update covering the problem, what I built, and what I learned.\nReview the post before publishing.", date: "2026-10-24" }
  ]
};
const EXAMPLES = [
  { name: "Weekend reset", input: SAMPLE, plan: fixture },
  {
    name: "Job interview",
    input: `Reply to the recruiter: thank them for the interview invitation and confirm I am available Tuesday afternoon.
Before the interview, review the company, prepare two project stories, and test my camera.
Block 2026-10-27 for the interview preparation session.`,
    plan: { summary: "Your interview prep is split into one reply, one checklist, and one calendar block.", tasks: [
      { title: "Confirm your interview availability", kind: "reply", effort: 5, source: "Reply to the recruiter: thank them for the interview invitation and confirm I am available Tuesday afternoon.", reason: "A prepared confirmation closes the scheduling loop.", draft: "Hi [Recruiter name],\n\nThank you for the interview invitation. I’m available on Tuesday afternoon and would be happy to confirm a time that works for the team.\n\nBest,\n[Your name]", date: "" },
      { title: "Prepare for the interview", kind: "checklist", effort: 35, source: "Before the interview, review the company, prepare two project stories, and test my camera.", reason: "A short checklist turns preparation into visible steps.", draft: "☐ Review the company and role\n☐ Prepare two concise project stories\n☐ Test the camera and microphone\n☐ Keep the job description nearby", date: "" },
      { title: "Interview preparation session", kind: "calendar", effort: 30, source: "Block 2026-10-27 for the interview preparation session.", reason: "A calendar block protects time for preparation.", draft: "Review the role, rehearse two project stories, and test the video setup.", date: "2026-10-27" }
    ] }
  },
  {
    name: "Study day",
    input: `Email Professor Shah to ask whether the assignment deadline includes Friday.
For tomorrow's study session, revise chapters 4 and 5, make flashcards, and attempt the practice quiz.`,
    plan: { summary: "One clear question and a manageable study plan are ready.", tasks: [
      { title: "Clarify the assignment deadline", kind: "reply", effort: 4, source: "Email Professor Shah to ask whether the assignment deadline includes Friday.", reason: "A concise question prevents deadline confusion.", draft: "Subject: Assignment deadline clarification\n\nHello Professor Shah,\n\nCould you please confirm whether the assignment deadline includes Friday, or if it is due before then?\n\nThank you,\n[Your name]", date: "" },
      { title: "Complete tomorrow’s study session", kind: "checklist", effort: 60, source: "For tomorrow's study session, revise chapters 4 and 5, make flashcards, and attempt the practice quiz.", reason: "The study session is divided into concrete steps.", draft: "☐ Revise chapter 4\n☐ Revise chapter 5\n☐ Create flashcards for difficult concepts\n☐ Attempt the practice quiz\n☐ Note topics that need another review", date: "" }
    ] }
  },
  {
    name: "Trip planning",
    input: `Ask Arun if he is free for the Goa trip on the first weekend of November.
I need to compare train options, shortlist two places to stay, and make a packing list.`,
    plan: { summary: "The coordination message and travel research list are prepared.", tasks: [
      { title: "Check Arun’s availability", kind: "reply", effort: 3, source: "Ask Arun if he is free for the Goa trip on the first weekend of November.", reason: "A quick message gets the planning started.", draft: "Hey Arun! Are you free for a Goa trip on the first weekend of November? If yes, I’ll start narrowing down the travel and stay options.", date: "" },
      { title: "Research the Goa trip", kind: "checklist", effort: 45, source: "I need to compare train options, shortlist two places to stay, and make a packing list.", reason: "A checklist keeps the open travel decisions together.", draft: "☐ Compare train times and prices\n☐ Save the best two train options\n☐ Shortlist two places to stay\n☐ Compare location, price, and reviews\n☐ Draft a packing list", date: "" }
    ] }
  },
  {
    name: "Portfolio launch",
    input: `Write a short LinkedIn post about finishing my local AI project and mention privacy, Ollama, and what I learned.
Before posting, choose three screenshots, check the repository README, and add the project to my resume.`,
    plan: { summary: "Your launch post and final portfolio checks are ready to review.", tasks: [
      { title: "Draft your project announcement", kind: "reply", effort: 15, source: "Write a short LinkedIn post about finishing my local AI project and mention privacy, Ollama, and what I learned.", reason: "A prepared post makes sharing the project easier.", draft: "I just finished building Later, a local AI productivity assistant powered by Ollama. It turns messy notes into editable replies, checklists, and calendar reminders while keeping inference on the user’s machine.\n\nBuilding it taught me how to work with structured model output, validate AI-generated data, and design a review-first workflow.\n\n[Add your repository or demo link]", date: "" },
      { title: "Finish the portfolio launch", kind: "checklist", effort: 30, source: "Before posting, choose three screenshots, check the repository README, and add the project to my resume.", reason: "These final checks make the project presentation complete.", draft: "☐ Choose three clear screenshots\n☐ Review the repository README\n☐ Verify setup instructions\n☐ Add the project to your resume\n☐ Review the LinkedIn post before publishing", date: "" }
    ] }
  }
];
let exampleIndex = -1;
let activeExample = EXAMPLES[0];
let saved;
try { saved = JSON.parse(localStorage.getItem("later-v1") || "{}"); } catch { saved = {}; }
let tasks = Array.isArray(saved.tasks) ? saved.tasks.filter(t => t && typeof t.title === "string" && typeof t.draft === "string") : [];
let profile = {
  name: typeof saved.profile?.name === "string" && saved.profile.name.trim() ? saved.profile.name.slice(0, 24) : "Your username",
  photo: typeof saved.profile?.photo === "string" && saved.profile.photo.startsWith("data:image/") ? saved.profile.photo : ""
};
let energy = 15, demo = false, online = false, hosted = false, busy = false, healthTimer = 0;
$("#sample").textContent = `Try ${EXAMPLES.length} examples ↗`;
$("#note").value = typeof saved.note === "string" ? saved.note : "";
function notice(text) { $("#notice").textContent = text; }
function persist() {
  try { localStorage.setItem("later-v1", JSON.stringify({ tasks, note: $("#note").value, profile })); }
  catch { notice("Browser storage is full or unavailable. Export your notebook to keep this work."); }
}
function element(tag, text, className) {
  const e = document.createElement(tag); e.textContent = text;
  if (className) e.className = className;
  return e;
}
function download(content, name, type = "text/markdown") {
  const url = URL.createObjectURL(new Blob([content], { type }));
  const a = document.createElement("a"); a.href = url; a.download = name; a.click();
  setTimeout(() => URL.revokeObjectURL(url), 1000);
}
function render() {
  const pending = tasks.filter(t => !t.done).sort((a, b) => a.effort - b.effort);
  $("#task-count").textContent = pending.length;
  $("#done-count").textContent = tasks.filter(t => t.done).length;
  $("#empty").hidden = pending.length > 0;
  $("#tasks").replaceChildren(); $("#completed").replaceChildren();
  for (const t of [...pending, ...tasks.filter(t => t.done)]) {
    const card = element("article", "", "task");
    card.append(element("div", { reply: "↗", checklist: "☷", calendar: "▦" }[t.kind] || "○", "task-icon"));
    const content = element("div", "", "task-main");
    content.append(element("div", `${t.kind} · ${t.demo ? "sample" : t.hosted ? "hosted open AI" : "local AI"}${!t.done && t.effort <= energy ? " · fits your energy" : ""}`, "tag"), element("h3", t.title), element("p", `~${t.effort} min preparation estimate`));
    card.append(content);
    const review = element("button", "Open draft ↗");
    review.onclick = () => openTask(t); card.append(review);
    const done = element("button", t.done ? "Restore" : "Done ✓", "finish");
    done.onclick = () => { t.done = !t.done; persist(); render(); };
    card.append(done);
    $(t.done ? "#completed" : "#tasks").append(card);
  }
  if (!tasks.some(t => t.done)) $("#completed").append(element("p", "Nothing here yet. Your first small win is waiting.", "muted"));
}
function openTask(t) {
  const root = $("#detail-content"); root.replaceChildren();
  root.append(element("span", t.demo ? "SAMPLE DRAFT · REVIEW BEFORE USE" : `${t.hosted ? "HOSTED OPEN AI" : "LOCAL AI"} DRAFT · REVIEW BEFORE USE`, "eyebrow"), element("h2", t.title), element("p", t.reason), element("blockquote", t.source));
  const label = element("label", "Make it yours"); label.htmlFor = "draft";
  const draft = element("textarea"); draft.id = "draft"; draft.value = t.draft;
  draft.oninput = () => { t.draft = draft.value; persist(); };
  root.append(label, draft);
  if (t.kind === "calendar") {
    const dateLabel = element("label", " Calendar date ");
    const date = element("input"); date.type = "date"; date.value = t.date; date.setAttribute("aria-label", "Calendar date");
    date.onchange = () => { t.date = date.value; persist(); };
    dateLabel.append(date); root.append(dateLabel);
  }
  const actions = element("div", "", "actions");
  const copy = element("button", "Copy draft", "primary");
  copy.onclick = async () => { try { await navigator.clipboard.writeText(t.draft); copy.textContent = "Copied ✓"; } catch { copy.textContent = "Select the draft to copy"; } };
  const save = element("button", t.kind === "calendar" ? "Download .ics" : "Download .md", "primary");
  save.onclick = async () => {
    if (t.kind !== "calendar") return download(`# ${t.title}\n\n${t.draft}\n`, "later-draft.md");
    try {
      const r = await fetch("/api/calendar", { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify(t) });
      if (!r.ok) throw new Error((await r.json()).error);
      download(await r.text(), "later-reminder.ics", "text/calendar");
    } catch (error) { status.textContent = error.message; }
  };
  const status = element("p", "Edits save automatically in this browser.", "muted"); status.setAttribute("role", "status");
  actions.append(copy, save); root.append(actions, status); $("#detail").showModal();
}
async function health() {
  clearTimeout(healthTimer);
  try {
    const r = await fetch("/api/health"); const data = await r.json(); online = data.online; hosted = Boolean(data.hosted);
    if (hosted) {
      $("#runtime-title").textContent = "Open weights, hosted together.";
      $("#runtime-copy").textContent = "This public demo runs the open-weight model and Later in the same Render service. Your drafts remain review-first and are stored only in your browser.";
      $("#setup-title").textContent = "Hosted demo";
      $("#setup-steps").replaceChildren(
        Object.assign(document.createElement("li"), { textContent: "The service starts Ollama automatically." }),
        Object.assign(document.createElement("li"), { textContent: "The first deployment downloads the configured model." }),
        Object.assign(document.createElement("li"), { textContent: "When the model selector appears, real inference is ready." })
      );
      $("#data-copy").textContent = "Notes used for real generation travel over HTTPS to this Render service and are processed by its Ollama container. Later does not log them or send them to a third-party inference API.";
      $("#innovation-copy").textContent = "The model remains swappable and open-weight, while the hosted container makes the demo accessible without requiring visitors to install Ollama.";
      if (!demo) $("#mode-label").textContent = "Hosted open-weight inference";
    }
    if (data.models.length) {
      $("#model").replaceChildren(...data.models.map(name => { const o = element("option", name); o.value = name; return o; }));
    }
  } catch { online = false; }
  finally { if (!online) healthTimer = setTimeout(health, 10000); }
}
function updateNote() {
  demo = false; $("#mode-label").textContent = hosted ? "Hosted open-weight inference" : "Local inference";
  $("#chars").textContent = `${$("#note").value.length.toLocaleString()} / 20k`; persist();
}
$("#note").oninput = updateNote;
$("#sample").onclick = () => {
  if (busy) return;
  exampleIndex = (exampleIndex + 1) % EXAMPLES.length;
  activeExample = EXAMPLES[exampleIndex];
  $("#note").value = activeExample.input; updateNote(); demo = true;
  $("#mode-label").textContent = `Sample mode · ${activeExample.name}`;
  $("#sample").textContent = `Next example ${exampleIndex + 1}/${EXAMPLES.length} ↗`;
  notice(`${activeExample.name} loaded. Click “Take this off my mind” for its prepared sample, or click again to browse the next example.`);
};
$("#file").onchange = async e => {
  const file = e.target.files[0]; if (!file) return;
  if (file.size > 80000) return notice("Please import a text file smaller than 80 KB.");
  const text = await file.text(); if (text.length > 20000) return notice("Please use a note under 20,000 characters.");
  $("#note").value = text; updateNote(); e.target.value = "";
};
$("#generate").onclick = async () => {
  if (busy) return;
  const input = $("#note").value;
  if (input.trim().length < 10) return notice("Drop in a little more context first — at least 10 characters.");
  if (!demo && !online) { notice("Ollama isn’t connected yet. Open Under the hood for setup, or use Try examples for the sample workflow."); return; }
  busy = true; $("#generate").disabled = true; $("#note").disabled = true; $("#file").disabled = true;
  $("#generate").textContent = "Finding your small moves…";
  notice(demo ? "Preparing the sample…" : "Your local model is working. The first run may take a few minutes while the model loads.");
  try {
    let plan;
    const sampleMode = demo;
    if (sampleMode) plan = structuredClone(activeExample.plan);
    else {
      const d = new Date(); const today = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}-${String(d.getDate()).padStart(2, "0")}`;
      const r = await fetch("/api/plan", { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify({ input, model: $("#model").value, today }) });
      plan = await r.json(); if (!r.ok) throw new Error(plan.error);
    }
    let added = 0;
    for (const task of plan.tasks) {
      if (tasks.some(t => t.source === task.source && t.kind === task.kind)) continue;
      tasks.push({ ...task, id: crypto.randomUUID(), done: false, demo: sampleMode, hosted: !sampleMode && hosted }); added++;
    }
    $("#summary").textContent = plan.summary;
    persist(); render();
    notice(`${sampleMode ? "Sample complete" : `Prepared locally in ${(plan.elapsed / 1000).toFixed(1)}s`}. ${added} new draft${added === 1 ? "" : "s"} ready to review.${added < plan.tasks.length ? " Existing tasks were kept without duplicates." : ""}`);
  } catch (error) { notice(error.message); }
  finally { busy = false; $("#generate").disabled = false; $("#note").disabled = false; $("#file").disabled = false; $("#generate").textContent = "Take this off my mind ↗"; }
};
document.querySelectorAll("[data-energy]").forEach(b => b.onclick = () => {
  energy = Number(b.dataset.energy); document.querySelectorAll("[data-energy]").forEach(x => x.classList.toggle("selected", x === b)); render();
});
document.querySelectorAll("[data-view]").forEach(b => b.onclick = () => {
  for (const name of ["desk", "done", "about"]) $(`#${name}`).hidden = b.dataset.view !== name;
  document.querySelectorAll("[data-view]").forEach(x => x.classList.toggle("active", x === b));
});
$("#export").onclick = () => {
  if (!tasks.length) return notice("Prepare a few drafts first, then export your notebook.");
  download(`# Later — your notebook\n\n${tasks.map(t => `## ${t.done ? "[x]" : "[ ]"} ${t.title}\n\n${t.demo ? "Sample draft" : "Local AI draft"} · ${t.kind}\n\n${t.draft}\n\nSource: ${t.source}\n${t.date ? `\nDate: ${t.date}\n` : ""}`).join("\n---\n\n")}`, "later-notebook.md");
};
$("#clear").onclick = () => {
  if (busy) return;
  if (!confirm("Clear all Later notes and drafts saved in this browser? Export anything you want to keep first.")) return;
  tasks = []; $("#note").value = ""; $("#summary").textContent = ""; demo = false; updateNote(); render(); notice("");
};
updateNote(); render(); health();

const profileName = $("#profile-name");
const profileAvatar = $("#profile-avatar");
const avatarUpload = document.querySelector(".avatar-upload");
function profileInitials(name) {
  const words = name.trim().split(/\s+/).filter(Boolean);
  return (words.length > 1 ? words[0][0] + words.at(-1)[0] : words[0]?.slice(0, 2) || "YU").toUpperCase();
}
function renderProfile() {
  profileName.value = profile.name;
  profileAvatar.textContent = profileInitials(profile.name);
  avatarUpload.classList.toggle("has-photo", Boolean(profile.photo));
  avatarUpload.style.backgroundImage = profile.photo ? `url(${profile.photo})` : "";
}
profileName.oninput = () => {
  profile.name = profileName.value.slice(0, 24);
  profileAvatar.textContent = profileInitials(profile.name);
  persist();
};
profileName.onblur = () => {
  if (!profile.name.trim()) profile.name = "Your username";
  renderProfile(); persist();
};
$("#profile-photo").onchange = event => {
  const file = event.target.files[0];
  if (!file) return;
  if (!/^image\/(png|jpeg|webp)$/.test(file.type) || file.size > 5_000_000) {
    notice("Choose a PNG, JPEG, or WebP profile picture under 5 MB.");
    event.target.value = ""; return;
  }
  const reader = new FileReader();
  reader.onload = () => {
    const image = new Image();
    image.onload = () => {
      const canvas = document.createElement("canvas"); canvas.width = 128; canvas.height = 128;
      const context = canvas.getContext("2d");
      const side = Math.min(image.naturalWidth, image.naturalHeight);
      const sx = (image.naturalWidth - side) / 2, sy = (image.naturalHeight - side) / 2;
      context.drawImage(image, sx, sy, side, side, 0, 0, 128, 128);
      profile.photo = canvas.toDataURL("image/jpeg", .82);
      renderProfile(); persist(); notice("Profile picture saved on this device.");
    };
    image.onerror = () => notice("That image could not be opened.");
    image.src = reader.result;
  };
  reader.readAsDataURL(file); event.target.value = "";
};
renderProfile();

// CSS geometry stays local and dependency-free; no renderer competes with inference.
const illustration = $(".illustration");
const tilt = element("div", "", "scene-tilt");
const floating = element("div", "", "scene-float");
const caption = illustration.querySelector(".illus-caption");
for (const child of [...illustration.children]) {
  if (child !== caption) floating.append(child);
}
const cube = element("div", "", "scene-cube");
for (const side of ["front", "back", "right", "left", "top", "bottom"]) {
  cube.append(element("div", "", `cube-face cube-${side}`));
}
floating.append(element("div", "", "scene-sphere"), cube);
tilt.append(floating);
illustration.prepend(element("div", "", "scene-shadow"), tilt);

const reducedMotion = matchMedia("(prefers-reduced-motion: reduce)");
const finePointer = matchMedia("(hover: hover) and (pointer: fine)");
let pointerFrame = 0, gazeFrame = 0;
const eyes = [...illustration.querySelectorAll(".eye")];
const pupils = eyes.map(eye => {
  const pupil = element("span", "", "pupil");
  eye.append(pupil);
  return pupil;
});
illustration.querySelector(".zzz")?.remove();
caption.textContent = "taking it all in, slowly";
function resetTilt() {
  cancelAnimationFrame(pointerFrame);
  tilt.style.removeProperty("--tilt-x");
  tilt.style.removeProperty("--tilt-y");
}
function resetGaze() {
  cancelAnimationFrame(gazeFrame);
  for (const pupil of pupils) {
    pupil.style.removeProperty("--gaze-x");
    pupil.style.removeProperty("--gaze-y");
  }
}
document.addEventListener("pointermove", event => {
  if (reducedMotion.matches || !finePointer.matches || event.pointerType === "touch") return;
  cancelAnimationFrame(gazeFrame);
  gazeFrame = requestAnimationFrame(() => {
    const bounds = eyes.map(eye => eye.getBoundingClientRect());
    if (!bounds[0].width) return; // Mascot is hidden on small screens or another view.
    const centers = bounds.map(rect => ({ x: rect.left + rect.width / 2, y: rect.top + rect.height / 2 }));
    // Undo the head's screen-space roll so the pupils look toward the actual cursor.
    const roll = Math.atan2(centers[1].y - centers[0].y, centers[1].x - centers[0].x);
    centers.forEach((center, i) => {
      const dx = event.clientX - center.x, dy = event.clientY - center.y;
      const localX = dx * Math.cos(roll) + dy * Math.sin(roll);
      const localY = -dx * Math.sin(roll) + dy * Math.cos(roll);
      const distance = Math.hypot(localX, localY);
      const travel = Math.min(5, distance / 24);
      pupils[i].style.setProperty("--gaze-x", `${distance ? localX / distance * travel : 0}px`);
      pupils[i].style.setProperty("--gaze-y", `${distance ? localY / distance * travel : 0}px`);
    });
  });
}, { passive: true });
illustration.addEventListener("pointermove", event => {
  if (reducedMotion.matches || !finePointer.matches || event.pointerType === "touch") return;
  const rect = illustration.getBoundingClientRect();
  const x = Math.max(-1, Math.min(1, (event.clientX - rect.left) / rect.width * 2 - 1));
  const y = Math.max(-1, Math.min(1, (event.clientY - rect.top) / rect.height * 2 - 1));
  cancelAnimationFrame(pointerFrame);
  pointerFrame = requestAnimationFrame(() => {
    tilt.style.setProperty("--tilt-x", `${-y * 12}deg`);
    tilt.style.setProperty("--tilt-y", `${x * 16}deg`);
  });
});
illustration.addEventListener("pointerleave", resetTilt);
function resetMascot() { resetTilt(); resetGaze(); }
document.documentElement.addEventListener("pointerleave", resetMascot);
window.addEventListener("blur", resetMascot);
reducedMotion.addEventListener("change", resetMascot);
document.addEventListener("visibilitychange", () => { if (document.hidden) resetMascot(); });
