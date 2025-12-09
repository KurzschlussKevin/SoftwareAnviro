extends Control

# VIEWS
@onready var blur_layer = $BlurLayer
@onready var view_select = $ViewSelect
@onready var view_main = $ViewMain
@onready var view_socket_details = $ViewSocketDetails

# SELECT UI
@onready var option_customer = $ViewSelect/Panel/M/VBox/OptionCustomer
@onready var btn_start = $ViewSelect/Panel/M/VBox/BtnStart

# MAIN UI (Links)
@onready var report_list = $ViewMain/HBoxContent/LeftCol/PanelList/M/VBoxList/ReportList
@onready var btn_back_select = $ViewMain/Header/M/HBox/BtnBackToSelect
@onready var label_main_title = $ViewMain/Header/M/HBox/LabelTitle

# MAIN UI (Rechts)
@onready var lbl_title = $ViewMain/HBoxContent/RightCol/PanelReport/M/VBoxOut/HeaderReport/VBoxInfo/LabelReportTitle
@onready var lbl_date = $ViewMain/HBoxContent/RightCol/PanelReport/M/VBoxOut/HeaderReport/VBoxInfo/LabelReportDate

@onready var btn_230 = $ViewMain/HBoxContent/RightCol/PanelReport/M/VBoxOut/HBoxStats/Btn230
@onready var lbl_count_230 = $ViewMain/HBoxContent/RightCol/PanelReport/M/VBoxOut/HBoxStats/Btn230/VBox/LabelCount230
@onready var btn_400 = $ViewMain/HBoxContent/RightCol/PanelReport/M/VBoxOut/HBoxStats/Btn400
@onready var lbl_count_400 = $ViewMain/HBoxContent/RightCol/PanelReport/M/VBoxOut/HBoxStats/Btn400/VBox/LabelCount400
@onready var btn_total = $ViewMain/HBoxContent/RightCol/PanelReport/M/VBoxOut/HBoxStats/BtnTotal
@onready var lbl_count_total = $ViewMain/HBoxContent/RightCol/PanelReport/M/VBoxOut/HBoxStats/BtnTotal/VBox/LabelCountTotal

@onready var defect_container = $ViewMain/HBoxContent/RightCol/PanelReport/M/VBoxOut/ScrollDefects/DefectList
@onready var defect_template = $ViewMain/HBoxContent/RightCol/PanelReport/M/VBoxOut/ScrollDefects/DefectList/DefectTemplate

# DETAILS UI
@onready var btn_back_main = $ViewSocketDetails/Header/M/HBox/BtnBackToMain
@onready var lbl_detail_title = $ViewSocketDetails/Header/M/HBox/LabelDetailTitle
@onready var socket_list = $ViewSocketDetails/Content/PanelList/M/Scroll/SocketList
@onready var socket_template = $ViewSocketDetails/Content/PanelList/M/Scroll/SocketList/SocketTemplate

# Demo-Datenbank
var current_customer = ""
var reports = [
	{
		"title": "Halle 3 - Prüfung",
		"date": "09.12.2025 - 14:30 Uhr",
		"count_230": 42,
		"count_400": 12,
		"defects": [
			{"text": "Steckdose 400V beschädigt (Halle 3, Tor 2)", "severity": "SCHWER"},
			{"text": "Abdeckung lose (Büro Meister)", "severity": "LEICHT"}
		]
	},
	{
		"title": "Bürogebäude A",
		"date": "08.12.2025 - 09:15 Uhr",
		"count_230": 156,
		"count_400": 0,
		"defects": []
	},
	{
		"title": "Werkstatt Süd",
		"date": "01.12.2025 - 11:00 Uhr",
		"count_230": 28,
		"count_400": 8,
		"defects": [
			{"text": "Isolierung Kabel defekt bei Maschine A", "severity": "GEFAHR"}
		]
	}
]

func _ready():
	show_view(view_select)
	defect_template.visible = false
	socket_template.visible = false
	
	# Signale
	btn_start.pressed.connect(_on_start_pressed)
	btn_back_select.pressed.connect(func(): show_view(view_select))
	report_list.item_selected.connect(_on_report_selected)
	
	# Drill-Down Signale
	btn_230.pressed.connect(func(): show_socket_details("230V"))
	btn_400.pressed.connect(func(): show_socket_details("400V"))
	btn_total.pressed.connect(func(): show_socket_details("ALL"))
	
	btn_back_main.pressed.connect(func(): show_view(view_main))

