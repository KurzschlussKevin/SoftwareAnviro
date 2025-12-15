extends Control

signal settings_saved

# --- UI REFERENZEN ---
# Firma
@onready var input_name = %InputName
@onready var input_addr = %InputAddr
@onready var input_tax = %InputTax
@onready var input_mail = %InputMail
# Neu: Bank & Rechtliches
@onready var input_iban = %InputIBAN
@onready var input_bic = %InputBIC
@onready var input_bank = %InputBank
@onready var input_ceo = %InputCEO

# Darstellung (Neu)
@onready var color_picker = %ColorAccent
@onready var slider_scale = %SliderScale
@onready var lbl_scale_val = %LabelScaleVal

# System
@onready var check_darkmode = %CheckDarkMode
@onready var check_autosave = %CheckAutoSave
@onready var lbl_version = %LabelVersion

# Buttons
@onready var btn_save = %BtnSave
@onready var btn_cancel = %BtnCancel
@onready var btn_delete_data = %BtnDeleteData

# --- DATENSPEICHER ---
var current_config = {
	"company_name": "Musterhandwerk GmbH",
	"address": "Musterstraße 1\n12345 Musterstadt",
	"tax_id": "DE123456789",
	"email": "kontakt@musterhandwerk.de",
	"iban": "DE00 1234 5678 9000 0000 00",
	"bic": "ABCDEFGH",
	"bank": "Musterbank",
	"ceo": "Max Mustermann",
	"accent_color": Color(0.2, 0.6, 1.0), # Standard Blau
	"ui_scale": 1.0,
	"darkmode": true,
	"autosave": true
}

func _ready():
	load_settings_to_ui()
	
	btn_save.pressed.connect(_on_save_pressed)
	btn_cancel.pressed.connect(_on_cancel_pressed)
	btn_delete_data.pressed.connect(_on_delete_pressed)
	
	# UI Logik für Slider
	slider_scale.value_changed.connect(func(v): lbl_scale_val.text = "%d %%" % (v * 100))
	
	# Version setzen
	if lbl_version: lbl_version.text = "SoftwareAnviro v0.8.2 (Beta)"

func load_settings_to_ui():
	if input_name: input_name.text = current_config.get("company_name", "")
	if input_addr: input_addr.text = current_config.get("address", "")
	if input_tax: input_tax.text = current_config.get("tax_id", "")
	if input_mail: input_mail.text = current_config.get("email", "")
	
	if input_iban: input_iban.text = current_config.get("iban", "")
	if input_bic: input_bic.text = current_config.get("bic", "")
	if input_bank: input_bank.text = current_config.get("bank", "")
	if input_ceo: input_ceo.text = current_config.get("ceo", "")
	
	if color_picker: color_picker.color = current_config.get("accent_color", Color(0.2, 0.6, 1.0))
	if slider_scale: 
		slider_scale.value = current_config.get("ui_scale", 1.0)
		lbl_scale_val.text = "%d %%" % (slider_scale.value * 100)
	
	if check_darkmode: check_darkmode.button_pressed = current_config.get("darkmode", false)
	if check_autosave: check_autosave.button_pressed = current_config.get("autosave", false)

func _on_save_pressed():
	current_config["company_name"] = input_name.text
	current_config["address"] = input_addr.text
	current_config["tax_id"] = input_tax.text
	current_config["email"] = input_mail.text
	
	current_config["iban"] = input_iban.text
	current_config["bic"] = input_bic.text
	current_config["bank"] = input_bank.text
	current_config["ceo"] = input_ceo.text
	
	current_config["accent_color"] = color_picker.color
	current_config["ui_scale"] = slider_scale.value
	
	current_config["darkmode"] = check_darkmode.button_pressed
	current_config["autosave"] = check_autosave.button_pressed
	
	print("Einstellungen gespeichert: ", current_config)
	
	# Hier könnte man das Theme live reloaden:
	# RenderingServer.set_default_clear_color(...) 
	
	settings_saved.emit()
	visible = false

func _on_cancel_pressed():
	load_settings_to_ui()
	visible = false

func _on_delete_pressed():
	print("ACHTUNG: Datenlöschung angefordert!")
