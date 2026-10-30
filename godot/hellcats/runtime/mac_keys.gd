extends RefCounted

## Godot keys as a Macintosh keyboard sends them: the virtual key code (the US layout's, which the
## game's GetKeys tests read) and the character, with the modifier bits (Command from Ctrl or Meta,
## Option from Alt).

const CODES := {
	KEY_A: 0x00, KEY_S: 0x01, KEY_D: 0x02, KEY_F: 0x03, KEY_H: 0x04, KEY_G: 0x05, KEY_Z: 0x06, KEY_X: 0x07,
	KEY_C: 0x08, KEY_V: 0x09, KEY_B: 0x0b, KEY_Q: 0x0c, KEY_W: 0x0d, KEY_E: 0x0e, KEY_R: 0x0f, KEY_Y: 0x10,
	KEY_T: 0x11, KEY_1: 0x12, KEY_2: 0x13, KEY_3: 0x14, KEY_4: 0x15, KEY_6: 0x16, KEY_5: 0x17, KEY_EQUAL: 0x18,
	KEY_9: 0x19, KEY_7: 0x1a, KEY_MINUS: 0x1b, KEY_8: 0x1c, KEY_0: 0x1d, KEY_BRACKETRIGHT: 0x1e, KEY_O: 0x1f,
	KEY_U: 0x20, KEY_BRACKETLEFT: 0x21, KEY_I: 0x22, KEY_P: 0x23, KEY_ENTER: 0x24, KEY_L: 0x25, KEY_J: 0x26,
	KEY_APOSTROPHE: 0x27, KEY_K: 0x28, KEY_SEMICOLON: 0x29, KEY_BACKSLASH: 0x2a, KEY_COMMA: 0x2b, KEY_SLASH: 0x2c,
	KEY_N: 0x2d, KEY_M: 0x2e, KEY_PERIOD: 0x2f, KEY_TAB: 0x30, KEY_SPACE: 0x31, KEY_QUOTELEFT: 0x32,
	KEY_BACKSPACE: 0x33, KEY_ESCAPE: 0x35, KEY_KP_PERIOD: 0x41, KEY_KP_MULTIPLY: 0x43, KEY_KP_ADD: 0x45,
	KEY_KP_DIVIDE: 0x4b, KEY_KP_ENTER: 0x4c, KEY_KP_SUBTRACT: 0x4e, KEY_KP_0: 0x52, KEY_KP_1: 0x53, KEY_KP_2: 0x54,
	KEY_KP_3: 0x55, KEY_KP_4: 0x56, KEY_KP_5: 0x57, KEY_KP_6: 0x58, KEY_KP_7: 0x59, KEY_KP_8: 0x5b, KEY_KP_9: 0x5c,
	KEY_LEFT: 0x7b, KEY_RIGHT: 0x7c, KEY_DOWN: 0x7d, KEY_UP: 0x7e, KEY_SHIFT: 0x38, KEY_CAPSLOCK: 0x39,
	KEY_ALT: 0x3a, KEY_CTRL: 0x3b, KEY_META: 0x37}
## Characters of keys that type none in Godot's unicode.
const CHARS := {KEY_ENTER: 0x0d, KEY_KP_ENTER: 0x03, KEY_TAB: 0x09, KEY_BACKSPACE: 0x08, KEY_ESCAPE: 0x1b,
	KEY_LEFT: 0x1c, KEY_RIGHT: 0x1d, KEY_UP: 0x1e, KEY_DOWN: 0x1f}

static func code(key: Key) -> int:
	return CODES.get(key, -1)

static func character(event: InputEventKey) -> int:
	if CHARS.has(event.keycode):
		return CHARS[event.keycode]
	var u: int = event.unicode
	if u > 0 and u < 0x80:
		return u
	return 0

static func modifiers(event: InputEventWithModifiers) -> int:
	var m: int = 0
	if event.ctrl_pressed or event.meta_pressed:
		m |= 0x100
	if event.shift_pressed:
		m |= 0x200
	if event.alt_pressed:
		m |= 0x800
	return m
