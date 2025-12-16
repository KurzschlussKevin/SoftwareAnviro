extends Control

# --- DUMMY DATENBANK ---
var customer_db = [
	{
		"id": 0, 
		"name": "Bäckerei Müller GmbH", 
		"addr_street": "Hauptstr. 1",
		"addr_city": "12345 Teighausen",
		"addr_site_street": "Brotgasse 5",
		"addr_site_city": "12345 Teighausen",
		
		"contact_main_name": "Frau Müller",
		"contact_main_mail": "buchhaltung@baeckerei.de",
		"contact_main_tel": "0711-123456",
		"contact_main_mob": "",
		"contact_site_name": "Herr Teig",
		"contact_site_mail": "",
		"contact_site_tel": "0711-987654",
		"contact_site_mob": "0170-99887766",
		
		# PRÜF-DATEN
		# Geräte 1 (Büro)
		"date_devices": "2022-05-01", 
		"int_devices": 2, # 24 Mon
		
		# Geräte 2 (Produktion) - VORHANDEN
		"has_devices_2": true,
		"date_devices_2": "2023-11-01",
		"int_devices_2": 1, # 12 Mon
		
		"date_machines": "2023-11-01", 
		"int_machines": 1, 
		"date_systems": "2020-06-01", 
		"int_systems": 3, 
		
		"more_contacts": []
	},
	{
		"id": 1, 
		"name": "Kfz-Werkstatt Schrauber", 
		"addr_street": "Ölweg 9",
		"addr_city": "54321 Motorstadt",
		"addr_site_street": "",
		"addr_site_city": "",
		"contact_main_name": "Meister Eder",
		"contact_site_name": "",
		
		"date_devices": "2023-11-20", 
		"int_devices": 1,
		"has_devices_2": false, # Kein 2. Bereich
		
		"more_contacts": []
	}
]

# --- UI REFERENZEN ---
@onready var customer_list = %CustomerList
@onready var search_bar = %SearchBar

# Stammdaten
@onready var input_name = %InputName
@onready var input_street = %InputStreet
@onready var input_city = %InputCity
@onready var check_site_addr = %CheckSiteAddr
@onready var container_site_addr = %ContainerSiteAddr
@onready var input_site_street = %InputSiteStreet
@onready var input_site_city = %InputSiteCity

# Kontakte
@onready var input_main_name = %InputMainName
@onready var input_main_mail = %InputMainMail
@onready var input_main_tel = %InputMainTel
@onready var input_main_mob = %InputMainMob
@onready var check_sec_contact = %CheckSecContact
@onready var card_site_contact = %CardSite
@onready var input_site_name = %InputSiteName
@onready var input_site_mail = %InputSiteMail
@onready var input_site_tel = %InputSiteTel
@onready var input_site_mob = %InputSiteMob
@onready var contact_list_container = %ContactListContainer
@onready var btn_add_contact = %BtnAddContact

# --- PRÜF-MANAGEMENT ---
# 1. Geräte (Standard/Büro)
@onready var input_date_devices = %InputDateDevices
@onready var input_int_devices = %InputIntDevices
@onready var lbl_res_devices = %LabelResDevices

# NEU: 1b. Geräte (Produktion/Zusatz)
@onready var check_devices_2 = %CheckDevices2
@onready var container_devices_2 = %ContainerDevices2
@onready var input_date_devices_2 = %InputDateDevices2
@onready var input_int_devices_2 = %InputIntDevices2
@onready var lbl_res_devices_2 = %LabelResDevices2

# 2. Maschinen
@onready var input_date_machines = %InputDateMachines
@onready var input_int_machines = %InputIntMachines
@onready var lbl_res_machines = %LabelResMachines

# 3. Anlagen
@onready var input_date_systems = %InputDateSystems
@onready var input_int_systems = %InputIntSystems
@onready var lbl_res_systems = %LabelResSystems

@onready var status_badge = %StatusBadge

# Buttons
@onready var btn_save = %BtnSave
@onready var btn_new = %BtnNew
@onready var btn_delete = %BtnDelete

var current_customer_id = -1

func _ready():
	refresh_list()
	clear_form()
	
	# Initialzustände Checkboxen
	container_site_addr.visible = false
	check_site_addr.button_pressed = false
	check_site_addr.toggled.connect(func(t): container_site_addr.visible = t)
	
	card_site_contact.visible = false
	check_sec_contact.button_pressed = false
	check_sec_contact.toggled.connect(func(t): card_site_contact.visible = t)
	
	container_devices_2.visible = false
	check_devices_2.button_pressed = false
	check_devices_2.toggled.connect(func(t): 
		container_devices_2.visible = t
		calculate_all_dates() # Neu berechnen wenn aktiviert
	)
	
	customer_list.item_selected.connect(_on_item_selected)
	search_bar.text_changed.connect(_on_search_text_changed)
	
	btn_new.pressed.connect(_on_new_pressed)
	btn_save.pressed.connect(_on_save_pressed)
	btn_delete.pressed.connect(_on_delete_pressed)
	btn_add_contact.pressed.connect(func(): create_dynamic_contact_row("", "", "", ""))
	
	# Auto-Berechnung für ALLE Felder
	var all_date_inputs = [input_date_devices, input_date_devices_2, input_date_machines, input_date_systems]
	for input in all_date_inputs:
		input.text_changed.connect(func(t): calculate_all_dates())
		
	var all_drops = [input_int_devices, input_int_devices_2, input_int_machines, input_int_systems]
	for drop in all_drops:
		drop.item_selected.connect(func(i): calculate_all_dates())

