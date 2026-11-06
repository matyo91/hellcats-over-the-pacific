class_name MacScreen
extends TextureRect

## The Macintosh's screen in Godot: the machine's 640 x 480 bytes of 8-bit indices shown through
## the screen device's colour table (a 256 x 1 palette texture looked up by mac_screen.gdshader,
## refreshed when the program changes the table), the bytes refreshed every frame.

var machine
var _image: Image
var _texture: ImageTexture
var _palette_image: Image
var _palette_texture: ImageTexture
var _palette_version: int = -1

func attach(owner) -> void:
	machine = owner
	_image = Image.create_from_data(machine.SCREEN_WIDTH, machine.SCREEN_HEIGHT, false, Image.FORMAT_L8, machine.screen_bytes())
	_texture = ImageTexture.create_from_image(_image)
	texture = _texture
	_palette_image = Image.create(256, 1, false, Image.FORMAT_RGBA8)
	_palette_texture = ImageTexture.create_from_image(_palette_image)
	(material as ShaderMaterial).set_shader_parameter("palette", _palette_texture)
	_update_palette()

## The screen device's colour table, which the program animates (palette_manager.gd).
func _update_palette() -> void:
	var palettes = machine.toolbox.palettes
	if palettes.version == _palette_version:
		return
	_palette_version = palettes.version
	var table: Array = palettes.colours()
	for k in 256:
		_palette_image.set_pixel(k, 0, table[k])
	_palette_texture.update(_palette_image)

func _process(_delta: float) -> void:
	if machine == null:
		return
	_update_palette()
	_image.set_data(machine.SCREEN_WIDTH, machine.SCREEN_HEIGHT, false, Image.FORMAT_L8, machine.screen_bytes())
	_texture.update(_image)
