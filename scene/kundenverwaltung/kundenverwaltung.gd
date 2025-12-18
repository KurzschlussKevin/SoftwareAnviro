extends Control

# --- DUMMY DATEN ---
var customers = [
	{
		"id": "1001", 
		"name": "Bäckerei Müller GmbH", 
		"city": "Berlin", 
		"address": "Hauptstr. 5\n10115 Berlin",
		"service_address": "Backstube Hinterhof\nHauptstr. 5a\n10115 Berlin", # Abweichend
		"contact": "Hr. Müller", 
		"phone": "030-12345",
		"email": "chef@baeckerei.de",
		"contact2_name": "Fr. Meier (Büro)",
		"contact2_phone": "030-12346",
		"notes": "Schlüssel beim Nachbarn holen.",
		"next_due": "2023-12-01", 
		"status": "overdue",
		"objects": ["Filiale Mitte (20 Geräte)", "Backstube (5 Maschinen)"],
		"history": ["10.12.2025: Angebot erstellt", "01.06.2023: Letzte Prüfung"]
	},
	{
		"id": "1002", 
		"name": "Kfz-Werkstatt Schrauber", 
		"city": "Hamburg",
		"address": "Hafenstr. 12\n20457 Hamburg", 
		"service_address": "", # Identisch (leer)
		"contact": "Fr. Schulze", 
		"phone": "040-998877",
		"email": "werkstatt@schrauber.com",
		"contact2_name": "",
		"contact2_phone": "",
		"notes": "",
		"next_due": "2025-05-15", 
		"status": "ok",
		"objects": ["Werkstatt Hauptgebäude", "Lackiererei"],
		"history": ["15.05.2024: Prüfung ohne Mängel"]
	},
	{
		"id": "1003", 
		"name": "Industrie AG", 
		"city": "München",
		"address": "Industriepark 1\n80331 München", 
		"service_address": "",
		"contact": "Dr. Technik", 
		"phone": "089-112233",
		"email": "technik@industrie-ag.de",
		"contact2_name": "Pforte Tor 3",
		"contact2_phone": "089-112244",
		"notes": "Sicherheitsschuhe erforderlich!",
		"next_due": "2024-01-20", 
		"status": "soon",
		"objects": ["Produktionshalle A", "Verwaltung", "Lager"],
		"history": ["20.01.2024: Prüfung fällig", "18.12.2023: Termin vereinbart"]
	}
]

# --- UI REFERENZEN HAUPTANSICHT ---
@onready var list_container = %CustomerList
@onready var search_input = %SearchInput
@onready var detail_panel = %DetailPanel
@onready var empty_label = %EmptyLabel
@onready var btn_edit = %BtnEdit

# --- DETAIL LABELS ---
@onready var lbl_name = %LblName
@onready var lbl_id = %LblID
@onready var val_address = %ValAddress
@onready var val_service_address = %ValServiceAddress # Neu
@onready var val_contact = %ValContact
@onready var val_contact2 = %ValContact2 # Neu
@onready var val_email = %ValEmail
@onready var val_notes = %ValNotes

@onready var obj_list = %ObjList
@onready var hist_list = %HistList

# --- EDIT OVERLAY REFERENZEN (Pfade angepasst an VBoxAddr) ---
@onready var edit_overlay = %EditOverlay
@onready var input_name = $EditOverlay/Panel/M/VBox/Scroll/Grid/InputName
@onready var input_id = $EditOverlay/Panel/M/VBox/Scroll/Grid/InputID

# Container für Adressen (damit Layout stabil bleibt)
@onready var input_addr = $EditOverlay/Panel/M/VBox/Scroll/Grid/VBoxAddr/InputAddr
@onready var check_service_loc = $EditOverlay/Panel/M/VBox/Scroll/Grid/VBoxAddr/CheckServiceLoc
@onready var container_service_addr = $EditOverlay/Panel/M/VBox/Scroll/Grid/VBoxAddr/ContainerServiceAddr
@onready var input_service_addr = $EditOverlay/Panel/M/VBox/Scroll/Grid/VBoxAddr/ContainerServiceAddr/InputServiceAddr

# Container Kontakt 1
@onready var input_contact = $EditOverlay/Panel/M/VBox/Scroll/Grid/VBoxC1/InputContact
@onready var input_phone = $EditOverlay/Panel/M/VBox/Scroll/Grid/VBoxC1/InputPhone
@onready var input_email = $EditOverlay/Panel/M/VBox/Scroll/Grid/VBoxC1/InputEmail

# Container Kontakt 2
@onready var input_contact2 = $EditOverlay/Panel/M/VBox/Scroll/Grid/VBoxC2/InputContact2
@onready var input_phone2 = $EditOverlay/Panel/M/VBox/Scroll/Grid/VBoxC2/InputPhone2

@onready var input_notes = $EditOverlay/Panel/M/VBox/Scroll/Grid/InputNotes

@onready var btn_cancel_edit = %BtnCancelEdit
@onready var btn_save_edit = %BtnSaveEdit

var current_customer = null

