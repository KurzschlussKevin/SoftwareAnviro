extends Control

# --- UI REFERENZEN RECHTS (Tabelle) ---
@onready var scroll_container_table = $HBox/RightCol/PositionsPanel/M/VBox/ScrollContainer
@onready var header_spacer = $HBox/RightCol/PositionsPanel/M/VBox/HeaderRow/HBox/ScrollbarSpacer

# --- UI REFERENZEN LINKS (Formular) ---
@onready var check_work_loc = $HBox/LeftCol/KundenPanel/M/ScrollContainer/VBox/CheckWorkLoc
@onready var check_ap2 = $HBox/LeftCol/KundenPanel/M/ScrollContainer/VBox/CheckAP2
@onready var container_work_loc = $HBox/LeftCol/KundenPanel/M/ScrollContainer/VBox/ContainerWorkLoc
@onready var container_ap2 = $HBox/LeftCol/KundenPanel/M/ScrollContainer/VBox/ContainerAP2

# --- BERICHT BUTTONS ---
# Bitte Pfad ggf. prüfen, sollte aber passen durch die Struktur im tscn
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

func _on_work_loc_toggled(toggled_on: bool):
	container_work_loc.visible = toggled_on

func _on_ap2_toggled(toggled_on: bool):
	container_ap2.visible = toggled_on

# --- FUNKTIONEN FÜR BERICHTE ---

func _on_btn_report_general_pressed():
	print("Erstelle allgemeinen Montagebericht (für diverse Typen)...")
	# Code zum Öffnen/Erstellen des Berichts

func _on_btn_report_travel_pressed():
	print("Erstelle Reise-/Übernachtungsbericht...")
	# Code zum Öffnen/Erstellen des Berichts

func _on_btn_report_combined_pressed():
	print("Erstelle Kombi-Bericht (Montage + Reise)...")
	# Code zum Öffnen/Erstellen des kombinierten Berichts
