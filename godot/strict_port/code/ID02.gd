class_name StrictID02
extends RefCounted
## Strict translations owned by CODE segment 2 (ID02.bin; address = file offset, 4-byte header).
## The sole provenance and verification record lives in mappings/functions.json.
##
## The C runtime at the start of the segment. MPW C passes int as a 16-bit word, so the
## character / value arguments here are the words the callers push; pointers and counts are
## longs. Globals live below A5 (`a5`); cross-segment calls go through StrictID01.

const C68kScript := preload("res://strict_port/compat/c68k.gd")
const StrictID01Script := preload("res://strict_port/code/ID01.gd")

const A5_CTYPE_TABLE: int = -0x1608 ## 256 class bytes: 0x80 lower, 0x40 upper, 0x10 digit, ...
const A5_STRTOK_NEXT: int = -0x1508 ## strtok's saved position (long)

var memory
var a5: int = 0
## Calls leaving the segment, keyed by A5 jump-table offset and by A-line trap word. Each takes
## the arguments in stack order (lowest address first: a C call's first parameter, a Pascal
## call's last; a buffer passed by address is given as the Array of its longs) and returns the
## result (D0 for a C call, the result slot for a Pascal function). Unported targets have no
## entry; tests install logging stand-ins (helpers/segment_cases.gd).
var jt_routines: Dictionary = {}
var traps: Dictionary = {}
## Code reached indirectly through an address held in memory (service pointers in A5 globals),
## keyed by that address.
var code_routines: Dictionary = {}
## The stack pointer at entry, for routines that hand buffers in their own frame to callees (the
## frames land below it, in the stack the original uses too).
var a7: int = 0
## Where the segment's code is loaded: the VBL sound handlers keep their A5 in a long inside their own
## code (0x39c4 / 0x3aca / 0x3be0).
var code_base: int = 0

func _init(memory_68k = null, a5_value: int = 0) -> void:
	memory = memory_68k
	a5 = a5_value

func _jt(offset: int, args: Array) -> int:
	assert(jt_routines.has(offset), "jump-table slot $%x has no routine" % offset)
	return jt_routines[offset].call(args)

func _call_address(address: int, args: Array) -> int:
	assert(code_routines.has(address), "code address %x has no routine" % address)
	return code_routines[address].call(args)

func _trap(word: int, args: Array) -> int:
	assert(traps.has(word), "A-line trap %04x has no routine" % word)
	return traps[word].call(args)

## 0x1e: NEG.L of a negative long (0x80000000 stays itself).
static func abs_long(value: int) -> int:
	value = C68kScript.s32(value)
	return C68kScript.u32(-value if value < 0 else value)

## 0x38: div_t {quot, rem} from the numerator / denominator words of `operands` (high / low):
## two DIVS.W of the sign-extended numerator by the denominator, the quotient and remainder
## words stored as one long at *result. On DIVS.W overflow (-0x8000 / -1) the register is left
## unchanged, so quot = the numerator and rem = its sign-extension's high word, as in the original.
func ansi_div(result: int, operands: int) -> void:
	var numer: int = C68kScript.s16(operands >> 16)
	var denom: int = C68kScript.s16(operands)
	assert(denom != 0, "ansi_div: DIVS.W by zero (the original takes the zero-divide exception)")
	var d0: int = _divs_w(C68kScript.u32(numer), denom)
	var quot: int = d0 & 0xffff
	var rem: int = (d0 >> 16) & 0xffff
	memory.write_u32(result, (quot << 16) | rem)

## DIVS.W of a 32-bit register by a word: remainder:quotient, or the register unchanged when the
## quotient does not fit 16 bits.
static func _divs_w(register: int, divisor: int) -> int:
	var q: int = C68kScript.divs_trunc(C68kScript.s32(register), divisor)
	if q < -0x8000 or q > 0x7fff:
		return C68kScript.u32(register)
	var r: int = C68kScript.s32(register) - q * divisor
	return ((r & 0xffff) << 16) | (q & 0xffff)

## 0x66: ldiv_t {quot, rem} through JT $5a / $62 (ID01 rt_sdiv32 / rt_smod32) into *result.
func ansi_ldiv(result: int, numer: int, denom: int) -> void:
	memory.write_u32(result, StrictID01Script.rt_sdiv32(numer, denom))
	memory.write_u32(result + 4, StrictID01Script.rt_smod32(numer, denom))

## The class byte of the character (low byte of the word) in the A5 ctype table, sign-extended
## to a word and masked (the ANDI.W result).
func _ctype(c: int, mask: int) -> int:
	return C68kScript.u16(C68kScript.s8(memory.read_u8(C68kScript.u32(a5 + A5_CTYPE_TABLE + (c & 0xff))))) & mask

func ansi_isalnum(c: int) -> int: return _ctype(c, 0xd0)   ## 0x9a
func ansi_isalpha(c: int) -> int: return _ctype(c, 0xc0)   ## 0xb6
func ansi_iscntrl(c: int) -> int: return _ctype(c, 0x3)    ## 0xd2
func ansi_isdigit(c: int) -> int: return _ctype(c, 0x10)   ## 0xee
func ansi_isgraph(c: int) -> int: return _ctype(c, 0xd8)   ## 0x10a
func ansi_islower(c: int) -> int: return _ctype(c, 0x80)   ## 0x126
func ansi_isprint(c: int) -> int: return _ctype(c, 0xdc)   ## 0x142
func ansi_ispunct(c: int) -> int: return _ctype(c, 0x8)    ## 0x15e
func ansi_isspace(c: int) -> int: return _ctype(c, 0x6)    ## 0x17a
func ansi_isupper(c: int) -> int: return _ctype(c, 0x40)   ## 0x196
func ansi_isxdigit(c: int) -> int: return _ctype(c, 0x30)  ## 0x1b2

## 0x1ce: a lower-case character (class bit 7) has bit 5 flipped; the word is returned
## zero-extended either way.
func ansi_toupper(c: int) -> int:
	return C68kScript.u16(c ^ 0x20) if (_ctype(c, 0xff) & 0x80) != 0 else C68kScript.u16(c)

## 0x200: an upper-case character (class bit 6) has bit 5 flipped.
func ansi_tolower(c: int) -> int:
	return C68kScript.u16(c ^ 0x20) if (_ctype(c, 0xff) & 0x40) != 0 else C68kScript.u16(c)

## 0x232: forward byte copy of count bytes (none when 0); returns dst.
func ansi_memcpy(dst: int, src: int, count: int) -> int:
	var n: int = C68kScript.u32(count)
	var k: int = 0
	while n != 0:
		memory.write_u8(C68kScript.u32(dst + k), memory.read_u8(C68kScript.u32(src + k)))
		k += 1
		n -= 1
	return C68kScript.u32(dst)

## 0x24a: overlap-safe copy: forward when src is above dst (unsigned), else backward from the end.
func ansi_memmove(dst: int, src: int, count: int) -> int:
	var n: int = C68kScript.u32(count)
	if n == 0:
		return C68kScript.u32(dst)
	if C68kScript.u32(src) > C68kScript.u32(dst):
		for k in n:
			memory.write_u8(C68kScript.u32(dst + k), memory.read_u8(C68kScript.u32(src + k)))
	else:
		for k in range(n - 1, -1, -1):
			memory.write_u8(C68kScript.u32(dst + k), memory.read_u8(C68kScript.u32(src + k)))
	return C68kScript.u32(dst)

## 0x2b0: count copies of the value word's low byte; returns dst.
func ansi_memset(dst: int, value: int, count: int) -> int:
	for k in C68kScript.u32(count):
		memory.write_u8(C68kScript.u32(dst + k), value & 0xff)
	return C68kScript.u32(dst)

## 0x2c8: copy through the terminator; returns dst.
func ansi_strcpy(dst: int, src: int) -> int:
	var k: int = 0
	while true:
		var b: int = memory.read_u8(C68kScript.u32(src + k))
		memory.write_u8(C68kScript.u32(dst + k), b)
		k += 1
		if b == 0:
			break
	return C68kScript.u32(dst)

## 0x2d8: copy src over dst's terminator; returns dst.
func ansi_strcat(dst: int, src: int) -> int:
	ansi_strcpy(C68kScript.u32(dst + _strlen(dst)), src)
	return C68kScript.u32(dst)

func _strlen(s: int) -> int:
	var k: int = 0
	while memory.read_u8(C68kScript.u32(s + k)) != 0:
		k += 1
	return k

## 0x2ee: 0 at a shared terminator, else +1 / -1 by the first differing byte (unsigned).
func ansi_strcmp(s1: int, s2: int) -> int:
	var k: int = 0
	while true:
		var a: int = memory.read_u8(C68kScript.u32(s1 + k))
		var b: int = memory.read_u8(C68kScript.u32(s2 + k))
		k += 1
		if a != b:
			return 1 if a > b else 0xffffffff
		if a == 0:
			return 0
	return 0  # not reached: the loop above always returns

## 0x30c: the first position holding the character (the word's low byte), the terminator
## included; else 0.
func ansi_strchr(s: int, c: int) -> int:
	var p: int = C68kScript.u32(s)
	while true:
		if memory.read_u8(p) == (c & 0xff):
			return p
		p = C68kScript.u32(p + 1)
		if memory.read_u8(p - 1) == 0:
			return 0
	return 0  # not reached: the loop above always returns

## 0x324: length of the leading run of bytes not in reject.
func ansi_strcspn(s: int, reject: int) -> int:
	var n: int = 0
	while true:
		var b: int = memory.read_u8(C68kScript.u32(s + n))
		if b == 0 or _in_set(reject, b):
			return n
		n += 1
	return 0  # not reached: the loop above always returns

func _in_set(set_ptr: int, b: int) -> bool:
	var k: int = 0
	while true:
		var x: int = memory.read_u8(C68kScript.u32(set_ptr + k))
		if x == 0:
			return false
		if x == b:
			return true
		k += 1
	return false  # not reached: the loop above always returns

## 0x33e: the first byte of s that is in accept, else 0.
func ansi_strpbrk(s: int, accept: int) -> int:
	var p: int = C68kScript.u32(s)
	while true:
		var b: int = memory.read_u8(p)
		if b == 0:
			return 0
		if _in_set(accept, b):
			return p
		p = C68kScript.u32(p + 1)
	return 0  # not reached: the loop above always returns

## 0x35a: the last position holding the character (the terminator included), else 0.
func ansi_strrchr(s: int, c: int) -> int:
	var found: int = 0
	var p: int = C68kScript.u32(s)
	while true:
		if memory.read_u8(p) == (c & 0xff):
			found = p
		p = C68kScript.u32(p + 1)
		if memory.read_u8(p - 1) == 0:
			return found
	return 0  # not reached: the loop above always returns

## 0x370: length of the leading run of bytes in accept.
func ansi_strspn(s: int, accept: int) -> int:
	var n: int = 0
	while true:
		var b: int = memory.read_u8(C68kScript.u32(s + n))
		if b == 0 or not _in_set(accept, b):
			return n
		n += 1
	return 0  # not reached: the loop above always returns

## 0x38c: the first position where needle matches (s itself for an empty needle); 0 once the
## haystack runs out during a comparison.
func ansi_strstr(s: int, needle: int) -> int:
	var start: int = C68kScript.u32(s)
	while true:
		var k: int = 0
		while true:
			var n: int = memory.read_u8(C68kScript.u32(needle + k))
			if n == 0:
				return start
			var h: int = memory.read_u8(C68kScript.u32(start + k))
			if h == 0:
				return 0
			if h != n:
				break
			k += 1
		start = C68kScript.u32(start + 1)
	return 0  # not reached: the loop above always returns

## 0x3aa: s, or (s == 0) the saved position (0 -> 0); the saved position is cleared, leading
## delimiters skipped (none left -> 0), then the token runs to the next delimiter, which is
## overwritten with 0 and the byte after it saved; a token ending at the terminator saves nothing.
func ansi_strtok(s: int, delim: int) -> int:
	var slot: int = C68kScript.u32(a5 + A5_STRTOK_NEXT)
	var start: int = C68kScript.u32(s)
	if start == 0:
		start = memory.read_u32(slot)
		if start == 0:
			return 0
	memory.write_u32(slot, 0)
	var p: int = start
	while true:
		var b: int = memory.read_u8(p)
		p = C68kScript.u32(p + 1)
		if b == 0:
			return memory.read_u32(slot)
		if not _in_set(delim, b):
			break
		start = p
	while true:
		var t: int = memory.read_u8(p)
		p = C68kScript.u32(p + 1)
		if t == 0:
			return start
		if _in_set(delim, t):
			memory.write_u32(slot, p)
			memory.write_u8(C68kScript.u32(p - 1), 0)
			return start
	return 0  # not reached: the loop above always returns

## 0x3f6: count bytes copied from src, src stopping at its terminator so the rest is zero-padded;
## returns dst.
func ansi_strncpy(dst: int, src: int, count: int) -> int:
	var n: int = C68kScript.u32(count)
	var a: int = C68kScript.u32(dst)
	var b: int = C68kScript.u32(src)
	while n != 0:
		var v: int = memory.read_u8(b)
		memory.write_u8(a, v)
		a = C68kScript.u32(a + 1)
		if v != 0:
			b = C68kScript.u32(b + 1)
		n -= 1
	return C68kScript.u32(dst)

## 0x412: count 0 does nothing; otherwise up to count bytes of src (terminator included) over
## dst's terminator, and a terminator after count bytes; returns dst.
func ansi_strncat(dst: int, src: int, count: int) -> int:
	var n: int = C68kScript.u32(count)
	if n == 0:
		return C68kScript.u32(dst)
	var a: int = C68kScript.u32(dst + _strlen(dst))
	var b: int = C68kScript.u32(src)
	while true:
		var v: int = memory.read_u8(b)
		b = C68kScript.u32(b + 1)
		memory.write_u8(a, v)
		a = C68kScript.u32(a + 1)
		if v == 0:
			return C68kScript.u32(dst)
		n -= 1
		if n == 0:
			memory.write_u8(a, 0)
			return C68kScript.u32(dst)
	return C68kScript.u32(dst)  # not reached: the loop above always returns


## Low-memory globals the segment reads at absolute addresses.
const LM_SOUND_BASE: int = 0x266   ## SoundBase: the hardware sound buffer (one sample byte per word)
const LM_SOUND_HOOK: int = 0x196   ## the VBL sound handler slot the segment switches
const LM_CURRENT_A5: int = 0x904   ## CurrentA5: the routines called at interrupt level reload A5 from here
const A5_SOUND_CHANNELS: int = -0x7d0  ## two channel records of 0x238: +0 playing node, +4 free node
const A5_SILENCE_BUFFER: int = -0xc26  ## 0x172 bytes of silence
const A5_SOUND_READY: int = -0xc38     ## word: init_sound_system succeeded
const A5_RATE_STEP_FRAC: int = -0xc2e  ## rate << 16 (fraction step)
const A5_RATE_STEP_INT: int = -0xc32   ## rate >> 16 (integer step)
const A5_RATE_FRAME_SPAN: int = -0xc2a ## (rate * 0x172) >> 16: source bytes per frame
const A5_TWO_CHANNEL_HANDLER: int = -0x35c ## code address of vbl_sound_handler_two_channel

## 0x1632: depth 1 (word A5 - 0x137a) keeps the colour index word at A5 - 0x13b8; otherwise it
## becomes the long +0x54 of the port at A5 - 0x160c (sign-extended).
func set_back_color_index(index: int) -> void:
	if memory.read_s16(C68kScript.u32(a5 - 0x137a)) == 1:
		memory.write_u16(C68kScript.u32(a5 - 0x13b8), index & 0xffff)
	else:
		memory.write_u32(C68kScript.u32(memory.read_u32(C68kScript.u32(a5 - 0x160c)) + 0x54), C68kScript.u32(C68kScript.s16(index)))

## 0x1656 / 0x1680: half the view width / height word (A5 - 0x1372 / - 0x1370, DIVS.W #2,
## sign-extended quotient) plus coordinate * scale (A5 - 0x149e, MULU.L) DIVS.L 0x12c0.
func design_x_to_screen(x: int) -> int:
	return _design_to_screen(x, -0x1372)

func design_y_to_screen(y: int) -> int:
	return _design_to_screen(y, -0x1370)

func _design_to_screen(v: int, half_offset: int) -> int:
	var half: int = C68kScript.divs_trunc(memory.read_s16(C68kScript.u32(a5 + half_offset)), 2)
	var scaled: int = C68kScript.u32(C68kScript.u32(C68kScript.s16(v)) * memory.read_u32(C68kScript.u32(a5 - 0x149e)))
	return C68kScript.u32(half + C68kScript.divs_trunc(C68kScript.s32(scaled), 0x12c0))

## 0x1c8a: the decimal Pascal string of value into buf (returns buf). Digits are built backwards
## from buf + 10 with DIVSL.L #10 (remainder + '0'), a '-' for a negative value (NEG.L, so
## 0x80000000 stays negative and its digits come from negative remainders), then the length byte
## goes before them and length + 1 bytes are copied to buf.
func format_int_decimal_pstring(value: int, buf: int) -> int:
	var pstr: Array = _decimal_pstring(value)
	var p: int = C68kScript.u32(buf + 10 - pstr.size())
	for k in pstr.size():
		memory.write_u8(C68kScript.u32(p + k), pstr[k])
	# Forward byte copy from memory: a string longer than 10 bytes starts below buf, the areas
	# overlap and the copy repeats its first bytes, as in the original.
	for k in pstr.size():
		memory.write_u8(C68kScript.u32(buf + k), memory.read_u8(C68kScript.u32(p + k)))
	return C68kScript.u32(buf)

## The Pascal string format_int_decimal_pstring builds (length byte first).
static func _decimal_pstring(value: int) -> Array:
	var v: int = C68kScript.s32(value)
	var negative: bool = v < 0
	if negative:
		v = C68kScript.s32(-v)
	var chars: Array = []
	while true:
		chars.push_front((v - C68kScript.divs_trunc(v, 10) * 10 + 0x30) & 0xff)
		v = C68kScript.divs_trunc(v, 10)
		if v == 0:
			break
	if negative:
		chars.push_front(0x2d)
	chars.push_front(chars.size() & 0xff)
	return chars

## 0x2ee4: copy the length byte, then (signed byte) that many characters.
func copy_pascal_string(src: int, dst: int) -> void:
	var length: int = memory.read_u8(src)
	memory.write_u8(dst, length)
	var n: int = C68kScript.s16(C68kScript.s8(length))
	var k: int = 1
	while true:
		n = C68kScript.s16(n - 1)
		if n < 0:
			break
		memory.write_u8(C68kScript.u32(dst + k), memory.read_u8(C68kScript.u32(src + k)))
		k += 1

## 0x3d36: 0x172 bytes of 0x80 at every other byte of the sound buffer (SoundBase).
func clear_sound_buffer_to_silence() -> void:
	var p: int = memory.read_u32(LM_SOUND_BASE)
	for k in 0x172:
		memory.write_u8(C68kScript.u32(p + 2 * k), 0x80)

func _current_a5() -> int:
	return memory.read_u32(LM_CURRENT_A5)

func _channel_record(world: int, channel: int) -> int:
	return C68kScript.u32(world + A5_SOUND_CHANNELS + C68kScript.u32(channel * 0x238))

## 0x3d50 (uses the caller's A5): take the channel's free node (record +4; the next free one is
## node +0x14) and fill it: +0 position = start, +4 fraction 0, +8 sample base, +0xc loop start =
## start, +0x10 end, +0x18 next node = the following node when `chain` (word), else itself.
func alloc_sound_buffer_node(channel: int, sample: int, start: int, end: int, chain: int) -> int:
	var rec: int = _channel_record(a5, channel)
	var node: int = memory.read_u32(rec + 4)
	memory.write_u32(rec + 4, memory.read_u32(node + 0x14))
	memory.write_u32(node, C68kScript.u32(start))
	memory.write_u32(node + 4, 0)
	memory.write_u32(node + 8, C68kScript.u32(sample))
	memory.write_u32(node + 0xc, C68kScript.u32(start))
	memory.write_u32(node + 0x10, C68kScript.u32(end))
	memory.write_u32(node + 0x18, memory.read_u32(node + 0x14) if (chain & 0xffff) != 0 else node)
	return node

## 0x3db8: channel 1 installs the two-channel VBL handler (A5 - 0x35c) in the sound hook.
func select_two_channel_sound_handler(channel: int) -> void:
	if C68kScript.u32(channel) == 1:
		memory.write_u32(LM_SOUND_HOOK, memory.read_u32(C68kScript.u32(a5 + A5_TWO_CHANNEL_HANDLER)))

## Channel 0 or 1 with the sound system ready (A5 from CurrentA5).
func _sound_channel_ok(world: int, channel: int) -> bool:
	return memory.read_u16(C68kScript.u32(world + A5_SOUND_READY)) != 0 and C68kScript.s32(channel) >= 0 and C68kScript.s32(channel) < 2

## The node chain play / enqueue build (0x3f88 / 0x4084): without a loop (loop_b <= loop_a,
## unsigned) start..end (chained) then a silence node; otherwise start..loop_a (chained),
## loop_a..loop_b (looping on itself) and loop_b..end (chained). Then the channel's VBL handler is
## selected. Returns the first node.
func _queue_sample_nodes(world: int, channel: int, sample: int, start: int, end: int, loop_a: int, loop_b: int) -> int:
	var saved: int = a5
	a5 = world
	var first: int
	if not (C68kScript.u32(loop_b) > C68kScript.u32(loop_a)):
		first = alloc_sound_buffer_node(channel, sample, start, end, 1)
		alloc_sound_buffer_node(channel, C68kScript.u32(world + A5_SILENCE_BUFFER), 0, 0x172, 0)
	else:
		first = alloc_sound_buffer_node(channel, sample, start, loop_a, 1)
		alloc_sound_buffer_node(channel, sample, loop_a, loop_b, 0)
		alloc_sound_buffer_node(channel, sample, loop_b, end, 1)
	select_two_channel_sound_handler(channel)
	a5 = saved
	return first

## 0x3f54: start a sample now: the nodes are queued and the channel's playing node (record +0)
## becomes the first one. 1, or 0 when the sound system is off or the channel is not 0 / 1.
func play_sample_on_channel(channel: int, sample: int, start: int, end: int, loop_a: int, loop_b: int) -> int:
	var world: int = _current_a5()
	if not _sound_channel_ok(world, channel):
		return 0
	var first: int = _queue_sample_nodes(world, channel, sample, start, end, loop_a, loop_b)
	memory.write_u32(_channel_record(world, channel), first)
	return 1

## 0x4050: queue a sample after the current one (the playing node is left alone).
func enqueue_sample_on_channel(channel: int, sample: int, start: int, end: int, loop_a: int, loop_b: int) -> int:
	var world: int = _current_a5()
	if not _sound_channel_ok(world, channel):
		return 0
	_queue_sample_nodes(world, channel, sample, start, end, loop_a, loop_b)
	return 1

