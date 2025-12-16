extends Control

# --- DUMMY DATENBANK ---
var customer_db = [
	{
		"id": 0, 
		"name": "Bäckerei Müller GmbH", 
		"address_invoice": "Hauptstr. 1, 12345 Teighausen",
		"address_site": "Filiale West, Brotgasse 5",
		"contact_main": "Frau Müller (Buchhaltung)",
		"contact_site": "Herr Teig (Filialleiter)",
		"email": "rechnung@baeckerei-mueller.de",
		"phone": "0123 456789",
		"last_check": "2023-01-15",
		"interval": 12,
		"more_contacts": [
			{"name": "Kevin Kurzschluss", "role": "IT-Support", "contact": "0170-123456"}
		]
	},
	{
		"id": 1, 
		"name": "Kfz-Werkstatt Schrauber", 
		"address_invoice": "Ölweg 9, 54321 Motorstadt",
		"address_site": "Ölweg 9, 54321 Motorstadt",
		"contact_main": "Meister Eder",
		"contact_site": "Meister Eder",
		"email": "werkstatt@schrauber.de",
		"phone": "0987 654321",
		"last_check": "2023-11-20",
		"interval": 12,
		"more_contacts": []
	}
]

# --- UI REFERENZEN ---
@onready var customer_list = %CustomerList
@onready var search_bar = %SearchBar

# Stammdaten
@onready var input_name = %InputName
@onready var input_addr_invoice = %InputAddrInvoice
@onready var input_addr_site = %InputAddrSite
@onready var input_contact_main = %InputContactMain
@onready var input_contact_site = %InputContactSite
@onready var input_mail = %InputMail
@onready var input_phone = %InputPhone

# Dynamische Kontaktliste
@onready var contact_list_container = %ContactListContainer
@onready var btn_add_contact = %BtnAddContact

# Prüfdaten
@onready var input_last_date = %InputLastDate
@onready var input_interval = %InputInterval
@onready var lbl_next_date = %LabelNextDate
@onready var status_badge = %StatusBadge

# Buttons
@onready var btn_save = %BtnSave
@onready var btn_new = %BtnNew
@onready var btn_delete = %BtnDelete

var current_customer_id = -1

func _ready():
	refresh_list()
	clear_form()
	
	customer_list.item_selected.connect(_on_item_selected)
	search_bar.text_changed.connect(_on_search_text_changed)
	
	btn_new.pressed.connect(_on_new_pressed)
	btn_save.pressed.connect(_on_save_pressed)
	btn_delete.pressed.connect(_on_delete_pressed)
	
	# Neu: Button Verbindung
	btn_add_contact.pressed.connect(func(): create_dynamic_contact_row("", "", ""))
	
	input_last_date.text_changed.connect(func(new_text): calculate_next_date())
	input_interval.item_selected.connect(func(idx): calculate_next_date())

func refresh_list(filter_text = ""):
	customer_list.clear()
	for cust in customer_db:
		if filter_text != "" and not filter_text.to_lower() in cust["name"].to_lower():
			continue
		
		var status_info = check_due_status(cust.get("last_check", ""), cust.get("interval", 12))
		var icon = "🟢"
		var color = Color.WHITE
		if status_info["status"] == "overdue":
			icon = "🔴"
			color = Color(1, 0.5, 0.5)
		elif status_info["status"] == "due_soon":
			icon = "🟡"
			color = Color(1, 0.9, 0.6)
			
		var idx = customer_list.add_item("%s %s" % [icon, cust["name"]])
		customer_list.set_item_metadata(idx, cust["id"])
		customer_list.set_item_custom_fg_color(idx, color)

func check_due_status(last_date_str, interval_months):
	if last_date_str == "": return {"status": "unknown", "days": 0, "next_str": "Unbekannt"}
	var last_date = Time.get_datetime_dict_from_datetime_string(last_date_str, false)
	if last_date.is_empty(): return {"status": "error", "days": 0, "next_str": "Fehler"}
	
	var last_unix = Time.get_unix_time_from_datetime_string(last_date_str)
	var interval_seconds = interval_months * 30 * 24 * 60 * 60
	var next_unix = last_unix + interval_seconds
	var today_unix = Time.get_unix_time_from_system()
	
	var diff_days = (next_unix - today_unix) / (24 * 60 * 60)
	var next_date_string = Time.get_datetime_string_from_unix_time(next_unix).left(10)
	
	if diff_days < 0: return {"status": "overdue", "days": diff_days, "next_str": next_date_string}
	elif diff_days < 30: return {"status": "due_soon", "days": diff_days, "next_str": next_date_string}
	else: return {"status": "ok", "days": diff_days, "next_str": next_date_string}

