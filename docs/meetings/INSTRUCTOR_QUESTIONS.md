# Questions for Instructor / Lab Assistant

Ask at the next lab session (Sat Sep 26, "Lab Study") or by e-mail. Record the answer, who answered,
and the date. Then update the linked assumption/decision.

| ID | Priority | Question | Why it matters | Linked | Answer | Answered by / date |
|---|---|---|---|---|---|---|
| Q-01 | **URGENT** | Is the Lab-DEBUG demonstration on **Sat Oct 03** or advanced to **Wed Sep 30**? Same question for Lab-CTRL (Oct 10 / Oct 07). | 6 vs. 9 days of work left; late factor 0.9/week | ASSUMPTION-013 | Lab-DEBUG deadline is **Wed Sep 30**; one lab deadline per week on Wednesdays. Later dates to confirm per lab. | Reported by eeerenbuyukbas, 2026-09-25 |
| Q-02 | High | Byte order: is the 1st transmitted byte of each 32-bit word the most-significant byte (as in the 55 AA CC 03 start header)? | RTL, testbench and MATLAB must agree | ASSUMPTION-006, REQ-DEBUG-007 | | |
| Q-03 | High | Should `ready_out` be '1' after reset? Should a `start_in` pulse during an active transfer be ignored? | Handshake behaviour for all blocks | ASSUMPTION-007/008, REQ-IF-003 | | |
| Q-04 | High | For the Lab-DEBUG demo, how much of Lab-CTRL is required? (Only start/ready of Lab-DEBUG, or full framing with stubbed sub-systems?) | Scope for the first deadline | DEC-003, REQ-DEBUG-016 | | |
| Q-05 | Medium | CTRL manual says RESET and START *switches*, the guidance says a *button* for start. Which Basys-3 inputs are expected (e.g. BTNC for START, a slide switch or BTNU for RESET)? | Pin assignment, debounce design | DEC-007, REQ-CTRL-006 | | |
| Q-06 | Medium | May we use a baud rate above 115 200 (e.g. 1 Mbaud) for later labs, as long as ≥ 115 200 is met? | Large RAM dumps take 5.7 s at 115 200 | DEC-005 | | |
| Q-07 | Low | Is a VHDL generic whose value is fixed by a package constant acceptable for "N shall be set in VHDL code as a constant definition"? | Simulation with small N | DEC-012 | | |
| Q-08 | Medium | Which numbers must be recognised (0–9?), in which language (Turkish/English), and is speaker-dependent recognition acceptable? | MATLAB model and COMPARE design | U-18 | | |
| Q-09 | Medium | How is "Recognition Performance" (10 final-demo points) and "Lab-MATLAB number-recognition-rate" measured? Test set, number of trials, speaker? | Validation target | U-19, REQ-PERF-003 | | |
| Q-10 | Medium | PCB: what manufacturing process is available at the lab (single/double layer, minimum trace/clearance, THT vs. SMD) and what is the lead time? | PCB is due Nov 07, difficulty 5 | U-21 | | |
| Q-11 | Low | The Lab-DCT and Lab-COMPARE manuals were not in the material we received — are they published later? | Planning | — | | |
| Q-12 | Low | The syllabus places the ADC/SPI lecture (Oct 21) after the Lab-ADC due date (Oct 17). Is the ADC lab date correct? | Planning | PROJECT_TIMELINE | | |
| Q-13 | Low | May the course manuals be stored in our **private** GitHub repository? | Course-material policy | README | | |

## Proposals that would need approval (none submitted yet)

- Alternative recognition algorithm (syllabus: must be assessed by the lecturer before implementation,
  with lab-style assignments and sub-system specifications). **No alternative is proposed at this time.**
