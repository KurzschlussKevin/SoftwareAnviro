extends Control

# Referenzen UI Settings
@onready var option_customer = $VBox/HBoxContent/MarginLeft/SettingsPanel/M/VBoxSet/OptionCustomer
@onready var spin_kw = $VBox/HBoxContent/MarginLeft/SettingsPanel/M/VBoxSet/HBoxTime/SpinKW
@onready var spin_year = $VBox/HBoxContent/MarginLeft/SettingsPanel/M/VBoxSet/HBoxTime/SpinYear
@onready var btn_export = $VBox/HBoxContent/MarginLeft/SettingsPanel/M/VBoxSet/BtnExport
@onready var btn_email = $VBox/HBoxContent/MarginLeft/SettingsPanel/M/VBoxSet/BtnEmail

# Referenzen UI Preview (Das "Papier")
@onready var prev_val_customer = $VBox/HBoxContent/MarginRight/PreviewPanel/M/VBoxDoc/GridInfo/ValCustomer
@onready var prev_val_time = $VBox/HBoxContent/MarginRight/PreviewPanel/M/VBoxDoc/GridInfo/ValTime
@onready var prev_list = $VBox/HBoxContent/MarginRight/PreviewPanel/M/VBoxDoc/PanelTable/Margin/LabelPlaceholder

func _ready():
	# Standard Datum setzen
	var time = Time.get_datetime_dict_from_system()
	spin_year.value = time.year
	# KW grob schätzen (für Demo reicht das)
	spin_kw.value = 50 
	
	# Signale verbinden
	option_customer.item_selected.connect(_on_settings_changed)
	spin_kw.value_changed.connect(func(v): _on_settings_changed(0))
	spin_year.value_changed.connect(func(v): _on_settings_changed(0))
	
	btn_export.pressed.connect(_on_export_pressed)
	btn_email.pressed.connect(_on_email_pressed)
	
	# Initial Update
	_on_settings_changed(0)

func _on_settings_changed(_idx):
	# Update Preview Texte
	var cust_name = option_customer.get_item_text(option_customer.selected)
	if option_customer.selected == 0:
		cust_name = "---"
		prev_list.text = "Bitte Kunde wählen..."
	else:
		# Hier würden wir echte Daten laden. Demo:
		prev_list.text = "- 10x Filterwechsel\n- 5x Reinigung\n- 2h Arbeitszeit (Max M.)"
	
	prev_val_customer.text = cust_name
	prev_val_time.text = "KW %d / %d" % [spin_kw.value, spin_year.value]
	
	# Email Button Text anpassen
	if option_customer.selected > 0:
		btn_email.text = "An kontakt@musterfirma.de senden"
	else:
		btn_email.text = "Per E-Mail senden"

func _on_export_pressed():
	# Demo Export
	btn_export.text = "Exportiere..."
	await get_tree().create_timer(1.0).timeout
	btn_export.text = "Erfolgreich gespeichert! ✓"
	await get_tree().create_timer(2.0).timeout
	btn_export.text = "HERUNTERLADEN"

func _on_email_pressed():
	if option_customer.selected == 0: return
	btn_email.text = "Sende..."
	await get_tree().create_timer(1.0).timeout
	btn_email.text = "Gesendet! ✓"
	await get_tree().create_timer(2.0).timeout
	_on_settings_changed(0)