## 0x412e: rate clamped to 0x8000..0x30000 (unsigned); the steps per output byte (rate >> 16,
## rate << 16) and the source bytes per frame ((rate * 0x172) >> 16, MULU.L) for the handlers.
func set_sound_playback_rate(rate: int) -> void:
	var world: int = _current_a5()
	if memory.read_u16(C68kScript.u32(world + A5_SOUND_READY)) == 0:
		return
	var r: int = C68kScript.u32(rate)
	if r < 0x8000:
		r = 0x8000
	elif r > 0x30000:
		r = 0x30000
	memory.write_u32(C68kScript.u32(world + A5_RATE_FRAME_SPAN), C68kScript.u32(r * 0x172) >> 16)
	memory.write_u32(C68kScript.u32(world + A5_RATE_STEP_FRAC), C68kScript.lsl32(r, 16))
	memory.write_u32(C68kScript.u32(world + A5_RATE_STEP_INT), r >> 16)

## 0x41a6: queue silence (alloc 0x14 below the body) and make every node from the playing one up
## to it chain forward (+0x18 = +0x14), ending any loop. (record +4 is rewritten with the
## silence node's +0x14, as alloc already did.)
func release_channel_loop(channel: int) -> void:
	var world: int = _current_a5()
	if not _sound_channel_ok(world, channel):
		return
	var saved: int = a5
	a5 = world
	var silence: int = alloc_sound_buffer_node(channel, C68kScript.u32(world + A5_SILENCE_BUFFER), 0, 0x172, 0)
	a5 = saved
	var rec: int = _channel_record(world, channel)
	memory.write_u32(rec + 4, memory.read_u32(silence + 0x14))
	var node: int = memory.read_u32(rec)
	while node != silence:
		memory.write_u32(node + 0x18, memory.read_u32(node + 0x14))
		node = memory.read_u32(node + 0x14)

## 0x4242: the channel plays a fresh silence node at once.
func silence_sound_channel(channel: int) -> void:
	var world: int = _current_a5()
	if not _sound_channel_ok(world, channel):
		return
	var saved: int = a5
	a5 = world
	var silence: int = alloc_sound_buffer_node(channel, C68kScript.u32(world + A5_SILENCE_BUFFER), 0, 0x172, 0)
	a5 = saved
	memory.write_u32(_channel_record(world, channel), silence)

## 0x42b0: 1 when the playing node's sample is not the silence buffer, else 0 (word).
func is_channel_playing(channel: int) -> int:
	var world: int = _current_a5()
	if not _sound_channel_ok(world, channel):
		return 0
	var node: int = memory.read_u32(_channel_record(world, channel))
	return 1 if memory.read_u32(node + 8) != C68kScript.u32(world + A5_SILENCE_BUFFER) else 0

## 0x488a: a ctab callback: clears word +6 (the size) of the colour table at A5 - 0x14b2 (A5 from
## CurrentA5).
func clear_ctab_size_callback() -> void:
	memory.write_u16(C68kScript.u32(memory.read_u32(C68kScript.u32(_current_a5() - 0x14b2)) + 6), 0)

## 0x49fe: the palette index of an RGB colour given as levels 0..4 (words): each level becomes
## (level << 6, 0x100 -> 0xff) << 8. The eight fixed entries (A5 - 0x350, 6 bytes) are searched,
## then the table at A5 - 0x14a6 (count word A5 - 0x14a2, indices + 8). Depth (A5 - 0x137a) 1 / 4
## returns the index (-1 when not found), depth 8 the index + 0xc8; any other depth returns what D0
## last held (the matched blue word, the matching index + 8, or the end of the second scan). The
## low word is the result.
func lookup_palette_index_for_rgb_level(r: int, g: int, b: int) -> int:
	var want: Array = []
	for level in [r, g, b]:
		var v: int = C68kScript.u16(level << 6)
		if v == 0x100:
			v = 0xff
		want.append(C68kScript.u16(v << 8))
	var found: int = -1
	var d0: int = 0
	for i in 8:
		var e: int = C68kScript.u32(a5 - 0x350 + 6 * i)
		if memory.read_u16(e) == want[0] and memory.read_u16(e + 2) == want[1] and memory.read_u16(e + 4) == want[2]:
			found = i
			d0 = want[2]
			break
	if found == -1:
		var table: int = memory.read_u32(C68kScript.u32(a5 - 0x14a6))
		var count: int = memory.read_s16(C68kScript.u32(a5 - 0x14a2))
		var i: int = 0
		d0 = 0
		while i < count:
			var e2: int = C68kScript.u32(table + 6 * i)
			if memory.read_u16(e2) == want[0] and memory.read_u16(e2 + 2) == want[1] and memory.read_u16(e2 + 4) == want[2]:
				found = i + 8
				d0 = found
				break
			i += 1
			d0 = i
	var depth: int = memory.read_s16(C68kScript.u32(a5 - 0x137a))
	if depth == 4 or depth == 1:
		return C68kScript.u16(found)
	if depth == 8:
		return C68kScript.u16(found + 0xc8)
	return C68kScript.u16(d0)

## 0x4b62: the standard colour indices: grey levels 3 / 0 / 0 / 3 / 2 / 3 / 0 / 3 / 1 into the
## words at A5 - 0x11ae, - 0x11ac, - 0x118c, - 0x1188, - 0x118a, - 0x117c, - 0x117e, - 0x11fa,
## - 0x11f8.
func init_standard_colour_indices() -> void:
	for pair in [[3, -0x11ae], [0, -0x11ac], [0, -0x118c], [3, -0x1188], [2, -0x118a], [3, -0x117c], [0, -0x117e],
			[3, -0x11fa], [1, -0x11f8]]:
		memory.write_u16(C68kScript.u32(a5 + pair[1]), lookup_palette_index_for_rgb_level(pair[0], pair[0], pair[0]))

## Jump-table slots of the ID09 Toolbox glue (Pascal: the glue pops its arguments).
const JT_DISPOSE_PTR: int = 0x23a     ## DisposPtr ($A01F)
const JT_NEW_PTR: int = 0x232         ## NewPtr ($A11E): function result long
const JT_DISPOSE_HANDLE: int = 0x25a  ## DisposHandle ($A023)
const JT_HLOCK: int = 0x272           ## HLock ($A029)
const JT_HUNLOCK: int = 0x27a         ## HUnlock ($A02A)
const JT_HPURGE: int = 0x282          ## HPurge ($A049)
const JT_HNOPURGE: int = 0x28a        ## HNoPurge ($A04A)
const JT_SWAP_MMU_MODE: int = 0x2e2   ## SwapMMUMode(VAR mode) ($A05D)
const JT_RGB_TO_PATTERN: int = 0x1ca  ## C routine: RGBColor by value (r, g, b words) -> D0
const TRAP_CLOSE_PORT: int = 0xa87d
const TRAP_SET_PORT: int = 0xa873
const TRAP_OPEN_CPORT: int = 0xaa00
const TRAP_RECT_RGN: int = 0xa8df
const TRAP_PEN_PAT: int = 0xa89d

## 0xd24 (caller's A5): ClosePort(port), then DisposPtr(port).
func close_and_dispose_port(port: int) -> void:
	_trap(TRAP_CLOSE_PORT, [port])
	_jt(JT_DISPOSE_PTR, [port])

## 0xf52: ClosePort(port) with A5 from CurrentA5 (the trap does not use it).
func close_port_a5safe(port: int) -> void:
	_trap(TRAP_CLOSE_PORT, [port])

## 0xf74: returns the current port (A5 - 0x160c, A5 from CurrentA5) and SetPort(port).
func swap_port_a5safe(port: int) -> int:
	var old: int = memory.read_u32(C68kScript.u32(_current_a5() - 0x160c))
	_trap(TRAP_SET_PORT, [port])
	return old

## 0x14e6: SwapMMUMode on the mode byte at A5 - 0x1000 (A5 from CurrentA5).
func swap_mmu_mode_a5safe() -> void:
	_jt(JT_SWAP_MMU_MODE, [C68kScript.u32(_current_a5() - 0x1000)])

## 0x1a04 / 0x1a84 / 0x1aa8 / 0x1acc / 0x1af0: the handle routines through the ID09 glue, with A5
## reloaded from CurrentA5 (the slots are relative to that A5; the routines are keyed by offset).
func dispose_handle_a5safe(h: int) -> void:
	_jt(JT_DISPOSE_HANDLE, [h])

func hlock_a5safe(h: int) -> void:
	_jt(JT_HLOCK, [h])

func hunlock_a5safe(h: int) -> void:
	_jt(JT_HUNLOCK, [h])

func hpurge_a5safe(h: int) -> void:
	_jt(JT_HPURGE, [h])

func hnopurge_a5safe(h: int) -> void:
	_jt(JT_HNOPURGE, [h])

## The RGB entry of a colour index (signed word): above 8 the extra table (A5 - 0x14a6, index -
## 8), else the fixed entries at A5 - 0x350 (6 bytes each).
func _colour_entry(index: int) -> int:
	if index > 8:
		return C68kScript.u32(memory.read_u32(C68kScript.u32(a5 - 0x14a6)) + C68kScript.s32((index - 8) * 6))
	return C68kScript.u32(a5 - 0x350 + C68kScript.s32(index * 6))

## 0x150a: at depth 1 (A5 - 0x137a) the pattern for the average (LSR.W of the word sum) of the
## fore (A5 - 0x13ba) and back (A5 - 0x13b8) colour entries, from the RGB-to-pattern routine (JT
## $1ca, C: D0); at other depths the black pattern at A5 - 0x1624.
func get_blended_fill_pattern() -> int:
	if memory.read_s16(C68kScript.u32(a5 - 0x137a)) != 1:
		return C68kScript.u32(a5 - 0x1624)
	var fore: int = _colour_entry(memory.read_s16(C68kScript.u32(a5 - 0x13ba)))
	var back: int = _colour_entry(memory.read_s16(C68kScript.u32(a5 - 0x13b8)))
	var rgb: Array = []
	for k in 3:
		rgb.append(((memory.read_u16(fore + 2 * k) + memory.read_u16(back + 2 * k)) & 0xffff) >> 1)
	return C68kScript.u32(_jt(JT_RGB_TO_PATTERN, rgb))

## 0x15cc: at depth 1 the fore colour index is kept (A5 - 0x13ba) and PenPat gets the pattern of
## its entry (JT $1ca); otherwise the port's long +0x50 (A5 - 0x160c) takes the sign-extended index.
func set_draw_color_index(index: int) -> void:
	if memory.read_s16(C68kScript.u32(a5 - 0x137a)) == 1:
		memory.write_u16(C68kScript.u32(a5 - 0x13ba), index & 0xffff)
		var entry: int = _colour_entry(C68kScript.s16(index))
		var pattern: int = _jt(JT_RGB_TO_PATTERN, [memory.read_u16(entry), memory.read_u16(entry + 2), memory.read_u16(entry + 4)])
		_trap(TRAP_PEN_PAT, [C68kScript.u32(pattern)])
	else:
		memory.write_u32(C68kScript.u32(memory.read_u32(C68kScript.u32(a5 - 0x160c)) + 0x50), C68kScript.u32(C68kScript.s16(index)))

## 0xca6: a colour port record (NewPtr 0x6c) opened (OpenCPort) and the current port restored
## (SetPort); its pixmap (*port +2) gets the row bytes word, base address and bounds, the port
## rect the bounds, and RectRgn(visRgn +0x18, bounds). Returns the port. (The bounds arrive as two
## longs: top / left and bottom / right.)
func new_offscreen_cport(row_bytes: int, base: int, bounds_tl: int, bounds_br: int) -> int:
	var port: int = C68kScript.u32(_jt(JT_NEW_PTR, [0x6c]))
	var saved: int = memory.read_u32(C68kScript.u32(a5 - 0x160c))
	_trap(TRAP_OPEN_CPORT, [port])
	_trap(TRAP_SET_PORT, [saved])
	var pixmap: int = memory.read_u32(memory.read_u32(port + 2))
	memory.write_u16(pixmap + 4, row_bytes & 0xffff)
	pixmap = memory.read_u32(memory.read_u32(port + 2))
	memory.write_u32(pixmap, C68kScript.u32(base))
	pixmap = memory.read_u32(memory.read_u32(port + 2))
	memory.write_u32(pixmap + 6, C68kScript.u32(bounds_tl))
	memory.write_u32(pixmap + 10, C68kScript.u32(bounds_br))
	memory.write_u32(port + 0x10, C68kScript.u32(bounds_tl))
	memory.write_u32(port + 0x14, C68kScript.u32(bounds_br))
	_trap(TRAP_RECT_RGN, [[C68kScript.u32(bounds_tl), C68kScript.u32(bounds_br)], memory.read_u32(port + 0x18)])
	return port

const JT_RECOVER_HANDLE: int = 0x262  ## RecoverHandle ($A128): function result long
const JT_SEGMENT3_ENTRY: int = 0x17a  ## segment 3's entry routine (C, no arguments)
const TRAP_PEN_SIZE: int = 0xa89b
const TRAP_MOVE_TO: int = 0xa893
const TRAP_LINE_TO: int = 0xa891
const TRAP_PEN_MODE_LONG: int = 0xa862  ## long argument (0x21 / 0x1e mode words, pushed with PEA)
const TRAP_SET_BACK_MODE: int = 0xa863
const TRAP_PEN_MODE: int = 0xa89c
const TRAP_SET_ENTRIES: int = 0xaa3f
const TRAP_COPY_BITS: int = 0xa8ec
const TRAP_PAINT_RECT: int = 0xa8a2
const TRAP_UNLOAD_SEG: int = 0xa9f1
const TRAP_GET_NEXT_EVENT: int = 0xa970
const TRAP_INVAL_RECT: int = 0xa928
const TRAP_ENABLE_ITEM: int = 0xa939
const TRAP_DISABLE_ITEM: int = 0xa93a
const TRAP_DRAW_MENU_BAR: int = 0xa937
const TRAP_SND_DISPOSE_CHANNEL: int = 0xa801
const TRAP_MOVE_WINDOW: int = 0xa91b
const TRAP_GET_RESOURCE: int = 0xa9a0
const TRAP_SET_RECT: int = 0xa8a7
const TRAP_SET_PALETTE: int = 0xaa95
const LM_MBAR_HEIGHT: int = 0xbaa
const A5_SOUND_SLOTS: int = -0xd62  ## twenty sound pointers (sample data, 0x14 past the handle's start)

## 0xa42: the port's foreground index (+0x50 of A5 - 0x160c) = colour, a 2 x 2 pen, and a line
## between the low words of (x0, y0) and (x1, y1).
func draw_thick_line_pixel_index_a5safe(colour: int, x0: int, y0: int, x1: int, y1: int) -> void:
	var world: int = _current_a5()
	memory.write_u32(C68kScript.u32(memory.read_u32(C68kScript.u32(world - 0x160c)) + 0x50), C68kScript.u32(colour))
	_trap(TRAP_PEN_SIZE, [2, 2])
	_trap(TRAP_MOVE_TO, [y0 & 0xffff, x0 & 0xffff])
	_trap(TRAP_LINE_TO, [y1 & 0xffff, x1 & 0xffff])

## 0xa86: an XOR line (pen mode 0x21, then 2 / back to 0 around it) with a 2 x 2 pen between the
## low words of (x0, y0) and (x1, y1).
func draw_thick_xor_line_a5safe(x0: int, y0: int, x1: int, y1: int) -> void:
	_trap(TRAP_PEN_MODE_LONG, [0x21])
	_trap(TRAP_PEN_MODE, [2])
	_trap(TRAP_PEN_SIZE, [2, 2])
	_trap(TRAP_MOVE_TO, [y0 & 0xffff, x0 & 0xffff])
	_trap(TRAP_LINE_TO, [y1 & 0xffff, x1 & 0xffff])
	_trap(TRAP_PEN_MODE, [0])

## 0xc68: SetEntries(-1, count - 1, entries) of the pending colour table (A5 - 0x14b2: word +6
## count, entries from +8), then its count is cleared.
func apply_pending_color_entries_a5safe() -> void:
	var table: int = memory.read_u32(C68kScript.u32(_current_a5() - 0x14b2))
	var count: int = C68kScript.u16(memory.read_u16(table + 6) - 1)
	_trap(TRAP_SET_ENTRIES, [C68kScript.u32(table + 8), count, 0xffff])
	memory.write_u16(memory.read_u32(C68kScript.u32(_current_a5() - 0x14b2)) + 6, 0)

## 0xe3e: the source port's pixmap base = base; the pen / back modes 0x21 / 0x1e; CopyBits from
## the source port's bits to the destination's (0: the current port, A5 - 0x160c), srcCopy, no
## mask.
func blit_pixels_via_port_a5safe(src_port: int, base: int, src_rect: int, dst_port: int, dst_rect: int) -> void:
	memory.write_u32(memory.read_u32(memory.read_u32(C68kScript.u32(src_port + 2))), C68kScript.u32(base))
	_trap(TRAP_PEN_MODE_LONG, [0x21])
	_trap(TRAP_SET_BACK_MODE, [0x1e])
	var dst: int = C68kScript.u32(dst_port)
	if dst == 0:
		dst = memory.read_u32(C68kScript.u32(_current_a5() - 0x160c))
	_trap(TRAP_COPY_BITS, [0, 0, C68kScript.u32(dst_rect), C68kScript.u32(src_rect), C68kScript.u32(dst + 2), C68kScript.u32(src_port + 2)])

## 0xe9e: OpenCPort(port), SetPort back to the current port; the pixmap gets row bytes | 0x8000
## (word), base and the bounds (rect at `bounds`); the port rect becomes (0, 0, bottom - top, right
## - left) and RectRgn(visRgn, that rect).
func open_offscreen_cport_a5safe(port: int, row_bytes: int, base: int, bounds: int) -> void:
	var saved: int = memory.read_u32(C68kScript.u32(_current_a5() - 0x160c))
	_trap(TRAP_OPEN_CPORT, [port])
	_trap(TRAP_SET_PORT, [saved])
	memory.write_u16(memory.read_u32(memory.read_u32(port + 2)) + 4, (0x8000 | row_bytes) & 0xffff)
	memory.write_u32(memory.read_u32(memory.read_u32(port + 2)), C68kScript.u32(base))
	var pixmap: int = memory.read_u32(memory.read_u32(port + 2))
	memory.write_u32(pixmap + 6, memory.read_u32(bounds))
	memory.write_u32(pixmap + 10, memory.read_u32(bounds + 4))
	var height: int = C68kScript.u16(memory.read_u16(bounds + 4) - memory.read_u16(bounds))
	var width: int = C68kScript.u16(memory.read_u16(bounds + 6) - memory.read_u16(bounds + 2))
	var rect_tl: int = 0
	var rect_br: int = (height << 16) | width
	memory.write_u32(port + 0x10, rect_tl)
	memory.write_u32(port + 0x14, rect_br)
	_trap(TRAP_RECT_RGN, [[rect_tl, rect_br], memory.read_u32(port + 0x18)])

## 0xfa0: set_draw_color_index (A5 from CurrentA5), PaintRect(rect), PenPat(black at A5 - 0x161c).
func paint_rect_color_index_a5safe(rect: int, index: int) -> void:
	var saved: int = a5
	a5 = _current_a5()
	set_draw_color_index(index & 0xffff)
	a5 = saved
	_trap(TRAP_PAINT_RECT, [C68kScript.u32(rect)])
	_trap(TRAP_PEN_PAT, [C68kScript.u32(_current_a5() - 0x161c)])

## 0x197c: segment 3's entry (JT $17a), then UnloadSeg(A5 + 0x18a) (A5 from CurrentA5).
func run_segment3_entry_and_unload_a5safe() -> void:
	_jt(JT_SEGMENT3_ENTRY, [])
	_trap(TRAP_UNLOAD_SEG, [C68kScript.u32(_current_a5() + 0x18a)])

## 0x1e68: each of the twenty sound pointers (A5 - 0xd62) that is set has its handle recovered
## (pointer - 0x14), made purgeable and unlocked when found, and the slot is cleared.
func release_sound_slots() -> void:
	for i in 20:
		var slot: int = C68kScript.u32(a5 + A5_SOUND_SLOTS + 4 * i)
		if memory.read_u32(slot) == 0:
			continue
		var h: int = C68kScript.u32(_jt(JT_RECOVER_HANDLE, [C68kScript.u32(memory.read_u32(slot) - 0x14)]))
		if h != 0:
			_jt(JT_HPURGE, [h])
			_jt(JT_HUNLOCK, [h])
		memory.write_u32(slot, 0)

## 0x20be: each set slot holds a handle: it is locked and the slot becomes its data + 0x14.
func lock_sound_slots() -> void:
	for i in 20:
		var slot: int = C68kScript.u32(a5 + A5_SOUND_SLOTS + 4 * i)
		if memory.read_u32(slot) == 0:
			continue
		_jt(JT_HLOCK, [memory.read_u32(slot)])
		var h: int = memory.read_u32(slot)
		memory.write_u32(slot, C68kScript.u32(memory.read_u32(h) + 0x14))

## 0x2fa0 (C, the EventRecord by value): an activate (modifiers & 3 == 3) of the game window
## (A5 - 0x14ca, set) while A5 - 0x14c6 is set invalidates its port rect (+0x10).
func handle_activate_event(_what: int, message: int, _when: int, _where: int, modifiers: int) -> void:
	if memory.read_u16(C68kScript.u32(a5 - 0x14c6)) == 0 or (modifiers & 3) != 3:
		return
	var window: int = memory.read_u32(C68kScript.u32(a5 - 0x14ca))
	if C68kScript.u32(message) != window or window == 0:
		return
	_trap(TRAP_INVAL_RECT, [C68kScript.u32(window + 0x10)])

## 0x3590: EnableItem / DisableItem(menu, item); item 0 (the whole menu) also redraws the bar.
func set_menu_item_enabled(menu: int, item: int, enable: int) -> void:
	_trap(TRAP_ENABLE_ITEM if (enable & 0xffff) != 0 else TRAP_DISABLE_ITEM, [item & 0xffff, C68kScript.u32(menu)])
	if (item & 0xffff) == 0:
		_trap(TRAP_DRAW_MENU_BAR, [])

## 0x4318: with sound running, channels 0 / 1 / 2 are silenced (2 is refused), the single-channel
## VBL handler (A5 - 0xc36) goes back in the sound hook, the buffer is silenced, the Sound Manager
## channel (A5 - 0x356) disposed (quietNow true) and the ready flag cleared.
func shutdown_sound() -> void:
	if memory.read_u16(C68kScript.u32(a5 + A5_SOUND_READY)) == 0:
		return
	silence_sound_channel(0)
	silence_sound_channel(1)
	silence_sound_channel(2)
	memory.write_u32(LM_SOUND_HOOK, memory.read_u32(C68kScript.u32(a5 - 0xc36)))
	clear_sound_buffer_to_silence()
	_trap(TRAP_SND_DISPOSE_CHANNEL, [1, memory.read_u32(C68kScript.u32(a5 - 0x356))])
	memory.write_u16(C68kScript.u32(a5 + A5_SOUND_READY), 0)

## Half / third of a word, as DIVS.W of its sign extension (the quotient word).
static func _wdiv(v: int, d: int) -> int:
	return C68kScript.divs_trunc(C68kScript.s16(v), d)

## The screen size from the main screen rect (A5 - 0x1680 .. - 0x167a): [width, height].
func _screen_size() -> Array:
	return [C68kScript.u16(memory.read_u16(C68kScript.u32(a5 - 0x167a)) - memory.read_u16(C68kScript.u32(a5 - 0x167e))),
			C68kScript.u16(memory.read_u16(C68kScript.u32(a5 - 0x167c)) - memory.read_u16(C68kScript.u32(a5 - 0x1680)))]

