extends RefCounted

const OriginalCases := preload("res://tests/strict_port/helpers/original_cases.gd")

## The per-frame simulation steps (clear_pending_entity_slots, apply_controller_velocities,
## tick_flagged_object_controllers, dispatch_entity_tick, age_contact_records), checked against the
## ORIGINAL bytes: tools/strict_port/gen_sim_step_cases.py runs them in the m68k_emu interpreter with
## the controller ticks logging their calls (fixtures/sim_step_cases.json); helpers/original_cases.gd
## replays the cases.
func run() -> bool:
	return OriginalCases.replay("res://tests/strict_port/fixtures/sim_step_cases.json")
