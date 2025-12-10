extends Control

# --- UI REFERENZEN RECHTS ---
@onready var scroll_container_table = $HBox/RightCol/PositionsPanel/M/VBox/ScrollContainer
@onready var header_spacer = $HBox/RightCol/PositionsPanel/M/VBox/HeaderRow/HBox/ScrollbarSpacer
@onready var positions_list = $HBox/RightCol/PositionsPanel/M/VBox/ScrollContainer/PositionsList
@onready var pos_template = $HBox/RightCol/PositionsPanel/M/VBox/ScrollContainer/PositionsList/PositionTemplate

# --- UI REFERENZEN LINKS ---
@onready var check_work_loc = $HBox/LeftCol/KundenPanel/M/ScrollContainer/VBox/CheckWorkLoc
@onready var check_ap2 = $HBox/LeftCol/KundenPanel/M/ScrollContainer/VBox/CheckAP2
@onready var container_work_loc = $HBox/LeftCol/KundenPanel/M/ScrollContainer/VBox/ContainerWorkLoc
@onready var container_ap2 = $HBox/LeftCol/KundenPanel/M/ScrollContainer/VBox/ContainerAP2

# Eingabefelder
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
# Mock-Buttons für Demo
@onready var btn_cust_1 = $CustomerSelectModal/Center/Panel/VBox/Scroll/CustomerList/BtnCust1
@onready var btn_cust_2 = $CustomerSelectModal/Center/Panel/VBox/Scroll/CustomerList/BtnCust2

func _ready():
	# Scrollbar Fix
	await get_tree().process_frame
	if is_instance_valid(scroll_container_table):
		var width = scroll_container_table.get_v_scroll_bar().size.x
		header_spacer.custom_minimum_size.x = width if width > 0 else 12.0
	
	# Formular
	check_work_loc.toggled.connect(_on_work_loc_toggled)
	check_ap2.toggled.connect(_on_ap2_toggled)
	container_work_loc.visible = false
	container_ap2.visible = false
	
	# Berichte
	if btn_report_general: btn_report_general.pressed.connect(_on_btn_report_general_pressed)
	if btn_report_travel: btn_report_travel.pressed.connect(_on_btn_report_travel_pressed)
	if btn_report_combined: btn_report_combined.pressed.connect(_on_btn_report_combined_pressed)
	
	# Auswahl Modal
	if select_modal: select_modal.visible = false
	if btn_cancel_select: btn_cancel_select.pressed.connect(func(): select_modal.visible = false)
	
	# Demo-Auswahl Logik
	if btn_cust_1: btn_cust_1.pressed.connect(func(): _select_customer("Musterfirma GmbH", "KD-1001"))
	if btn_cust_2: btn_cust_2.pressed.connect(func(): _select_customer("Bäckerei Müller", "KD-1002"))

func _on_work_loc_toggled(toggled_on: bool):
	container_work_loc.visible = toggled_on

func _on_ap2_toggled(toggled_on: bool):
	container_ap2.visible = toggled_on

func _on_btn_report_general_pressed(): print("Bericht Allgemein")
func _on_btn_report_travel_pressed(): print("Bericht Reise")
func _on_btn_report_combined_pressed(): print("Bericht Kombi")

# Helper: Kunde auswählen
func _select_customer(firma: String, nr: String):
	input_firma.text = firma
	input_kundennr.text = nr
	select_modal.visible = false
	print("Kunde übernommen: ", firma)

# --- WIRD VOM DASHBOARD AUFGERUFEN ---
func start_new_offer():
	print("Vertrieb: Starte neues Angebot mit Auswahl...")
	
	# 1. Reset Formular
	if input_firma: input_firma.text = ""
	if input_kundennr: input_kundennr.text = ""
	if input_plz: input_plz.text = ""
	if input_stadt: input_stadt.text = ""
	if input_strasse: input_strasse.text = ""
	
	check_work_loc.button_pressed = false
	check_ap2.button_pressed = false
	container_work_loc.visible = false
	container_ap2.visible = false
	
	# 2. Positionen leeren
	if positions_list:
		for child in positions_list.get_children():
			if child != pos_template:
				child.queue_free()
	
	# 3. Auswahl-Modal anzeigen (anstatt direkt Fokus)
	if select_modal:
		select_modal.visible = true