## 0x435e: the window (port rect +0x10..+0x16) centred across, and vertically at a half of the
## screen below the menu bar (MBarHeight 0xbaa) when it does not fit, else at a third; MoveWindow
## (front).
func position_window_on_screen(window: int) -> void:
	var w: int = C68kScript.u16(memory.read_u16(window + 0x16) - memory.read_u16(window + 0x12))
	var h: int = C68kScript.u16(memory.read_u16(window + 0x14) - memory.read_u16(window + 0x10))
	var screen: Array = _screen_size()
	var sh: int = C68kScript.u16(screen[1] - memory.read_u16(LM_MBAR_HEIGHT))
	var left: int = C68kScript.u16(_wdiv(screen[0], 2) - _wdiv(w, 2))
	var top: int
	if C68kScript.s16(sh) < C68kScript.s16(h):
		top = C68kScript.u16(_wdiv(sh, 2) - _wdiv(h, 2))
	else:
		top = C68kScript.u16(_wdiv(sh, 3) - _wdiv(h, 3))
	_trap(TRAP_MOVE_WINDOW, [1, top, left, C68kScript.u32(window)])

## 0x442e: the alert template 'ALRT' id (GetResource) gets its rect re-centred: across at a half,
## down at a half when a third of the screen is under half the alert's height, else at a third.
func position_alert_template(id: int) -> void:
	var h: int = C68kScript.u32(_trap(TRAP_GET_RESOURCE, [id & 0xffff, 0x414c5254]))
	var rect: int = memory.read_u32(h)
	var w: int = C68kScript.u16(memory.read_u16(rect + 6) - memory.read_u16(rect + 2))
	var ht: int = C68kScript.u16(memory.read_u16(rect + 4) - memory.read_u16(rect))
	var screen: Array = _screen_size()
	var left: int = C68kScript.u16(_wdiv(screen[0], 2) - _wdiv(w, 2))
	var right: int = C68kScript.u16(_wdiv(screen[0], 2) + _wdiv(w, 2))
	var div: int = 2 if C68kScript.s16(_wdiv(screen[1], 3)) < C68kScript.s16(_wdiv(ht, 2)) else 3
	var top: int = C68kScript.u16(_wdiv(screen[1], div) - _wdiv(ht, 2))
	var bottom: int = C68kScript.u16(_wdiv(screen[1], div) + _wdiv(ht, 2))
	_trap(TRAP_SET_RECT, [bottom, right, top, left, memory.read_u32(h)])

## 0x4582: the window centred across, and vertically at a half of the full screen height plus
## half the menu bar; MoveWindow (front).
func centre_window_on_screen(window: int) -> void:
	var w: int = C68kScript.u16(memory.read_u16(window + 0x16) - memory.read_u16(window + 0x12))
	var h: int = C68kScript.u16(memory.read_u16(window + 0x14) - memory.read_u16(window + 0x10))
	var screen: Array = _screen_size()
	var left: int = C68kScript.u16(_wdiv(screen[0], 2) - _wdiv(w, 2))
	var top: int = C68kScript.u16(_wdiv(screen[1], 2) - _wdiv(h, 2) + _wdiv(memory.read_u16(LM_MBAR_HEIGHT), 2))
	_trap(TRAP_MOVE_WINDOW, [1, top, left, C68kScript.u32(window)])

## 0x4610: the game window (A5 - 0x14ca, when set) loses its palette (SetPalette nil) and the
## current palette depth (A5 - 0x2cc) is cleared.
func detach_window_palette() -> void:
	var window: int = memory.read_u32(C68kScript.u32(a5 - 0x14ca))
	if window == 0:
		return
	_trap(TRAP_SET_PALETTE, [0, 0, window])
	memory.write_u16(C68kScript.u32(a5 - 0x2cc), 0)

## 0x462c: when the depth (A5 - 0x137a) differs from the palette depth (A5 - 0x2cc): depth 4
## and 8 attach their palette (A5 - 0x14ae / - 0x14aa) to the game window and select the 5 / 9
## extra colour entries at A5 - 0x320 / - 0x302; depth 1 selects the 5 entries without a palette;
## the palette depth is recorded (any other depth leaves it 0).
func select_palette_for_depth() -> void:
	var depth: int = memory.read_s16(C68kScript.u32(a5 - 0x137a))
	if depth == memory.read_s16(C68kScript.u32(a5 - 0x2cc)):
		return
	memory.write_u16(C68kScript.u32(a5 - 0x2cc), 0)
	if depth == 4 or depth == 8:
		var palette: int = memory.read_u32(C68kScript.u32(a5 + (-0x14ae if depth == 4 else -0x14aa)))
		_trap(TRAP_SET_PALETTE, [0, palette, memory.read_u32(C68kScript.u32(a5 - 0x14ca))])
		memory.write_u16(C68kScript.u32(a5 - 0x2cc), depth)
		memory.write_u32(C68kScript.u32(a5 - 0x14a6), C68kScript.u32(a5 + (-0x320 if depth == 4 else -0x302)))
		memory.write_u16(C68kScript.u32(a5 - 0x14a2), 5 if depth == 4 else 9)
	elif depth == 1:
		memory.write_u32(C68kScript.u32(a5 - 0x14a6), C68kScript.u32(a5 - 0x320))
		memory.write_u16(C68kScript.u32(a5 - 0x14a2), 5)
		memory.write_u16(C68kScript.u32(a5 - 0x2cc), 1)

const JT_FREE_MEM: int = 0x212    ## FreeMem: function result long
const JT_C2PSTR: int = 0x302      ## C routine: C string to Pascal in place
const JT_P2CSTR: int = 0x2fa      ## C routine: Pascal string back to C in place
const TRAP_OPEN_POLY: int = 0xa8cb
const TRAP_CLOSE_POLY: int = 0xa8cc
const TRAP_LINE: int = 0xa892
const TRAP_PARAM_TEXT: int = 0xa98b
const TRAP_CAUTION_ALERT: int = 0xa988
const TRAP_GET_NEW_DIALOG: int = 0xa97c
const TRAP_SHOW_WINDOW: int = 0xa915
const TRAP_DRAW_DIALOG: int = 0xa981
const TRAP_DISPOSE_DIALOG: int = 0xa983
const TRAP_BUTTON: int = 0xa974
const TRAP_GET_MENU: int = 0xa9bf
const TRAP_INSERT_MENU: int = 0xa935
const TRAP_ADD_RES_MENU: int = 0xa94d

## 0xd3a: blit the offscreen frame into the window. The first time (no port at A5 - 0x103a) the
## source rect (A5 - 0x14f2) is 0 / 0 / view height / view width, the destination (A5 - 0x14ea) a
## copy, and an offscreen port is made over `base` with row bytes ((width * depth + 15) asr 4) * 2
## | 0x8000. Each time: the pixmap base = base, the source bottom = the low word of `rows`, the
## destination top = the low word of `top` and bottom = top + rows, its left / right those of the
## source, shifted left (mode 2) / right (mode 3) by A5 - 0x137e; then the pen / back modes and
## CopyBits from the offscreen bits to the current port's.
func blit_offscreen_frame_to_window(base: int, top: int, rows: int, mode: int) -> void:
	var world: int = _current_a5()
	var saved: int = a5
	a5 = world
	var src: int = C68kScript.u32(world - 0x14f2)
	var dst: int = C68kScript.u32(world - 0x14ea)
	if memory.read_u32(C68kScript.u32(world - 0x103a)) == 0:
		memory.write_u16(src + 2, 0)
		memory.write_u16(src, 0)
		memory.write_u16(src + 6, memory.read_u16(C68kScript.u32(world - 0x1372)))
		memory.write_u16(src + 4, memory.read_u16(C68kScript.u32(world - 0x1370)))
		memory.write_u32(dst, memory.read_u32(src))
		memory.write_u32(dst + 4, memory.read_u32(src + 4))
		var width_bits: int = C68kScript.u16(C68kScript.s16(memory.read_u16(C68kScript.u32(world - 0x1372))) * C68kScript.s16(memory.read_u16(C68kScript.u32(world - 0x137a))) + 0xf)
		var row_bytes: int = C68kScript.u16(C68kScript.u16(C68kScript.s16(width_bits) >> 4) * 2) | 0x8000
		memory.write_u32(C68kScript.u32(world - 0x103a), new_offscreen_cport(row_bytes, base, memory.read_u32(dst), memory.read_u32(dst + 4)))
	var port: int = memory.read_u32(C68kScript.u32(world - 0x103a))
	memory.write_u32(memory.read_u32(memory.read_u32(port + 2)), C68kScript.u32(base))
	memory.write_u16(src + 4, rows & 0xffff)
	memory.write_u16(dst, top & 0xffff)
	memory.write_u16(dst + 4, C68kScript.u32(top + rows) & 0xffff)
	memory.write_u16(dst + 2, memory.read_u16(src + 2))
	memory.write_u16(dst + 6, memory.read_u16(src + 6))
	var shift: int = memory.read_u16(C68kScript.u32(world - 0x137e))
	if C68kScript.u32(mode) == 2:
		memory.write_u16(dst + 2, C68kScript.u16(memory.read_u16(dst + 2) - shift))
		memory.write_u16(dst + 6, C68kScript.u16(memory.read_u16(dst + 6) - shift))
	elif C68kScript.u32(mode) == 3:
		memory.write_u16(dst + 2, C68kScript.u16(memory.read_u16(dst + 2) + shift))
		memory.write_u16(dst + 6, C68kScript.u16(memory.read_u16(dst + 6) + shift))
	_trap(TRAP_PEN_MODE_LONG, [0x21])
	_trap(TRAP_SET_BACK_MODE, [0x1e])
	var current: int = memory.read_u32(C68kScript.u32(world - 0x160c))
	_trap(TRAP_COPY_BITS, [0, 0, dst, src, C68kScript.u32(current + 2), C68kScript.u32(memory.read_u32(C68kScript.u32(world - 0x103a)) + 2)])
	a5 = saved

## 0x10ce: the notched frame polygon (OpenPoly .. ClosePoly) between top / left (a, b) and the
## bottom / right (c, d) made relative to the port's +0x34 / +0x36: notch n = ((d - b) << 2) /
## 16 (word, DIVS.W), offset m = n / 2 + n - port +0x34 / 2. Returns the polygon.
func build_notched_frame_poly(a: int, b: int, c: int, d: int) -> int:
	var poly: int = C68kScript.u32(_trap(TRAP_OPEN_POLY, []))
	var port: int = memory.read_u32(C68kScript.u32(a5 - 0x160c))
	a &= 0xffff
	b &= 0xffff
	d = C68kScript.u16(d - memory.read_u16(port + 0x36))
	c = C68kScript.u16(c - memory.read_u16(port + 0x34))
	var n: int = C68kScript.u16(C68kScript.divs_trunc(C68kScript.s16(C68kScript.u16(d - b) << 2), 0x10))
	var m: int = C68kScript.u16(_wdiv(n, 2) + n - _wdiv(memory.read_u16(port + 0x34), 2))
	var neg_n: int = C68kScript.u16(-n)
	_trap(TRAP_MOVE_TO, [a, b])
	_trap(TRAP_LINE_TO, [a, d])
	_trap(TRAP_LINE, [m, 0])
	_trap(TRAP_LINE, [n, neg_n])
	_trap(TRAP_LINE, [n, n])
	_trap(TRAP_LINE_TO, [C68kScript.u16(c - n), d])
	_trap(TRAP_LINE_TO, [c, C68kScript.u16(d - n)])
	_trap(TRAP_LINE_TO, [c, C68kScript.u16(b + n)])
	_trap(TRAP_LINE_TO, [C68kScript.u16(c - n), b])
	_trap(TRAP_LINE_TO, [C68kScript.u16(a + m + n + n), b])
	_trap(TRAP_LINE, [neg_n, n])
	_trap(TRAP_LINE, [neg_n, neg_n])
	_trap(TRAP_LINE, [C68kScript.u16(-m), 0])
	_trap(TRAP_CLOSE_POLY, [])
	return poly

## 0x16aa: the view frame outline in design coordinates (design_x / design_y): at depth 1 the box
## (-3200, 670) .. (3200, 2400); otherwise the outline with the cockpit notch at (-1060 .. 1060,
## 670) and the sides down to 1200 (the left edge one pixel further left, a pixel nudge at the
## notch and the right corner as in the original).
func draw_view_frame_outline() -> void:
	var x_left: int = design_x_to_screen(-0xc80)
	var x_right: int = design_x_to_screen(0xc80)
	if memory.read_s16(C68kScript.u32(a5 - 0x137a)) == 1:
		_trap(TRAP_MOVE_TO, [design_y_to_screen(0x960) & 0xffff, C68kScript.u16(x_left - 1)])
		_trap(TRAP_LINE_TO, [design_y_to_screen(0x29e) & 0xffff, C68kScript.u16(x_left - 1)])
		_trap(TRAP_LINE_TO, [design_y_to_screen(0x29e) & 0xffff, x_right & 0xffff])
		_trap(TRAP_LINE_TO, [design_y_to_screen(0x960) & 0xffff, x_right & 0xffff])
		_trap(TRAP_LINE_TO, [design_y_to_screen(0x960) & 0xffff, x_left & 0xffff])
		return
	_trap(TRAP_MOVE_TO, [design_y_to_screen(0x960) & 0xffff, C68kScript.u16(x_left - 1)])
	_trap(TRAP_LINE_TO, [design_y_to_screen(0x4b0) & 0xffff, C68kScript.u16(x_left - 1)])
	_trap(TRAP_LINE_TO, [design_y_to_screen(0x4b0) & 0xffff, x_left & 0xffff])
	_trap(TRAP_LINE_TO, [design_y_to_screen(0x29e) & 0xffff, design_x_to_screen(-0x424) & 0xffff])
	_trap(TRAP_LINE_TO, [design_y_to_screen(0x29e) & 0xffff, C68kScript.u16(design_x_to_screen(0x424) - 2)])
	_trap(TRAP_LINE_TO, [C68kScript.u16(design_y_to_screen(0x4b0) + 1), x_right & 0xffff])
	_trap(TRAP_LINE_TO, [design_y_to_screen(0x960) & 0xffff, x_right & 0xffff])
	_trap(TRAP_LINE_TO, [design_y_to_screen(0x960) & 0xffff, x_left & 0xffff])

## 0x1b14: FreeMem (JT $212) with A5 from CurrentA5.
func freemem_a5safe() -> int:
	return C68kScript.u32(_jt(JT_FREE_MEM, []))

## 0x1d48: the message (a C string, made Pascal in place) in a caution alert (ALRT 0x102, placed
## with position_alert_template): number 0 shows it alone (ParamText with the strings at A5 -
## 0xd0e / - 0xd0c / - 0xd0a), otherwise with the number as a decimal Pascal string built in the
## frame (and the strings at A5 - 0xd08 / - 0xd06, or - 0xd04 / - 0xd02 for a nil message);
## the message is made C again.
func show_caution_alert_with_number(message: int, number: int) -> void:
	_jt(JT_C2PSTR, [C68kScript.u32(message)])
	if (number & 0xffff) == 0:
		_trap(TRAP_PARAM_TEXT, [C68kScript.u32(a5 - 0xd0a), C68kScript.u32(a5 - 0xd0c), _pstr_at(C68kScript.u32(a5 - 0xd0e)), C68kScript.u32(message)])
	else:
		var digits: Array = _decimal_pstring(C68kScript.s16(number))
		if C68kScript.u32(message) != 0:
			_trap(TRAP_PARAM_TEXT, [C68kScript.u32(a5 - 0xd06), C68kScript.u32(a5 - 0xd08), digits, C68kScript.u32(message)])
		else:
			_trap(TRAP_PARAM_TEXT, [C68kScript.u32(a5 - 0xd02), C68kScript.u32(a5 - 0xd04), digits, C68kScript.u32(message)])
	position_alert_template(0x102)
	_trap(TRAP_CAUTION_ALERT, [0, 0x102])
	_jt(JT_P2CSTR, [C68kScript.u32(message)])

## A Pascal string in memory as its bytes (length first): how the stand-ins log a string argument
## whose buffer may be the caller's frame.
func _pstr_at(p: int) -> Array:
	var out: Array = []
	for k in memory.read_u8(p) + 1:
		out.append(memory.read_u8(C68kScript.u32(p + k)))
	return out

## 0x1dd4: once (A5 - 0xd12): dialog 0x8b (GetNewDialog, behind all), placed and shown, waits
## for a click (Button down, then up) and is disposed.
func show_sound_error_dialog_once() -> void:
	if memory.read_u16(C68kScript.u32(a5 - 0xd12)) != 0:
		return
	var dialog: int = C68kScript.u32(_trap(TRAP_GET_NEW_DIALOG, [0xffffffff, 0, 0x8b]))
	position_window_on_screen(dialog)
	_trap(TRAP_SHOW_WINDOW, [dialog])
	_trap(TRAP_DRAW_DIALOG, [dialog])
	while (_trap(TRAP_BUTTON, []) >> 8) & 0xff == 0:
		pass
	_trap(TRAP_DISPOSE_DIALOG, [dialog])
	while (_trap(TRAP_BUTTON, []) >> 8) & 0xff != 0:
		pass
	memory.write_u16(C68kScript.u32(a5 - 0xd12), 1)

## 0x1e32: dialog 0x80 ("creating"), placed, shown and drawn; returns it.
func show_creating_panel_dialog() -> int:
	var dialog: int = C68kScript.u32(_trap(TRAP_GET_NEW_DIALOG, [0xffffffff, 0, 0x80]))
	position_window_on_screen(dialog)
	_trap(TRAP_SHOW_WINDOW, [dialog])
	_trap(TRAP_DRAW_DIALOG, [dialog])
	return dialog

## 0x30fa: menus 1..5 (GetMenu, kept at A5 - 0xc4e .. - 0xc3e) inserted at the end, the desk
## accessories added to menu 1 (AddResMenu 'DRVR'), then DrawMenuBar.
func install_menus() -> void:
	for k in 5:
		var menu: int = C68kScript.u32(_trap(TRAP_GET_MENU, [k + 1]))
		memory.write_u32(C68kScript.u32(a5 - 0xc4e + 4 * k), menu)
		_trap(TRAP_INSERT_MENU, [0, menu])
		if k == 0:
			_trap(TRAP_ADD_RES_MENU, [0x44525652, memory.read_u32(C68kScript.u32(a5 - 0xc4e))])
	_trap(TRAP_DRAW_MENU_BAR, [])

const JT_MAX_MEM: int = 0x21a           ## MaxMem(VAR grow): function result long
const JT_HAS_DEEP_SCREENS: int = 0x2da  ## Pascal Boolean function, no arguments (result in the high byte)
const TRAP_GET_NAMED_RESOURCE: int = 0xa9a1
const TRAP_RELEASE_RESOURCE: int = 0xa9a3
const TRAP_GET_RES_ATTRS: int = 0xa9a6
const TRAP_SET_RES_ATTRS: int = 0xa9a7
const TRAP_CHANGED_RESOURCE: int = 0xa9aa
const TRAP_SET_ENTRY_USAGE: int = 0xaa9e
const TRAP_SET_ENTRY_COLOR: int = 0xaa9c
const TRAP_FRONT_WINDOW: int = 0xa924
const TRAP_GET_GDEVICE: int = 0xaa32
const TRAP_SET_GDEVICE: int = 0xaa31
const TRAP_INDEX_TO_FORE: int = 0xaa97
const TRAP_GET_DEVICE_LIST: int = 0xaa29
const TRAP_GET_MAIN_DEVICE: int = 0xaa2a
const TRAP_GET_NEXT_DEVICE: int = 0xaa2b
const A5_DEVICE_RECORDS: int = -0x136e  ## device records of 0x16: +0 GDHandle, +4 index map (0x200)

## 0x1edc: the 'snd ' resource named `name` into sound slot `slot`: 1 when missing. It is made
## unpurgeable and unlocked; with FreeMem and MaxMem both under 0x3000 it is released again
## (HUnlock, HPurge, ReleaseResource) and 1 returned. Otherwise it is marked purgeable on disk
## (res attribute 0x20, SetResAttrs + ChangedResource, unless already set), stored in the slot
## (A5 - 0xd62) and 0 returned.
func load_named_sound_into_slot(name: int, slot: int) -> int:
	var h: int = C68kScript.u32(_trap(TRAP_GET_NAMED_RESOURCE, [C68kScript.u32(name), 0x736e6420]))
	if h == 0:
		return 1
	_jt(JT_HNOPURGE, [h])
	_jt(JT_HUNLOCK, [h])
	if C68kScript.s32(_jt(JT_FREE_MEM, [])) < 0x3000 and C68kScript.s32(_jt(JT_MAX_MEM, [[]])) < 0x3000:
		_jt(JT_HUNLOCK, [h])
		_jt(JT_HPURGE, [h])
		_trap(TRAP_RELEASE_RESOURCE, [h])
		return 1
	var attrs: int = _trap(TRAP_GET_RES_ATTRS, [h]) & 0xffff
	if (attrs & 0x20) == 0:
		_trap(TRAP_SET_RES_ATTRS, [attrs | 0x20, h])
		_trap(TRAP_CHANGED_RESOURCE, [h])
	memory.write_u32(C68kScript.u32(a5 + A5_SOUND_SLOTS + 4 * C68kScript.s16(slot)), h)
	return 0

## 0x46b4: A5 - 0x102a cleared; depth 1 rebuilds the standard indices only; with a palette depth
## (A5 - 0x2cc) the offscreen port (A5 - 0x103a) is closed and the index maps of devices 1..3
## (A5 - 0x136e records) rebuilt with build_palette_index_map (the count and the reverse map in
## this routine's frame).
func rebuild_all_palette_index_maps() -> void:
	memory.write_u16(C68kScript.u32(a5 - 0x102a), 0)
	if memory.read_s16(C68kScript.u32(a5 - 0x137a)) == 1:
		init_standard_colour_indices()
		return
	if memory.read_u16(C68kScript.u32(a5 - 0x2cc)) == 0:
		return
	var port: int = memory.read_u32(C68kScript.u32(a5 - 0x103a))
	if port != 0:
		close_and_dispose_port(port)
		memory.write_u32(C68kScript.u32(a5 - 0x103a), 0)
	assert(a7 != 0, "rebuild_all_palette_index_maps needs a7 (its frame holds the reverse map)")
	var entry_a7: int = a7
	var a6: int = entry_a7 - 4
	for i in range(1, 4):
		var rec: int = C68kScript.u32(a5 + A5_DEVICE_RECORDS + 0x16 * i)
		if memory.read_u32(rec) == 0:
			continue
		a7 = entry_a7 - 0x21a   # link 0x204, 0xe bytes of arguments, the return address
		build_palette_index_map(i, a6 - 4, memory.read_u32(rec + 4), a6 - 0x204)
		a7 = entry_a7

