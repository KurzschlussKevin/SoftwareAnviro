extends Control

# Signal an MainTemplate
signal request_navigation(target_name: String, mode: String)

# Zugriff über Unique Names (%)
# Das funktioniert garantiert, wenn die Nodes in der Szene als 'Access as Unique Name' markiert sind
@onready var label_welcome = %LabelWelcome
@onready var label_date = %LabelDate
@onready var progress_goal = %ProgressBar

@onready var btn_kunden = %BtnNavKunden
@onready var btn_vertrieb = %BtnNavVertrieb
@onready var btn_stats = %BtnNavStats

func _ready():
	update_greeting()
	
	# Fortschrittsbalken animieren
	if progress_goal:
		var tween = create_tween()
		tween.tween_property(progress_goal, "value", 65.0, 1.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	# Buttons verbinden
	if btn_kunden:
		btn_kunden.pressed.connect(func(): _on_nav_request("Kundenverwaltung", "create"))
	
	if btn_vertrieb:
		btn_vertrieb.pressed.connect(func(): _on_nav_request("Vertriebsbereich", "create"))
	
	if btn_stats:
		# Geht jetzt zum neuen Profil
		btn_stats.pressed.connect(func(): _on_nav_request("Profil", ""))

func update_greeting():
	var time = Time.get_time_dict_from_system()
	var hour = time.hour
	var greeting = "Hallo"
	
	if hour < 12:
		greeting = "Guten Morgen"
	elif hour < 18:
		greeting = "Guten Tag"
	else:
		greeting = "Guten Abend"
	
	if label_welcome:
		label_welcome.text = "%s, Admin!" % greeting
	
	if label_date:
		var date = Time.get_datetime_dict_from_system()
		label_date.text = "%02d.%02d.%d" % [date.day, date.month, date.year]

func _on_nav_request(target: String, mode: String):
	print("Dashboard -> Navigation: ", target, " (Modus: ", mode, ")")
	request_navigation.emit(target, mode)
