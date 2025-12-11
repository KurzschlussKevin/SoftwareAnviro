extends Control

signal request_navigation(target_name: String, mode: String)

@onready var label_welcome = %LabelWelcome
@onready var label_date = %LabelDate
@onready var progress_goal = %ProgressBar

# Zugriff auf die Buttons über Unique Names
@onready var btn_nav_kunden = %BtnNavKunden
@onready var btn_nav_vertrieb = %BtnNavVertrieb
@onready var btn_nav_stats = %BtnNavStats

func _ready():
	update_greeting()
	
	if progress_goal:
		var tween = create_tween()
		tween.tween_property(progress_goal, "value", 65.0, 1.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	# --- NAVIGATION LOGIK ---
	
	if btn_nav_kunden:
		# WICHTIG: Hier "create" senden, damit es zum MainTemplate passt
		btn_nav_kunden.pressed.connect(func(): _on_nav_request("Kundenverwaltung", "create"))
	
	if btn_nav_vertrieb:
		# Auch hier "create" verwenden
		btn_nav_vertrieb.pressed.connect(func(): _on_nav_request("Vertriebsbereich", "create"))
	
	if btn_nav_stats:
		# Geht zum Profil
		btn_nav_stats.pressed.connect(func(): _on_nav_request("Profil", ""))

func update_greeting():
	var time = Time.get_time_dict_from_system()
	var hour = time.hour
	var greeting = "Guten Morgen" if hour < 12 else ("Guten Tag" if hour < 18 else "Guten Abend")
	
	if label_welcome:
		label_welcome.text = "%s, Admin!" % greeting
	
	if label_date:
		var date = Time.get_datetime_dict_from_system()
		label_date.text = "%02d.%02d.%d" % [date.day, date.month, date.year]

func _on_nav_request(target: String, mode: String):
	print("Dashboard Navigation -> ", target, " (Modus: ", mode, ")")
	request_navigation.emit(target, mode)
