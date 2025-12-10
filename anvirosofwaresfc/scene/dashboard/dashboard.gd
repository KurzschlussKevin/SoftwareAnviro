extends Control

# --- SIGNAL DEFINITION ---
# Damit das MainTemplate weiß, wann wir die Szene wechseln wollen
signal request_navigation(target_name: String)

# --- UI REFERENZEN (DEINE BESTEHENDEN) ---
@onready var label_welcome = $VBox/Header/M/HBox/VBoxText/LabelWelcome
@onready var label_date = $VBox/Header/M/HBox/LabelDate
@onready var progress_goal = $VBox/ScrollContainer/Content/StatsArea/VBox/HBoxCards/CardGoal/M/VBox/ProgressBar

# --- UI REFERENZEN (NEU FÜR BUTTONS) ---
@onready var btn_new_cust = $VBox/ScrollContainer/Content/QuickActions/VBox/HBoxBtns/BtnNewCust
@onready var btn_new_offer = $VBox/ScrollContainer/Content/QuickActions/VBox/HBoxBtns/BtnNewOffer
@onready var btn_stats = $VBox/ScrollContainer/Content/QuickActions/VBox/HBoxBtns/BtnStats

func _ready():
	# 1. Deine Initialisierungen
	update_greeting()
	
	# Animation für den Fortschrittsbalken
	var target_value = 65.0
	progress_goal.value = 0
	var tween = create_tween()
	tween.tween_property(progress_goal, "value", target_value, 1.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	# 2. Neue Signale für die Buttons verbinden
	if btn_new_cust:
		btn_new_cust.pressed.connect(func(): _on_nav_request("Kundenverwaltung"))
	
	if btn_new_offer:
		# Leitet zum Vertrieb weiter (dort werden Angebote erstellt)
		btn_new_offer.pressed.connect(func(): _on_nav_request("Vertriebsbereich"))
	
	if btn_stats:
		# Leitet zu den Berichten weiter
		btn_stats.pressed.connect(func(): _on_nav_request("Export & Berichte"))

# Deine Funktion für Zeit/Datum
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
	
	label_welcome.text = "%s, Admin!" % greeting
	
	# Datum setzen
	var date = Time.get_datetime_dict_from_system()
	label_date.text = "%02d.%02d.%d" % [date.day, date.month, date.year]

# Neue Hilfsfunktion für Navigation
func _on_nav_request(target: String):
	print("Dashboard: Navigiere zu ", target)
	request_navigation.emit(target)
