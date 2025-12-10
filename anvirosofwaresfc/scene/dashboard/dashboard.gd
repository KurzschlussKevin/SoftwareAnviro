extends Control

# --- SIGNAL DEFINITION ---
# Wir senden jetzt ZWEI Infos: Wohin (target) und was dort passieren soll (mode)
signal request_navigation(target_name: String, mode: String)

# --- UI REFERENZEN ---
@onready var label_welcome = $VBox/Header/M/HBox/VBoxText/LabelWelcome
@onready var label_date = $VBox/Header/M/HBox/LabelDate
@onready var progress_goal = $VBox/ScrollContainer/Content/StatsArea/VBox/HBoxCards/CardGoal/M/VBox/ProgressBar

# Buttons (Namen bleiben wie sie sind, Funktion ändert sich)
@onready var btn_new_cust = $VBox/ScrollContainer/Content/QuickActions/VBox/HBoxBtns/BtnNewCust
@onready var btn_new_offer = $VBox/ScrollContainer/Content/QuickActions/VBox/HBoxBtns/BtnNewOffer
@onready var btn_stats = $VBox/ScrollContainer/Content/QuickActions/VBox/HBoxBtns/BtnStats

func _ready():
	# 1. Init
	update_greeting()
	
	# Animation
	var target_value = 65.0
	progress_goal.value = 0
	var tween = create_tween()
	tween.tween_property(progress_goal, "value", target_value, 1.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	# 2. Signale verbinden (mit dem neuen "Modus"-Parameter)
	if btn_new_cust:
		# Ziel: Kundenverwaltung, Modus: "create" (Erstellen)
		btn_new_cust.pressed.connect(func(): _on_nav_request("Kundenverwaltung", "create"))
	
	if btn_new_offer:
		# Ziel: Vertrieb, Modus: "create"
		btn_new_offer.pressed.connect(func(): _on_nav_request("Vertriebsbereich", "create"))
	
	if btn_stats:
		# Ziel: Berichte, Modus: "" (Standard / Leer)
		btn_stats.pressed.connect(func(): _on_nav_request("Export & Berichte", ""))

func update_greeting():
	var time = Time.get_time_dict_from_system()
	var hour = time.hour
	var greeting = "Guten Morgen" if hour < 12 else ("Guten Tag" if hour < 18 else "Guten Abend")
	label_welcome.text = "%s, Admin!" % greeting
	var date = Time.get_datetime_dict_from_system()
	label_date.text = "%02d.%02d.%d" % [date.day, date.month, date.year]

func _on_nav_request(target: String, mode: String):
	print("Dashboard: Navigiere zu '%s' im Modus '%s'" % [target, mode])
	request_navigation.emit(target, mode)