func refresh_list(filter_text = ""):
	customer_list.clear()
	for cust in customer_db:
		if filter_text != "" and not filter_text.to_lower() in cust["name"].to_lower():
			continue
		
		# Ampel berechnen (Worst Case aus allen aktiven Kategorien)
		var s1 = check_due_status(cust.get("date_devices", ""), get_months(cust.get("int_devices", 1)))
		var s2 = check_due_status(cust.get("date_machines", ""), get_months(cust.get("int_machines", 1)))
		var s3 = check_due_status(cust.get("date_systems", ""), get_months(cust.get("int_systems", 3)))
		
		var s1b = {"status": "ok"}
		if cust.get("has_devices_2", false):
			s1b = check_due_status(cust.get("date_devices_2", ""), get_months(cust.get("int_devices_2", 1)))
		
		var icon = "🟢"
		var color = Color(0.8, 0.8, 0.8)
		
		# Wenn IRGENDEINER überfällig ist -> Rot
		if "overdue" in [s1["status"], s1b["status"], s2["status"], s3["status"]]:
			icon = "🔴"
			color = Color(1, 0.6, 0.6)
		elif "due_soon" in [s1["status"], s1b["status"], s2["status"], s3["status"]]:
			icon = "🟡"
			color = Color(1, 0.9, 0.6)
			
		var idx = customer_list.add_item("%s %s" % [icon, cust["name"]])
		customer_list.set_item_metadata(idx, cust["id"])
		customer_list.set_item_custom_fg_color(idx, color)

func get_months(index):
	match index:
		0: return 6
		1: return 12
		2: return 24
		3: return 48
		_: return 12

func check_due_status(last_date_str, interval_months):
	if last_date_str == "" or last_date_str == null: return {"status": "unknown", "next_str": "-"}
	var last_date = Time.get_datetime_dict_from_datetime_string(last_date_str, false)
	if last_date.is_empty(): return {"status": "error", "next_str": "Fehler"}
	
	var last_unix = Time.get_unix_time_from_datetime_string(last_date_str)
	var interval_seconds = interval_months * 30 * 24 * 60 * 60
	var next_unix = last_unix + interval_seconds
	var today_unix = Time.get_unix_time_from_system()
	
	var diff_days = (next_unix - today_unix) / (24 * 60 * 60)
	var next_date_string = Time.get_datetime_string_from_unix_time(next_unix).left(10)
	
	if diff_days < 0: return {"status": "overdue", "next_str": next_date_string}
	elif diff_days < 30: return {"status": "due_soon", "next_str": next_date_string}
	else: return {"status": "ok", "next_str": next_date_string}

func calculate_all_dates():
	# Geräte 1
	var res1 = check_due_status(input_date_devices.text, get_months(input_int_devices.selected))
	lbl_res_devices.text = res1["next_str"]
	style_label(lbl_res_devices, res1["status"])
	
	# Geräte 2 (nur wenn aktiv)
	var res1b = {"status": "ok", "next_str": "-"}
	if check_devices_2.button_pressed:
		res1b = check_due_status(input_date_devices_2.text, get_months(input_int_devices_2.selected))
		lbl_res_devices_2.text = res1b["next_str"]
		style_label(lbl_res_devices_2, res1b["status"])
	
	# Maschinen
	var res2 = check_due_status(input_date_machines.text, get_months(input_int_machines.selected))
	lbl_res_machines.text = res2["next_str"]
	style_label(lbl_res_machines, res2["status"])
	
	# Anlagen
	var res3 = check_due_status(input_date_systems.text, get_months(input_int_systems.selected))
	lbl_res_systems.text = res3["next_str"]
	style_label(lbl_res_systems, res3["status"])
	
	var all_stats = [res1["status"], res2["status"], res3["status"]]
	if check_devices_2.button_pressed:
		all_stats.append(res1b["status"])
	
	if "overdue" in all_stats:
		status_badge.text = " ⚠️ HANDLUNGSBEDARF "
		status_badge.modulate = Color.RED
	elif "due_soon" in all_stats:
		status_badge.text = " BALD FÄLLIG "
		status_badge.modulate = Color.YELLOW
	else:
		status_badge.text = " ✅ ALLES OK "
		status_badge.modulate = Color.GREEN