func show_view(target):
	view_select.visible = false
	view_main.visible = false
	view_socket_details.visible = false
	blur_layer.visible = false
	
	target.visible = true
	
	if target == view_select:
		blur_layer.visible = true

func _on_start_pressed():
	if option_customer.selected == 0: return
	current_customer = option_customer.get_item_text(option_customer.selected)
	label_main_title.text = "Prüfberichte: " + current_customer
	
	# Liste befüllen
	report_list.clear()
	for report in reports:
		report_list.add_item(report["title"] + " (" + report["date"] + ")")
	
	show_view(view_main)

func _on_report_selected(index):
	var data = reports[index]
	
	lbl_title.text = data["title"]
	lbl_date.text = "Erfasst am: " + data["date"]
	lbl_count_230.text = str(data["count_230"])
	lbl_count_400.text = str(data["count_400"])
	lbl_count_total.text = str(data["count_230"] + data["count_400"])
	
	# Mängel füllen
	for c in defect_container.get_children():
		if c != defect_template: c.queue_free()
		
	if data["defects"].size() == 0:
		var lbl = Label.new()
		lbl.text = "Keine Mängel verzeichnet."
		lbl.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		defect_container.add_child(lbl)
	else:
		for defect in data["defects"]:
			var row = defect_template.duplicate()
			row.visible = true
			row.get_node("M/HBox/LabelText").text = defect["text"]
			var lbl_sev = row.get_node("M/HBox/LabelSev")
			lbl_sev.text = defect["severity"]
			
			if defect["severity"] == "LEICHT":
				var s = row.get_theme_stylebox("panel").duplicate()
				s.border_color = Color.YELLOW
				row.add_theme_stylebox_override("panel", s)
				lbl_sev.add_theme_color_override("font_color", Color.YELLOW)
			elif defect["severity"] == "GEFAHR":
				var s = row.get_theme_stylebox("panel").duplicate()
				s.border_color = Color.RED
				row.add_theme_stylebox_override("panel", s)
				lbl_sev.add_theme_color_override("font_color", Color.RED)
			
			defect_container.add_child(row)

func show_socket_details(type):
	show_view(view_socket_details)
	
	# Liste leeren
	for c in socket_list.get_children():
		if c != socket_template: c.queue_free()
	
	var count = 0
	var title = ""
	
	if type == "230V":
		count = int(lbl_count_230.text)
		title = "Einzelnachweis: 230V Steckdosen"
	elif type == "400V":
		count = int(lbl_count_400.text)
		title = "Einzelnachweis: 400V Steckdosen"
	else:
		count = int(lbl_count_total.text)
		title = "Einzelnachweis: Alle Steckdosen"
		
	lbl_detail_title.text = "  " + title
	
	for i in range(count):
		var row = socket_template.duplicate()
		row.visible = true
		
		# Zufallsdaten
		var id = "ID-%04d" % (randi() % 9000 + 1000)
		var locs = ["Werkbank", "Bürowand", "Maschine B", "Eingangsbereich", "Teeküche"]
		var loc = locs[randi() % locs.size()]
		
		# Bei "ALL" mischen wir die Typen in den Text (simuliert)
		if type == "ALL":
			var socket_type = "230V" if randf() > 0.3 else "400V"
			id = socket_type + " " + id
		
		row.get_node("M/HBox/ID").text = id
		row.get_node("M/HBox/Loc").text = loc
		
		# Status (meist OK)
		if randf() > 0.1:
			row.get_node("M/HBox/Status").text = "PRÜFUNG OK"
			row.get_node("M/HBox/Status").add_theme_color_override("font_color", Color(0.2, 0.9, 0.5))
		else:
			row.get_node("M/HBox/Status").text = "DEFEKT"
			row.get_node("M/HBox/Status").add_theme_color_override("font_color", Color(1, 0.4, 0.4))
			var s = row.get_theme_stylebox("panel").duplicate()
			s.border_color = Color(1, 0.4, 0.4)
			row.add_theme_stylebox_override("panel", s)
			
		socket_list.add_child(row)
