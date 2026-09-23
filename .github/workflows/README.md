# CI plan (PLANNED — no workflow active yet)

Vivado cannot run on GitHub-hosted runners, so CI can only cover vendor-independent checks:

| Job | Tool | Scope | Status |
|---|---|---|---|
| VHDL analyse | GHDL (`--std=08`) | All RTL except files instantiating Xilinx IP | PLANNED |
| Unit testbenches | GHDL | Pure-RTL TBs (e.g. UART TX, FSMs); fail if log lacks `TB_RESULT: PASS` | PLANNED |
| Markdown link check | lychee / markdown-link-check | docs | PLANNED |

Synthesis, implementation and IP-based simulation stay manual (Vivado) and their results are attached to
each PR. A workflow file is added only after the first pure-RTL testbench exists, so CI never runs
against empty folders.
