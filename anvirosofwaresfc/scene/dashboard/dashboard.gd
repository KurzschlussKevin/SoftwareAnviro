extends Control

signal request_navigation(target_name: String, mode: String)

@onready var label_welcome = $VBox/Header/M/HBox/VBoxText/LabelWelcome
@onready var label_date = $VBox/Header/M/HBox/LabelDate
@onready var progress_goal = $VBox/ScrollContainer/Content/StatsArea/VBox/HBoxCards/CardGoal/M/VBox/ProgressBar

@onready var btn_nav_kunden = $VBox/ScrollContainer/Content/QuickActions/VBox/HBoxBtns/BtnNavKunden
@onready var btn_nav_vertrieb = $VBox/ScrollContainer/Content/QuickActions/VBox/HBoxBtns/BtnNavVertrieb
@onready var btn_nav_stats = $VBox/ScrollContainer/Content/QuickActions/VBox/HBoxBtns/BtnNavStats

func _ready():
	update_greeting()
	
	var tween = create_tween()
	tween.tween_property(progress_goal, "value", 65.0, 1.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	# --- NAVIGATION LOGIK ---
	
	if btn_nav_kunden:
		# Ziel: Kunden, Modus: "create" (Erstellen fokusieren)
		btn_nav_kunden.pressed.connect(func(): _on_nav_request("Kundenverwaltung", "create"))
	
	if btn_nav_vertrieb:
		# Ziel: Vertrieb, Modus: "create" (Angebot mit Auswahl)
		btn_nav_vertrieb.pressed.connect(func(): _on_nav_request("Vertriebsbereich", "create"))
	
	if btn_nav_stats:
		# Ziel: Profil (NEU)
		btn_nav_stats.pressed.connect(func(): _on_nav_request("Profil", ""))

func update_greeting():
	var time = Time.get_time_dict_from_system()
	var hour = time.hour
	var greeting = "Guten Morgen" if hour < 12 else ("Guten Tag" if hour < 18 else "Guten Abend")
	label_welcome.text = "%s, Admin!" % greeting
	var date = Time.get_datetime_dict_from_system()
	label_date.text = "%02d.%02d.%d" % [date.day, date.month, date.year]

func _on_nav_request(target: String, mode: String):
	request_navigation.emit(target, mode)
