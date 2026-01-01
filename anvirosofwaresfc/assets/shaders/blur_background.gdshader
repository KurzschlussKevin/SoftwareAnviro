shader_type canvas_item;

// Stärke der Unschärfe (Level of Detail)
uniform float lod: hint_range(0.0, 5.0) = 3.0;
// Optionale Abdunklung/Färbung
uniform vec4 color_overlay: source_color = vec4(0.1, 0.1, 0.1, 0.3);

// Zugriff auf den Bildschirm-Inhalt hinter diesem Node
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment(){
	// Farbe vom Screen lesen, aber mit Mipmap-Level (lod) für den Blur-Effekt
	vec4 screen_color = textureLod(SCREEN_TEXTURE, SCREEN_UV, lod);

	// Mit Overlay mischen
	COLOR = mix(screen_color, color_overlay, color_overlay.a);
}