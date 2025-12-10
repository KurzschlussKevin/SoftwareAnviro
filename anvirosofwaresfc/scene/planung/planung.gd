extends Control

@onready var scroll_emp = $VBox/PlanContainer/LeftColEmployees/ScrollEmp
@onready var scroll_time = $VBox/PlanContainer/RightColTimeline/ScrollTime

func _ready():
	# Synchronisiertes Scrollen: Wenn man rechts im Zeitplan scrollt, 
	# sollen die Mitarbeiter-Namen links mitscrollen (vertikal).
	scroll_time.get_v_scroll_bar().value_changed.connect(_on_scroll_time_changed)
	scroll_emp.get_v_scroll_bar().value_changed.connect(_on_scroll_emp_changed)
	
	# Scrollbalken links ausblenden, da wir über rechts steuern
	scroll_emp.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER

func _on_scroll_time_changed(value):
	scroll_emp.set_v_scroll(int(value))

func _on_scroll_emp_changed(value):
	scroll_time.set_v_scroll(int(value))

# Hier könnte man später Funktionen bauen wie:
# func load_data():
#    ... lädt Mitarbeiter und Termine aus Datenbank/JSON ...
