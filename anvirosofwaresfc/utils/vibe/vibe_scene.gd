extends Node2D

# --- KONFIGURATION ---
@export_group("Optik")
@export var main_color: Color = Color("ff006e") # Pink
@export var satellite_colors: Array[Color] = [
	Color("3a86ff"), # Blau
	Color("8338ec"), # Lila
	Color("ffbe0b"), # Gelb
	Color("fb5607")  # Orange/Rot
]
@export var satellite_count: int = 12
@export var radius: float = 150.0

@export_group("Physik")
@export var spring_length: float = 130.0
@export var spring_stiffness: float = 20.0
@export var spring_damping: float = 0.5

# Referenzen
@onready var main_ball = $MainBall
@onready var main_sprite = $MainBall/Sprite2D

# Status für Drag & Drop
var is_dragging = false
var drag_offset = Vector2.ZERO

func _ready():
	# 1. Main Ball Farbe setzen
	main_sprite.modulate = main_color
	
	# 2. Pulsieren Animation starten
	start_pulsing(main_sprite, 1.05)
	
	# 3. Satelliten erzeugen
	spawn_satellites()

func spawn_satellites():
	for i in range(satellite_count):
		# Winkel berechnen
		var angle = (TAU / satellite_count) * i
		var spawn_pos = main_ball.position + Vector2(cos(angle), sin(angle)) * radius
		
		# -- KREIS ERSTELLEN --
		var sat_body = RigidBody2D.new()
		sat_body.position = spawn_pos
		sat_body.gravity_scale = 0
		sat_body.linear_damp = 2.0 # Etwas träger als der Hauptball
		
		# Sprite für den Satelliten (Kopie vom Haupt-Sprite nutzen für einfachen Look)
		var sat_sprite = main_sprite.duplicate()
		sat_sprite.scale = Vector2(0.4, 0.4) # Kleiner
		# Farbe rotieren
		sat_sprite.modulate = satellite_colors[i % satellite_colors.size()]
		sat_body.add_child(sat_sprite)
		
		# Kollision
		var sat_shape = $MainBall/CollisionShape2D.duplicate()
		sat_shape.shape = sat_shape.shape.duplicate()
		sat_shape.shape.radius *= 0.4
		sat_body.add_child(sat_shape)
		
		add_child(sat_body)
		
		# Animation für Satelliten (mit leichtem Versatz)
		var delay = i * 0.1
		var timer = get_tree().create_timer(delay)
		timer.timeout.connect(func(): start_pulsing(sat_sprite, 1.2))
		
		# -- FEDER (JOINT) ERSTELLEN --
		var joint = DampedSpringJoint2D.new()
		joint.node_a = main_ball.get_path()
		joint.node_b = sat_body.get_path()
		joint.length = spring_length
		joint.rest_length = spring_length
		joint.stiffness = spring_stiffness
		joint.damping = spring_damping
		
		# Joint muss auch zur Szene hinzugefügt werden
		add_child(joint)

# --- ANIMATION ---
func start_pulsing(node: Node2D, scale_target: float):
	var tween = create_tween().set_loops()
	tween.tween_property(node, "scale", node.scale * scale_target, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "scale", node.scale, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

# --- INTERAKTION (DRAG & DROP) ---
func _unhandled_input(event):
	if event is InputEventMouseButton or event is InputEventScreenTouch:
		if event.pressed:
			# Prüfen, ob wir den MainBall getroffen haben
			# Wir nutzen den PhysicsDirectSpaceState für präzise Klick-Abfragen
			var space_state = get_world_2d().direct_space_state
			var query = PhysicsPointQueryParameters2D.new()
			query.position = get_global_mouse_position()
			var result = space_state.intersect_point(query)
			
			for entry in result:
				if entry.collider == main_ball:
					start_drag()
					break
		elif not event.pressed and is_dragging:
			end_drag()
			
	if event is InputEventMouseMotion or event is InputEventScreenDrag:
		if is_dragging:
			# Bewege den Ball direkt zur Mausposition
			main_ball.global_position = get_global_mouse_position()

func start_drag():
	is_dragging = true
	# Physik temporär ausschalten (Freeze), damit wir volle Kontrolle haben
	main_ball.freeze = true 
	# Ball etwas größer machen als Feedback
	var tween = create_tween()
	tween.tween_property(main_sprite, "scale", Vector2(1.2, 1.2), 0.1)

func end_drag():
	is_dragging = false
	# Physik wieder einschalten
	main_ball.freeze = false
	# Falls du den Ball "werfen" willst, könnte man hier noch eine Impuls-Logik einbauen
	# basierend auf der Mausgeschwindigkeit (Input.get_last_mouse_velocity())
	main_ball.apply_impulse(Input.get_last_mouse_velocity() * 0.5) # Leichter Wurf
	
	# Größe zurücksetzen
	var tween = create_tween()
	tween.tween_property(main_sprite, "scale", Vector2(1.0, 1.0), 0.1)
