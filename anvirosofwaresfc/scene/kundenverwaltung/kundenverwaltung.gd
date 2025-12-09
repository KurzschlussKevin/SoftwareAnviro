extends Control

@onready var blur_layer = $BlurLayer
@onready var edit_modal = $EditModal

# Referenzen UI (Buttons)
@onready var btn_save = $EditModal/Panel/M/VBox/HBoxButtons/SaveBtn
@onready var btn_cancel = $EditModal/Panel/M/VBox/HBoxButtons/CancelBtn
@onready var demo_edit_btn = $VBox/ScrollContainer/GridContainer/KundenTemplate/M/VBox/Actions/Settings

# Logik Stammdaten
@onready var check_work_loc = $EditModal/Panel/M/VBox/TabContainer/Stammdaten/ScrollContainer/VBoxData/CheckWorkLoc
@onready var container_work_loc = $EditModal/Panel/M/VBox/TabContainer/Stammdaten/ScrollContainer/VBoxData/ContainerWorkLoc
@onready var check_ap2 = $EditModal/Panel/M/VBox/TabContainer/Stammdaten/ScrollContainer/VBoxData/CheckAP2
@onready var container_ap2 = $EditModal/Panel/M/VBox/TabContainer/Stammdaten/ScrollContainer/VBoxData/ContainerAP2

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

func _ready():
	# Initialzustand
	blur_layer.visible = false
	edit_modal.visible = false
	container_work_loc.visible = false
	container_ap2.visible = false
	
	# Scrollbar fix (Tabelle)
	await get_tree().process_frame
	var scroll_width = scroll_container_table.get_v_scroll_bar().size.x
	if scroll_width > 0:
		header_spacer.custom_minimum_size.x = scroll_width
	else:
		header_spacer.custom_minimum_size.x = 12.0
	
	# Signale verbinden
	btn_cancel.pressed.connect(close_modal)
	btn_save.pressed.connect(_on_save_pressed)
	demo_edit_btn.pressed.connect(open_modal)
	
	check_work_loc.toggled.connect(func(toggled): container_work_loc.visible = toggled)
	check_ap2.toggled.connect(func(toggled): container_ap2.visible = toggled)
	
	btn_add_emp.pressed.connect(_on_add_emp_pressed)
	btn_add_pos.pressed.connect(_on_add_pos_pressed)
	
	# Templates verstecken (wir nutzen sie nur zum Kopieren)
	# (Alternativ kann man das erste sichtbar lassen, aber so ist es sauberer)
	# emp_template.visible = false 
	# pos_template.visible = false

func open_modal():
	blur_layer.visible = true
	edit_modal.visible = true
	
	edit_modal.scale = Vector2(0.9, 0.9)
	var tween = create_tween()
	tween.tween_property(edit_modal, "scale", Vector2(1.0, 1.0), 0.1).set_trans(Tween.TRANS_CUBIC)

func close_modal():
	blur_layer.visible = false
	edit_modal.visible = false

func _on_save_pressed():
	print("Gespeichert!")
	close_modal()

func _on_add_emp_pressed():
	var new_row = emp_template.duplicate()
	new_row.visible = true
	
	# Löschen-Button Logik
	var delete_btn = new_row.get_node("DeleteEmpBtn")
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
