extends Control

# --- UI REFERENZEN (Links: Kunde & Ansprechpartner) ---
@onready var input_firma = $MainMargin/HBox/LeftCol/KundenPanel/M/Scroll/VBox/Firma
@onready var input_kundennr = $MainMargin/HBox/LeftCol/KundenPanel/M/Scroll/VBox/Kundennr
@onready var input_strasse = $MainMargin/HBox/LeftCol/KundenPanel/M/Scroll/VBox/Strasse
@onready var input_plz = $MainMargin/HBox/LeftCol/KundenPanel/M/Scroll/VBox/RowCity/PLZ
@onready var input_stadt = $MainMargin/HBox/LeftCol/KundenPanel/M/Scroll/VBox/RowCity/Stadt

# Leistungsort
@onready var check_work_loc = $MainMargin/HBox/LeftCol/KundenPanel/M/Scroll/VBox/CheckWorkLoc
@onready var container_work_loc = $MainMargin/HBox/LeftCol/KundenPanel/M/Scroll/VBox/ContainerWorkLoc

# 2. Ansprechpartner (Neu!)
@onready var check_ap2 = $MainMargin/HBox/LeftCol/KundenPanel/M/Scroll/VBox/CheckAP2
@onready var container_ap2 = $MainMargin/HBox/LeftCol/KundenPanel/M/Scroll/VBox/ContainerAP2

# --- UI REFERENZEN (Links: Berichtstyp - Neu!) ---
@onready var btn_report_general = $MainMargin/HBox/LeftCol/ReportPanel/M/VBox/BtnGeneral
@onready var btn_report_travel = $MainMargin/HBox/LeftCol/ReportPanel/M/VBox/BtnTravel
@onready var btn_report_combined = $MainMargin/HBox/LeftCol/ReportPanel/M/VBox/BtnCombined

# --- UI REFERENZEN (Rechts: Positionen & Templates) ---
@onready var template_option = $MainMargin/HBox/RightCol/TemplatePanel/M/HBox/TemplateOption
@onready var btn_load_template = $MainMargin/HBox/RightCol/TemplatePanel/M/HBox/LoadTemplateBtn

@onready var positions_list = $MainMargin/HBox/RightCol/PositionsPanel/M/VBox/Scroll/PositionsList
@onready var position_template_row = $MainMargin/HBox/RightCol/PositionsPanel/M/VBox/Scroll/PositionsList/PositionTemplate

@onready var btn_add_pos = $MainMargin/HBox/RightCol/ButtonsRow/AddPosBtn
@onready var btn_save_all = $MainMargin/HBox/RightCol/ButtonsRow/SaveAllBtn
@onready var total_sum_label = $MainMargin/HBox/RightCol/PositionsPanel/M/VBox/HBoxSum/TotalSumLabel

# Variable für Berichtstyp
var selected_report_type = "general" # general, travel, combined

# Vorlagen
var templates = {
	1: [{"bez": "Prüfung DGUV V3", "menge": 50, "preis": 4.50}, {"bez": "Anfahrt", "menge": 1, "preis": 45.00}],
	2: [{"bez": "Anlagenprüfung", "menge": 1, "preis": 120.00}],
	3: [{"bez": "Maschinenprüfung", "menge": 1, "preis": 180.00}]
}

func _ready():
	# 1. Startzustand UI
	container_work_loc.visible = false
	container_ap2.visible = false
	position_template_row.visible = false
	
	# 2. Signale verbinden
	check_work_loc.toggled.connect(_on_work_loc_toggled)
	check_ap2.toggled.connect(_on_ap2_toggled)
	
	# Berichtstyp Buttons
	btn_report_general.pressed.connect(func(): _set_report_type("general"))
	btn_report_travel.pressed.connect(func(): _set_report_type("travel"))
	btn_report_combined.pressed.connect(func(): _set_report_type("combined"))
	
	# Restliche Buttons
	btn_add_pos.pressed.connect(func(): _add_new_position())
	btn_load_template.pressed.connect(_on_load_template_pressed)
	btn_save_all.pressed.connect(_on_save_all_pressed)
	
	# Erste Zeile einfügen
	_add_new_position()

func _on_work_loc_toggled(active):
	container_work_loc.visible = active

func _on_ap2_toggled(active):
	container_ap2.visible = active

func _set_report_type(type):
	selected_report_type = type
	
	# Visuelles Feedback (Radio-Button Verhalten)
	btn_report_general.button_pressed = (type == "general")
	btn_report_travel.button_pressed = (type == "travel")
	btn_report_combined.button_pressed = (type == "combined")
	
	print("Berichtstyp gewählt: ", type)

# --- POSITIONS LOGIK ---
func _add_new_position(data = null):
	var new_row = position_template_row.duplicate()
	new_row.visible = true
	
	# Laufende Nummer
	var current_count = 0
	for child in positions_list.get_children():
		if child.visible: current_count += 1
	new_row.get_node("Pos").text = str(current_count + 1)
	
	# Daten füllen
	if data:
		new_row.get_node("Bez").text = data.get("bez", "")
		new_row.get_node("Menge").text = str(data.get("menge", 1))
		new_row.get_node("Preis").text = "%.2f" % data.get("preis", 0.0)
	else:
		new_row.get_node("Menge").text = "1"
		new_row.get_node("Preis").text = "0.00"
	
	# Signale verbinden
	new_row.get_node("Menge").text_changed.connect(func(t): _recalc_row(new_row))
	new_row.get_node("Preis").text_changed.connect(func(t): _recalc_row(new_row))
	
	positions_list.add_child(new_row)
	_recalc_row(new_row)

func _recalc_row(row):
	var m = float(row.get_node("Menge").text.replace(",", "."))
	var p = float(row.get_node("Preis").text.replace(",", "."))
	row.get_node("Gesamt").text = "%.2f €" % (m * p)
	_recalc_total()

func _recalc_total():
	var total = 0.0
	for child in positions_list.get_children():
		if !child.visible or child.is_queued_for_deletion(): continue
		var val = child.get_node("Gesamt").text.replace(" €", "").replace(",", ".")
		total += float(val)
	total_sum_label.text = "%.2f €" % total

func _on_load_template_pressed():
	var id = template_option.get_selected_id()
	if templates.has(id):
		# Alles leeren außer Template
		for child in positions_list.get_children():
			if child != position_template_row: child.queue_free()
		# Neu füllen
		for item in templates[id]:
			_add_new_position(item)

func _on_save_all_pressed():
	print("Speichere Angebot...")
	print("Firma: ", input_firma.text)
	print("Berichtstyp: ", selected_report_type)
	print("Summe: ", total_sum_label.text)