func _ready():
	_refresh_list()
	edit_overlay.visible = false
	
	# Signale verbinden
	search_input.text_changed.connect(func(t): _refresh_list())
	btn_edit.pressed.connect(_on_edit_pressed)
	
	btn_cancel_edit.pressed.connect(func(): edit_overlay.visible = false)
	btn_save_edit.pressed.connect(_on_save_changes_pressed)
	
	# Checkbox Logik (zeigt/versteckt das zusätzliche Adressfeld)
	check_service_loc.toggled.connect(func(active): container_service_addr.visible = active)

# --- ALARM SYSTEM (Für Dashboard Glocke) ---
func get_overdue_customer_recall_count() -> int:
	var count = 0
	for c in customers:
		if c.status == "overdue": count += 1
	return count

func get_overdue_alerts() -> Array:
	var alerts = []
	for c in customers:
		if c.status == "overdue": alerts.append("Prüfung fällig: " + c.name)
	return alerts

# --- LISTEN ANSICHT ---
func _refresh_list():
	for child in list_container.get_children():
		child.queue_free()
	
	var filter = search_input.text.to_lower()
	
	for c in customers:
		if filter != "" and not filter in c.name.to_lower() and not filter in c.city.to_lower():
			continue
		
		_create_list_item(c)

func _create_list_item(c):
	var btn = Button.new()
	btn.custom_minimum_size.y = 60
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.15, 0.2)
	style.content_margin_left = 10
	style.border_width_left = 5
	
	if c.status == "overdue": style.border_color = Color(0.9, 0.3, 0.3) # Rot
	elif c.status == "soon": style.border_color = Color(0.9, 0.7, 0.2) # Gelb
	else: style.border_color = Color(0.3, 0.8, 0.5) # Grün
	
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_stylebox_override("hover", style.duplicate())
	
	btn.text = c.name + "\n" + c.city
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	
	btn.pressed.connect(func(): _show_details(c))
	list_container.add_child(btn)

# --- DETAIL ANSICHT ---
func _show_details(c):
	current_customer = c
	empty_label.visible = false
	detail_panel.visible = true
	
	lbl_name.text = c.name
	lbl_id.text = "KD-Nr: " + c.id
	
	# Adresse
	val_address.text = c.address
	
	# Leistungsort Logik
	var s_addr = c.get("service_address", "")
	if s_addr == "" or s_addr == c.address:
		val_service_address.text = "Identisch mit Rechnung"
		val_service_address.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	else:
		val_service_address.text = s_addr
		val_service_address.add_theme_color_override("font_color", Color(0.2, 0.8, 0.6))
	
	# Kontakte
	val_contact.text = c.contact + "\n" + c.phone
	val_email.text = c.get("email", "-")
	
	var c2_name = c.get("contact2_name", "")
	if c2_name != "":
		val_contact2.text = c2_name + "\n" + c.get("contact2_phone", "")
	else:
		val_contact2.text = "-"
		
	val_notes.text = c.get("notes", "-")
	
	# Tabellen füllen
	for child in obj_list.get_children(): child.queue_free()
	for obj in c.objects:
		var l = Label.new()
		l.text = "• " + obj
		obj_list.add_child(l)
	
	for child in hist_list.get_children(): child.queue_free()
	for h in c.history:
		var l = Label.new()
		l.text = h
		l.modulate = Color(0.7, 0.7, 0.7)
		hist_list.add_child(l)

# --- EDITIEREN LOGIK ---
func _on_edit_pressed():
	if current_customer == null: return
	
	# 1. Felder vorfüllen
	input_name.text = current_customer.name
	input_id.text = current_customer.id
	input_addr.text = current_customer.address
	
	# 2. Prüfort Logik setzen
	var s_addr = current_customer.get("service_address", "")
	# Wenn Leistungsort existiert UND anders ist als Rechnungsadresse
	if s_addr != "" and s_addr != current_customer.address:
		check_service_loc.button_pressed = true
		container_service_addr.visible = true
		input_service_addr.text = s_addr
	else:
		check_service_loc.button_pressed = false
		container_service_addr.visible = false
		input_service_addr.text = "" # Leer lassen

	# 3. Kontakte füllen
	input_contact.text = current_customer.contact
	input_phone.text = current_customer.phone
	input_email.text = current_customer.get("email", "")
	
	input_contact2.text = current_customer.get("contact2_name", "")
	input_phone2.text = current_customer.get("contact2_phone", "")
	
	input_notes.text = current_customer.get("notes", "")
	
	edit_overlay.visible = true

func _on_save_changes_pressed():
	if current_customer == null: return
	
	# Daten zurückschreiben
	current_customer.name = input_name.text
	current_customer.address = input_addr.text
	
	# Prüfort speichern
	if check_service_loc.button_pressed:
		current_customer.service_address = input_service_addr.text
	else:
		current_customer.service_address = "" # Leer = Identisch
	
	current_customer.contact = input_contact.text
	current_customer.phone = input_phone.text
	current_customer.email = input_email.text
	
	current_customer.contact2_name = input_contact2.text
	current_customer.contact2_phone = input_phone2.text
	
	current_customer.notes = input_notes.text
	
	# UI Aktualisieren
	edit_overlay.visible = false
	_show_details(current_customer)
	_refresh_list()
