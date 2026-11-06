# Pilot roster and scores (`HEL1` 128)

`HEL1` 128 is named "Player and Score Data" in the resource dump
(`artifacts/reverse-engineering/resources/resource_dasm_Hellcats_app/`). The
shipped copy is all zero (empty roster). `initialize_application` (ID02)
loads it into the handle at `A5-0x13a8`, or creates it with
`NewHandleClear(0x500)` and adds it to the application's resource file when
missing. `0x500 = 20 × 0x40`: 20 pilot records of 64 bytes.

Confidence: offsets come from the exported C (**[PROVEN]** for the accesses
listed); field meanings are marked.

## Record layout (0x40 bytes)

| Offset | Size | Field | Evidence |
|---|---|---|---|
| +0x00 | 32 bytes | name, Pascal string | converted with p2cstr / c2pstr in `build_rank_and_name_string` |
| +0x20 | word | pilot status, set from `A5-0x12b4` by `conclude_mission` | **[STRONG INFERENCE]** index into the status strings; status 1 (Dead) triggers a one-shot path |
| +0x22 | word | rank index into the rank strings | `build_rank_and_name_string`; raised by the Mission Summary promotion step (ID04 0x2b74) to the highest rank whose threshold (longs at `A5-0xfd6`) is ≤ the score |
| +0x24 | word | friendly-fire offence count (1, 2 = warnings; 3 = dishonourable discharge, status 4) | cleared by `reset_pilot_record`; incremented by Mission Summary state 0 (ID04 0x2798) **[STRONG INFERENCE from the texts]** |
| +0x26 | word | awards bitmask (bits 0–7 → cicn 512–519; bit = mission `A5-0x12f8` − 3, set by summary state 2 when the mission succeeds); missions 3 Bomb Base … 9 The Duel use bits 0–6, Flight School (2) gives none, and bit 7 has no mission **[STRONG INFERENCE]** | cleared by `reset_pilot_record`; drawn by `draw_mission_awards` (ID04 0x1dde) **[STRONG INFERENCE]** |
| +0x28 | 12 words | tallies | weighted by 12 words at `A5-0xf5e` in `compute_pilot_score` |

The current pilot's index is the word at `A5-0x13a4`.

## Related strings (STR# 129, groups set up by ID07 `init_string_pointer_groups`)

| Group | Slots | Text |
|---|---|---|
| `A5-0xffe` | 94–99 | Ensign, Lt. Junior Grade, Lieutenant, Lt. Commander, Commander, Captain |
| `A5-0xfae` | 100–105 | Active, Dead, Retired, POW, Discharged, MIA |
| `A5-0xf86` | 106–115 | Fighter, Bomber, Tank, AAA Battery, Vehicle, Carrier, Battleship, Cruiser, PT Boat, Runway |

Record +0x20 indexes the status group (6 values) **[STRONG INFERENCE]**.
Tallies 0–9 probably count destroyed targets of the 10
target types **[HYPOTHESIS]**, supported by the 12-item loop in
`show_mission_summary_dialog` (DLOG 133 "Mission Summary": "Targets
Destroyed", "Total Aircraft Destroyed", "Score"); tallies 10–11 are unknown. Tallies 0 + 1 (Fighter + Bomber)
are drawn as aircraft kill markers by `draw_aircraft_kill_markers` (ID04
0x1f5e) under "Total Aircraft Destroyed", which supports
tallies = destroyed targets per type **[STRONG INFERENCE]**.

## Functions (ID04)

| File | Name | Role |
|---|---|---|
| 0x588 | `compute_pilot_score` | Σ tallies × weights |
| 0xf4e | `rank_pilots_by_score` | scores and sorted order for all 20 pilots |
| 0x1106 | `reset_pilot_record` | clear rank, words +0x20..+0x26 and tallies |
| 0x1a0e | `build_rank_and_name_string` | "rank separator name" for the current pilot |
| 0x116a | `prune_inactive_pilots_beyond_ten` | keeps the ten best non-Active pilots |
| 0x644 (unexported, JT $132) | `run_duty_roster_dialog` | DLOG 130 "Duty Roster": rank / name / score of up to ten Active pilots, Dossier… = pilot summary, OK saves edited names |
| 0x1200 | `draw_high_scores_table` | DLOG 134 "High Scores" table; runner 0x137a erases non-Active pilots |
| 0x560 | `confirm_erase_high_scores` | ALRT 260 ("erase all non-active duty high scores") |
| 0x516 | `confirm_end_mission` | ALRT 259 ("You will collect no points") |

## Open questions

- Scoring weights at `A5-0xf5e` (A5 initial data, not yet read): `draw_targets_destroyed_row` shows count × weight[type] per target type, so weights 0–9 are points per destroyed target of each type **[STRONG INFERENCE]**.
- Meaning of tallies 10–11. Rank +0x22 also selects cicn 256 + rank (insignia, ID04 0x1b3e).
- ~~Where the roster is written back~~ — Mission Summary state 3 (ID04
  0x2a60): after adding each mission kill count `A5-0x12ce[t]` to `tally[t]`,
  `ChangedResource(roster handle)` and `UpdateResFile(A5-0x1002)` run. This
  proves tallies 0–9 are lifetime kills per target type.
- Pilot-status source: host +0xd4 (`A5-0x12b4`) is copied into record +0x20 by
  `conclude_mission`. `update_aircraft_damage_state` sets 1 (Dead) when the
  player's pilot is hit and no parachute exists; `resolve_bailout_outcome`
  decides after a bail-out (enemy territory: POW 1/2; friendly: Dead 1/8; sea:
  POW or Dead 1/4 each) and sets 4 (Discharged) when the player abandoned an
  undamaged aircraft that still had fuel **[STRONG INFERENCE]**.
