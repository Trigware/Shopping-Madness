shader_type canvas_item;

const float maximum_alpha_level = 0.4;

void fragment() {
	COLOR.a = (1.0 - UV.y) * maximum_alpha_level;
}
