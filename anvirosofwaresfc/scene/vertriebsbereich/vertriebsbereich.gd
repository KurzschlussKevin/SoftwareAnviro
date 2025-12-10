extends Control

# --- UI REFERENZEN RECHTS (Tabelle) ---
@onready var scroll_container_table = $HBox/RightCol/PositionsPanel/M/VBox/ScrollContainer
@onready var header_spacer = $HBox/RightCol/PositionsPanel/M/VBox/HeaderRow/HBox/ScrollbarSpacer
@onready var positions_list = $HBox/RightCol/PositionsPanel/M/VBox/ScrollContainer/PositionsList
@onready var pos_template = $HBox/RightCol/PositionsPanel/M/VBox/ScrollContainer/PositionsList/PositionTemplate

# --- UI REFERENZEN LINKS (Formular) ---
@onready var check_work_loc = $HBox/LeftCol/KundenPanel/M/ScrollContainer/VBox/CheckWorkLoc
@onready var check_ap2 = $HBox/LeftCol/KundenPanel/M/ScrollContainer/VBox/CheckAP2
@onready var container_work_loc = $HBox/LeftCol/KundenPanel/M/ScrollContainer/VBox/ContainerWorkLoc
@onready var container_ap2 = $HBox/LeftCol/KundenPanel/M/ScrollContainer/VBox/ContainerAP2

# Eingabefelder (für Reset)
@onready var input_firma = $HBox/LeftCol/KundenPanel/M/ScrollContainer/VBox/Firma
@onready var input_kundennr = $HBox/LeftCol/KundenPanel/M/ScrollContainer/VBox/Kundennr
@onready var input_plz = $HBox/LeftCol/KundenPanel/M/ScrollContainer/VBox/Row/PLZ
@onready var input_stadt = $HBox/LeftCol/KundenPanel/M/ScrollContainer/VBox/Row/Stadt
@onready var input_strasse = $HBox/LeftCol/KundenPanel/M/ScrollContainer/VBox/Strasse

# --- BERICHT BUTTONS ---
@onready var btn_report_general = $HBox/LeftCol/ReportPanel/M/VBox/BtnReportGeneral
@onready var btn_report_travel = $HBox/LeftCol/ReportPanel/M/VBox/BtnReportTravel
@onready var btn_report_combined = $HBox/LeftCol/ReportPanel/M/VBox/BtnReportCombined

func _ready():
	# 1. Tabellen-Fix (Scrollbar-Breite)
	await get_tree().process_frame
	if is_instance_valid(scroll_container_table):
		var scrollbar_width = scroll_container_table.get_v_scroll_bar().size.x
		if scrollbar_width > 0:
			header_spacer.custom_minimum_size.x = scrollbar_width
		else:
			header_spacer.custom_minimum_size.x = 12.0
	
	# 2. Signale für Formular verbinden
	check_work_loc.toggled.connect(_on_work_loc_toggled)
	check_ap2.toggled.connect(_on_ap2_toggled)
	
	# 3. Initialzustand setzen
	container_work_loc.visible = false
	container_ap2.visible = false
	
	# 4. Signale für Berichte verbinden
	if btn_report_general:
		btn_report_general.pressed.connect(_on_btn_report_general_pressed)
	if btn_report_travel:
		btn_report_travel.pressed.connect(_on_btn_report_travel_pressed)
	if btn_report_combined:
		btn_report_combined.pressed.connect(_on_btn_report_combined_pressed)
		
	# Template initial verstecken (optional, falls es stört)
	# pos_template.visible = false

func _on_work_loc_toggled(toggled_on: bool):
	container_work_loc.visible = toggled_on

func _on_ap2_toggled(toggled_on: bool):
	container_ap2.visible = toggled_on

# --- FUNKTIONEN FÜR BERICHTE ---

func _on_btn_report_general_pressed():
	print("Erstelle allgemeinen Montagebericht (für diverse Typen)...")

func _on_btn_report_travel_pressed():
	print("Erstelle Reise-/Übernachtungsbericht...")

func _on_btn_report_combined_pressed():
	print("Erstelle Kombi-Bericht (Montage + Reise)...")

# --- NEU: WIRD VOM DASHBOARD AUFGERUFEN ---
func start_new_offer():
	print("Vertrieb: Starte neues Angebot (Felder leeren)")
	
	# 1. Hauptfelder leeren
	if input_firma: input_firma.text = ""
	if input_kundennr: input_kundennr.text = ""
	if input_plz: input_plz.text = ""
	if input_stadt: input_stadt.text = ""
	if input_strasse: input_strasse.text = ""
	
	# 2. Checkboxen zurücksetzen
	check_work_loc.button_pressed = false
	check_ap2.button_pressed = false
	container_work_loc.visible = false
	container_ap2.visible = false
	
	# 3. Positionstabelle leeren (alle außer das Template)
	for child in positions_list.get_children():
		if child != pos_template:
			child.queue_free()
			
	# 4. Fokus setzen
	if input_firma:
		input_firma.grab_focus()
