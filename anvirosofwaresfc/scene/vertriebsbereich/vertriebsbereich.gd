extends Control

@onready var blur_layer = $BlurLayer

# --- ALTE ANSICHT (HBox mit LeftCol/RightCol) ---
@onready var main_view_container = $HBox
@onready var scroll_container_table = $HBox/RightCol/PositionsPanel/M/VBox/ScrollContainer
@onready var header_spacer = $HBox/RightCol/PositionsPanel/M/VBox/HeaderRow/HBox/ScrollbarSpacer
@onready var check_work_loc = $HBox/LeftCol/KundenPanel/M/ScrollContainer/VBox/CheckWorkLoc
@onready var check_ap2 = $HBox/LeftCol/KundenPanel/M/ScrollContainer/VBox/CheckAP2
@onready var container_work_loc = $HBox/LeftCol/KundenPanel/M/ScrollContainer/VBox/ContainerWorkLoc
@onready var container_ap2 = $HBox/LeftCol/KundenPanel/M/ScrollContainer/VBox/ContainerAP2
@onready var btn_report_general = $HBox/LeftCol/ReportPanel/M/VBox/BtnReportGeneral
@onready var btn_report_travel = $HBox/LeftCol/ReportPanel/M/VBox/BtnReportTravel
@onready var btn_report_combined = $HBox/LeftCol/ReportPanel/M/VBox/BtnReportCombined

# --- MODAL 1: KUNDEN AUSWÄHLEN ---
@onready var select_modal = $SelectCustomerModal
@onready var btn_select_cancel = $SelectCustomerModal/Panel/M/VBox/HBoxButtons/CancelSelect
@onready var btn_select_next = $SelectCustomerModal/Panel/M/VBox/HBoxButtons/NextBtn
@onready var customer_option = $SelectCustomerModal/Panel/M/VBox/CustomerOption

# --- MODAL 2: ANGEBOT ERSTELLEN (Nur Positionen) ---
@onready var create_modal = $CreateOfferModal
@onready var btn_create_cancel = $CreateOfferModal/Panel/M/VBox/HBoxButtons/CancelCreate
@onready var btn_create_save = $CreateOfferModal/Panel/M/VBox/HBoxButtons/SaveCreate
@onready var subtitle_label = $CreateOfferModal/Panel/M/VBox/Subtitle
@onready var positions_list = $CreateOfferModal/Panel/M/VBox/ScrollContainer/PositionsList
@onready var pos_template = $CreateOfferModal/Panel/M/VBox/ScrollContainer/PositionsList/PositionTemplate
@onready var btn_add_pos = $CreateOfferModal/Panel/M/VBox/AddPosBtn

# --- TEMPLATE LOGIK IM MODAL ---
@onready var template_option_modal = $CreateOfferModal/Panel/M/VBox/TemplateHBox/TemplateOption
@onready var btn_load_template_modal = $CreateOfferModal/Panel/M/VBox/TemplateHBox/LoadTemplateBtn

func _ready():
	# Initialzustand: Alte Ansicht sichtbar, Modals unsichtbar
	blur_layer.visible = false
	select_modal.visible = false
	create_modal.visible = false
	main_view_container.visible = true
	
	# Alte Logik (Scrollbar fix)
	await get_tree().process_frame
	if is_instance_valid(scroll_container_table):
		var width = scroll_container_table.get_v_scroll_bar().size.x
		header_spacer.custom_minimum_size.x = width if width > 0 else 12.0
	
	# Alte Logik (Toggle Container)
	check_work_loc.toggled.connect(func(t): container_work_loc.visible = t)
	check_ap2.toggled.connect(func(t): container_ap2.visible = t)
	container_work_loc.visible = false
	container_ap2.visible = false
	
	# --- BERICHTE BUTTONS (Wiederhergestellt) ---
	if btn_report_general: 
		btn_report_general.pressed.connect(func(): print("Erstelle Montagebericht (Typen)..."))
	if btn_report_travel: 
		btn_report_travel.pressed.connect(func(): print("Erstelle Reisebericht (Übernachtung)..."))
	if btn_report_combined: 
		btn_report_combined.pressed.connect(func(): print("Erstelle Kombi-Bericht..."))
	
	# --- MODALS VERBINDEN ---
	
	# Modal 1 Buttons
	btn_select_cancel.pressed.connect(close_all_modals)
	btn_select_next.pressed.connect(_on_next_pressed)
	
	# Modal 2 Buttons
	btn_create_cancel.pressed.connect(close_all_modals)
	btn_create_save.pressed.connect(_on_save_offer_pressed)
	btn_add_pos.pressed.connect(_on_add_pos_pressed)
	
	# Vorlage laden
	btn_load_template_modal.pressed.connect(_on_load_template_modal_pressed)

