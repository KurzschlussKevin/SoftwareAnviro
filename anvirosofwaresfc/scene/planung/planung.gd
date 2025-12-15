extends Control

# Referenzen auf die Container im Szenenbaum
@onready var scroll_emp = $VBox/PlanContainer/LeftColEmployees/ScrollEmp
@onready var emp_list_container = $VBox/PlanContainer/LeftColEmployees/ScrollEmp/EmpList
@onready var scroll_time = $VBox/PlanContainer/RightColTimeline/ScrollTime
@onready var header_days_container = $VBox/PlanContainer/RightColTimeline/HeaderDays
@onready var grid_container = $VBox/PlanContainer/RightColTimeline/ScrollTime/Grid

# Timer für die 3-Sekunden-Verzögerung
var hover_timer: Timer
# Referenz auf das Popup-Fenster (wird im Code erstellt)
var info_popup: PanelContainer
var popup_label: Label
# Speichert temporär die Daten des Blocks, über dem die Maus schwebt
var current_hover_data = {}

func _ready():
	# 1. Synchronisiertes Scrollen (wie gehabt)
	scroll_time.get_v_scroll_bar().value_changed.connect(_on_scroll_time_changed)
	scroll_emp.get_v_scroll_bar().value_changed.connect(_on_scroll_emp_changed)
	scroll_emp.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	
	# 2. Setup für das Hover-System
	_setup_hover_system()
	
	# 3. Wochenansicht generieren (Dummy-Daten)
	# Hier löschen wir erst die Platzhalter aus dem Editor, damit wir sauber neu bauen können
	_clear_placeholders()
	_generate_week_view()

# --- Synchronisation ---
func _on_scroll_time_changed(value):
	scroll_emp.set_v_scroll(int(value))

func _on_scroll_emp_changed(value):
	scroll_time.set_v_scroll(int(value))

# --- Setup & Hilfsfunktionen ---

func _clear_placeholders():
	# Löscht die Dummy-Elemente, die du im Editor zum Designen erstellt hast
	for child in header_days_container.get_children():
		child.queue_free()
	for child in emp_list_container.get_children():
		child.queue_free()
	for child in grid_container.get_children():
		child.queue_free()

func _setup_hover_system():
	# Timer erstellen
	hover_timer = Timer.new()
	hover_timer.wait_time = 3.0 # 3 Sekunden Wartezeit
	hover_timer.one_shot = true
	hover_timer.timeout.connect(_on_hover_timeout)
	add_child(hover_timer)
	
	# Popup erstellen (Ein einfaches Panel, das über allem schwebt)
	info_popup = PanelContainer.new()
	info_popup.visible = false
	info_popup.z_index = 100 # Sicherstellen, dass es ganz oben liegt
	# Ein bisschen Styling für das Popup (optional)
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.15, 0.95)
	style.border_color = Color(0.0, 0.8, 0.5) # Anviro Grün ;)
	style.set_border_width_all(2)
	style.content_margin_left = 10
	style.content_margin_top = 10
	style.content_margin_right = 10
	style.content_margin_bottom = 10
	info_popup.add_theme_stylebox_override("panel", style)
	
	popup_label = Label.new()
	popup_label.text = "Lade Daten..."
	info_popup.add_child(popup_label)
	add_child(info_popup)