## 0x4738: the palette entries of the depth: at 4, entries 8..12 courteous (usage 2) with the
## depth-1 / 4 extras (A5 - 0x320) and 0..7 the fixed colours (usage 0, tolerance 0x1000); at 8,
## 0xd0..0xd8 courteous with the depth-8 extras (A5 - 0x302), 0xc8..0xcf courteous with the fixed
## colours and 0..0xc7 animated (usage 4). Other depths do nothing.
func configure_palette_entries(depth: int) -> void:
	var d: int = C68kScript.s16(depth)
	if d == 4:
		var pal4: int = memory.read_u32(C68kScript.u32(a5 - 0x14ae))
		for i in 5:
			_trap(TRAP_SET_ENTRY_USAGE, [0, 2, i + 8, pal4])
			_trap(TRAP_SET_ENTRY_COLOR, [C68kScript.u32(a5 - 0x320 + 6 * i), i + 8, memory.read_u32(C68kScript.u32(a5 - 0x14ae))])
		for i in 8:
			_trap(TRAP_SET_ENTRY_USAGE, [0x1000, 0, i, memory.read_u32(C68kScript.u32(a5 - 0x14ae))])
			_trap(TRAP_SET_ENTRY_COLOR, [C68kScript.u32(a5 - 0x350 + 6 * i), i, memory.read_u32(C68kScript.u32(a5 - 0x14ae))])
	elif d == 8:
		for i in 9:
			_trap(TRAP_SET_ENTRY_USAGE, [0, 2, i + 0xd0, memory.read_u32(C68kScript.u32(a5 - 0x14aa))])
			_trap(TRAP_SET_ENTRY_COLOR, [C68kScript.u32(a5 - 0x302 + 6 * i), i + 0xd0, memory.read_u32(C68kScript.u32(a5 - 0x14aa))])
		for i in 8:
			_trap(TRAP_SET_ENTRY_USAGE, [0, 2, i + 0xc8, memory.read_u32(C68kScript.u32(a5 - 0x14aa))])
			_trap(TRAP_SET_ENTRY_COLOR, [C68kScript.u32(a5 - 0x350 + 6 * i), i + 0xc8, memory.read_u32(C68kScript.u32(a5 - 0x14aa))])
		for i in 0xc8:
			_trap(TRAP_SET_ENTRY_USAGE, [0, 4, i, memory.read_u32(C68kScript.u32(a5 - 0x14aa))])

## 0x48ae: the index map of device record `device` (A5 - 0x136e + 0x16 * device; 0 when it has no
## device): with that device current (GetGDevice / SetGDevice), each palette index 0 .. count - 1
## (count 0xd at palette depth 4, 0xd9 at 8) is made the foreground (the colour index lands in the
## port's +0x52) and recorded both ways: map[i] = colour (map at `map_ptr`), reverse[colour] = i
## (the 256 words at `reverse_ptr`, cleared first). A colour hit twice at palette depth 8 below
## 0xc8 sets A5 - 0x102a, which selects the alternate service (A5 + 0x46a instead of + 0x33a) at
## A5 - 0x1122. *count_ptr = 0 (the start index); returns the count. (FrontWindow is compared with
## the game window into a frame word the routine never reads; the frame word holding the count is
## only set at palette depths 4 and 8.)
func build_palette_index_map(device: int, count_ptr: int, map_ptr: int, reverse_ptr: int) -> int:
	var rec: int = C68kScript.u32(a5 + A5_DEVICE_RECORDS + C68kScript.s32(C68kScript.s16(device) * 0x16))
	if memory.read_u32(rec) == 0:
		return 0
	_trap(TRAP_FRONT_WINDOW, [])
	var saved_device: int = C68kScript.u32(_trap(TRAP_GET_GDEVICE, []))
	_trap(TRAP_SET_GDEVICE, [memory.read_u32(rec)])
	var hits: Array = []
	hits.resize(256)
	hits.fill(0)
	for k in 0x100:
		memory.write_u16(C68kScript.u32(reverse_ptr + 2 * k), 0)
	var palette_depth: int = memory.read_s16(C68kScript.u32(a5 - 0x2cc))
	assert(palette_depth == 4 or palette_depth == 8, "build_palette_index_map: the count is an unset frame word at other palette depths")
	var count: int = 0xd if palette_depth == 4 else 0xd9
	var i: int = 0
	memory.write_u16(count_ptr, i)
	while i < count:
		_trap(TRAP_INDEX_TO_FORE, [i])
		var colour: int = memory.read_s16(memory.read_u32(C68kScript.u32(a5 - 0x160c)) + 0x52)
		memory.write_u16(C68kScript.u32(map_ptr + 2 * i), colour & 0xffff)
		memory.write_u16(C68kScript.u32(reverse_ptr + 2 * colour), i)
		var slot: int = colour & 0xff
		if hits[slot] != 0 and palette_depth == 8 and i < 0xc8:
			memory.write_u16(C68kScript.u32(a5 - 0x102a), 1)
		hits[slot] = (hits[slot] + 1) & 0xffff
		i += 1
	_trap(TRAP_SET_GDEVICE, [saved_device])
	var service: int = 0x46a if memory.read_u16(C68kScript.u32(a5 - 0x102a)) != 0 else 0x33a
	memory.write_u32(C68kScript.u32(a5 - 0x1122), C68kScript.u32(a5 + service))
	return count

## 0x2192: the display records of the main device (GetMainDevice, kept at A5 - 0x1036): the three
## records (A5 - 0x1358 main, - 0x1342 left, - 0x132c right; 0x16 bytes) lose their device; each
## device of GetDeviceList .. GetNextDevice with the main device's top, bottom, width and pixel
## size picks the record for its side, but only the main device itself fills one (as in the
## original): a 0x200-byte index map (NewPtr) when missing, the device, row bytes & 0x1fff, the
## colour flag (0 when the JT $2da test is true, else the device's flags bit 0), "is not
## type 0" (+4 word) and the base address. A5 - 0x1032 is cleared.
func scan_display_devices() -> void:
	var main: int = C68kScript.u32(_trap(TRAP_GET_MAIN_DEVICE, []))
	memory.write_u32(C68kScript.u32(a5 - 0x1036), main)
	var main_rect: int = memory.read_u32(memory.read_u32(memory.read_u32(main) + 0x16)) + 6
	var mtop: int = memory.read_u16(main_rect)
	var mleft: int = memory.read_u16(main_rect + 2)
	var mbottom: int = memory.read_u16(main_rect + 4)
	var mright: int = memory.read_u16(main_rect + 6)
	for off in [-0x132c, -0x1342, -0x1358]:
		memory.write_u32(C68kScript.u32(a5 + off), 0)
	var dev: int = C68kScript.u32(_trap(TRAP_GET_DEVICE_LIST, []))
	while dev != 0:
		var pm: int = memory.read_u32(memory.read_u32(memory.read_u32(dev) + 0x16))
		var top: int = memory.read_u16(pm + 6)
		var left: int = memory.read_u16(pm + 8)
		var bottom: int = memory.read_u16(pm + 10)
		var right: int = memory.read_u16(pm + 12)
		var main_pm: int = memory.read_u32(memory.read_u32(memory.read_u32(memory.read_u32(C68kScript.u32(a5 - 0x1036))) + 0x16))
		if top == mtop and bottom == mbottom and C68kScript.u16(right - left) == C68kScript.u16(mright - mleft) \
				and memory.read_u16(main_pm + 0x20) == memory.read_u16(pm + 0x20):
			var rec: int = 0
			if dev == memory.read_u32(C68kScript.u32(a5 - 0x1036)):
				rec = C68kScript.u32(a5 - 0x1358)
			elif right == mleft:
				rec = C68kScript.u32(a5 - 0x1342)
			elif left == mright:
				rec = C68kScript.u32(a5 - 0x132c)
			if rec != 0 and dev == memory.read_u32(C68kScript.u32(a5 - 0x1036)):
				if memory.read_u32(rec + 4) == 0:
					memory.write_u32(rec + 4, C68kScript.u32(_jt(JT_NEW_PTR, [0x200])))
				memory.write_u32(rec, dev)
				memory.write_u16(rec + 0xe, memory.read_u16(memory.read_u32(memory.read_u32(memory.read_u32(dev) + 0x16)) + 4) & 0x1fff)
				var flag: int = 0
				if (_jt(JT_HAS_DEEP_SCREENS, []) >> 8) & 0xff == 0 and (memory.read_u8(memory.read_u32(dev) + 0x14) & 1) != 0:
					flag = 1
				memory.write_u16(rec + 0x10, flag)
				memory.write_u16(rec + 8, 1 if memory.read_u16(memory.read_u32(dev) + 4) != 0 else 0)
				memory.write_u32(rec + 0xa, memory.read_u32(memory.read_u32(memory.read_u32(memory.read_u32(dev) + 0x16))))
		dev = C68kScript.u32(_trap(TRAP_GET_NEXT_DEVICE, [dev]))
	memory.write_u16(C68kScript.u32(a5 - 0x1032), 0)

const JT_HGET_STATE: int = 0x2d2       ## HGetState(h): SignedByte (bit 7 = locked) in the result word's high byte
const JT_PALETTE_CHANGED: int = 0x182  ## C routine (device handle, new index map)
const TRAP_FILL_POLY: int = 0xa8ca
const TRAP_PAINT_POLY: int = 0xa8c7
const TRAP_FRAME_POLY: int = 0xa8c6
const TRAP_KILL_POLY: int = 0xa8cd
const TRAP_OFFSET_POLY: int = 0xa8ce
const TRAP_RGB_FORE_COLOR: int = 0xaa14
const TRAP_NEW_RGN: int = 0xa8d8
const TRAP_DISPOSE_RGN: int = 0xa8d9
const TRAP_OPEN_RGN: int = 0xa8da
const TRAP_CLOSE_RGN: int = 0xa8db
const TRAP_SET_CLIP: int = 0xa879
const TRAP_GET_CLIP: int = 0xa87a

## 0xfd2: a polygon through `count` 8-byte points (x long, y long; the words drawn are x's low
## word and -y) starting at the last, filled with the colour in `rgb` (bytes 3 / 2 / 1 = red /
## green / blue, each << 8):
## at depth 1 with the RGB-to-pattern pattern (FillPoly), otherwise RGBForeColor + PaintPoly; then
## KillPoly. RGBForeColor gets the frame colour record (red / green / blue words at A6 - 8 .. - 4),
## logged with the loop counter word (A6 - 2) after it.
func paint_polygon_rgb_a5safe(points: int, count: int, rgb: int) -> void:
	assert(a7 != 0, "paint_polygon_rgb_a5safe needs a7 (its frame holds the colour record)")
	var a6: int = a7 - 4
	var world: int = _current_a5()
	var r: int = ((C68kScript.asr32(rgb, 24) & 0xff) << 8) & 0xffff
	var g: int = ((C68kScript.asr32(rgb, 16) & 0xff) << 8) & 0xffff
	var b: int = ((C68kScript.asr32(rgb, 8) & 0xff) << 8) & 0xffff
	memory.write_u16(a6 - 8, r)
	memory.write_u16(a6 - 6, g)
	memory.write_u16(a6 - 4, b)
	var poly: int = C68kScript.u32(_trap(TRAP_OPEN_POLY, []))
	var n: int = C68kScript.s32(count)
	var last: int = C68kScript.u32(points + C68kScript.s32(C68kScript.lsl32(n - 1, 3)))
	_trap(TRAP_MOVE_TO, [C68kScript.u16(-memory.read_u32(last + 4)), memory.read_u16(last + 2)])
	var i: int = 0
	while i < n:
		var p: int = C68kScript.u32(points + 8 * i)
		_trap(TRAP_LINE_TO, [C68kScript.u16(-memory.read_u32(p + 4)), memory.read_u16(p + 2)])
		i = C68kScript.s16(i + 1)
	memory.write_u16(a6 - 2, i & 0xffff)
	_trap(TRAP_CLOSE_POLY, [])
	if memory.read_s16(C68kScript.u32(world - 0x137a)) == 1:
		var pattern: int = _jt(JT_RGB_TO_PATTERN, [r, g, b])
		_trap(TRAP_FILL_POLY, [C68kScript.u32(pattern), poly])
	else:
		_trap(TRAP_RGB_FORE_COLOR, [C68kScript.u32(a6 - 8)])
		_trap(TRAP_PAINT_POLY, [poly])
	_trap(TRAP_KILL_POLY, [poly])

## 0x11ec: the panel's notched frame drawn twice (the second time shifted by the panel width
## A5 - 0x1192 - A5 - 0x119a): polygons of the rect at A5 - 0x119c built with 2 x 2 and 1 x 1
## pens; each pass fills the inner one in colour `colour` (painted when `paint`, else filled with
## the pattern at A5 - 0x14e2) over the back colour (A5 - 0x118c), frames the outer in that colour
## and the inner in A5 - 0x118a, then offsets both; the second pass uses `colour2`. Both polygons
## are killed and the pen pattern set back to black.
func draw_notched_frame_pair_a5safe(paint: int, colour: int, colour2: int) -> void:
	var world: int = _current_a5()
	var saved: int = a5
	a5 = world
	var rect: int = C68kScript.u32(world - 0x119c)
	_trap(TRAP_PEN_SIZE, [2, 2])
	var outer: int = build_notched_frame_poly(memory.read_u16(rect), memory.read_u16(rect + 2), memory.read_u16(rect + 4), memory.read_u16(rect + 6))
	_trap(TRAP_PEN_SIZE, [1, 1])
	var inner: int = build_notched_frame_poly(memory.read_u16(rect), memory.read_u16(rect + 2), memory.read_u16(rect + 4), memory.read_u16(rect + 6))
	_trap(TRAP_PEN_MODE_LONG, [0x21])
	_trap(TRAP_SET_BACK_MODE, [0x1e])
	var c: int = colour
	for k in 2:
		set_draw_color_index(c & 0xffff)
		set_back_color_index(memory.read_u16(C68kScript.u32(world - 0x118c)))
		_trap(TRAP_PEN_SIZE, [1, 1])
		if C68kScript.u32(paint) != 0:
			_trap(TRAP_PAINT_POLY, [inner])
		else:
			_trap(TRAP_FILL_POLY, [C68kScript.u32(world - 0x14e2), inner])
		set_draw_color_index(memory.read_u16(C68kScript.u32(world - 0x118c)))
		_trap(TRAP_PEN_SIZE, [2, 2])
		_trap(TRAP_FRAME_POLY, [outer])
		set_draw_color_index(memory.read_u16(C68kScript.u32(world - 0x118a)))
		_trap(TRAP_PEN_SIZE, [1, 1])
		_trap(TRAP_FRAME_POLY, [inner])
		var dx: int = C68kScript.u16(memory.read_u16(C68kScript.u32(world - 0x1192)) - memory.read_u16(C68kScript.u32(world - 0x119a)))
		_trap(TRAP_OFFSET_POLY, [0, dx, inner])
		_trap(TRAP_OFFSET_POLY, [0, dx, outer])
		c = colour2
	_trap(TRAP_KILL_POLY, [inner])
	_trap(TRAP_KILL_POLY, [outer])
	_trap(TRAP_PEN_PAT, [C68kScript.u32(world - 0x161c)])
	a5 = saved

## 0x1876: the frame image (port A5 - 0x1496 over the image handle A5 - 0x12b0, locked for the
## copy when it was not, HGetState bit 7) blitted onto itself in the current port, clipped to the
## view frame outline region (OpenRgn .. CloseRgn around draw_view_frame_outline; the old clip is
## kept and restored). Row bytes come from the image table (A5 - 0x13b2, record of 0x160 for the
## index at A5 - 0x13ae, word +0xa).
func blit_image_clipped_to_region() -> void:
	var unlock: bool = false
	_trap(TRAP_PEN_SIZE, [1, 1])
	var frame_rgn: int = C68kScript.u32(_trap(TRAP_NEW_RGN, []))
	_trap(TRAP_OPEN_RGN, [])
	draw_view_frame_outline()
	_trap(TRAP_CLOSE_RGN, [frame_rgn])
	var old_clip: int = C68kScript.u32(_trap(TRAP_NEW_RGN, []))
	_trap(TRAP_GET_CLIP, [old_clip])
	_trap(TRAP_SET_CLIP, [frame_rgn])
	var image: int = memory.read_u32(C68kScript.u32(a5 - 0x12b0))
	if ((_jt(JT_HGET_STATE, [image]) >> 8) & 0x80) == 0:
		unlock = true
		_jt(JT_HLOCK, [memory.read_u32(C68kScript.u32(a5 - 0x12b0))])
	_trap(TRAP_PEN_MODE_LONG, [0x21])
	_trap(TRAP_SET_BACK_MODE, [0x1e])
	var port: int = memory.read_u32(C68kScript.u32(a5 - 0x1496))
	memory.write_u32(memory.read_u32(memory.read_u32(port + 2)), memory.read_u32(memory.read_u32(C68kScript.u32(a5 - 0x12b0))))
	var row_rec: int = C68kScript.u32(C68kScript.s32(memory.read_s16(C68kScript.u32(a5 - 0x13ae)) * 0x160) + memory.read_u32(memory.read_u32(C68kScript.u32(a5 - 0x13b2))))
	memory.write_u16(memory.read_u32(memory.read_u32(port + 2)) + 4, memory.read_u16(row_rec + 0xa))
	var current: int = memory.read_u32(C68kScript.u32(a5 - 0x160c))
	_trap(TRAP_COPY_BITS, [0, 0, C68kScript.u32(port + 0x10), C68kScript.u32(port + 0x10), C68kScript.u32(current + 2), C68kScript.u32(port + 2)])
	if unlock:
		_jt(JT_HUNLOCK, [memory.read_u32(C68kScript.u32(a5 - 0x12b0))])
	_trap(TRAP_SET_CLIP, [old_clip])
	_trap(TRAP_DISPOSE_RGN, [frame_rgn])
	_trap(TRAP_DISPOSE_RGN, [old_clip])

## 0x195c: blit_image_clipped_to_region with A5 from CurrentA5.
func blit_image_clipped_to_region_a5safe() -> void:
	var saved: int = a5
	a5 = _current_a5()
	blit_image_clipped_to_region()
	a5 = saved

## 0x4c18: A5 - 0x102a cleared; depth 1 rebuilds the standard indices. Otherwise each device record
## 1..3 (A5 - 0x136e) with a device has its index map rebuilt into this frame and compared from
## the start index with its stored map; on a difference the device is flagged, device 1 reports
## the new map (JT $182 with the main device record's device A5 - 0x1354), and the stored map is
## rebuilt. When any changed and A5 - 0x1006 is set, the service at A5 - 0x1096 is called.
func check_device_color_state_changed() -> void:
	var any_changed: bool = false
	memory.write_u16(C68kScript.u32(a5 - 0x102a), 0)
	if memory.read_s16(C68kScript.u32(a5 - 0x137a)) == 1:
		init_standard_colour_indices()
		return
	assert(a7 != 0, "check_device_color_state_changed needs a7 (its frame holds the new maps)")
	var entry_a7: int = a7
	var a6: int = entry_a7 - 4
	for d in range(1, 4):
		var rec: int = C68kScript.u32(a5 + A5_DEVICE_RECORDS + 0x16 * d)
		if memory.read_u32(rec) == 0:
			continue
		a7 = entry_a7 - 0x40e - 0x12
		var count: int = build_palette_index_map(d, a6 - 4, a6 - 0x20a, a6 - 0x40a)
		a7 = entry_a7
		var changed: bool = false
		var i: int = memory.read_s16(a6 - 4)
		while i < C68kScript.s16(count):
			if memory.read_u16(C68kScript.u32(a6 - 0x20a + 2 * i)) != memory.read_u16(C68kScript.u32(memory.read_u32(rec + 4) + 2 * i)):
				changed = true
				any_changed = true
				break
			i += 1
			memory.write_u16(a6 - 4, i & 0xffff)
		if not changed:
			continue
		if d == 1:
			_jt(JT_PALETTE_CHANGED, [memory.read_u32(C68kScript.u32(a5 - 0x1354)), []])
		a7 = entry_a7 - 0x40e - 0x12
		build_palette_index_map(d, a6 - 4, memory.read_u32(rec + 4), a6 - 0x40a)
		a7 = entry_a7
	if any_changed and memory.read_u32(C68kScript.u32(a5 - 0x1006)) != 0:
		_call_address(memory.read_u32(C68kScript.u32(a5 - 0x1096)), [])

const JT_NEW_HANDLE_CLEAR: int = 0x252  ## NewHandleClear(size): function result long
const JT_MEM_ERROR: int = 0x29a         ## MemError: function result word
const JT_SET_HANDLE_SIZE: int = 0x26a   ## SetHandleSize(h, size)
const TRAP_EXIT_TO_SHELL: int = 0xa9f4

## 0x19e2 (caller's A5): the out-of-memory exit: the frame buffer (A5 - 0x1006) is freed, sound
## shut down, the message at A5 - 0xdd2 shown in a caution alert, then ExitToShell (which does not
## return on the Mac; the stand-in returns to the RTS that follows it).
func fatal_memory_error_exit() -> void:
	var buffer: int = memory.read_u32(C68kScript.u32(a5 - 0x1006))
	if buffer != 0:
		_jt(JT_DISPOSE_PTR, [buffer])
	shutdown_sound()
	show_caution_alert_with_number(memory.read_u32(C68kScript.u32(a5 - 0xdd2)), 0)
	_trap(TRAP_EXIT_TO_SHELL, [])

## 0x19a2: NewHandleClear(size) with A5 from CurrentA5; a Memory Manager error exits the program.
## Returns the handle.
func new_handle_clear_or_die_a5safe(size: int) -> int:
	var saved: int = a5
	a5 = _current_a5()
	var h: int = C68kScript.u32(_jt(JT_NEW_HANDLE_CLEAR, [C68kScript.u32(size)]))
	if (_jt(JT_MEM_ERROR, []) & 0xffff) != 0:
		fatal_memory_error_exit()
	a5 = saved
	return h

## 0x1a28: SetHandleSize(h, size) (a Memory Manager error exits the program), then the block
## locked, cleared (ansi_memset over size bytes) and unlocked. A5 from CurrentA5.
func realloc_and_clear_handle_a5safe(h: int, size: int) -> void:
	var saved: int = a5
	a5 = _current_a5()
	_jt(JT_SET_HANDLE_SIZE, [C68kScript.u32(size), C68kScript.u32(h)])
	if (_jt(JT_MEM_ERROR, []) & 0xffff) != 0:
		fatal_memory_error_exit()
	_jt(JT_HLOCK, [C68kScript.u32(h)])
	ansi_memset(memory.read_u32(C68kScript.u32(h)), 0, size)
	_jt(JT_HUNLOCK, [C68kScript.u32(h)])
	a5 = saved

## 0x1f8e: (re)load the game sounds: the slot table (A5 - 0xd62) recorded at A5 - 0x112a, the old
## slots released, MaxMem / FreeMem asked, then the named sounds loaded (the engine sound in slot 0
## from A5 - 0xd00 with more than 0x2e400 free, else A5 - 0xcf8; then slots 5, 2, 9, 6, 7, 1, 12,
## 11, 10 and 8, slot 8 from A5 - 0xca4 when A5 - 0xcae is missing, which also counts as a
## failure). Any failure shows the sound error dialog once.
func load_game_sounds() -> void:
	memory.write_u32(C68kScript.u32(a5 - 0x112a), C68kScript.u32(a5 + A5_SOUND_SLOTS))
	release_sound_slots()
	var failed: int = 0
	_jt(JT_MAX_MEM, [[]])
	var free: int = C68kScript.s32(_jt(JT_FREE_MEM, []))
	failed |= load_named_sound_into_slot(C68kScript.u32(a5 + (-0xd00 if free > 0x2e400 else -0xcf8)), 0)
	for pair in [[-0xcea, 5], [-0xce6, 2], [-0xce2, 9], [-0xcd0, 6], [-0xcca, 7], [-0xcc4, 1], [-0xcc0, 0xc], [-0xcba, 0xb],
			[-0xcb4, 0xa]]:
		failed |= load_named_sound_into_slot(C68kScript.u32(a5 + pair[0]), pair[1])
	if load_named_sound_into_slot(C68kScript.u32(a5 - 0xcae), 8) != 0:
		failed |= 1
		failed |= load_named_sound_into_slot(C68kScript.u32(a5 - 0xca4), 8)
	if (failed & 0xffff) != 0:
		show_sound_error_dialog_once()

