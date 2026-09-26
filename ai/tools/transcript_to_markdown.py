"""transcript_to_markdown.py — readable Markdown from a Claude Code session export (transcript.jsonl).

The JSONL file is the complete record (syllabus GenAI policy: full, unedited chat). This script
produces a readable companion for the report:
  - every user message and every assistant text answer, in order, with local time;
  - every tool call (tool name, description, input) with its result, folded in <details>;
  - long tool inputs / results are shortened (full content stays in the JSONL);
  - omitted: the model's internal "thinking" blocks and automatic <system-reminder>/attachment
    entries (both remain in the JSONL).

Usage:
  python ai/tools/transcript_to_markdown.py <transcript.jsonl> <out.md> [--title "..."] [--member "..."]
                                            [--utc-offset 3] [--max-input 3000] [--max-result 2000]

Redact personal data in the JSONL first (TEAM_MANUAL §9); this script does not redact.

Author : Eren (eeerenbuyukbas) — AI-assisted (Claude Opus 5.5, Claude Code), AI-0016
"""
import argparse
import datetime as dt
import json
import re

REMINDER = re.compile(r"<system-reminder>.*?</system-reminder>", re.S)


def local_time(ts, offset_h):
    t = dt.datetime.fromisoformat(ts.replace("Z", "+00:00")) + dt.timedelta(hours=offset_h)
    return t.strftime("%Y-%m-%d %H:%M")


def shorten(text, limit):
    if len(text) <= limit:
        return text
    return text[:limit] + "\n… [%d more characters — see the JSONL]" % (len(text) - limit)


def block_text(content):
    """text of a tool_result / message content (str or list of blocks)"""
    if isinstance(content, str):
        return content
    out = []
    for b in content or []:
        if b.get("type") == "text":
            out.append(b.get("text", ""))
        elif b.get("type") == "image":
            out.append("[image]")
    return "\n".join(out)


def fence(text):
    ticks = "````" if "```" in text else "```"
    return "%s\n%s\n%s" % (ticks, text.rstrip("\n"), ticks)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("jsonl")
    ap.add_argument("out")
    ap.add_argument("--title", default="Claude Code session")
    ap.add_argument("--member", default="")
    ap.add_argument("--utc-offset", type=float, default=3.0)
    ap.add_argument("--max-input", type=int, default=3000)
    ap.add_argument("--max-result", type=int, default=2000)
    a = ap.parse_args()

    rows = [json.loads(l) for l in open(a.jsonl, encoding="utf-8") if l.strip()]
    results = {}                                    # tool_use_id -> result text
    for o in rows:
        m = o.get("message")
        if o.get("type") == "user" and isinstance(m, dict) and isinstance(m.get("content"), list):
            for b in m["content"]:
                if b.get("type") == "tool_result":
                    results[b.get("tool_use_id")] = block_text(b.get("content"))

    times = [o["timestamp"] for o in rows if o.get("timestamp")]
    model = next((o["message"].get("model") for o in rows
                  if o.get("type") == "assistant" and isinstance(o.get("message"), dict)
                  and o["message"].get("model")), "")
    n_user = n_tool = 0
    body = []
    last_role = None
    for o in rows:
        m = o.get("message")
        if not isinstance(m, dict) or o.get("isSidechain"):
            continue
        ts = local_time(o["timestamp"], a.utc_offset) if o.get("timestamp") else ""
        if o.get("type") == "user":
            c = m.get("content")
            if isinstance(c, list) and all(b.get("type") == "tool_result" for b in c):
                continue                            # shown under the tool call
            text = REMINDER.sub("", block_text(c)).strip()
            if not text:
                continue
            n_user += 1
            body.append("\n---\n\n### User — %s\n\n%s\n" % (ts, text))
            last_role = "user"
        elif o.get("type") == "assistant":
            for b in m.get("content") or []:
                kind = b.get("type")
                if kind == "text" and b.get("text", "").strip():
                    if last_role != "assistant":
                        body.append("\n### Claude — %s\n" % ts)
                    body.append("\n" + b["text"].strip() + "\n")
                    last_role = "assistant"
                elif kind == "tool_use":
                    if last_role != "assistant":
                        body.append("\n### Claude — %s\n" % ts)
                        last_role = "assistant"
                    n_tool += 1
                    inp = b.get("input") or {}
                    desc = inp.get("description", "") if isinstance(inp, dict) else ""
                    summary = "Tool: %s%s" % (b.get("name", "?"), (" — " + desc) if desc else "")
                    res = results.get(b.get("id"), "(no result recorded)")
                    body.append("\n<details><summary>%s</summary>\n\n**Input**\n\n%s\n\n**Result**\n\n%s\n\n</details>\n"
                                % (summary.replace("<", "&lt;"),
                                   fence(shorten(json.dumps(inp, ensure_ascii=False, indent=1), a.max_input)),
                                   fence(shorten(res, a.max_result))))

    head = [
        "# %s" % a.title, "",
        "| | |", "|---|---|",
        "| Member | %s |" % (a.member or "—"),
        "| Tool / model | Claude Code (desktop app) / `%s` |" % (model or "unknown"),
        "| Period (UTC%+g) | %s → %s |" % (a.utc_offset, local_time(min(times), a.utc_offset),
                                          local_time(max(times), a.utc_offset)),
        "| User messages / tool calls | %d / %d |" % (n_user, n_tool),
        "| Full record | `%s` (complete JSONL, same session) |" % a.jsonl.replace("\\", "/").split("/")[-1],
        "",
        "Readable companion generated by `ai/tools/transcript_to_markdown.py`. Omitted here (kept in the JSONL): "
        "the model's internal thinking blocks and automatic system reminders/attachments; tool inputs longer "
        "than %d and results longer than %d characters are shortened." % (a.max_input, a.max_result),
        "",
    ]
    with open(a.out, "w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(head) + "".join(body))
    print("wrote %s: %d user messages, %d tool calls" % (a.out, n_user, n_tool))


if __name__ == "__main__":
    main()
