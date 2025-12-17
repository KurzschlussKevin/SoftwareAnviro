shader_type canvas_item;

uniform float lod: hint_range(0.0, 5.0) = 2.0;
uniform vec4 color_overlay: source_color = vec4(0.05, 0.05, 0.08, 0.6);

// Diese Zeile ist wichtig, damit der Shader den Bildschirm "hinter" sich lesen kann
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	// Hole die Farbe vom Bildschirm hinter diesem Element, aber unscharf (LOD)
	vec4 screen_color = textureLod(SCREEN_TEXTURE, SCREEN_UV, lod);
	
	// Mische das unscharfe Bild mit deiner dunklen Farbe
	COLOR = mix(screen_color, color_overlay, color_overlay.a);
}