## 0xad0: the view's horizon bands, clipped to the view region (A5 - 0x13b6; the old clip kept and
## restored). With the view origin (A5 - 0x1202 / - 0x1200) and size (- 0x11fe / - 0x11fc): the
## band from the origin to `a` is painted in `upper` (PaintRect of the frame rect); when a <= b
## the sloped band between the horizon heights ya / yb (the low words of the arguments) is painted
## as two polygons (`sky_colour`, `ground_colour`) and the band from b to the far edge in `lower`.
## Only the low words of the long arguments are used; `unused` is never read.
func paint_view_horizon_bands_a5safe(a: int, b: int, _unused: int, upper: int, lower: int, ya: int, yb: int,
		sky_colour: int, ground_colour: int) -> void:
	var world: int = _current_a5()
	var saved: int = a5
	a5 = world
	var old_clip: int = C68kScript.u32(_trap(TRAP_NEW_RGN, []))
	_trap(TRAP_GET_CLIP, [old_clip])
	_trap(TRAP_SET_CLIP, [memory.read_u32(C68kScript.u32(world - 0x13b6))])
	var d7: int = memory.read_s16(C68kScript.u32(world - 0x1202))
	var d6: int = memory.read_u16(C68kScript.u32(world - 0x1200))
	var d4: int = C68kScript.u16(d6 + memory.read_u16(C68kScript.u32(world - 0x11fe)))
	var d5: int = C68kScript.u16(d7 + memory.read_u16(C68kScript.u32(world - 0x11fc)))
	var xa: int = C68kScript.u16(d7 + C68kScript.s32(a))
	var xb: int = C68kScript.u16(d7 + C68kScript.s32(b))
	set_draw_color_index(upper & 0xffff)
	_trap(TRAP_PAINT_RECT, [[((d7 & 0xffff) << 16) | d6, (xa << 16) | d4]])
	if C68kScript.s32(a) <= C68kScript.s32(b):
		var poly: int = C68kScript.u32(_trap(TRAP_OPEN_POLY, []))
		_trap(TRAP_MOVE_TO, [xa, d6])
		_trap(TRAP_LINE_TO, [xa, ya & 0xffff])
		_trap(TRAP_LINE_TO, [xb, yb & 0xffff])
		_trap(TRAP_LINE_TO, [xb, d6])
		_trap(TRAP_LINE_TO, [xa, d6])
		_trap(TRAP_CLOSE_POLY, [])
		set_draw_color_index(sky_colour & 0xffff)
		_trap(TRAP_PAINT_POLY, [poly])
		_trap(TRAP_KILL_POLY, [poly])
		poly = C68kScript.u32(_trap(TRAP_OPEN_POLY, []))
		_trap(TRAP_MOVE_TO, [xa, d4])
		_trap(TRAP_LINE_TO, [xb, d4])
		_trap(TRAP_LINE_TO, [xb, yb & 0xffff])
		_trap(TRAP_LINE_TO, [xa, ya & 0xffff])
		_trap(TRAP_LINE_TO, [xa, d4])
		_trap(TRAP_CLOSE_POLY, [])
		set_draw_color_index(ground_colour & 0xffff)
		_trap(TRAP_PAINT_POLY, [poly])
		_trap(TRAP_KILL_POLY, [poly])
		set_draw_color_index(lower & 0xffff)
		_trap(TRAP_PAINT_RECT, [[(xb << 16) | d6, (d5 << 16) | d4]])
	_trap(TRAP_PEN_PAT, [C68kScript.u32(world - 0x161c)])
	_trap(TRAP_SET_CLIP, [old_clip])
	_trap(TRAP_DISPOSE_RGN, [old_clip])
	a5 = saved

const TRAP_FILL_RECT: int = 0xa8a5
const TRAP_TEXT_FACE: int = 0xa888
const TRAP_CHAR_WIDTH: int = 0xa88d
const TRAP_DRAW_STRING: int = 0xa884
const TRAP_GET_PEN: int = 0xa89a
const TRAP_MOVE: int = 0xa894
const TRAP_DRAW_TEXT: int = 0xa885
const TRAP_CHECK_ITEM: int = 0xa945

## 0x1308: the status line under the view. Laying out (`layout` set): a 1-pixel rule (black
## pattern A5 - 0x161c) and the bar (pattern A5 - 0x1614) across the view width at height - 0x14;
## the four labels (A5 - 0xde2 / - 0xdde / - 0xdda / - 0xdd6, the last skipped when `three`) are
## drawn from x 8 at height - 5 in plain text after measuring '0' in bold, and each column's value
## start (pen h + digit width, A5 - 0x14da + 2 k) and width (5 / 3 / 4 / 4 digits, A5 - 0x14d2 +
## 2 k) recorded, with two digit widths of gap. Otherwise column `column` is cleared and `count`
## characters of `text` from `first` are drawn in bold at its start. GetPen writes the pen point
## into this routine's frame (the port models A7 for it).
func draw_text_in_columns_a5safe(text: int, column: int, first: int, count: int, layout: int, three: int) -> void:
	var world: int = _current_a5()
	assert(a7 != 0, "draw_text_in_columns_a5safe needs a7 (GetPen writes into its frame)")
	var a6: int = a7 - 4
	var height: int = memory.read_u16(C68kScript.u32(world - 0x1370))
	var rect: Array
	if C68kScript.u32(layout) != 0:
		var width: int = memory.read_u16(C68kScript.u32(world - 0x1372))
		var top: int = C68kScript.u16(height - 0x14)
		rect = [top << 16, (C68kScript.u16(top + 1) << 16) | width]
		_trap(TRAP_PEN_MODE_LONG, [0x21])
		_trap(TRAP_SET_BACK_MODE, [0x1e])
		_trap(TRAP_FILL_RECT, [C68kScript.u32(world - 0x161c), rect])
		rect = [C68kScript.u16(height - 0x13) << 16, (height << 16) | width]
		_trap(TRAP_FILL_RECT, [C68kScript.u32(world - 0x1614), rect])
		_trap(TRAP_MOVE_TO, [C68kScript.u16(height - 5), 8])
		_trap(TRAP_TEXT_FACE, [1])
		var digit: int = _trap(TRAP_CHAR_WIDTH, [0x30]) & 0xffff
		_trap(TRAP_TEXT_FACE, [0])
		var labels: Array = [[-0xde2, 5], [-0xdde, 3], [-0xdda, 4], [-0xdd6, 4]]
		for k in 4:
			if k == 3 and C68kScript.u32(three) != 0:
				break
			_trap(TRAP_DRAW_STRING, [memory.read_u32(C68kScript.u32(world + labels[k][0]))])
			_trap(TRAP_GET_PEN, [a6 - 6])
			memory.write_u16(C68kScript.u32(world - 0x14da + 2 * k), C68kScript.u16(memory.read_u16(a6 - 4) + digit))
			var span: int = C68kScript.u16(C68kScript.s16(digit) * labels[k][1])
			memory.write_u16(C68kScript.u32(world - 0x14d2 + 2 * k), span)
			if k < 3:
				_trap(TRAP_MOVE, [0, C68kScript.u16(digit * 2 + span)])
		return
	var start: int = memory.read_u16(C68kScript.u32(world - 0x14da + 2 * C68kScript.s32(column)))
	var right: int = C68kScript.u16(start + memory.read_u16(C68kScript.u32(world - 0x14d2 + 2 * C68kScript.s32(column))))
	rect = [(C68kScript.u16(height - 0x13) << 16) | start, (height << 16) | right]
	_trap(TRAP_PEN_MODE_LONG, [0x21])
	_trap(TRAP_SET_BACK_MODE, [0x1e])
	_trap(TRAP_FILL_RECT, [C68kScript.u32(world - 0x1614), rect])
	_trap(TRAP_TEXT_FACE, [1])
	_trap(TRAP_MOVE_TO, [C68kScript.u16(height - 5), start])
	_trap(TRAP_DRAW_TEXT, [count & 0xffff, first & 0xffff, C68kScript.u32(text)])

## 0x3174: the menus' enabled / checked state from the game state (caller's A5). File menu (A5 -
## 0xc4a): item 7 when playing (A5 - 0x102e, - 0x12f8) and not (paused - 0x12f0 clear with the
## mode - 0x14c4 at 1), item 4 with a frame buffer while playing and in game state 2 / 0 or with
## A5 - 0x12b4 clear, item 8 when playing unpaused, item 9 in state 2 or a state with the mode not
## 1, items 5 / 6 from state 3. Edit menu (A5 - 0xc46): enabled for a desk accessory in front
## (window kind < 0), the whole menu redrawn when that changes (A5 - 0xc3a). Options (A5 - 0xc42)
## and view (A5 - 0xc3e): checks from the settings record (A5 - 0x13ac) and the sound flag (A5 -
## 0x102f), items 8 / 10 / 9 enabled unless a session is busy (A5 - 0x1032 and - 0x12d4), the depth
## items 7 (depth 8) and 11 (depth not 4).
func update_menu_items() -> void:
	var front: int = C68kScript.u32(_trap(TRAP_FRONT_WINDOW, []))
	var kind: int = memory.read_s16(front + 0x6c) if front != 0 else 0
	var da: int = 1 if kind < 0 else 0
	var busy: bool = memory.read_u16(C68kScript.u32(a5 - 0x1032)) != 0 and memory.read_u16(C68kScript.u32(a5 - 0x12d4)) != 0
	var playing: bool = memory.read_u16(C68kScript.u32(a5 - 0x102e)) != 0
	var state: int = memory.read_s16(C68kScript.u32(a5 - 0x12f8))
	var paused: bool = memory.read_u16(C68kScript.u32(a5 - 0x12f0)) != 0
	var mode1: bool = memory.read_s16(C68kScript.u32(a5 - 0x14c4)) == 1
	var file_menu: int = memory.read_u32(C68kScript.u32(a5 - 0xc4a))
	set_menu_item_enabled(file_menu, 7, 1 if playing and state != 0 and (paused or not mode1) else 0)
	var item4: int = 0
	if memory.read_u32(C68kScript.u32(a5 - 0x1006)) != 0 and playing:
		item4 = 1 if state == 2 or state == 0 or memory.read_u16(C68kScript.u32(a5 - 0x12b4)) == 0 else 0
	set_menu_item_enabled(file_menu, 4, item4)
	set_menu_item_enabled(file_menu, 8, 1 if playing and state != 0 and not paused else 0)
	var item9: int = 1 if state == 2 else (0 if state == 0 else (1 if not mode1 else 0))
	set_menu_item_enabled(file_menu, 9, item9)
	set_menu_item_enabled(file_menu, 5, 1 if playing and state >= 3 else 0)
	set_menu_item_enabled(file_menu, 6, 1 if playing and state >= 3 else 0)
	var edit_menu: int = memory.read_u32(C68kScript.u32(a5 - 0xc46))
	if da != memory.read_s16(C68kScript.u32(a5 - 0xc3a)):
		set_menu_item_enabled(edit_menu, 0, da)
		memory.write_u16(C68kScript.u32(a5 - 0xc3a), da)
	for item in [1, 3, 4, 5, 6]:
		set_menu_item_enabled(edit_menu, item, da)
	var settings: int = memory.read_u32(memory.read_u32(C68kScript.u32(a5 - 0x13ac)))
	var options: int = memory.read_u32(C68kScript.u32(a5 - 0xc42))
	_trap(TRAP_CHECK_ITEM, [memory.read_u8(settings + 3), 1, options])
	_trap(TRAP_CHECK_ITEM, [memory.read_u8(settings + 5), 2, options])
	_trap(TRAP_CHECK_ITEM, [memory.read_u8(C68kScript.u32(a5 - 0x102f)), 4, options])
	_trap(TRAP_CHECK_ITEM, [memory.read_u8(settings + 7), 5, options])
	_trap(TRAP_CHECK_ITEM, [memory.read_u8(settings + 9), 6, options])
	for item in [8, 0xa, 9]:
		set_menu_item_enabled(options, item, 0 if busy else 1)
	for pair in [[8, 1], [0xa, 2], [9, 3]]:
		_trap(TRAP_CHECK_ITEM, [1 if memory.read_s16(settings + 0xe) == pair[1] else 0, pair[0], options])
	var view_menu: int = memory.read_u32(C68kScript.u32(a5 - 0xc3e))
	set_menu_item_enabled(view_menu, 7, 1 if memory.read_s16(C68kScript.u32(a5 - 0x137a)) == 8 else 0)
	set_menu_item_enabled(view_menu, 0xb, 1 if memory.read_s16(C68kScript.u32(a5 - 0x137a)) != 4 else 0)
	for k in range(1, 6):
		_trap(TRAP_CHECK_ITEM, [1 if memory.read_s16(settings + 0x10) == k else 0, k, view_menu])
	for pair in [[7, 0x13], [9, 0x15], [8, 0x17], [0xb, 0x1b], [0xa, 0x19]]:
		_trap(TRAP_CHECK_ITEM, [memory.read_u8(settings + pair[1]), pair[0], view_menu])

const TRAP_BEGIN_UPDATE: int = 0xa922
const TRAP_END_UPDATE: int = 0xa923
const TRAP_HIDE_CURSOR: int = 0xa852
const TRAP_SHOW_CURSOR: int = 0xa853
const A5_HOOK_PREPARE: int = -0x1082   ## the overlay's session hooks (code pointers)
const A5_HOOK_START: int = -0x107e
const A5_HOOK_RUN: int = -0x107a       ## (C: two longs)
const A5_HOOK_FINISH: int = -0x1076
const A5_GAME_WINDOW: int = -0x14ca
const LOCAL_SESSION_SETUP: int = 0x95a       ## not exported
const LOCAL_SYNC_SCREEN_GLOBALS: int = 0x4d96 ## not exported: DisposCTable-like refresh of the screen globals
const LOCAL_AFTER_REDRAW: int = 0xa26        ## not exported

## A call to a routine of this segment not ported yet (or not exported), by its segment offset.
func _local(offset: int, args: Array) -> int:
	assert(code_routines.has(offset), "segment routine %x has no stand-in" % offset)
	return code_routines[offset].call(args)

func _hook(slot: int, args: Array = []) -> int:
	return _call_address(memory.read_u32(C68kScript.u32(a5 + slot)), args)

## 0x45a: an overlay session begun: this code's segment unloaded (UnloadSeg A5 + 0xa2), memory and
## sound made ready, the prepare hook, the game sounds loaded, MaxMem when under 100 000 bytes are
## free, the start hook, 0x95a, the sound slots locked.
func begin_overlay_session() -> void:
	assert(a7 != 0, "begin_overlay_session needs a7 (MaxMem's grow is in its frame)")
	var entry: int = a7
	var a6: int = entry - 4
	memory.write_u32(a6 - 4, 0)
	_trap(TRAP_UNLOAD_SEG, [C68kScript.u32(a5 + 0xa2)])
	a7 = entry - 4 - 4 - 4
	ensure_free_memory_and_init_sound()
	a7 = entry
	_hook(A5_HOOK_PREPARE)
	load_game_sounds()
	if C68kScript.s32(_jt(JT_FREE_MEM, [])) < 0x186a0:
		_jt(JT_MAX_MEM, [[]])
	_hook(A5_HOOK_START)
	_local(LOCAL_SESSION_SETUP, [])
	lock_sound_slots()

## 0x4c6: MaxMem when under 500 000 bytes are free; with sound on (A5 - 0x12ee) the sound system
## set up (init_sound_system(0)).
func ensure_free_memory_and_init_sound() -> void:
	assert(a7 != 0, "ensure_free_memory_and_init_sound needs a7 (MaxMem's grow is in its frame)")
	memory.write_u32(a7 - 4 - 4, 0)
	if C68kScript.s32(_jt(JT_FREE_MEM, [])) < 0x7a120:
		_jt(JT_MAX_MEM, [[]])
	if memory.read_u16(C68kScript.u32(a5 - 0x12ee)) != 0:
		init_sound_system(0)

## 0x930 (C, two longs): the overlay's hooks in turn: prepare, start, run(a, b), finish.
func call_overlay_session_hooks(a: int, b: int) -> void:
	_hook(A5_HOOK_PREPARE)
	_hook(A5_HOOK_START)
	_hook(A5_HOOK_RUN, [C68kScript.u32(a), C68kScript.u32(b)])
	_hook(A5_HOOK_FINISH)

## 0x4d34: pending update events (GetNextEvent, update mask) for the game window (A5 - 0x14ca)
## handled: BeginUpdate, redraw_main_window, EndUpdate; stops at the first other or none.
func process_pending_update_events() -> void:
	assert(a7 != 0, "process_pending_update_events needs a7 (the event record is in its frame)")
	var entry: int = a7
	var a6: int = entry - 4
	while (_trap(TRAP_GET_NEXT_EVENT, [a6 - 0x10, 0x40]) >> 8) & 0xff != 0:
		if memory.read_u32(a6 - 0xe) != memory.read_u32(C68kScript.u32(a5 + A5_GAME_WINDOW)):
			return
		_redraw_window_update(entry, 0x10)

func _redraw_window_update(entry: int, locals: int) -> void:
	_trap(TRAP_BEGIN_UPDATE, [memory.read_u32(C68kScript.u32(a5 + A5_GAME_WINDOW))])
	a7 = entry - 4 - locals - 4
	redraw_main_window()
	a7 = entry
	_trap(TRAP_END_UPDATE, [memory.read_u32(C68kScript.u32(a5 + A5_GAME_WINDOW))])

## 0x4d6a (C, the event): an update of the game window, while it is up (A5 - 0x14c6), redrawn.
func handle_update_event(event: int) -> void:
	if memory.read_u16(C68kScript.u32(a5 - 0x14c6)) == 0:
		return
	if memory.read_u32(C68kScript.u32(event + 2)) != memory.read_u32(C68kScript.u32(a5 + A5_GAME_WINDOW)):
		return
	_redraw_window_update(a7, 0)

## 0x4db0: the game window redrawn while it is up with a frame buffer (A5 - 0x1006) in a running game
## (A5 - 0x12f8): A5 - 0x12ea set (its old value to A5 - 0x103c), the cursor hidden, the device
## colours checked, UnloadSeg (A5 + 0x18a), the redraw hook (A5 - 0x109e), the screen globals
## refreshed (0x4d96), the overlay hooks run (0, 1), 0xa26, the cursor shown.
func redraw_main_window() -> void:
	assert(a7 != 0, "redraw_main_window needs a7")
	var entry: int = a7
	var a6: int = entry - 4
	var flag: bool = memory.read_u16(C68kScript.u32(a5 - 0x12d4)) != 0 and memory.read_u16(C68kScript.u32(a5 - 0x1032)) != 0
	memory.write_u16(a6 - 4, 1 if flag else 0)
	if memory.read_u16(C68kScript.u32(a5 - 0x14c6)) == 0 or memory.read_u32(C68kScript.u32(a5 - 0x1006)) == 0 \
			or memory.read_u16(C68kScript.u32(a5 - 0x12f8)) == 0:
		return
	if memory.read_u16(C68kScript.u32(a5 - 0x12ea)) == 0:
		memory.write_u16(C68kScript.u32(a5 - 0x103c), memory.read_u16(C68kScript.u32(a5 - 0x12ea)))
		memory.write_u16(C68kScript.u32(a5 - 0x12ea), 1)
	_trap(TRAP_HIDE_CURSOR, [])
	a7 = entry - 4 - 4 - 4
	check_device_color_state_changed()
	a7 = entry
	_trap(TRAP_UNLOAD_SEG, [C68kScript.u32(a5 + 0x18a)])
	_call_address(memory.read_u32(C68kScript.u32(a5 - 0x109e)), [])
	_local(LOCAL_SYNC_SCREEN_GLOBALS, [])
	call_overlay_session_hooks(0, 1)
	_local(LOCAL_AFTER_REDRAW, [])
	_trap(TRAP_SHOW_CURSOR, [])

const TRAP_HIDE_WINDOW: int = 0xa916
const TRAP_SIZE_WINDOW: int = 0xa91d
const TRAP_NEW_CWINDOW: int = 0xaa45
const TRAP_NEW_PALETTE: int = 0xaa91
const TRAP_SET_ORIGIN: int = 0xa878
const JT_VIEW_BUFFER_1BIT: int = 0x1aa  ## C routine (buffer, count word, 0x7f, width, height): word result, 0 when it failed
const JT_VIEW_BUFFER_COLOUR: int = 0x1b2 ## C routine, no arguments
const JT_VIEW_BUFFER_BASE: int = 0x1d2  ## C routine, no arguments: long result
const LOCAL_CLOSE_OFFSCREEN_PORT: int = 0xd24  ## not exported (C, the port at A5 - 0x103a)
const MBAR_HEIGHT: int = 0xbaa

## The menu-bar shift of the device records (A5 - 0x136e + 0x16 * 1..3, those with a device): their
## base (+0xa) moved by MBarHeight rows of their row bytes (+0xe), down (`sign` 1) or back up (-1).
func _shift_device_bases(mbar: int, sign: int) -> void:
	for i in range(1, 4):
		var rec: int = C68kScript.u32(a5 - 0x136e + 0x16 * i)
		if memory.read_u32(rec) != 0:
			var delta: int = C68kScript.u32(memory.read_s16(rec + 0xe) * C68kScript.s16(mbar))
			memory.write_u32(rec + 0xa, C68kScript.u32(memory.read_u32(rec + 0xa) + sign * delta))

