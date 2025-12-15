extends Control

# --- DUMMY DATENBANK ---
var inventory = [
	{
		"id": 1,
		"name": "SECUTEST PRO",
		"manufacturer": "Gossen Metrawatt",
		"serial": "GM-2023-8842",
		"last_cal": "2023-11-01",
		"next_cal": "2024-11-01", # Bald fällig
		"standard": "DGUV V3 / VDE 0701-0702"
	},
	{
		"id": 2,
		"name": "Fluke 6500-2",
		"manufacturer": "Fluke",
		"serial": "FL-9921-X",
		"last_cal": "2023-05-15",
		"next_cal": "2024-05-15", # Abgelaufen!
		"standard": "VDE 0701-0702"
	},
	{
		"id": 3,
		"name": "Benning ST 725",
		"manufacturer": "Benning",
		"serial": "BN-7721-A",
		"last_cal": "2024-01-10",
		"next_cal": "2025-01-10", # OK
		"standard": "DGUV V3"
	}
]

# --- UI REFERENZEN ---
@onready var device_list = %DeviceList
@onready var input_name = %InputName
@onready var input_manuf = %InputManuf
@onready var input_serial = %InputSerial
@onready var input_norm = %InputNorm
@onready var input_last_cal = %InputLastCal
@onready var input_next_cal = %InputNextCal
@onready var status_badge = %StatusBadge

@onready var btn_save = %BtnSave
@onready var btn_new = %BtnNew

var current_selection_id = -1

func _ready():
	refresh_list()
	clear_form()
	
	# Signale
	device_list.item_selected.connect(_on_item_selected)
	btn_new.pressed.connect(_on_new_pressed)
	btn_save.pressed.connect(_on_save_pressed)

func refresh_list():
	device_list.clear()
	var today = Time.get_date_dict_from_system()
	var today_unix = Time.get_unix_time_from_datetime_string("%04d-%02d-%02d" % [today.year, today.month, today.day])
	
	for item in inventory:
		var status_icon = " ✅"
		
		# Einfache Datumsprüfung (Simulation)
		var next_cal_unix = Time.get_unix_time_from_datetime_string(item["next_cal"])
		# Warnung 30 Tage vorher (ca. 2.6 Mio Sekunden)
		if next_cal_unix < today_unix:
			status_icon = " ❌ (ABGELAUFEN)"
		elif next_cal_unix < (today_unix + 2600000):
			status_icon = " ⚠️ (Fällig)"
			
		var display_text = "%s - %s (%s)%s" % [item["manufacturer"], item["name"], item["serial"], status_icon]
		var idx = device_list.add_item(display_text)
		
		# ID als Metadaten speichern um sie beim Klick wiederzufinden
		device_list.set_item_metadata(idx, item["id"])

func _on_item_selected(index):
	var id = device_list.get_item_metadata(index)
	current_selection_id = id
	
	# Daten suchen
	var data = null
	for item in inventory:
		if item["id"] == id:
			data = item
			break
			
	if data:
		input_name.text = data["name"]
		input_manuf.text = data["manufacturer"]
		input_serial.text = data["serial"]
		input_norm.text = data.get("standard", "")
		input_last_cal.text = data["last_cal"]
		input_next_cal.text = data["next_cal"]
		
		update_status_visuals(data["next_cal"])

func update_status_visuals(next_cal_str):
	var today = Time.get_unix_time_from_system()
	var next = Time.get_unix_time_from_datetime_string(next_cal_str)
	
	if next < today:
		status_badge.text = " KALIBRIERUNG ABGELAUFEN "
		status_badge.modulate = Color(1, 0.3, 0.3) # Rot
	elif next < (today + 2600000):
		status_badge.text = " KALIBRIERUNG BALD FÄLLIG "
		status_badge.modulate = Color(1, 0.8, 0.2) # Gelb
	else:
		status_badge.text = " EINSATZBEREIT "
		status_badge.modulate = Color(0.4, 1.0, 0.5) # Grün

func _on_new_pressed():
	current_selection_id = -1
	device_list.deselect_all()
	clear_form()
	input_name.grab_focus()

func clear_form():
	input_name.text = ""
	input_manuf.text = ""
	input_serial.text = ""
	input_norm.text = ""
	input_last_cal.text = ""
	input_next_cal.text = ""
	status_badge.text = " NEUES GERÄT "
	status_badge.modulate = Color.WHITE

func _on_save_pressed():
	print("Speichere Prüfmittel...")
	# Hier würde der Code stehen, um 'inventory' zu updaten oder neuen Eintrag zu pushen
	refresh_list()
