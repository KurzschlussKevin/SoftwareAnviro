extends Control

signal settings_saved

# --- UI REFERENZEN ---
# Firma
@onready var input_name = %InputName
@onready var input_addr = %InputAddr
@onready var input_tax = %InputTax
@onready var input_mail = %InputMail
# Bank & Rechtliches
@onready var input_iban = %InputIBAN
@onready var input_bic = %InputBIC
@onready var input_bank = %InputBank
@onready var input_ceo = %InputCEO

# Darstellung
@onready var color_picker = %ColorAccent
@onready var slider_scale = %SliderScale
@onready var lbl_scale_val = %LabelScaleVal
@onready var check_darkmode = %CheckDarkMode

# Benutzer (NEU: Tree statt ItemList)
@onready var user_tree = %UserTree
@onready var btn_add_user = %BtnAddUser
@onready var btn_reset_pwd = %BtnResetPwd

# System
@onready var check_autosave = %CheckAutoSave
@onready var lbl_version = %LabelVersion
@onready var btn_load_backup = %BtnLoadBackup # NEU

# Buttons
@onready var btn_save = %BtnSave
@onready var btn_cancel = %BtnCancel
@onready var btn_delete_data = %BtnDeleteData

# --- DATENSPEICHER ---
var current_config = {
	"company_name": "Musterprüfservice GmbH",
	"address": "Stromweg 1\n12345 Volthausen",
	"tax_id": "DE123456789",
	"email": "info@pruefservice.de",
	"iban": "DE00 1234 5678 9000 0000 00",
	"bic": "ABCDEFGH",
	"bank": "Volksbank",
	"ceo": "Max Mustermann",
	"accent_color": Color(0.2, 0.6, 1.0),
	"ui_scale": 1.0,
	"darkmode": true,
	"autosave": true
}

func _ready():
	load_settings_to_ui()
	setup_user_tree() # Baum aufbauen
	
	btn_save.pressed.connect(_on_save_pressed)
	btn_cancel.pressed.connect(_on_cancel_pressed)
	btn_delete_data.pressed.connect(_on_delete_pressed)
	btn_load_backup.pressed.connect(_on_load_backup_pressed) # Neu verbinden
	
	slider_scale.value_changed.connect(func(v): lbl_scale_val.text = "%d %%" % (v * 100))
	if lbl_version: lbl_version.text = "SoftwareAnviro v0.8.3 (Beta)"

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

func setup_user_tree():
	user_tree.clear()
	# Root-Item (unsichtbar, aber notwendig als Anker)
	var root = user_tree.create_item()
	user_tree.hide_root = true 
	
	# 1. Ebene: Geschäftsführung
	var boss = user_tree.create_item(root)
	boss.set_text(0, "Geschäftsführung (Admin)")
	boss.set_selectable(0, true)
	
	# 2. Ebene: Teamleiter Nord
	var tl_nord = user_tree.create_item(root)
	tl_nord.set_text(0, "Teamleiter Prüfservice Nord (Michael Master)")
	tl_nord.collapsed = false # Standardmäßig aufgeklappt
	
	# Mitarbeiter unter TL Nord
	var ma1 = user_tree.create_item(tl_nord)
	ma1.set_text(0, "Kevin Kurzschluss (Prüfer)")
	
	var ma2 = user_tree.create_item(tl_nord)
	ma2.set_text(0, "Lisa Lötkolben (Azubi)")
	
	# 2. Ebene: Teamleiter Süd
	var tl_sued = user_tree.create_item(root)
	tl_sued.set_text(0, "Teamleiter Prüfservice Süd (Sven Spannung)")
	tl_sued.collapsed = true # Zugeklappt starten
	
	# Mitarbeiter unter TL Süd
	var ma3 = user_tree.create_item(tl_sued)
	ma3.set_text(0, "Peter Phase (Prüfer)")

func _on_save_pressed():
	# Daten speichern (Logik wie vorher)
	print("Einstellungen gespeichert.")
	settings_saved.emit()
	visible = false

func _on_cancel_pressed():
	load_settings_to_ui()
	visible = false

func _on_delete_pressed():
	print("ACHTUNG: Werksreset angefordert!")

func _on_load_backup_pressed():
	print("Öffne Datei-Dialog für Backup-Import...")
	# Hier würde man einen FileDialog öffnen
	# $FileDialog.popup()