## 0x2334 (C, the screen rect by value: top, left, bottom, right): the game window and view laid out.
## The view width (in the frame at -0xe) is the screen width (A5 - 0x137e) by the size option (the
## settings' +0xe, or 1 for a two-screen session: settings +0x1c and A5 - 0x1032): 1 whole, 2 half,
## 3 three quarters (of the word product), 4 a quarter; ID01's dense switch leaves the frame word
## for any other. The device bases come back up a menu bar when it was skipped (A5 - 0x1028). A
## whole 512-wide view on a screen of 342 less the menu bar skips the menu bar (bases down, the
## height and the rect top grown by it, A5 - 0x1028 set); otherwise the width is rounded down to
## longs of pixels and the height is 480/640 of it, shrunk while it does not fit the rect (in steps
## of four longs when the aspect test fails). An odd height loses a row; the view rect is centred
## (left rounded down to longs), each device's view base (+0x12) its base plus the offset rows and
## the left offset in bytes, A5 - 0x1370 / - 0x1372 the size. The window is made the first time
## (NewCWindow over the rect, invisible, procID 2, in front; NewPalette 13 and 0xd9 configured for
## depth 4 and 8; the palette selected; SetPort) or moved and sized (hidden around it when it was
## visible). The origin is the screen width to the left for a two-screen session with a left
## device, else 0 / 0. The offscreen port is closed; the view buffers rebuilt (JT $1b2, or at depth 1
## JT $1aa then JT $1d2 into A5 - 0x1300, the out-of-memory exit when $1aa fails), with the
## overlay's resize hook (A5 - 0x10a2) in a running game.
func layout_game_window_and_view(top: int, left: int, bottom: int, right: int) -> void:
	assert(a7 != 0, "layout_game_window_and_view needs a7 (NewCWindow's bounds are in its frame)")
	var a6: int = a7 - 4
	var settings: int = memory.read_u32(memory.read_u32(C68kScript.u32(a5 - 0x13ac)))
	var two_screens: bool = memory.read_u16(settings + 0x1c) != 0 and memory.read_u16(C68kScript.u32(a5 - 0x1032)) != 0
	var option: int = 1 if two_screens else memory.read_u16(settings + 0xe)
	var screen_w: int = memory.read_s16(C68kScript.u32(a5 - 0x137e))
	var w: int
	match C68kScript.s16(option):
		1: w = C68kScript.u16(screen_w)
		2: w = C68kScript.u16(screen_w / 2)
		3: w = C68kScript.u16(C68kScript.s16(screen_w * 3) / 4)
		4: w = C68kScript.u16(screen_w / 4)
		_: w = memory.read_u16(a6 - 0xe)
	var mbar: int = memory.read_u16(MBAR_HEIGHT)
	if memory.read_u16(C68kScript.u32(a5 - 0x1028)) != 0:
		_shift_device_bases(mbar, 1)
		memory.write_u16(C68kScript.u32(a5 - 0x137c), memory.read_u16(C68kScript.u32(a5 - 0x137c)) - mbar)
	var h: int = memory.read_u16(C68kScript.u32(a5 - 0x137c))
	var depth: int = memory.read_s16(C68kScript.u32(a5 - 0x137a))
	if C68kScript.s16(option) == 1 and w == 0x200 and C68kScript.u16(0x156 - mbar) == h:
		if memory.read_u16(C68kScript.u32(a5 - 0x1028)) == 0:
			_shift_device_bases(mbar, -1)
			memory.write_u16(C68kScript.u32(a5 - 0x137c), memory.read_u16(C68kScript.u32(a5 - 0x137c)) + mbar)
			memory.write_u16(C68kScript.u32(a5 - 0x1028), 1)
			top = C68kScript.u16(top - mbar)
		h = memory.read_u16(C68kScript.u32(a5 - 0x137c))
	else:
		var step: int = 8 / depth
		w = C68kScript.u16((C68kScript.s16(C68kScript.s16(w) / step) & 0xfffc) * step)
		while true:
			h = C68kScript.u16(C68kScript.s32(C68kScript.u32(C68kScript.s16(w) * 0x1e0)) / 0x280)
			var avail: int = C68kScript.u16(bottom - top)
			if C68kScript.s16(avail) >= C68kScript.s16(h):
				break
			var c: int = C68kScript.u16(C68kScript.s16(C68kScript.u16(C68kScript.s16(w) / 2 + w)) / 2)
			var scaled: int = C68kScript.s32(C68kScript.u32(C68kScript.s16(c) * 0x8d4)) / 0x12c0
			c = C68kScript.u16(C68kScript.s16(avail) / 2 + scaled)
			if C68kScript.s16(c) <= C68kScript.s16(avail):
				h = avail
				break
			w = C68kScript.u16(w - ((8 / depth) << 2))
	if h & 1:
		h = C68kScript.u16(h - 1)
	var vtop: int = C68kScript.u16(C68kScript.s16(top + bottom) / 2 - C68kScript.s16(h) / 2)
	var vbottom: int = C68kScript.u16(vtop + h)
	var vleft: int = C68kScript.u16(C68kScript.s16(left + right) / 2 - C68kScript.s16(w) / 2)
	var step2: int = 8 / depth
	vleft = C68kScript.u16((C68kScript.s16(C68kScript.s16(vleft) / step2) & 0xfffc) * step2)
	var vright: int = C68kScript.u16(vleft + w)
	memory.write_u16(a6 - 8, vtop)
	memory.write_u16(a6 - 6, vleft)
	memory.write_u16(a6 - 4, vbottom)
	memory.write_u16(a6 - 2, vright)
	for i in range(1, 4):
		var rec: int = C68kScript.u32(a5 - 0x136e + 0x16 * i)
		if memory.read_u32(rec) != 0:
			var rows: int = C68kScript.u32(memory.read_s16(rec + 0xe) * C68kScript.s16(vtop - top))
			var bytes: int = C68kScript.s16(C68kScript.s16(vleft - left) / step2)
			memory.write_u32(rec + 0x12, C68kScript.u32(rows + memory.read_u32(rec + 0xa) + bytes))
	memory.write_u16(C68kScript.u32(a5 - 0x1370), h)
	memory.write_u16(C68kScript.u32(a5 - 0x1372), w)
	var window: int = memory.read_u32(C68kScript.u32(a5 - 0x14ca))
	if window == 0:
		window = C68kScript.u32(_trap(TRAP_NEW_CWINDOW, [0, 0, 0xffffffff, 2, 0, _pstr_at(C68kScript.u32(a5 - 0xc92)),
				[memory.read_u32(a6 - 8), memory.read_u32(a6 - 4)], 0]))
		memory.write_u32(C68kScript.u32(a5 - 0x14ca), window)
		memory.write_u32(C68kScript.u32(a5 - 0x14ae), C68kScript.u32(_trap(TRAP_NEW_PALETTE, [0, 0, 0, 0xd])))
		configure_palette_entries(4)
		memory.write_u32(C68kScript.u32(a5 - 0x14aa), C68kScript.u32(_trap(TRAP_NEW_PALETTE, [0, 0, 0, 0xd9])))
		configure_palette_entries(8)
		select_palette_for_depth()
		_trap(TRAP_SET_PORT, [memory.read_u32(C68kScript.u32(a5 - 0x14ca))])
	else:
		var visible: int = C68kScript.s8(memory.read_u8(window + 0x6e))
		if visible != 0:
			_trap(TRAP_HIDE_WINDOW, [window])
		_trap(TRAP_MOVE_WINDOW, [0, vtop, vleft, memory.read_u32(C68kScript.u32(a5 - 0x14ca))])
		_trap(TRAP_SIZE_WINDOW, [1, h, C68kScript.u16(vright - vleft), memory.read_u32(C68kScript.u32(a5 - 0x14ca))])
		select_palette_for_depth()
		if visible != 0:
			_trap(TRAP_SHOW_WINDOW, [memory.read_u32(C68kScript.u32(a5 - 0x14ca))])
	if two_screens and memory.read_u32(C68kScript.u32(a5 - 0x1342)) != 0:
		_trap(TRAP_SET_ORIGIN, [0, C68kScript.u16(-memory.read_u16(C68kScript.u32(a5 - 0x137e)))])
	else:
		_trap(TRAP_SET_ORIGIN, [0, 0])
	var offscreen: int = memory.read_u32(C68kScript.u32(a5 - 0x103a))
	if offscreen != 0:
		_local(LOCAL_CLOSE_OFFSCREEN_PORT, [offscreen])
		memory.write_u32(C68kScript.u32(a5 - 0x103a), 0)
	if memory.read_u16(C68kScript.u32(a5 - 0x137a)) != 1:
		_jt(JT_VIEW_BUFFER_COLOUR, [])
	if memory.read_u32(C68kScript.u32(a5 - 0x10a2)) != 0 and memory.read_u16(C68kScript.u32(a5 - 0x102e)) != 0:
		_hook(-0x10a2)
	if memory.read_u16(C68kScript.u32(a5 - 0x137a)) == 1:
		var ok: int = _jt(JT_VIEW_BUFFER_1BIT, [memory.read_u32(C68kScript.u32(a5 - 0x1346)), memory.read_u16(C68kScript.u32(a5 - 0x134a)),
				0x7f, w, h])
		if (ok & 0xffff) == 0:
			fatal_memory_error_exit()
		memory.write_u32(C68kScript.u32(a5 - 0x1300), C68kScript.u32(_jt(JT_VIEW_BUFFER_BASE, [])))
	else:
		_jt(JT_VIEW_BUFFER_COLOUR, [])

func _depth_supported(depth: int) -> bool:
	return depth == 1 or depth == 4 or depth == 8

func _main_pixmap() -> int:
	return memory.read_u32(memory.read_u32(memory.read_u32(memory.read_u32(C68kScript.u32(a5 - 0x1036))) + 0x16))

## 0x27e4: the display configured from the main device (scan_display_devices). An unsupported depth
## (not 1 / 4 / 8) hides a visible game window (A5 - 0xd10 set), shows the caution alert (message A5 -
## 0xd76), rescans and records the old depth in A5 - 0x137a; still unsupported clears A5 - 0x102e.
## Otherwise a window hidden that way is shown again in a running game, and A5 - 0x102e is set. With
## it set the screen globals come from the pixmap (scenery index - 0x13ae = -1, base, depth, height,
## width, row bytes, the two-screen option from the settings). HasDeepScreens (byte in A5 - 0x1000)
## and the device's flag bit 0 give A5 - 0x1312, then A5 - 0x1000 = 1; the device bases go down a
## menu bar, the height loses it, A5 - 0x1028 is cleared and the window is laid out over (MBarHeight,
## 0, MBarHeight + height, width).
func configure_display_from_main_device() -> void:
	assert(a7 != 0, "configure_display_from_main_device needs a7 (its callee's frame)")
	var entry: int = a7
	scan_display_devices()
	var depth: int = memory.read_u16(_main_pixmap() + 0x20)
	var ok: bool = _depth_supported(depth)
	if not ok:
		var window: int = memory.read_u32(C68kScript.u32(a5 - 0x14ca))
		if window != 0 and memory.read_u8(window + 0x6e) != 0:
			memory.write_u16(C68kScript.u32(a5 - 0xd10), 1)
			_trap(TRAP_HIDE_WINDOW, [memory.read_u32(C68kScript.u32(a5 - 0x14ca))])
		show_caution_alert_with_number(memory.read_u32(C68kScript.u32(a5 - 0xd76)), 0)
		scan_display_devices()
		memory.write_u16(C68kScript.u32(a5 - 0x137a), depth)
		depth = memory.read_u16(_main_pixmap() + 0x20)
		ok = _depth_supported(depth)
		if not ok:
			memory.write_u16(C68kScript.u32(a5 - 0x102e), 0)
	if ok:
		if memory.read_u16(C68kScript.u32(a5 - 0xd10)) != 0 and memory.read_u32(C68kScript.u32(a5 - 0x14ca)) != 0 \
				and memory.read_u16(C68kScript.u32(a5 - 0x12f8)) != 0:
			_trap(TRAP_SHOW_WINDOW, [memory.read_u32(C68kScript.u32(a5 - 0x14ca))])
		memory.write_u16(C68kScript.u32(a5 - 0xd10), 0)
		memory.write_u16(C68kScript.u32(a5 - 0x102e), 1)
	if memory.read_u16(C68kScript.u32(a5 - 0x102e)) != 0:
		memory.write_u16(C68kScript.u32(a5 - 0x13ae), 0xffff)
		var pm: int = _main_pixmap()
		memory.write_u32(C68kScript.u32(a5 - 0x1386), memory.read_u32(pm))
		memory.write_u16(C68kScript.u32(a5 - 0x137a), memory.read_u16(pm + 0x20))
		pm = _main_pixmap()
		memory.write_u16(C68kScript.u32(a5 - 0x137c), C68kScript.u16(memory.read_u16(pm + 0xa) - memory.read_u16(pm + 6)))
		memory.write_u16(C68kScript.u32(a5 - 0x137e), C68kScript.u16(memory.read_u16(pm + 0xc) - memory.read_u16(pm + 8)))
		memory.write_u16(C68kScript.u32(a5 - 0x1378), memory.read_u16(_main_pixmap() + 4) & 0x1fff)
		memory.write_u16(C68kScript.u32(a5 - 0x12d4), memory.read_u16(memory.read_u32(memory.read_u32(C68kScript.u32(a5 - 0x13ac))) + 0x1c))
	var deep: int = (_jt(JT_HAS_DEEP_SCREENS, []) >> 8) & 0xff
	memory.write_u8(C68kScript.u32(a5 - 0x1000), deep)
	var flag: bool = deep == 0 and (memory.read_u8(memory.read_u32(memory.read_u32(C68kScript.u32(a5 - 0x1036))) + 0x14) & 1) != 0
	memory.write_u16(C68kScript.u32(a5 - 0x1312), 1 if flag else 0)
	memory.write_u8(C68kScript.u32(a5 - 0x1000), 1)
	var mbar: int = memory.read_u16(MBAR_HEIGHT)
	_shift_device_bases(mbar, 1)
	memory.write_u16(C68kScript.u32(a5 - 0x137c), C68kScript.u16(memory.read_u16(C68kScript.u32(a5 - 0x137c)) - mbar))
	memory.write_u16(C68kScript.u32(a5 - 0x1028), 0)
	a7 = entry - 0x30
	layout_game_window_and_view(mbar, 0, C68kScript.u16(mbar + memory.read_u16(C68kScript.u32(a5 - 0x137c))),
			memory.read_u16(C68kScript.u32(a5 - 0x137e)))
	a7 = entry

## 0x2a44: the settings (handle A5 - 0x13ac) copied to the live options: sound (+2), +4, the drawn-
## once flag (+0xc, also A5 - 0x103c). A change of any of +0x10 / +0x18 / +8 / +0x14 with a frame
## buffer (A5 - 0x1006) runs the overlay's hook A5 - 0x1092, of +0x16 the hook A5 - 0x104e, and at
## depth 8 of +0x12 the hook A5 - 0x1096 (+0x1a copied; at other depths both cleared). The rest are
## copied (+0x22, +0x24, +6, +0x1c, +0xa) and the window redrawn when a hook ran.
func apply_settings_to_live_options() -> void:
	assert(a7 != 0, "apply_settings_to_live_options needs a7 (its callee's frame)")
	var entry: int = a7
	var changed: bool = false
	var s: Callable = func(off: int) -> int:
		return memory.read_u16(memory.read_u32(memory.read_u32(C68kScript.u32(a5 - 0x13ac))) + off)
	var g: Callable = func(off: int) -> int:
		return memory.read_u16(C68kScript.u32(a5 + off))
	var put: Callable = func(off: int, v: int) -> void:
		memory.write_u16(C68kScript.u32(a5 + off), v)
	put.call(-0x12ee, s.call(2))
	put.call(-0x12ec, s.call(4))
	var drawn: int = s.call(0xc)
	put.call(-0x12ea, drawn)
	put.call(-0x103c, drawn)
	var old: Array = [g.call(-0x12e0), g.call(-0x12d8), g.call(-0x12e6), g.call(-0x12dc)]
	put.call(-0x12e0, s.call(0x10))
	put.call(-0x12d8, s.call(0x18))
	put.call(-0x12e6, s.call(8))
	put.call(-0x12dc, s.call(0x14))
	var buffer: bool = memory.read_u32(C68kScript.u32(a5 - 0x1006)) != 0
	if (g.call(-0x12e0) != old[0] or g.call(-0x12d8) != old[1] or g.call(-0x12e6) != old[2] or g.call(-0x12dc) != old[3]) and buffer:
		_hook(-0x1092)
		changed = true
	var prev: int = g.call(-0x12da)
	put.call(-0x12da, s.call(0x16))
	if prev != g.call(-0x12da) and memory.read_u32(C68kScript.u32(a5 - 0x1006)) != 0:
		_hook(-0x104e)
		changed = true
	if g.call(-0x137a) == 8:
		prev = g.call(-0x12de)
		put.call(-0x12de, s.call(0x12))
		if g.call(-0x12de) != prev and memory.read_u32(C68kScript.u32(a5 - 0x1006)) != 0:
			_hook(-0x1096)
			changed = true
		put.call(-0x12d6, s.call(0x1a))
	else:
		put.call(-0x12de, 0)
		put.call(-0x12d6, 0)
	put.call(-0x12d2, s.call(0x22))
	put.call(-0x12d0, s.call(0x24))
	put.call(-0x12e8, s.call(6))
	put.call(-0x12d4, s.call(0x1c))
	put.call(-0x12e4, s.call(0xa))
	if changed:
		a7 = entry - 0x12
		redraw_main_window()
		a7 = entry

const TRAP_SYSTEM_TASK: int = 0xa9b4
const TRAP_SYSTEM_CLICK: int = 0xa9b3
const TRAP_FIND_WINDOW: int = 0xa92c
const TRAP_MENU_SELECT: int = 0xa93d
const TRAP_MENU_KEY: int = 0xa93e
const TRAP_TRACK_GO_AWAY: int = 0xa91e
const TRAP_HILITE_MENU: int = 0xa938
const TRAP_NEW_WINDOW: int = 0xa913
const TRAP_TEXT_FONT: int = 0xa887
const TRAP_TICK_COUNT: int = 0xa975
const JT_GET_PTR_SIZE: int = 0x242    ## GetPtrSize: Pascal, function result long
const JT_IDLE_HOOK: int = 0x172       ## C routine, no arguments
const LOCAL_SYNC_OVERLAY_GLOBALS: int = 0x4d24  ## not exported

## The EventRecord in a frame at `at` as handle_activate_event's arguments (what, message, when,
## where, modifiers).
func _activate_from_frame(at: int) -> void:
	handle_activate_event(memory.read_u16(at), memory.read_u32(at + 2), memory.read_u32(at + 6), memory.read_u32(at + 0xa),
			memory.read_u16(at + 0xe))

## 0x29f2: a new main device (GetMainDevice against A5 - 0x1036) is rescanned; a depth that no longer
## matches A5 - 0x137a reconfigures the display, reapplies the settings, syncs the overlay globals
## (0x4d24, not exported) and, in a running game with a frame buffer and the window up, runs the
## overlay's depth hook (A5 - 0x1096).
func refresh_display_if_changed() -> void:
	assert(a7 != 0, "refresh_display_if_changed needs a7 (its callees' frames)")
	var entry: int = a7
	if C68kScript.u32(_trap(TRAP_GET_MAIN_DEVICE, [])) != memory.read_u32(C68kScript.u32(a5 - 0x1036)):
		scan_display_devices()
	if memory.read_u16(C68kScript.u32(a5 - 0x137a)) == memory.read_u16(_main_pixmap() + 0x20):
		return
	a7 = entry - 0xc
	configure_display_from_main_device()
	a7 = entry - 0xc
	apply_settings_to_live_options()
	a7 = entry
	_local(LOCAL_SYNC_OVERLAY_GLOBALS, [])
	if memory.read_u16(C68kScript.u32(a5 - 0x102e)) != 0 and memory.read_u32(C68kScript.u32(a5 - 0x1006)) != 0 \
			and memory.read_u16(C68kScript.u32(a5 - 0x14c6)) != 0:
		_hook(-0x1096)

## 0x212a: the overlay's state reset: its bss (after code and data: A5 - 0x1006 + - 0x1022 + -
## 0x101e, A5 - 0x101a bytes) and the block A5 - 0x1040 (GetPtrSize long) cleared with memset, its
## entry (A5 - 0x1006 + - 0x1012) called with (A5 - 0x1388, TickCount), then the overlay globals
## synced (0x4d24, not exported) and the settings applied.
func reset_overlay_state() -> void:
	assert(a7 != 0, "reset_overlay_state needs a7 (its callee's frame)")
	var entry: int = a7
	var g: Callable = func(off: int) -> int: return memory.read_u32(C68kScript.u32(a5 + off))
	ansi_memset(C68kScript.u32(g.call(-0x1006) + g.call(-0x1022) + g.call(-0x101e)), 0, g.call(-0x101a))
	ansi_memset(g.call(-0x1040), 0, C68kScript.u32(_jt(JT_GET_PTR_SIZE, [g.call(-0x1040)])))
	var target: int = C68kScript.u32(g.call(-0x1006) + g.call(-0x1012))
	var ticks: int = C68kScript.u32(_trap(TRAP_TICK_COUNT, []))
	_call_address(target, [C68kScript.u32(a5 - 0x1388), ticks])
	_local(LOCAL_SYNC_OVERLAY_GLOBALS, [])
	a7 = entry - 0xc
	apply_settings_to_live_options()
	a7 = entry

## 0x35bc (C, the option word): a new view-size option (settings +0xe) is stored and the display
## reconfigured.
func set_view_size_option(option: int) -> void:
	assert(a7 != 0, "set_view_size_option needs a7 (its callee's frame)")
	var entry: int = a7
	var settings: int = memory.read_u32(memory.read_u32(C68kScript.u32(a5 - 0x13ac)))
	if memory.read_u16(settings + 0xe) == (option & 0xffff):
		return
	memory.write_u16(memory.read_u32(memory.read_u32(C68kScript.u32(a5 - 0x13ac))) + 0xe, option & 0xffff)
	a7 = entry - 8
	configure_display_from_main_device()
	a7 = entry

## 0x2db8: SystemTask and GetNextEvent(every event) into the frame, the display refreshed, until a
## mouse-down, key-down or auto-key (ID01's dense switch on 1..8). Updates of the game window (while
## it is up) are redrawn between BeginUpdate / EndUpdate; activates go to handle_activate_event.
func wait_for_click_or_key() -> void:
	assert(a7 != 0, "wait_for_click_or_key needs a7 (the event record is in its frame)")
	var entry: int = a7
	var a6: int = entry - 4
	while true:
		_trap(TRAP_SYSTEM_TASK, [])
		var got: int = C68kScript.s8((_trap(TRAP_GET_NEXT_EVENT, [a6 - 0x12, 0xffff]) >> 8) & 0xff)
		a7 = entry - 0x1a
		refresh_display_if_changed()
		a7 = entry
		if got == 0:
			continue
		match C68kScript.s16(memory.read_u16(a6 - 0x12)):
			1, 3, 5:
				return
			6:
				if memory.read_u16(C68kScript.u32(a5 - 0x14c6)) != 0 \
						and memory.read_u32(a6 - 0x10) == memory.read_u32(C68kScript.u32(a5 + A5_GAME_WINDOW)):
					_redraw_window_update(entry, 0x12)
			8:
				_activate_from_frame(a6 - 0x12)

## 0x2e36: the resource-file error box: a window (NewWindow over SetRect 0x98 / 0x3c / 0x164 / 0x84,
## title A5 - 0xc50, visible, procID 1, in front) with the two messages (Pascal strings at A5 -
## 0xd72 / - 0xd6e) drawn in the system font at 4 / 20 and 4 / 40, until the button is down.
func show_resource_file_error_box() -> void:
	assert(a7 != 0, "show_resource_file_error_box needs a7 (its rect is in its frame)")
	var a6: int = a7 - 4
	_trap(TRAP_SET_RECT, [0x84, 0x164, 0x3c, 0x98, a6 - 8])
	var window: int = C68kScript.u32(_trap(TRAP_NEW_WINDOW, [0, 0, 0xffffffff, 1, 1, _pstr_at(C68kScript.u32(a5 - 0xc50)), a6 - 8, 0]))
	_trap(TRAP_SET_PORT, [window])
	_trap(TRAP_TEXT_FONT, [0])
	_trap(TRAP_MOVE_TO, [0x14, 4])
	_trap(TRAP_DRAW_STRING, [_pstr_at(memory.read_u32(C68kScript.u32(a5 - 0xd72)))])
	_trap(TRAP_MOVE_TO, [0x28, 4])
	_trap(TRAP_DRAW_STRING, [_pstr_at(memory.read_u32(C68kScript.u32(a5 - 0xd6e)))])
	while (_trap(TRAP_BUTTON, []) >> 8) & 0xff == 0:
		pass