func style_label(lbl, status):
	match status:
		"overdue": lbl.modulate = Color(1, 0.4, 0.4)
		"due_soon": lbl.modulate = Color(1, 0.9, 0.4)
		"ok": lbl.modulate = Color(0.6, 1, 0.6)
		_: lbl.modulate = Color.WHITE

func _on_item_selected(index):
	var id = customer_list.get_item_metadata(index)
	current_customer_id = id
	
	var data = null
	for c in customer_db:
		if c["id"] == id:
			data = c
			break
			
	if data:
		input_name.text = data["name"]
		input_street.text = data.get("addr_street", "")
		input_city.text = data.get("addr_city", "")
		
		# Abweichende Adresse
		var s_street = data.get("addr_site_street", "")
		if s_street != "":
			check_site_addr.button_pressed = true
			container_site_addr.visible = true
			input_site_street.text = s_street
			input_site_city.text = data.get("addr_site_city", "")
		else:
			check_site_addr.button_pressed = false
			container_site_addr.visible = false
			input_site_street.text = ""
			input_site_city.text = ""
		
		# Kontakte
		input_main_name.text = data.get("contact_main_name", "")
		input_main_mail.text = data.get("contact_main_mail", "")
		input_main_tel.text = data.get("contact_main_tel", "")
		input_main_mob.text = data.get("contact_main_mob", "")
		
		var site_name = data.get("contact_site_name", "")
		if site_name != "":
			check_sec_contact.button_pressed = true
			card_site_contact.visible = true
			input_site_name.text = site_name
			input_site_mail.text = data.get("contact_site_mail", "")
			input_site_tel.text = data.get("contact_site_tel", "")
			input_site_mob.text = data.get("contact_site_mob", "")
		else:
			check_sec_contact.button_pressed = false
			card_site_contact.visible = false
			input_site_name.text = ""
			input_site_mail.text = ""
			input_site_tel.text = ""
			input_site_mob.text = ""
		
		# Fristen
		input_date_devices.text = data.get("date_devices", "")
		input_int_devices.selected = data.get("int_devices", 1)
		
		# Geräte 2 (Checkbutton)
		if data.get("has_devices_2", false):
			check_devices_2.button_pressed = true
			container_devices_2.visible = true
			input_date_devices_2.text = data.get("date_devices_2", "")
			input_int_devices_2.selected = data.get("int_devices_2", 1)
		else:
			check_devices_2.button_pressed = false
			container_devices_2.visible = false
			input_date_devices_2.text = ""
		
		input_date_machines.text = data.get("date_machines", "")
		input_int_machines.selected = data.get("int_machines", 1)
		
		input_date_systems.text = data.get("date_systems", "")
		input_int_systems.selected = data.get("int_systems", 3)
		
		calculate_all_dates()
		
		for child in contact_list_container.get_children(): child.queue_free()
		for c in data.get("more_contacts", []):
			create_dynamic_contact_row(c.get("name"), c.get("email"), c.get("phone"), c.get("mobile"))

func create_dynamic_contact_row(name, email, phone, mobile):
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	var i_name = LineEdit.new(); i_name.text=name; i_name.placeholder_text="Name"; i_name.size_flags_horizontal=3
	var i_mail = LineEdit.new(); i_mail.text=email; i_mail.placeholder_text="Email"; i_mail.size_flags_horizontal=3
	var i_tel = LineEdit.new(); i_tel.text=phone; i_tel.placeholder_text="Tel"; i_tel.size_flags_horizontal=3
	var i_mob = LineEdit.new(); i_mob.text=mobile; i_mob.placeholder_text="Mobil"; i_mob.size_flags_horizontal=3
	var btn = Button.new(); btn.text=" X "; btn.pressed.connect(func(): row.queue_free())
	row.add_child(i_name); row.add_child(i_mail); row.add_child(i_tel); row.add_child(i_mob); row.add_child(btn)
	contact_list_container.add_child(row)

func _on_search_text_changed(new_text): refresh_list(new_text)

func _on_new_pressed():
	current_customer_id = -1
	customer_list.deselect_all()
	clear_form()
	input_name.grab_focus()

func clear_form():
	input_name.text = ""
	input_street.text = ""
	input_city.text = ""
	check_site_addr.button_pressed = false
	container_site_addr.visible = false
	input_site_street.text = ""
	input_site_city.text = ""
	input_main_name.text = ""
	input_main_mail.text = ""
	input_main_tel.text = ""
	input_main_mob.text = ""
	check_sec_contact.button_pressed = false
	card_site_contact.visible = false
	input_site_name.text = ""
	input_site_mail.text = ""
	input_site_tel.text = ""
	input_site_mob.text = ""
	
	input_date_devices.text = ""
	check_devices_2.button_pressed = false
	container_devices_2.visible = false
	input_date_devices_2.text = ""
	
	input_date_machines.text = ""
	input_date_systems.text = ""
	input_int_devices.selected = 1
	calculate_all_dates()
	for child in contact_list_container.get_children(): child.queue_free()

func _on_save_pressed():
	print("Speichere...")
	refresh_list()

func _on_delete_pressed(): print("Lösche...")
