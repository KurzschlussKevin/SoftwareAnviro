extends Control

@onready var blur_layer = $BlurLayer
@onready var edit_modal = $EditModal

@onready var btn_save = $EditModal/Panel/M/VBox/HBoxButtons/SaveBtn
@onready var btn_cancel = $EditModal/Panel/M/VBox/HBoxButtons/CancelBtn

# Demo Button im Template
@onready var demo_edit_btn = $VBox/ScrollContainer/GridContainer/UserTemplate/M/HBox/Actions/Settings

# Referenz zur Kundenliste (Preissichtbarkeit)
@onready var customer_list = $"EditModal/Panel/M/VBox/TabContainer/Preissichtbarkeit (Kunden)/VBoxPrices/ScrollContainer/CustomerList"
@onready var customer_template = customer_list.get_node("CustomerTemplate")

func _ready():
	blur_layer.visible = false
	edit_modal.visible = false
	
	btn_cancel.pressed.connect(close_modal)
	btn_save.pressed.connect(_on_save_pressed)
	demo_edit_btn.pressed.connect(open_modal)
	
	# Template standardmäßig verstecken oder für Demo duplizieren
	# Wir erstellen hier einfach mal 5 Dummy-Einträge für die Preis-Sichtbarkeit
	for i in range(5):
		var new_row = customer_template.duplicate()
		new_row.visible = true
		new_row.get_node("Name").text = "Beispielkunde " + str(i+1) + " GmbH"
		customer_list.add_child(new_row)
		
	# Das Original-Template verstecken wir jetzt
	customer_template.visible = false

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
	print("Mitarbeiter Rechte gespeichert!")
	close_modal()
