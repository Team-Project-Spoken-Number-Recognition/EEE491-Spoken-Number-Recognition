# Hardware documentation

## Datasheets / documents to obtain (Lab-DEBUG stage)

| Document | Needed for | Source | Stored as | Status |
|---|---|---|---|---|
| Basys-3 Reference Manual | UART section, buttons, LEDs, part number | Digilent website | `datasheets/` or link | TODO |
| `Basys3_Master.xdc` | Pin constraints | Digilent GitHub (digilent-xdc) | `fpga/constraints/Basys3_Master.xdc` (unmodified copy) | TODO |
| FT2232H datasheet | UART interface, max baud | FTDI website | `datasheets/` | TODO |
| AN232B-05 Baud Rates | Baud rate selection | FTDI website | `datasheets/` | TODO |
| FTDI VCP driver | PC connection | FTDI website | install only | TODO |
| Vivado Block Memory Generator product guide (PG058) | ROM latency, COE | AMD docs | link | TODO |

Record the document revision/date for each file. Later stages (ADC chip, microphone, op-amps) are
added when their manuals are released.

## Folders
- `board/` — Basys-3 notes: board revision, part number check, inputs used for RESET/START.
- `adc/` — ADC notes (Lab-ADC stage; empty until released).
