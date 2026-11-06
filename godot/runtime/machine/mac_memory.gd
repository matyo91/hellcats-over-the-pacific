extends "res://strict_port/compat/memory_68k.gd"

## The strict port's Memory68k as a 24-bit Macintosh addresses it: 16 MB, the address's high byte
## ignored, as the Memory Manager of the game's era (24-bit mode) does. The runtime relies on it to
## load the Pacific Conflict overlay at 0x01000000, whose low 24 bits are 0: the overlay port
## addresses the image at base 0, while the host code sees the nonzero pointer it expects.

const SIZE := 0x1000000
const MASK := 0xffffff

func _init() -> void:
	super._init(SIZE)

func contains(address: int, width: int = 1) -> bool:
	return width >= 0 and (address & MASK) + width <= SIZE

func _offset(address: int, width: int) -> int:
	var at: int = address & MASK
	assert(at + width <= SIZE, "68000 memory access out of bounds")
	return at