func close_all_modals():
	blur_layer.visible = false
	select_modal.visible = false
	create_modal.visible = false
	# Alte Ansicht wieder anzeigen
	main_view_container.visible = true

func _on_next_pressed():
	# Prüfen ob Kunde gewählt wurde
	if customer_option.selected == 0:
		print("Bitte wähle einen Kunden aus!")
		return
		
	var selected_customer_name = customer_option.get_item_text(customer_option.selected)
	
	# Modal 1 schließen, Modal 2 öffnen
	select_modal.visible = false
	create_modal.visible = true
	
	# Untertitel aktualisieren
	subtitle_label.text = "für " + selected_customer_name
	
	# Animation für Modal 2
	create_modal.scale = Vector2(0.9, 0.9)
	var tween = create_tween()
	tween.tween_property(create_modal, "scale", Vector2(1.0, 1.0), 0.1).set_trans(Tween.TRANS_CUBIC)

func _on_save_offer_pressed():
	print("Neues Angebot gespeichert!")
	close_all_modals()

func _on_add_pos_pressed():
	var new_row = pos_template.duplicate()
	new_row.visible = true
	_clear_row(new_row)
	positions_list.add_child(new_row)

func _clear_row(row):
	for child in row.get_children():
		if child is LineEdit:
			child.text = ""
			if child.name == "Menge": child.text = "1"
			if child.name == "Preis" or child.name == "Gesamt": child.text = "0.00"
			if child.name == "Pos": child.text = str(positions_list.get_child_count() + 1)

# --- VORLAGE IM MODAL LADEN ---
func _on_load_template_modal_pressed():
	var selected_id = template_option_modal.selected
	print("Lade Vorlage ID: ", selected_id)
	
	# 1. Bestehende (sichtbare) Zeilen löschen, außer Template
	for child in positions_list.get_children():
		if child != pos_template:
			child.queue_free()
	
	# 2. Neue Zeilen basierend auf Auswahl einfügen
	if selected_id == 1: # Website Standard
		_add_pos_row("Webdesign Grundpaket", "1", "1500.00")
		_add_pos_row("Hosting Einrichtung", "1", "250.00")
	elif selected_id == 2: # SEO
		_add_pos_row("SEO Analyse", "1", "800.00")
		_add_pos_row("Content Optimierung", "10", "120.00")
	else:
		print("Keine Vorlage gewählt")

func _add_pos_row(bez, menge, preis):
	var new_row = pos_template.duplicate()
	new_row.visible = true
	positions_list.add_child(new_row)
	
	# Werte setzen
	new_row.get_node("Bez").text = bez
	new_row.get_node("Menge").text = menge
	new_row.get_node("Preis").text = preis
	# Gesamt berechnen (simuliert)
	var gesamt = float(menge) * float(preis)
	new_row.get_node("Gesamt").text = "%.2f" % gesamt
	new_row.get_node("Pos").text = str(positions_list.get_child_count() - 1) # -1 wegen hidden template

# --- WIRD VOM DASHBOARD AUFGERUFEN ---
func start_new_offer():
	print("Vertrieb: Starte neues Angebot...")
	main_view_container.visible = false
	blur_layer.visible = true
	select_modal.visible = true
	create_modal.visible = false
	
	if customer_option:
		customer_option.selected = 0
	
	select_modal.scale = Vector2(0.9, 0.9)
	var tween = create_tween()
	tween.tween_property(select_modal, "scale", Vector2(1.0, 1.0), 0.1).set_trans(Tween.TRANS_CUBIC)
