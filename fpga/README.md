# FPGA

| Folder | Content |
|---|---|
| `rtl/common/` | Shared packages (`*_pkg.vhd`: constants, types), synchroniser, debouncer, edge detector |
| `rtl/top/` | Top-level entities per demo (e.g. `top_debug_demo.vhd`) |
| `rtl/<block>/` | One folder per lab block: `debug`, `ctrl`, `adc`, `window`, `fft`, `mel`, `dct`, `compare` |
| `tb/common/` | Testbench helpers (UART receiver model, memory model, report procedures) |
| `tb/<block>/` | `tb_<entity>.vhd` — self-checking testbenches |
| `constraints/` | XDC files derived from Digilent `Basys3_Master.xdc` (one per top level) |
| `ip/` | Vivado IP `.xci` files and `.coe` memory-init files (generated products are not committed) |
| `vivado/` | `create_<design>.tcl` scripts that re-create the Vivado project (DEC-013) |

Only folders of **released** stages may contain code. Other block folders stay empty (`.gitkeep`)
until their manual is released.

Rules: see `CONTRIBUTING.md` §6. Every RTL file lists the requirement IDs it implements.

Re-creating a project (once scripts exist):

```text
vivado -mode batch -source fpga/vivado/create_debug_demo.tcl
```