## 0x2f1e (C, the EventRecord pointer): a mouse-down by FindWindow part (ID01's dense switch on
## 1..6): the menu bar runs MenuSelect's choice through do_menu_command, a system window
## gets SystemClick, the game window's close box (TrackGoAway) hides it.
func handle_mouse_down(event: int) -> void:
	assert(a7 != 0, "handle_mouse_down needs a7 (FindWindow's window is in its frame)")
	var a6: int = a7 - 4
	var part: int = _trap(TRAP_FIND_WINDOW, [a6 - 4, memory.read_u32(C68kScript.u32(event + 0xa))])
	match C68kScript.s16(part):
		1:
			var choice: int = C68kScript.u32(_trap(TRAP_MENU_SELECT, [memory.read_u32(C68kScript.u32(event + 0xa))]))
			var entry: int = a7
			a7 = entry - 0x12
			do_menu_command(choice)
			a7 = entry
		2:
			_trap(TRAP_SYSTEM_CLICK, [memory.read_u32(a6 - 4), C68kScript.u32(event)])
		6:
			var window: int = memory.read_u32(C68kScript.u32(a5 + A5_GAME_WINDOW))
			if memory.read_u32(a6 - 4) == window:
				if (_trap(TRAP_TRACK_GO_AWAY, [memory.read_u32(C68kScript.u32(event + 0xa)), window]) >> 8) & 0xff != 0:
					_trap(TRAP_HIDE_WINDOW, [memory.read_u32(C68kScript.u32(a5 + A5_GAME_WINDOW))])

## 0x2fd4: one pass of the application's event loop: HiliteMenu(0), SystemTask, the menus updated,
## the JT $172 idle routine, GetNextEvent(every event) into the frame and the display refreshed.
## Then by kind (ID01's dense switch on 1..8): mouse-down to handle_mouse_down, a command key
## (modifiers bit 8) through MenuKey(character) to do_menu_command, an update of the game window
## (after another refresh) redrawn while it is up, an activate to handle_activate_event.
func poll_and_dispatch_event() -> void:
	assert(a7 != 0, "poll_and_dispatch_event needs a7 (the event record is in its frame)")
	var entry: int = a7
	var a6: int = entry - 4
	_trap(TRAP_HILITE_MENU, [0])
	_trap(TRAP_SYSTEM_TASK, [])
	update_menu_items()
	_jt(JT_IDLE_HOOK, [])
	var got: int = C68kScript.s8((_trap(TRAP_GET_NEXT_EVENT, [a6 - 0x12, 0xffff]) >> 8) & 0xff)
	a7 = entry - 0x1a
	refresh_display_if_changed()
	a7 = entry
	if got == 0:
		return
	match C68kScript.s16(memory.read_u16(a6 - 0x12)):
		1:
			a7 = entry - 0x1e
			handle_mouse_down(a6 - 0x12)
			a7 = entry
		3, 5:
			if (memory.read_u16(a6 - 4) & 0x100) != 0:
				var ch: int = C68kScript.u16(C68kScript.s8(memory.read_u32(a6 - 0x10) & 0xff))
				var choice: int = C68kScript.u32(_trap(TRAP_MENU_KEY, [ch]))
				a7 = entry - 0x1e
				do_menu_command(choice)
				a7 = entry
		6:
			a7 = entry - 0x1a
			refresh_display_if_changed()
			a7 = entry
			if memory.read_u16(C68kScript.u32(a5 - 0x14c6)) != 0 \
					and memory.read_u32(a6 - 0x10) == memory.read_u32(C68kScript.u32(a5 + A5_GAME_WINDOW)):
				_redraw_window_update(entry, 0x12)
		8:
			_activate_from_frame(a6 - 0x12)

const TRAP_HI_WORD: int = 0xa86a
const TRAP_LO_WORD: int = 0xa86b
const TRAP_GET_PORT: int = 0xa874
const TRAP_GET_ITEM: int = 0xa946
const TRAP_OPEN_DESK_ACC: int = 0xa9b6
const TRAP_SYSTEM_EDIT: int = 0xa9c2
const TRAP_SYS_BEEP: int = 0xa9c8
const JT_MISSION_READY: int = 0x132     ## C routine, no arguments: word result, 0 when no mission can start
const JT_MISSION_CHECK: int = 0x82      ## C routine, no arguments: word result, 0 to stay
const JT_ABOUT_BOX: int = 0x162         ## C routine, no arguments
const JT_FILE_NEW: int = 0x1da          ## C routine, no arguments (File item 1)
const JT_CONCLUDE_MISSION: int = 0xda   ## C routine (message long, mode word): word result
const JT_FILE_ITEM_6: int = 0x10a       ## C routine, no arguments
const JT_SAVE_CHANGES: int = 0x13a      ## C routine, no arguments: word result, 2 to close
const JT_FILE_ITEM_11: int = 0x102      ## C routine, no arguments
const LOCAL_SAVE_SETTINGS: int = 0x2da0         ## not exported: the settings resource written when changed
const LOCAL_QUIT_APPLICATION: int = 0x2eaa      ## not exported: quit_application

## 0x35e4: a new mission when the JT $132 and JT $82 checks allow it: the overlay's mission hook
## (A5 - 0x109a) with the game flag (A5 - 0x12f8, sign-extended), the game window's port rect
## invalidated while it is up (the port A5 - 0x160c restored), pause (A5 - 0x12f0) and the twelve
## counters at A5 - 0x13a2 / - 0x12ce cleared with A5 - 0x12b4 / - 0x12b6 / - 0x12b2 / - 0x14c4 /
## - 0x14c2 / - 0x14c0, the 1-bit hook A5 - 0x1096 in a running game with a frame buffer and the
## window up, then run_flight_session.
func start_new_mission() -> void:
	if (_jt(JT_MISSION_READY, []) & 0xffff) == 0:
		return
	if (_jt(JT_MISSION_CHECK, []) & 0xffff) == 0:
		return
	_hook(-0x109a, [C68kScript.u32(memory.read_s16(C68kScript.u32(a5 - 0x12f8)))])
	if memory.read_u16(C68kScript.u32(a5 - 0x14c6)) != 0:
		var saved: int = memory.read_u32(C68kScript.u32(a5 - 0x160c))
		_trap(TRAP_SET_PORT, [memory.read_u32(C68kScript.u32(a5 + A5_GAME_WINDOW))])
		_trap(TRAP_INVAL_RECT, [C68kScript.u32(memory.read_u32(C68kScript.u32(a5 + A5_GAME_WINDOW)) + 0x10)])
		_trap(TRAP_SET_PORT, [saved])
	memory.write_u16(C68kScript.u32(a5 - 0x12f0), 0)
	for i in 0xc:
		memory.write_u16(C68kScript.u32(a5 - 0x13a2 + 2 * i), 0)
		memory.write_u16(C68kScript.u32(a5 - 0x12ce + 2 * i), 0)
	for off in [-0x12b4, -0x12b6, -0x12b2, -0x14c4, -0x14c2, -0x14c0]:
		memory.write_u16(C68kScript.u32(a5 + off), 0)
	if memory.read_u16(C68kScript.u32(a5 - 0x102e)) != 0 and memory.read_u32(C68kScript.u32(a5 - 0x1006)) != 0 \
			and memory.read_u16(C68kScript.u32(a5 - 0x137a)) == 1 and memory.read_u16(C68kScript.u32(a5 - 0x14c6)) != 0:
		_hook(-0x1096)
	assert(a7 != 0, "start_new_mission needs a7 (run_flight_session's frame)")
	var entry: int = a7
	a7 = entry - 0xa - 4
	run_flight_session()
	a7 = entry

## Bit 0 of the settings byte at `offset` toggled and the settings marked changed (A5 - 0x138a).
func _toggle_setting(offset: int) -> void:
	var at: int = memory.read_u32(memory.read_u32(C68kScript.u32(a5 - 0x13ac))) + offset
	memory.write_u8(at, memory.read_u8(at) ^ 1)
	memory.write_u16(C68kScript.u32(a5 - 0x138a), 1)

## 0x36a2 (C, MenuSelect's long): the menu (HiWord) and item (LoWord) through ID01's dense switches.
## Apple (1): item 1 the About box (JT $162), others the desk accessory of that name (GetItem of
## A5 - 0xc4e into the frame, OpenDeskAcc, the port kept). File (2): 1 JT $1da and the two sound
## segments unloaded, 2 the settings saved (0x2da0), 4 start_new_mission, 5 JT $da(A5 - 0xd6a, 3), 6
## JT $10a, 7 run_flight_session, 8 the same paused, 9 JT $13a closing the game window on 2, 11 JT
## $102, 13 quit (0x2eaa). Edit (3): SystemEdit(item - 1), a beep when not taken. Options (4): bit 0
## of settings +3 / +5 / +7 / +9 toggled, A5 - 0x102f's flipped, view size 1 / 3 / 2. Detail (5): 1..5
## into settings +0x10, bit 0 of +0x13 / +0x17 / +0x15 / +0x19 / +0x1b toggled. The settings are
## marked changed (A5 - 0x138a) where set, and always applied at the end.
func do_menu_command(choice: int) -> void:
	assert(a7 != 0, "do_menu_command needs a7 (GetPort and the item name are in its frame)")
	var entry: int = a7
	var a6: int = entry - 4
	var menu: int = C68kScript.s16(_trap(TRAP_HI_WORD, [C68kScript.u32(choice)]))
	var item: int = C68kScript.s16(_trap(TRAP_LO_WORD, [C68kScript.u32(choice)]))
	var settings: int = memory.read_u32(memory.read_u32(C68kScript.u32(a5 - 0x13ac)))
	match menu:
		1:
			if item == 1:
				_jt(JT_ABOUT_BOX, [])
			else:
				_trap(TRAP_GET_PORT, [a6 - 0x108])
				_trap(TRAP_GET_ITEM, [a6 - 0x104, C68kScript.u16(item), memory.read_u32(C68kScript.u32(a5 - 0xc4e))])
				_trap(TRAP_OPEN_DESK_ACC, [a6 - 0x104])
				_trap(TRAP_SET_PORT, [memory.read_u32(a6 - 0x108)])
		2:
			match item:
				1:
					_jt(JT_FILE_NEW, [])
					_trap(TRAP_UNLOAD_SEG, [C68kScript.u32(a5 + 0x1ea)])
					_trap(TRAP_UNLOAD_SEG, [C68kScript.u32(a5 + 0x56a)])
				2:
					_local(LOCAL_SAVE_SETTINGS, [])
				4:
					a7 = entry - 0x114
					start_new_mission()
					a7 = entry
				5:
					_jt(JT_CONCLUDE_MISSION, [3, memory.read_u32(C68kScript.u32(a5 - 0xd6a))])
				6:
					_jt(JT_FILE_ITEM_6, [])
				7:
					a7 = entry - 0x114
					run_flight_session()
					a7 = entry
				8:
					memory.write_u16(C68kScript.u32(a5 - 0x12f0), 1)
					a7 = entry - 0x114
					run_flight_session()
					a7 = entry
				9:
					if (_jt(JT_SAVE_CHANGES, []) & 0xffff) == 2:
						memory.write_u16(C68kScript.u32(a5 - 0x12f8), 0)
						_trap(TRAP_HIDE_WINDOW, [memory.read_u32(C68kScript.u32(a5 + A5_GAME_WINDOW))])
						memory.write_u16(C68kScript.u32(a5 - 0x14c6), 0)
				11:
					_jt(JT_FILE_ITEM_11, [])
				13:
					_local(LOCAL_QUIT_APPLICATION, [])
		3:
			if (_trap(TRAP_SYSTEM_EDIT, [C68kScript.u16(item - 1)]) >> 8) & 0xff == 0:
				_trap(TRAP_SYS_BEEP, [5])
		4:
			match item:
				1: _toggle_setting(3)
				2: _toggle_setting(5)
				4:
					var at: int = C68kScript.u32(a5 - 0x102f)
					memory.write_u8(at, memory.read_u8(at) ^ 1)
				5: _toggle_setting(7)
				6: _toggle_setting(9)
				8, 9, 10:
					a7 = entry - 0x116
					set_view_size_option({8: 1, 9: 3, 10: 2}[item])
					a7 = entry
					memory.write_u16(C68kScript.u32(a5 - 0x138a), 1)
		5:
			match item:
				1, 2, 3, 4, 5:
					memory.write_u16(settings + 0x10, item)
					memory.write_u16(C68kScript.u32(a5 - 0x138a), 1)
				7: _toggle_setting(0x13)
				8: _toggle_setting(0x17)
				9: _toggle_setting(0x15)
				10: _toggle_setting(0x19)
				11: _toggle_setting(0x1b)
	a7 = entry - 0x114
	apply_settings_to_live_options()
	a7 = entry

const VBL_A5_SLOT_UNROLLED: int = 0x39c4
const VBL_A5_SLOT_VARIANT: int = 0x3aca
const VBL_A5_SLOT_TWO_CHANNEL: int = 0x3be0
const SOUND_FRAME: int = 0x172   ## samples per VBL frame (370)
const TRAP_SND_NEW_CHANNEL: int = 0xa807

## A VBL handler's entry: the first call stores CurrentA5 in its code slot and returns (-1 here);
## later calls return that A5.
func _vbl_world(slot: int) -> int:
	assert(code_base != 0, "the VBL sound handlers need code_base")
	var at: int = C68kScript.u32(code_base + slot)
	if memory.read_u32(at) == 0:
		memory.write_u32(at, memory.read_u32(LM_CURRENT_A5))
		return -1
	return memory.read_u32(at)

## Channel 0's resampling state as the handlers keep it in registers.
class _Voice:
	var node: int
	var pos: int
	var frac: int
	var sample: int
	var end: int

func _voice(world: int) -> _Voice:
	var v := _Voice.new()
	v.node = memory.read_u32(C68kScript.u32(world + A5_SOUND_CHANNELS))
	v.pos = memory.read_u32(v.node)
	v.frac = memory.read_u32(v.node + 4)
	v.sample = memory.read_u32(v.node + 8)
	v.end = memory.read_u32(v.node + 0x10)
	return v

## One source byte (the sample base indexed by the position long), then the step: the fraction
## (ADD.L) carries into the position (ADDX.L).
func _voice_byte(world: int, v: _Voice) -> int:
	var b: int = memory.read_u8(C68kScript.u32(v.sample + v.pos))
	var sum: int = v.frac + memory.read_u32(C68kScript.u32(world + A5_RATE_STEP_FRAC))
	v.frac = C68kScript.u32(sum)
	v.pos = C68kScript.u32(v.pos + memory.read_u32(C68kScript.u32(world + A5_RATE_STEP_INT)) + (1 if sum > 0xffffffff else 0))
	return b

## At or past the node's end (signed), the next node (+0x18) becomes channel 0's: its sample, loop
## start (+0xc) with fraction 0, and end.
func _voice_wrap(world: int, v: _Voice) -> void:
	if C68kScript.s32(v.end) > C68kScript.s32(v.pos):
		return
	v.node = memory.read_u32(v.node + 0x18)
	v.sample = memory.read_u32(v.node + 8)
	v.pos = memory.read_u32(v.node + 0xc)
	v.frac = 0
	v.end = memory.read_u32(v.node + 0x10)
	memory.write_u32(C68kScript.u32(world + A5_SOUND_CHANNELS), v.node)

## The k-th sample's place in the sound buffer: 368 from SoundBase + 4, the last 2 at SoundBase.
func _sound_slot(k: int) -> int:
	var base: int = memory.read_u32(LM_SOUND_BASE)
	return C68kScript.u32(base + 4 + 2 * k) if k < 0x170 else C68kScript.u32(base + 2 * (k - 0x170))

## Whether the frame fits in the node: end - position (signed) above A5 - 0xc2a.
func _voice_fast(world: int, v: _Voice) -> bool:
	return C68kScript.s32(v.end - v.pos) > C68kScript.s32(memory.read_u32(C68kScript.u32(world + A5_RATE_FRAME_SPAN)))

func _voice_store(v: _Voice) -> void:
	memory.write_u32(v.node, v.pos)
	memory.write_u32(v.node + 4, v.frac)

## 0x39a8 (a VBL task, all registers kept): channel 0 resampled into the sound buffer, 370 samples:
## while the frame fits in the node without checks (four per loop pass), else each sample after the
## end test (_voice_wrap); the position / fraction stored back, then the previous sound hook (A5 -
## 0xc36) runs, as the handler returns through it.
func vbl_sound_handler_ch0_unrolled() -> void:
	var world: int = _vbl_world(VBL_A5_SLOT_UNROLLED)
	if world == -1:
		return
	var chain: int = memory.read_u32(C68kScript.u32(world - 0xc36))
	var v: _Voice = _voice(world)
	var fast: bool = _voice_fast(world, v)
	for k in SOUND_FRAME:
		if not fast:
			_voice_wrap(world, v)
		memory.write_u8(_sound_slot(k), _voice_byte(world, v))
	_voice_store(v)
	_call_address(chain, [])

## 0x3aae (a VBL task): as vbl_sound_handler_ch0_unrolled, but a frame that fits is copied straight
## (370 bytes from the position, longs through MOVEP after an odd byte; the position advanced by
## 370, the fraction register reused for those longs, so the last one is stored as the fraction).
func vbl_sound_handler_ch0_variant() -> void:
	var world: int = _vbl_world(VBL_A5_SLOT_VARIANT)
	if world == -1:
		return
	var chain: int = memory.read_u32(C68kScript.u32(world - 0xc36))
	var v: _Voice = _voice(world)
	if _voice_fast(world, v):
		var src: int = C68kScript.u32(v.sample + v.pos)
		for k in SOUND_FRAME:
			memory.write_u8(_sound_slot(k), memory.read_u8(C68kScript.u32(src + k)))
		v.pos = C68kScript.u32(v.pos + SOUND_FRAME)
		# D1 carried the MOVEP longs: the stored fraction is the last one read.
		v.frac = memory.read_u32(C68kScript.u32(src + (0x169 if (src & 1) != 0 else 0x16c)))
	else:
		for k in SOUND_FRAME:
			_voice_wrap(world, v)
			memory.write_u8(_sound_slot(k), _voice_byte(world, v))
	_voice_store(v)
	_call_address(chain, [])

## 0x3bc4 (a VBL task): channel 0 resampled as in vbl_sound_handler_ch0_unrolled, each sample mixed
## with channel 1's next byte (its node at A5 - 0x598 played straight from its position) as the low
## byte of a + b - 0x80. Channel 1's position moves 370 on; at or past its end (signed) its next node
## (+0x18) takes over from its loop start, and reaching the silence buffer (A5 - 0xc26) puts the
## single-channel handler (A5 - 0x360) back in the sound hook. Then the previous hook runs.
func vbl_sound_handler_two_channel() -> void:
	var world: int = _vbl_world(VBL_A5_SLOT_TWO_CHANNEL)
	if world == -1:
		return
	var chain: int = memory.read_u32(C68kScript.u32(world - 0xc36))
	var other: int = memory.read_u32(C68kScript.u32(world - 0x598))
	var opos: int = memory.read_u32(other)
	var src: int = C68kScript.u32(memory.read_u32(other + 8) + opos)
	opos = C68kScript.u32(opos + SOUND_FRAME)
	var v: _Voice = _voice(world)
	var fast: bool = _voice_fast(world, v)
	for k in SOUND_FRAME:
		if not fast:
			_voice_wrap(world, v)
		var a: int = _voice_byte(world, v)
		memory.write_u8(_sound_slot(k), (a + memory.read_u8(C68kScript.u32(src + k)) - 0x80) & 0xff)
	_voice_store(v)
	if C68kScript.s32(opos) >= C68kScript.s32(memory.read_u32(other + 0x10)):
		other = memory.read_u32(other + 0x18)
		opos = memory.read_u32(other + 0xc)
		memory.write_u32(C68kScript.u32(world - 0x598), other)
		if memory.read_u32(other + 8) == C68kScript.u32(world + A5_SILENCE_BUFFER):
			memory.write_u32(LM_SOUND_HOOK, memory.read_u32(C68kScript.u32(world - 0x360)))
	memory.write_u32(other, opos)
	_call_address(chain, [])

## 0x3dd0 (C, a long): the sound system (re)started: shut down first when ready; each channel's
## nineteen nodes (0x1c apart from record +8) linked through +0x14 with the playing, free and first
## pointers (+0, +4, +0x230) at the first; 0x456 bytes of silence at A5 - 0xc26 and the buffer
## silenced; rate 1.0 (A5 - 0xc32 = 1, - 0xc2e = 0, frame span 0x172); a silence node on each
## channel. The single-channel handler (A5 - 0x360) is slot $412 when `flag` is set, else $41a; the
## two-channel one slot $422 (A5 - 0x35c). The first time (A5 - 0x352) the three handlers are
## called once so they record A5. The sound hook's old value goes to A5 - 0xc36, the handler in;
## SndNewChannel(A5 - 0x356, sampled synth 5, 0, nil). Returns 1 (and sets the ready flag) when it
## succeeded, else 0.
func init_sound_system(flag: int) -> int:
	if memory.read_u16(C68kScript.u32(a5 + A5_SOUND_READY)) != 0:
		shutdown_sound()
	for ch in 2:
		var rec: int = _channel_record(a5, ch)
		var first: int = C68kScript.u32(rec + 8)
		memory.write_u32(rec + 0x230, first)
		memory.write_u32(rec + 4, first)
		memory.write_u32(rec, first)
		for i in 0x13:
			memory.write_u32(C68kScript.u32(rec + i * 0x1c + 0x1c), C68kScript.u32(rec + (i + 1) * 0x1c + 8))
	for k in 0x456:
		memory.write_u8(C68kScript.u32(a5 + A5_SILENCE_BUFFER + k), 0x80)
	clear_sound_buffer_to_silence()
	memory.write_u32(C68kScript.u32(a5 + A5_RATE_STEP_INT), 1)
	memory.write_u32(C68kScript.u32(a5 + A5_RATE_STEP_FRAC), 0)
	memory.write_u32(C68kScript.u32(a5 + A5_RATE_FRAME_SPAN), SOUND_FRAME)
	alloc_sound_buffer_node(0, C68kScript.u32(a5 + A5_SILENCE_BUFFER), 0, SOUND_FRAME, 0)
	alloc_sound_buffer_node(1, C68kScript.u32(a5 + A5_SILENCE_BUFFER), 0, SOUND_FRAME, 0)
	memory.write_u32(C68kScript.u32(a5 - 0x360), C68kScript.u32(a5 + (0x412 if C68kScript.u32(flag) != 0 else 0x41a)))
	memory.write_u32(C68kScript.u32(a5 + A5_TWO_CHANNEL_HANDLER), C68kScript.u32(a5 + 0x422))
	if memory.read_u16(C68kScript.u32(a5 - 0x352)) == 0:
		memory.write_u16(C68kScript.u32(a5 - 0x352), 1)
		vbl_sound_handler_ch0_variant()
		vbl_sound_handler_ch0_unrolled()
		vbl_sound_handler_two_channel()
	memory.write_u32(C68kScript.u32(a5 - 0xc36), memory.read_u32(LM_SOUND_HOOK))
	memory.write_u32(LM_SOUND_HOOK, memory.read_u32(C68kScript.u32(a5 - 0x360)))
	memory.write_u32(C68kScript.u32(a5 - 0x356), 0)
	if (_trap(TRAP_SND_NEW_CHANNEL, [0, 0, 5, C68kScript.u32(a5 - 0x356)]) & 0xffff) != 0:
		return 0
	memory.write_u16(C68kScript.u32(a5 + A5_SOUND_READY), 1)
	return 1

