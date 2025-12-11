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

# --- AUSWAHL MODAL (NEU) ---
@onready var select_modal = $CustomerSelectModal
@onready var btn_cancel_select = $CustomerSelectModal/Center/Panel/VBox/CancelSelectBtn
@onready var btn_cust_1 = $CustomerSelectModal/Center/Panel/VBox/Scroll/CustomerList/BtnCust1
@onready var btn_cust_2 = $CustomerSelectModal/Center/Panel/VBox/Scroll/CustomerList/BtnCust2

func _ready():
	await get_tree().process_frame
	if is_instance_valid(scroll_container_table):
		var width = scroll_container_table.get_v_scroll_bar().size.x
		header_spacer.custom_minimum_size.x = width if width > 0 else 12.0
	
	check_work_loc.toggled.connect(func(t): container_work_loc.visible = t)
	check_ap2.toggled.connect(func(t): container_ap2.visible = t)
	container_work_loc.visible = false
	container_ap2.visible = false
	
	if btn_report_general: btn_report_general.pressed.connect(func(): print("Bericht General"))
	if btn_report_travel: btn_report_travel.pressed.connect(func(): print("Bericht Reise"))
	if btn_report_combined: btn_report_combined.pressed.connect(func(): print("Bericht Kombi"))
	
	# Auswahl Modal Logik
	if select_modal: select_modal.visible = false
	if btn_cancel_select: btn_cancel_select.pressed.connect(func(): select_modal.visible = false)
	
	# Demo: Kunde wählen
	if btn_cust_1: btn_cust_1.pressed.connect(func(): _select_customer("Musterfirma GmbH", "KD-1001"))
	if btn_cust_2: btn_cust_2.pressed.connect(func(): _select_customer("Bäckerei Müller", "KD-1002"))

func _select_customer(firma: String, nr: String):
	input_firma.text = firma
	input_kundennr.text = nr
	select_modal.visible = false
	print("Kunde gewählt: ", firma)

# --- NEU: Startet den Prozess "Neues Angebot" ---
func start_offer_selection():
	print("Vertrieb: Öffne Kundenauswahl...")
	
	# 1. Alles leeren
	input_firma.text = ""
	input_kundennr.text = ""
	
	# 2. Modal öffnen
	if select_modal:
		select_modal.visible = true
