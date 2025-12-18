extends Control

# Simulierte Dokumenten-Datenbank
var documents = [
	{"id": 1, "name": "Prüfprotokoll_Anlage_3.pdf", "date": "18.12.2025", "type": "protocol", "size": "1.2 MB", "customer": "Bäckerei Müller"},
	{"id": 2, "name": "Rechnung_RE-2025-004.pdf", "date": "15.12.2025", "type": "invoice", "size": "0.4 MB", "customer": "Industrie AG"},
	{"id": 3, "name": "Montagebericht_KW50.pdf", "date": "12.12.2025", "type": "report", "size": "2.1 MB", "customer": "Kfz Schrauber"},
	{"id": 4, "name": "Mängelliste_Halle1.pdf", "date": "01.12.2025", "type": "protocol", "size": "0.8 MB", "customer": "Industrie AG"}
]

@onready var doc_list = %DocList
@onready var filter_input = %FilterInput
@onready var option_filter = %OptionFilter
@onready var btn_upload = %BtnUpload
@onready var file_dialog = %FileDialog

# Details Bereich
@onready var details_box = %DetailsBox
@onready var empty_state = %EmptyState
@onready var val_name = %ValName
@onready var val_date = %ValDate
@onready var val_size = %ValSize
@onready var progress_bar = %ProgressBar

# Buttons im Detail Bereich
@onready var btn_open = $MainLayout/Inspector/M/DetailsBox/BtnOpen
@onready var btn_print = $MainLayout/Inspector/M/DetailsBox/BtnPrint
@onready var btn_mail = $MainLayout/Inspector/M/DetailsBox/BtnMail

var selected_doc = null

func _ready():
	_refresh_list()
	
	# Signale verbinden
	filter_input.text_changed.connect(func(t): _refresh_list())
	option_filter.item_selected.connect(func(i): _refresh_list())
	btn_upload.pressed.connect(_on_upload_pressed)
	file_dialog.file_selected.connect(_on_file_selected)
	
	# Action Buttons
	btn_print.pressed.connect(_simulate_action.bind("Drucken..."))
	btn_mail.pressed.connect(_simulate_action.bind("Sende E-Mail..."))
	btn_open.pressed.connect(func(): OS.shell_open("https://google.com")) # Dummy Link

func _refresh_list():
	# Liste leeren
	for child in doc_list.get_children():
		child.queue_free()
	
	var filter_txt = filter_input.text.to_lower()
	var type_filter = option_filter.get_selected_id() # 0=All, 1=Protocol, 2=Invoice
	
	for doc in documents:
		# Suche
		if filter_txt != "" and not filter_txt in doc.name.to_lower() and not filter_txt in doc.customer.to_lower():
			continue
			
		# Typ Filter
		if type_filter == 1 and doc.type != "protocol": continue
		if type_filter == 2 and doc.type != "invoice": continue
		
		_create_doc_item(doc)

func _create_doc_item(doc):
	var btn = Button.new()
	btn.custom_minimum_size.y = 60
	
	# Style
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.15, 0.2)
	style.border_width_left = 4
	style.content_margin_left = 15
	
	if doc.type == "invoice": style.border_color = Color(0.8, 0.6, 0.2) # Orange
	else: style.border_color = Color(0.3, 0.5, 0.9) # Blau
	
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_stylebox_override("hover", style.duplicate()) # Todo: Heller machen
	
	# Text Layout
	btn.text = " " + doc.name + " (" + doc.customer + ") - " + doc.date
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	
	# Klick Event
	btn.pressed.connect(func(): _select_document(doc))
	
	doc_list.add_child(btn)

func _select_document(doc):
	selected_doc = doc
	empty_state.visible = false
	details_box.visible = true
	
	val_name.text = doc.name
	val_date.text = doc.date
	val_size.text = doc.size

func _on_upload_pressed():
	file_dialog.visible = true

func _on_file_selected(path):
	# Simuliert den Upload
	var file_name = path.get_file()
	var new_doc = {
		"id": randi(),
		"name": file_name,
		"date": Time.get_date_string_from_system(),
		"type": "protocol",
		"size": "Unknown",
		"customer": "Upload"
	}
	documents.push_front(new_doc)
	_refresh_list()
	_select_document(new_doc)

func _simulate_action(action_name):
	if progress_bar.visible: return
	
	btn_print.disabled = true
	btn_mail.disabled = true
	progress_bar.visible = true
	progress_bar.value = 0
	
	# Fake Ladebalken
	var tween = create_tween()
	tween.tween_property(progress_bar, "value", 100, 1.5)
	await tween.finished
	
	progress_bar.visible = false
	btn_print.disabled = false
	btn_mail.disabled = false
	print(action_name + " abgeschlossen!")