func _generate_week_view():
	# Definieren wir die Woche (Mo-So)
	var days = ["Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag", "Samstag", "Sonntag"]
	
	# 1. Header erstellen (Wochentage)
	for day in days:
		var panel = Panel.new()
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL # Wichtig: Verteilt Platz gleichmäßig
		panel.custom_minimum_size.y = 50
		# Optional: StyleBox zuweisen, damit es aussieht wie deine Vorlage
		
		var lbl = Label.new()
		lbl.text = day
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
		
		panel.add_child(lbl)
		header_days_container.add_child(panel)

	# 2. Mitarbeiter und Zeilen erstellen (Beispiel: 5 Mitarbeiter)
	for i in range(5):
		var emp_name = "Mitarbeiter " + str(i + 1)
		
		# A) Linke Spalte: Mitarbeiter-Karte
		var emp_card = PanelContainer.new()
		emp_card.custom_minimum_size.y = 80 # Feste Höhe pro Zeile
		var emp_lbl = Label.new()
		emp_lbl.text = "  " + emp_name
		emp_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		emp_card.add_child(emp_lbl)
		emp_list_container.add_child(emp_card)
		
		# B) Rechte Spalte: Die Zeitleiste (Row)
		var row = HBoxContainer.new()
		row.custom_minimum_size.y = 80
		row.add_theme_constant_override("separation", 0) # Keine Lücken zwischen Tagen
		
		# Für jeden Tag der Woche eine "Zelle" erstellen
		for d in range(7):
			var day_slot = Panel.new()
			day_slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL # Gleichmäßig verteilen
			day_slot.name = "Slot_" + str(d)
			
			# HIER FÜGEN WIR TESTWEISE AUFGABEN EIN
			# Sagen wir, an Tag 2 (Mittwoch) und Tag 4 (Freitag) gibt es Aufgaben
			if (i == 0 and d == 2) or (i == 1 and d == 4): 
				_add_task_to_slot(day_slot, "Kunde Müller", 12.5) # 12.5 Stunden gearbeitet
			
			row.add_child(day_slot)
			
		grid_container.add_child(row)

func _add_task_to_slot(parent_slot: Control, kunden_name: String, stunden: float):
	# Erstellt den visuellen Block für die Aufgabe
	var task_panel = PanelContainer.new()
	task_panel.name = "TaskBlock"
	
	# Damit der Block etwas Abstand zum Rand hat (Margin)
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 4)
	margin.add_theme_constant_override("margin_right", 4)
	margin.add_theme_constant_override("margin_top", 4)
	margin.add_theme_constant_override("margin_bottom", 4)
	
	# Styling für den Block (Blau)
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.4, 0.9, 0.8)
	style.set_corner_radius_all(6)
	task_panel.add_theme_stylebox_override("panel", style)
	
	var lbl = Label.new()
	lbl.text = kunden_name
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.clip_text = true # Text abschneiden wenn zu lang
	
	task_panel.add_child(lbl)
	margin.add_child(task_panel)
	
	# Layout im Slot (füllt den ganzen Tag aus für dieses Beispiel)
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	parent_slot.add_child(margin)
	
	# --- SIGNAL VERBINDUNG FÜR HOVER ---
	# Wir speichern die Infos direkt im Node (oder in einem Dictionary)
	task_panel.set_meta("info_data", {"kunde": kunden_name, "stunden": stunden})
	
	# Maus betritt Block
	task_panel.mouse_entered.connect(func(): _on_task_mouse_entered(task_panel))
	# Maus verlässt Block
	task_panel.mouse_exited.connect(_on_task_mouse_exited)

# --- HOVER LOGIK ---

func _on_task_mouse_entered(task_node):
	# Daten holen
	current_hover_data = task_node.get_meta("info_data")
	# Timer starten
	hover_timer.start()

func _on_task_mouse_exited():
	# Timer abbrechen, wenn man rausgeht bevor die 3 Sek. um sind
	hover_timer.stop()
	# Popup verstecken
	info_popup.visible = false

func _on_hover_timeout():
	# Diese Funktion wird nach 3 Sekunden aufgerufen
	if current_hover_data.is_empty():
		return
		
	# Popup Text setzen
	var txt = "Kunde: %s\nBereits gearbeitet: %s Std.\nStatus: In Arbeit" % [current_hover_data.get("kunde"), str(current_hover_data.get("stunden"))]
	popup_label.text = txt
	
	# Popup Position setzen (neben der Maus)
	info_popup.global_position = get_global_mouse_position() + Vector2(15, 15)
	info_popup.visible = true
