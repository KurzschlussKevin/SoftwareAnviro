extends Control

@onready var blur_layer = $BlurLayer
@onready var edit_modal = $EditModal

# Referenzen UI (Buttons)
@onready var btn_save = $EditModal/Panel/M/VBox/HBoxButtons/SaveBtn
@onready var btn_cancel = $EditModal/Panel/M/VBox/HBoxButtons/CancelBtn
@onready var demo_edit_btn = $VBox/ScrollContainer/GridContainer/KundenTemplate/M/VBox/Actions/Settings

# Logik Stammdaten
@onready var tab_container = $EditModal/Panel/M/VBox/TabContainer
@onready var check_work_loc = $EditModal/Panel/M/VBox/TabContainer/Stammdaten/ScrollContainer/VBoxData/CheckWorkLoc
@onready var container_work_loc = $EditModal/Panel/M/VBox/TabContainer/Stammdaten/ScrollContainer/VBoxData/ContainerWorkLoc
@onready var check_ap2 = $EditModal/Panel/M/VBox/TabContainer/Stammdaten/ScrollContainer/VBoxData/CheckAP2
@onready var container_ap2 = $EditModal/Panel/M/VBox/TabContainer/Stammdaten/ScrollContainer/VBoxData/ContainerAP2

# Eingabefelder Stammdaten (Beispiele zum Leeren)
@onready var input_firma = $EditModal/Panel/M/VBox/TabContainer/Stammdaten/ScrollContainer/VBoxData/Firma
@onready var input_kundennr = $EditModal/Panel/M/VBox/TabContainer/Stammdaten/ScrollContainer/VBoxData/Kundennr

# Logik Arbeitsauftrag (Mitarbeiter)
@onready var emp_list = $EditModal/Panel/M/VBox/TabContainer/Arbeitsauftrag/VBoxTask/ScrollContainerEmployees/EmployeeList
@onready var emp_template = $EditModal/Panel/M/VBox/TabContainer/Arbeitsauftrag/VBoxTask/ScrollContainerEmployees/EmployeeList/EmployeeTemplate
@onready var btn_add_emp = $EditModal/Panel/M/VBox/TabContainer/Arbeitsauftrag/VBoxTask/AddEmployeeBtn

# Logik Arbeitsauftrag (Positionen)
@onready var btn_add_pos = $EditModal/Panel/M/VBox/TabContainer/Arbeitsauftrag/VBoxTask/AddPosBtn
@onready var positions_list = $EditModal/Panel/M/VBox/TabContainer/Arbeitsauftrag/VBoxTask/ScrollContainer/PositionsList
@onready var pos_template = $EditModal/Panel/M/VBox/TabContainer/Arbeitsauftrag/VBoxTask/ScrollContainer/PositionsList/PositionTemplate
@onready var scroll_container_table = $EditModal/Panel/M/VBox/TabContainer/Arbeitsauftrag/VBoxTask/ScrollContainer
@onready var header_spacer = $EditModal/Panel/M/VBox/TabContainer/Arbeitsauftrag/VBoxTask/HeaderRow/HBox/ScrollbarSpacer

# Referenz zur Hauptliste (damit wir sie ausblenden können)
@onready var main_list_container = $VBox/ScrollContainer

func _ready():
	# Initialzustand
	blur_layer.visible = false
	edit_modal.visible = false
	container_work_loc.visible = false
	container_ap2.visible = false
	
	# Scrollbar fix (Tabelle)
	await get_tree().process_frame
	if is_instance_valid(scroll_container_table):
		var scroll_width = scroll_container_table.get_v_scroll_bar().size.x
		if scroll_width > 0:
			header_spacer.custom_minimum_size.x = scroll_width
		else:
			header_spacer.custom_minimum_size.x = 12.0
	
	# Signale verbinden
	btn_cancel.pressed.connect(close_modal)
	btn_save.pressed.connect(_on_save_pressed)
	if demo_edit_btn:
		demo_edit_btn.pressed.connect(open_modal)
	
	check_work_loc.toggled.connect(func(toggled): container_work_loc.visible = toggled)
	check_ap2.toggled.connect(func(toggled): container_ap2.visible = toggled)
	
	btn_add_emp.pressed.connect(_on_add_emp_pressed)
	btn_add_pos.pressed.connect(_on_add_pos_pressed)

func open_modal():
	blur_layer.visible = true
	edit_modal.visible = true
	
	edit_modal.scale = Vector2(0.9, 0.9)
	var tween = create_tween()
	tween.tween_property(edit_modal, "scale", Vector2(1.0, 1.0), 0.1).set_trans(Tween.TRANS_CUBIC)

func close_modal():
	blur_layer.visible = false
	edit_modal.visible = false
	
	# Liste wieder anzeigen
	if main_list_container:
		main_list_container.visible = true

func _on_save_pressed():
	print("Gespeichert!")
	close_modal()

func _on_add_emp_pressed():
	var new_row = emp_template.duplicate()
	new_row.visible = true
	
	# Löschen-Button Logik
	var delete_btn = new_row.get_node_or_null("DeleteEmpBtn")
	if delete_btn:
		delete_btn.pressed.connect(func(): new_row.queue_free())
	
	emp_list.add_child(new_row)

func _on_add_pos_pressed():
	var new_row = pos_template.duplicate()
	new_row.visible = true
	
	# Felder leeren und Standardwerte setzen
	for child in new_row.get_children():
		if child is LineEdit:
			child.text = ""
			if child.name == "Menge": child.text = "1"
			if child.name == "Preis" or child.name == "Gesamt": child.text = "0.00"
			if child.name == "Pos": child.text = str(positions_list.get_child_count() + 1)
			
	positions_list.add_child(new_row)

# --- NEU: WIRD VOM DASHBOARD AUFGERUFEN ---
func start_new_customer():
	print("Kundenverwaltung: Öffne Modal für neuen Kunden...")
	
	# 1. Liste im Hintergrund ausblenden
	if main_list_container:
		main_list_container.visible = false
	
	# 2. Modal öffnen
	open_modal()
	
	# 3. Tab auf den ersten Reiter zurücksetzen
	if tab_container:
		tab_container.current_tab = 0
		
	# 4. Felder leeren
	if input_firma: input_firma.text = ""
	if input_kundennr: input_kundennr.text = ""
	
	# 5. Checkboxen/Container resetten
	check_work_loc.button_pressed = false
	check_ap2.button_pressed = false
	container_work_loc.visible = false
	container_ap2.visible = false
	
	# 6. Fokus setzen
	if input_firma:
		input_firma.grab_focus()
