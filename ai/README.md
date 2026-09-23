# GenAI Usage Record

Required by the syllabus GenAI policy: initial problem definitions, **every** prompt / data input /
clarification, the **full unedited chat history**, correction logs, all raw code outputs, and a list of
all tools and models used. Students act as Lead Engineers; the whole group is responsible for the
correctness and synthesizability of AI-generated code.

## Folders

| Folder | Content | Naming |
|---|---|---|
| `sessions/` | Full, unedited chat exports (Markdown/JSON/PDF as exported by the tool) | `YYYY-MM-DD_<member>_<tool>_<topic>.<ext>` |
| `prompts/` | Initial problem definitions and important prompts (verbatim) | `YYYY-MM-DD_<topic>.md` |
| `outputs/` | One record per significant interaction (template below) + raw AI code outputs | `YYYY-MM-DD_AI-NNNN_<topic>.md` |
| `corrections/` | Correction logs: what the AI got wrong, how we found it, what we changed | `YYYY-MM-DD_CORR-NNNN_<topic>.md` |
| `decisions/` | AI-proposed decisions and the team's accept/reject reasoning | `YYYY-MM-DD_<DEC-ID>.md` |

Index of all records: [AI_USAGE_LOG.md](AI_USAGE_LOG.md) · Tools/models: [TOOLS_AND_MODELS.md](TOOLS_AND_MODELS.md)

## Rules

1. Export the chat the **same day** into `sessions/` — chat histories can disappear.
2. Raw AI code is stored unmodified (in the record or as a file next to it) **before** we edit it, so
   the diff between AI output and final code is visible.
3. AI-generated VHDL follows: AI generated → human reviewed → simulated → synthesised → hardware
   verified. The record states how far along this chain it is.
4. A commit that contains AI-assisted code says so in the commit body: `AI-assisted: AI-NNNN`.

## Record template (`outputs/`)

```text
ID:
Date:
Team Member:
AI Tool:
Model:
Purpose:
Initial Prompt:        (verbatim, or link to prompts/ or sessions/)
Input Data:            (files, manuals, datasheets given to the AI)
AI Output:             (summary + link to raw output)
Human Review:          (who, when, what was checked)
Detected Issues:
Correction:            (link to corrections/ record)
Final Decision:
Verification:          (review / simulation / synthesis / hardware — with evidence links)
Related Commit:
```
