export const schema = {
  type: "object", required: ["summary", "tasks"], additionalProperties: false,
  properties: {
    summary: { type: "string" },
    tasks: { type: "array", maxItems: 8, items: {
      type: "object", additionalProperties: false,
      required: ["title", "kind", "effort", "source", "reason", "draft", "date"],
      properties: {
        title: { type: "string" }, kind: { type: "string", enum: ["reply", "checklist", "calendar"] },
        effort: { type: "integer", minimum: 1, maximum: 60 },
        source: { type: "string" }, reason: { type: "string" }, draft: { type: "string" },
        date: { type: "string", description: "YYYY-MM-DD only when explicitly known; otherwise empty" }
      }
    }}
  }
};
export function validatePlan(value, input) {
  if (!value || typeof value.summary !== "string" || !Array.isArray(value.tasks) || value.tasks.length > 8) throw new Error("Model returned an invalid plan. Try again.");
  return { summary: value.summary.slice(0, 1000), tasks: value.tasks.map(t => {
    for (const key of ["title", "source", "reason", "draft", "date"]) if (typeof t[key] !== "string") throw new Error("Model omitted a required field.");
    if (!["reply", "checklist", "calendar"].includes(t.kind) || !Number.isInteger(t.effort) || t.effort < 1 || t.effort > 60) throw new Error("Model returned an invalid task.");
    if (!t.source.trim() || !input.includes(t.source)) throw new Error("A task could not be traced to your original note. Try again.");
    if (t.date && (!/^\d{4}-\d{2}-\d{2}$/.test(t.date) || new Date(t.date).toISOString().slice(0, 10) !== t.date)) throw new Error("Model returned an invalid date.");
    return Object.fromEntries(Object.keys(schema.properties.tasks.items.properties).map(k => [k, t[k]]));
  }) };
}
export function calendar(task) {
  if (!/^\d{4}-\d{2}-\d{2}$/.test(task.date)) throw new Error("Choose a date first.");
  const escape = s => s.replace(/\\/g, "\\\\").replace(/\r?\n/g, "\\n").replace(/;/g, "\\;").replace(/,/g, "\\,");
  // Fold by UTF-8 bytes, as required by RFC 5545.
  const fold = line => {
    let result = "", n = 0;
    for (const c of line) { const size = Buffer.byteLength(c); if (n + size > 74) { result += "\r\n "; n = 1; } result += c; n += size; }
    return result;
  };
  return ["BEGIN:VCALENDAR", "VERSION:2.0", "PRODID:-//Later//Local AI//EN", "BEGIN:VEVENT",
    `UID:${crypto.randomUUID()}@later.local`, `DTSTAMP:${new Date().toISOString().replace(/[-:]/g, "").replace(/\.\d{3}/, "")}`,
    `DTSTART;VALUE=DATE:${task.date.replaceAll("-", "")}`, `SUMMARY:${escape(task.title)}`, `DESCRIPTION:${escape(task.draft)}`,
    "END:VEVENT", "END:VCALENDAR"].map(fold).join("\r\n") + "\r\n";
}
