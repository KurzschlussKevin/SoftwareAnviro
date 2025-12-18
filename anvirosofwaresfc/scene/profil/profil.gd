extends Control

@onready var label_name = %LabelName
@onready var label_initial = %LabelInitial

# Unsere neuen Statistik-Labels für Prüflinge
@onready var label_sockets = %LabelSocketsVal
@onready var label_systems = %LabelSystemsVal
@onready var label_machines = %LabelMachinesVal

@onready var btn_pass = $Margin/HBox/RightCol/ActionsPanel/M/VBox/BtnPass
@onready var check_dark = $Margin/HBox/RightCol/ActionsPanel/M/VBox/CheckDark

func _ready():
	# Benutzer Info
	label_name.text = "Kevin Prüfer"
	label_initial.text = "KP"
	
	# Statistik Daten: Geprüfte Betriebsmittel
	label_sockets.text = "1.250"  # Steckdosen
	label_systems.text = "35"     # Anlagen
	label_machines.text = "128"   # Maschinen
	
	# Signale verbinden
	btn_pass.pressed.connect(_on_pass_pressed)
	check_dark.toggled.connect(_on_dark_mode_toggled)

func _on_pass_pressed():
	btn_pass.text = "Funktion folgt..."
	btn_pass.disabled = true
	await get_tree().create_timer(1.0).timeout
	btn_pass.text = "Passwort ändern"
	btn_pass.disabled = false

func _on_dark_mode_toggled(active):
	print("Dunkelmodus: ", active)
