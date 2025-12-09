extends Control

# Hier referenzieren wir die neuen Pfade, die jetzt in der .tscn existieren
@onready var label_welcome = $VBox/Header/M/HBox/VBoxText/LabelWelcome
@onready var label_date = $VBox/Header/M/HBox/LabelDate
@onready var progress_goal = $VBox/ScrollContainer/Content/StatsArea/VBox/HBoxCards/CardGoal/M/VBox/ProgressBar

func _ready():
	update_greeting()
	
	# Optional: Animation für den Fortschrittsbalken
	var target_value = 65.0
	progress_goal.value = 0
	var tween = create_tween()
	tween.tween_property(progress_goal, "value", target_value, 1.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

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
