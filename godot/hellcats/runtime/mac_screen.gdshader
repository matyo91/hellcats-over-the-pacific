shader_type canvas_item;

// The screen's bytes are palette indices (in the red channel of an L8 texture): look each one up
// in the 256 x 1 colour table.
uniform sampler2D palette : filter_nearest;

void fragment() {
	float index = texture(TEXTURE, UV).r;
	COLOR = texture(palette, vec2((index * 255.0 + 0.5) / 256.0, 0.5));
}