const JT_MORE_MASTERS: int = 0x222     ## C routine, no arguments
const JT_INIT_STEP: int = 0x292        ## C routine, no arguments (called twice)
const JT_FLUSH_EVENTS: int = 0x202     ## FlushEvents(whichMask, stopMask): Pascal
const JT_EVENT_GLUE: int = 0x1fa       ## Pascal (word): the ID09 event glue
const JT_INIT_TOOLS: int = 0x592       ## C routine, no arguments
const JT_CHECK_SYSTEM: int = 0xf2      ## C routine, no arguments: word result, 0 to quit
const JT_SYS_ENVIRONS: int = 0x1f2     ## SysEnvirons(version, VAR rec): Pascal, word result
const JT_GET_SETTINGS_FLAG: int = 0x1e2 ## C routine, no arguments: word result
const TRAP_CUR_RES_FILE: int = 0xa994
const TRAP_INIT_GRAF: int = 0xa86e
const TRAP_INIT_FONTS: int = 0xa8fe
const TRAP_INIT_WINDOWS: int = 0xa912
const TRAP_INIT_MENUS: int = 0xa930
const TRAP_TE_INIT: int = 0xa9cc
const TRAP_INIT_DIALOGS: int = 0xa97b
const TRAP_INIT_CURSOR: int = 0xa850
const TRAP_GET_CTSEED: int = 0xaa28
const TRAP_ADD_RESOURCE: int = 0xa9ab
const TRAP_WRITE_RESOURCE: int = 0xa9b0
const TRAP_LOAD_RESOURCE: int = 0xa9a2
const RES_MENU: int = 0x4d454e55       ## 'MENU'
const RES_HEL1: int = 0x48454c31       ## 'HEL1'
const LOCAL_MAIN_SETUP: int = 0x1b42   ## not exported

## A settings resource ('HEL1' `id`) into A5 + `slot`: loaded when present, else a new handle of
## `size` added (named by the Pascal string at A5 + `name`), passed to `fill`, marked changed and
## written.
func _settings_resource(slot: int, id: int, size: int, name: int, fill: Callable) -> void:
	var h: int = C68kScript.u32(_trap(TRAP_GET_RESOURCE, [id, RES_HEL1]))
	memory.write_u32(C68kScript.u32(a5 + slot), h)
	if h != 0:
		_trap(TRAP_LOAD_RESOURCE, [memory.read_u32(C68kScript.u32(a5 + slot))])
		return
	memory.write_u32(C68kScript.u32(a5 + slot), C68kScript.u32(_jt(JT_NEW_HANDLE_CLEAR, [size])))
	_trap(TRAP_ADD_RESOURCE, [C68kScript.u32(a5 + name), id, RES_HEL1, memory.read_u32(C68kScript.u32(a5 + slot))])
	fill.call()
	_trap(TRAP_CHANGED_RESOURCE, [memory.read_u32(C68kScript.u32(a5 + slot))])
	_trap(TRAP_WRITE_RESOURCE, [memory.read_u32(C68kScript.u32(a5 + slot))])

## 0x2bbc: the application set up: JT $222 and twice JT $292, the resource file (CurResFile into A5
## - 0x1002), the Toolbox managers (InitGraf on A5 - 0x160c, fonts, FlushEvents(all, 0), windows,
## menus, TextEdit, dialogs, cursor), the ID09 event glue(-1), JT $592, its segment unloaded, JT $f2
## (0: ExitToShell). SysEnvirons(1) in the frame gives Color QuickDraw (A5 - 0x1388) and a 68020 /
## 68030 (A5 - 0x1387); with colour the devices are scanned and a colour table header made (NewPtr
## 0x6d8: GetCTSeed, flags 0x8000; A5 - 0x14b2 and - 0x1316). Without MENU 2 a beep, the resource
## error box and quit (0x2eaa, not exported). The settings 'HEL1' 127 (0x12a bytes: options 2 / 1,
## +0x24 = 2, +0x26 = 1, the name copied from A5 - 0xc78 to +0x2a) and 'HEL1' 128 (0x500 bytes, A5 -
## 0x13a8) are made when missing; then the display is configured and the game window's port set.
func initialize_application() -> void:
	assert(a7 != 0, "initialize_application needs a7 (SysEnvirons' record is in its frame)")
	var entry: int = a7
	var a6: int = entry - 4
	_jt(JT_MORE_MASTERS, [])
	for i in 2:
		memory.write_u16(a6 - 2, i)
		_jt(JT_INIT_STEP, [])
	memory.write_u16(a6 - 2, 2)
	memory.write_u16(C68kScript.u32(a5 - 0x1002), _trap(TRAP_CUR_RES_FILE, []) & 0xffff)
	_trap(TRAP_INIT_GRAF, [C68kScript.u32(a5 - 0x160c)])
	_trap(TRAP_INIT_FONTS, [])
	_jt(JT_FLUSH_EVENTS, [0, 0xffff])
	_trap(TRAP_INIT_WINDOWS, [])
	_trap(TRAP_INIT_MENUS, [])
	_trap(TRAP_TE_INIT, [])
	_trap(TRAP_INIT_DIALOGS, [0])
	_trap(TRAP_INIT_CURSOR, [])
	_jt(JT_EVENT_GLUE, [0xffff])
	_jt(JT_INIT_TOOLS, [])
	_trap(TRAP_UNLOAD_SEG, [C68kScript.u32(a5 + 0x58a)])
	if (_jt(JT_CHECK_SYSTEM, []) & 0xffff) == 0:
		_trap(TRAP_EXIT_TO_SHELL, [])
	_jt(JT_SYS_ENVIRONS, [a6 - 0x1e, 1])
	memory.write_u8(C68kScript.u32(a5 - 0x1388), memory.read_u8(a6 - 0x15))
	var cpu: int = memory.read_u16(a6 - 0x18)
	memory.write_u8(C68kScript.u32(a5 - 0x1387), 1 if cpu == 1 or cpu == 2 else 0)
	if memory.read_u8(C68kScript.u32(a5 - 0x1388)) != 0:
		scan_display_devices()
		memory.write_u32(C68kScript.u32(a5 - 0x14b2), C68kScript.u32(_jt(JT_NEW_PTR, [0x6d8])))
		var seed: int = C68kScript.u32(_trap(TRAP_GET_CTSEED, []))
		memory.write_u32(memory.read_u32(C68kScript.u32(a5 - 0x14b2)), seed)
		memory.write_u16(memory.read_u32(C68kScript.u32(a5 - 0x14b2)) + 4, 0x8000)
		memory.write_u32(C68kScript.u32(a5 - 0x1316), memory.read_u32(C68kScript.u32(a5 - 0x14b2)))
	if C68kScript.u32(_trap(TRAP_GET_RESOURCE, [2, RES_MENU])) == 0:
		_trap(TRAP_SYS_BEEP, [0x14])
		a7 = entry - 0x26
		show_resource_file_error_box()
		a7 = entry
		_local(LOCAL_QUIT_APPLICATION, [])
	_settings_resource(-0x13ac, 0x7f, 0x12a, -0xc90, func() -> void:
		var put: Callable = func(off: int, v: int) -> void:
			memory.write_u16(memory.read_u32(memory.read_u32(C68kScript.u32(a5 - 0x13ac))) + off, v)
		put.call(0x10, 2)
		put.call(0xe, 1)
		put.call(0x24, 2)
		put.call(0x26, 1)
		copy_pascal_string(C68kScript.u32(a5 - 0xc78), memory.read_u32(memory.read_u32(C68kScript.u32(a5 - 0x13ac))) + 0x2a))
	_settings_resource(-0x13a8, 0x80, 0x500, -0xc66, func() -> void: pass)
	a7 = entry - 0x26
	configure_display_from_main_device()
	a7 = entry
	_trap(TRAP_SET_PORT, [memory.read_u32(C68kScript.u32(a5 + A5_GAME_WINDOW))])

## The passes of main's event loop a harness lets run before main returns (the original never
## returns: -1 keeps it so).
var event_loop_passes: int = -1

## 0x309a: the program: A5 - 0x13ae = -1, initialize_application, its segment unloaded, MaxMem
## (grow in the frame), the unexported set-up 0x1b42, A5 - 0x14c4 = 1, JT $1e2's flag, the two sound
## segments unloaded, the menus installed, a new mission at once when the flag and A5 - 0x102e are
## set, then poll_and_dispatch_event for ever.
func main() -> void:
	assert(a7 != 0, "main needs a7 (MaxMem's grow is in its frame)")
	var entry: int = a7
	var a6: int = entry - 4
	memory.write_u32(a6 - 6, 0)
	memory.write_u16(C68kScript.u32(a5 - 0x13ae), 0xffff)
	a7 = entry - 0xe
	initialize_application()
	a7 = entry
	_trap(TRAP_UNLOAD_SEG, [C68kScript.u32(a5 + 0xa2)])
	_jt(JT_MAX_MEM, [[]])
	_local(LOCAL_MAIN_SETUP, [])
	memory.write_u16(C68kScript.u32(a5 - 0x14c4), 1)
	var flag: int = _jt(JT_GET_SETTINGS_FLAG, []) & 0xffff
	memory.write_u16(a6 - 2, flag)
	_trap(TRAP_UNLOAD_SEG, [C68kScript.u32(a5 + 0x1ea)])
	_trap(TRAP_UNLOAD_SEG, [C68kScript.u32(a5 + 0x56a)])
	install_menus()
	if flag != 0 and memory.read_u16(C68kScript.u32(a5 - 0x102e)) != 0:
		a7 = entry - 0xe
		start_new_mission()
		a7 = entry
	while event_loop_passes != 0:
		if event_loop_passes > 0:
			event_loop_passes -= 1
		a7 = entry - 0xe
		poll_and_dispatch_event()
		a7 = entry

const TRAP_SELECT_WINDOW: int = 0xa91f
const TRAP_GET_MOUSE: int = 0xa972
const TRAP_UPDATE_RES_FILE: int = 0xa999
const JT_SESSION_CLEANUP: int = 0x9a    ## C routine, no arguments
const JT_SHOW_PAUSED_DIALOG: int = 0x122 ## C routine, no arguments
const LOCAL_END_OVERLAY_SESSION: int = 0x4a4  ## not exported: end_overlay_session
const FLIGHT_KEYS_MASK: int = 0x18      ## keyDown | keyUp
const FLIGHT_OTHER_EVENTS_MASK: int = 0xffe7

## The pilot's roster record: 'HEL1' 128 (A5 - 0x13a8) + 0x40 * the pilot (A5 - 0x13a4, signed).
func _pilot_record() -> int:
	return C68kScript.u32(memory.read_u32(memory.read_u32(C68kScript.u32(a5 - 0x13a8))) + (memory.read_s16(C68kScript.u32(a5 - 0x13a4)) << 6))

## The overlay's key hook (A5 - 0x106a) with (character, what) longs: its word result.
func _key_hook(ch: int, what: int) -> int:
	return _hook(-0x106a, [C68kScript.u32(ch), C68kScript.u32(what)]) & 0xffff

## A setting changed during flight: applied with the window marked down (A5 - 0x14c6) around it.
func _apply_in_flight(entry: int) -> void:
	memory.write_u16(C68kScript.u32(a5 - 0x14c6), 0)
	a7 = entry - 0x30
	apply_settings_to_live_options()
	a7 = entry
	memory.write_u16(C68kScript.u32(a5 - 0x14c6), 1)

## 0x4fc: a flight. Set-up (also the restart point): HiliteMenu(0), the screen base / row bytes /
## flag copied (A5 - 0x1346 / - 0x134a / - 0x1348 into - 0x1382 / - 0x1378 / - 0x1312), SetGDevice on
## the main device, run_segment3_entry_and_unload_a5safe, the window shown (or selected with its
## updates processed), begin_overlay_session, HideCursor, the drawn-once flags reset together, the
## ID09 event glue(-7) and the overlay's pilot hook (A5 - 0x106e) with the pilot record's +0x22, the
## start ticks and frame counters. Each frame (at least 4 ticks after the last, A5 - 0x1044): the mouse
## (GetMouse in the frame; a move stored with the vertical offset by half the menu bar) and button,
## then one key event: a command key-up through ID01's sparse switch (T: A5 - 0x102f's bit 0; 1..5:
## the detail setting; Q: result 5; S: sound toggled around the session; E: settings +5's bit 0),
## then, still without a result, the key hook (A5 - 0x106a) with (0, 0); a plain key goes to the hook
## with (character, what), no key to the hook with (0, 0). Every other event pending: updates and
## activates handled around the session (ID01's dense switch on 6..8). With A5 - 0x1030 the hook A5 -
## 0x1086 may ask for the key hook (twice when the first answers 0); the step hook (A5 - 0x107a) runs
## with (1, 1) and, without a result, the frame count (A5 - 0x14fc) goes up. The end: the session
## closed, the screen globals synced (0x4d96), the glue(-1), InitCursor, the pilot status (A5 -
## 0x12b4) written back to the roster when it changed (ChangedResource, UpdateResFile), then by the
## result's low byte (dense switch on -1..10): 1 and 6..10 conclude the mission (JT $da with A5 -
## 0xde6) and, when it answers 3, restart (9 at once; else JT $9a and the hook A5 - 0x108e, then 1 at
## once, others after the hook A5 - 0x108a and a redraw); 2 restarts after JT $9a and A5 - 0x108e; 4
## after the paused dialog (JT $122); 5 quits (0x2eaa); the rest return.
func run_flight_session() -> void:
	assert(a7 != 0, "run_flight_session needs a7 (its event record and mouse point are in its frame)")
	var entry: int = a7
	var a6: int = entry - 4
	var event: int = a6 - 0x22
	memory.write_u32(a6 - 0xe, 0)
	var two: bool = memory.read_u16(C68kScript.u32(a5 - 0x12d4)) != 0 and memory.read_u16(C68kScript.u32(a5 - 0x1032)) != 0
	memory.write_u16(a6 - 0x24, 1 if two else 0)
	while true:
		_trap(TRAP_HILITE_MENU, [0])
		memory.write_u32(C68kScript.u32(a5 - 0x1382), memory.read_u32(C68kScript.u32(a5 - 0x1346)))
		memory.write_u16(C68kScript.u32(a5 - 0x1378), memory.read_u16(C68kScript.u32(a5 - 0x134a)))
		memory.write_u16(C68kScript.u32(a5 - 0x1312), memory.read_u16(C68kScript.u32(a5 - 0x1348)))
		_trap(TRAP_SET_GDEVICE, [memory.read_u32(C68kScript.u32(a5 - 0x1036))])
		run_segment3_entry_and_unload_a5safe()
		if memory.read_u16(C68kScript.u32(a5 - 0x14c6)) == 0:
			_trap(TRAP_SHOW_WINDOW, [memory.read_u32(C68kScript.u32(a5 + A5_GAME_WINDOW))])
			memory.write_u16(C68kScript.u32(a5 - 0x14c6), 1)
		else:
			_trap(TRAP_SELECT_WINDOW, [memory.read_u32(C68kScript.u32(a5 + A5_GAME_WINDOW))])
			a7 = entry - 0x30
			process_pending_update_events()
			a7 = entry
		a7 = entry - 0x30
		begin_overlay_session()
		a7 = entry
		_trap(TRAP_HIDE_CURSOR, [])
		_reset_drawn_once()
		memory.write_u16(C68kScript.u32(a5 - 0x1046), 0)
		_jt(JT_EVENT_GLUE, [0xfff9])
		_hook(-0x106e, [C68kScript.u32(memory.read_s16(_pilot_record() + 0x22))])
		memory.write_u32(C68kScript.u32(a5 - 0x1504), C68kScript.u32(_trap(TRAP_TICK_COUNT, [])))
		memory.write_u32(C68kScript.u32(a5 - 0x14fc), 0)
		memory.write_u32(C68kScript.u32(a5 - 0x1500), 0)
		var result: int = 0
		memory.write_u16(a6 - 0xa, 0)
		var half_bar: int = C68kScript.u16(C68kScript.s16(memory.read_u16(LM_MBAR_HEIGHT)) / 2)
		memory.write_u16(a6 - 4, half_bar)
		while true:
			while C68kScript.s32(C68kScript.u32(_trap(TRAP_TICK_COUNT, [])) - memory.read_u32(C68kScript.u32(a5 - 0x1044))) < 4:
				pass
			memory.write_u32(C68kScript.u32(a5 - 0x1044), C68kScript.u32(_trap(TRAP_TICK_COUNT, [])))
			_trap(TRAP_GET_MOUSE, [a6 - 0x28])
			if memory.read_u16(a6 - 0x26) != memory.read_u16(C68kScript.u32(a5 - 0x14f6)) \
					or memory.read_u16(a6 - 0x28) != memory.read_u16(C68kScript.u32(a5 - 0x14f8)):
				memory.write_u32(C68kScript.u32(a5 - 0x14f8), memory.read_u32(a6 - 0x28))
				memory.write_u16(C68kScript.u32(a5 - 0x104a), memory.read_u16(a6 - 0x26))
				memory.write_u16(C68kScript.u32(a5 - 0x1048), C68kScript.u16(memory.read_u16(a6 - 0x28) + half_bar))
			memory.write_u16(C68kScript.u32(a5 - 0x1046), C68kScript.u16(C68kScript.s8((_trap(TRAP_BUTTON, []) >> 8) & 0xff)))
			if (_trap(TRAP_GET_NEXT_EVENT, [event, FLIGHT_KEYS_MASK]) >> 8) & 0xff != 0:
				if (memory.read_u16(a6 - 0x14) & 0x100) != 0:
					if memory.read_u16(event) == 4:
						result = _flight_command_key(entry, memory.read_u32(event + 2) & 0xff, result)
						if result == 0:
							result = _key_hook(0, 0)
					else:
						result = _key_hook(0, 0)
				else:
					result = _key_hook(memory.read_u32(event + 2) & 0xff, memory.read_s16(event))
			else:
				result = _key_hook(0, 0)
			memory.write_u16(a6 - 0xa, result)
			while (_trap(TRAP_GET_NEXT_EVENT, [event, FLIGHT_OTHER_EVENTS_MASK]) >> 8) & 0xff != 0:
				match memory.read_s16(event):
					6:
						_local(LOCAL_END_OVERLAY_SESSION, [])
						a7 = entry - 0x34
						handle_update_event(event)
						a7 = entry
						_reset_drawn_once()
						_trap(TRAP_HIDE_CURSOR, [])
						a7 = entry - 0x30
						begin_overlay_session()
						a7 = entry
					8:
						_local(LOCAL_END_OVERLAY_SESSION, [])
						_activate_from_frame(event)
						a7 = entry - 0x30
						begin_overlay_session()
						a7 = entry
			if memory.read_u16(C68kScript.u32(a5 - 0x1030)) != 0 and _hook(-0x1086) != 0:
				if result == 0:
					result = _key_hook(0, 0)
				if result == 0:
					result = _key_hook(0, 0)
				memory.write_u16(a6 - 0xa, result)
			_hook(-0x107a, [1, 1])
			if result != 0:
				break
			memory.write_u32(C68kScript.u32(a5 - 0x14fc), C68kScript.u32(memory.read_u32(C68kScript.u32(a5 - 0x14fc)) + 1))
		_local(LOCAL_END_OVERLAY_SESSION, [])
		_local(LOCAL_SYNC_SCREEN_GLOBALS, [])
		_jt(JT_EVENT_GLUE, [0xffff])
		_trap(TRAP_INIT_CURSOR, [])
		if memory.read_u16(_pilot_record() + 0x20) != memory.read_u16(C68kScript.u32(a5 - 0x12b4)):
			memory.write_u16(_pilot_record() + 0x20, memory.read_u16(C68kScript.u32(a5 - 0x12b4)))
			_trap(TRAP_CHANGED_RESOURCE, [memory.read_u32(C68kScript.u32(a5 - 0x13a8))])
			_trap(TRAP_UPDATE_RES_FILE, [memory.read_u16(C68kScript.u32(a5 - 0x1002))])
		var low: int = result & 0xff
		match low:
			1, 6, 7, 8, 9, 10:
				if (_jt(JT_CONCLUDE_MISSION, [result, memory.read_u32(C68kScript.u32(a5 - 0xde6))]) & 0xffff) != 3:
					return
				if low == 9:
					continue
				_jt(JT_SESSION_CLEANUP, [])
				_hook(-0x108e)
				if low == 1:
					continue
				_hook(-0x108a)
				a7 = entry - 0x30
				redraw_main_window()
				a7 = entry
			2:
				_jt(JT_SESSION_CLEANUP, [])
				_hook(-0x108e)
			4:
				_jt(JT_SHOW_PAUSED_DIALOG, [])
			5:
				_local(LOCAL_QUIT_APPLICATION, [])
				return
			_:
				return

## Both drawn-once flags (A5 - 0x103c and - 0x12ea) cleared when the first is clear and the second set.
func _reset_drawn_once() -> void:
	if memory.read_u16(C68kScript.u32(a5 - 0x103c)) == 0 and memory.read_u16(C68kScript.u32(a5 - 0x12ea)) != 0:
		memory.write_u16(C68kScript.u32(a5 - 0x103c), 0)
		memory.write_u16(C68kScript.u32(a5 - 0x12ea), 0)

## A command key-up during flight (ID01's sparse switch on the character): its result, the one given
## when it sets none.
func _flight_command_key(entry: int, ch: int, result: int) -> int:
	var settings: int = memory.read_u32(memory.read_u32(C68kScript.u32(a5 - 0x13ac)))
	match ch:
		0x54, 0x74:
			var at: int = C68kScript.u32(a5 - 0x102f)
			memory.write_u8(at, memory.read_u8(at) ^ 1)
		0x31, 0x32, 0x33, 0x34, 0x35:
			memory.write_u16(settings + 0x10, ch - 0x30)
			_apply_in_flight(entry)
		0x51, 0x71:
			return 5
		0x53, 0x73:
			_local(LOCAL_END_OVERLAY_SESSION, [])
			_toggle_setting_bit(3)
			_apply_in_flight(entry)
			a7 = entry - 0x30
			begin_overlay_session()
			a7 = entry
		0x45, 0x65:
			_toggle_setting_bit(5)
			_apply_in_flight(entry)
	return result

## Bit 0 of the settings byte at `offset` toggled (without marking the settings changed).
func _toggle_setting_bit(offset: int) -> void:
	var at: int = memory.read_u32(memory.read_u32(C68kScript.u32(a5 - 0x13ac))) + offset
	memory.write_u8(at, memory.read_u8(at) ^ 1)