# DIESE FUNKTION HAT GEFEHLT:
func calculate_next_date():
	var date_str = input_last_date.text
	var interval_map = {0: 6, 1: 12, 2: 24}
	var months = interval_map.get(input_interval.selected, 12)
	
	var result = check_due_status(date_str, months)
	
	lbl_next_date.text = result["next_str"]
	
	match result["status"]:
		"ok":
			status_badge.text = " ✅ GÜLTIG "
			status_badge.modulate = Color.GREEN
			lbl_next_date.modulate = Color.WHITE
		"due_soon":
			status_badge.text = " ⚠️ BALD FÄLLIG "
			status_badge.modulate = Color.YELLOW
			lbl_next_date.modulate = Color.YELLOW
		"overdue":
			status_badge.text = " ❌ ÜBERFÄLLIG! "
			status_badge.modulate = Color.RED
			lbl_next_date.modulate = Color.RED
		_:
			status_badge.text = " -- "
			status_badge.modulate = Color.WHITE

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
		input_addr_invoice.text = data.get("address_invoice", "")
		input_addr_site.text = data.get("address_site", "")
		input_contact_main.text = data.get("contact_main", "")
		input_contact_site.text = data.get("contact_site", "")
		input_mail.text = data["email"]
		input_phone.text = data["phone"]
		
		input_last_date.text = data.get("last_check", "")
		var interval = data.get("interval", 12)
		match interval:
			6: input_interval.selected = 0
			12: input_interval.selected = 1
			24: input_interval.selected = 2
			_: input_interval.selected = 1
		
		calculate_next_date()
		
		# --- Dynamische Kontakte laden ---
		for child in contact_list_container.get_children():
			child.queue_free()
		
		var more = data.get("more_contacts", [])
		for c in more:
			create_dynamic_contact_row(c.get("name", ""), c.get("role", ""), c.get("contact", ""))

func create_dynamic_contact_row(name_val, role_val, contact_val):
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	
	var i_name = LineEdit.new()
	i_name.placeholder_text = "Name..."
	i_name.text = name_val
	i_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var i_role = LineEdit.new()
	i_role.placeholder_text = "Funktion/Rolle..."
	i_role.text = role_val
	i_role.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var i_contact = LineEdit.new()
	i_contact.placeholder_text = "Tel / E-Mail..."
	i_contact.text = contact_val
	i_contact.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var btn_del = Button.new()
	btn_del.text = " X "
	btn_del.modulate = Color(1, 0.5, 0.5)
	btn_del.pressed.connect(func(): row.queue_free())
	
	row.add_child(i_name)
	row.add_child(i_role)
	row.add_child(i_contact)
	row.add_child(btn_del)
	
	contact_list_container.add_child(row)

func _on_search_text_changed(new_text):
	refresh_list(new_text)

func _on_new_pressed():
	current_customer_id = -1
	customer_list.deselect_all()
	clear_form()
	input_name.grab_focus()

func clear_form():
	input_name.text = ""
	input_addr_invoice.text = ""
	input_addr_site.text = ""
	input_contact_main.text = ""
	input_contact_site.text = ""
	input_mail.text = ""
	input_phone.text = ""
	input_last_date.text = Time.get_date_string_from_system()
	input_interval.selected = 1
	calculate_next_date()
	
	for child in contact_list_container.get_children():
		child.queue_free()

func _on_save_pressed():
	print("Speichere Kunden...")
	if current_customer_id != -1:
		for c in customer_db:
			if c["id"] == current_customer_id:
				c["name"] = input_name.text
				# Hier würde man alle Felder speichern...
				
				var new_contacts = []
				for row in contact_list_container.get_children():
					var n = row.get_child(0).text
					var r = row.get_child(1).text
					var k = row.get_child(2).text
					if n != "":
						new_contacts.append({"name": n, "role": r, "contact": k})
				c["more_contacts"] = new_contacts
				break
	
	refresh_list()
	print("Gespeichert inkl. Zusatzkontakte.")

func _on_delete_pressed():
	print("Lösche Kunde...")
