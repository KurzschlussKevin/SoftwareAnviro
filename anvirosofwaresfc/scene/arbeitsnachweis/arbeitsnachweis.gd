extends Control

# --- UI REFERENZEN ---
@onready var blur_layer = $BlurLayer
@onready var view_select = $ViewSelect
@onready var view_calendar = $ViewCalendar
@onready var view_details = $ViewDetails

# --- VIEW 1: KUNDEN SELECT ---
@onready var option_customer_select = $ViewSelect/Panel/MarginSelect/VBoxSelect/OptionCustomerSelect
@onready var btn_start = $ViewSelect/Panel/MarginSelect/VBoxSelect/BtnStart

# --- VIEW 2: CALENDAR ---
@onready var label_selected_cust = $ViewCalendar/Panel/MarginCal/VBoxCal/HBoxHeader/LabelSelectedCustomer
@onready var label_month_year = $ViewCalendar/Panel/MarginCal/VBoxCal/HBoxNav/LabelMonthYear
@onready var btn_prev_month = $ViewCalendar/Panel/MarginCal/VBoxCal/HBoxNav/BtnPrevMonth
@onready var btn_next_month = $ViewCalendar/Panel/MarginCal/VBoxCal/HBoxNav/BtnNextMonth
@onready var btn_back_select = $ViewCalendar/Panel/MarginCal/VBoxCal/HBoxHeader/BtnBackToSelect
@onready var grid_days = $ViewCalendar/Panel/MarginCal/VBoxCal/GridDays

# --- VIEW 3: DETAILS ---
@onready var tasks_container = $ViewDetails/ScrollContainer/TaskList/MarginTask/VBoxTasks
@onready var task_template = $ViewDetails/ScrollContainer/TaskList/MarginTask/VBoxTasks/TaskTemplate
@onready var label_detail_customer = $ViewDetails/HeaderInfo/MarginHeader/HBoxHeaderInfo/VBoxInfo/LabelDetailCustomer
@onready var btn_back_cal = $ViewDetails/HeaderInfo/MarginHeader/HBoxHeaderInfo/BtnBackToCal
@onready var btn_finish = $ViewDetails/FooterBar/MarginFooter/HBoxFooter/BtnFinish

# Auto-Save Status Label
@onready var lbl_autosave_status = $ViewDetails/FooterBar/MarginFooter/HBoxFooter/LabelAutoSaveStatus

@onready var option_employee = $ViewDetails/HeaderInfo/MarginHeader/HBoxHeaderInfo/VBoxInfo/HBoxUser/OptionEmployee
@onready var btn_add_colleague = $ViewDetails/HeaderInfo/MarginHeader/HBoxHeaderInfo/VBoxInfo/HBoxUser/BtnAddColleague
@onready var option_report_type = $ViewDetails/HeaderInfo/MarginHeader/HBoxHeaderInfo/VBoxInfo/HBoxTypeSelect/OptionReportType

# Datums-Steuerung (Detailansicht)
@onready var label_date_detail = $ViewDetails/HeaderInfo/MarginHeader/HBoxHeaderInfo/DateSelector/LabelDate
@onready var btn_prev_day = $ViewDetails/HeaderInfo/MarginHeader/HBoxHeaderInfo/DateSelector/BtnPrevDay
@onready var btn_next_day = $ViewDetails/HeaderInfo/MarginHeader/HBoxHeaderInfo/DateSelector/BtnNextDay
@onready var btn_today = $ViewDetails/HeaderInfo/MarginHeader/HBoxHeaderInfo/DateSelector/BtnToday


# --- DATA ---
var current_customer = ""
var current_report_type_id = 0 # 0=Montage, 1=Reise, 2=Kombi
var current_view_month = {} # {year, month}
var current_detail_unix = 0 # Unix-Timestamp für den ausgewählten Tag in Details
var session_data = {} 
var current_employee_id = 0
var colleagues = ["Lisa Müller", "Tom Technik"]

func _ready():
	# Start-Zustand
	show_view(view_select)
	task_template.visible = false
	
	# Aktuelle Zeit
	var time = Time.get_datetime_dict_from_system()
	current_view_month = { "year": time.year, "month": time.month }
	current_detail_unix = Time.get_unix_time_from_system()
	
	# --- SIGNALE VERBINDEN ---
	
	# Kunde wählen
	btn_start.pressed.connect(_on_start_pressed)
	btn_back_select.pressed.connect(func(): show_view(view_select))
	
	# Kalender Navigation
	btn_prev_month.pressed.connect(_on_prev_month)
	btn_next_month.pressed.connect(_on_next_month)
	
	# Details Navigation & Aktionen
	btn_prev_day.pressed.connect(_on_prev_day_details)
	btn_next_day.pressed.connect(_on_next_day_details)
	btn_today.pressed.connect(_on_today_details)
	btn_back_cal.pressed.connect(func(): show_view(view_calendar))
	
	# NEU: BtnFinish geht wieder direkt zum Kalender zurück (Speichern und Schließen)
	btn_finish.pressed.connect(func(): show_view(view_calendar))
	
	option_employee.item_selected.connect(_on_employee_change)
	btn_add_colleague.pressed.connect(_on_add_colleague)
	option_report_type.item_selected.connect(_on_report_type_changed)


func show_view(target_view):
	view_select.visible = false
	view_calendar.visible = false
	view_details.visible = false
	target_view.visible = true
	
	if target_view == view_select or target_view == view_calendar:
		# blur_layer.visible = false
		pass
	else:
		blur_layer.visible = true
		
	if target_view == view_calendar:
		build_calendar()

func _on_start_pressed():
	if option_customer_select.selected == 0: return
	current_customer = option_customer_select.get_item_text(option_customer_select.selected)
	label_selected_cust.text = "Kunde: " + current_customer
	show_view(view_calendar)

# --- KALENDER LOGIK ---
func build_calendar():
	for child in grid_days.get_children(): child.queue_free()
	
	var month_names = ["", "Januar", "Februar", "März", "April", "Mai", "Juni", "Juli", "August", "September", "Oktober", "November", "Dezember"]
	label_month_year.text = "%s %d" % [month_names[current_view_month.month], current_view_month.year]
	
	var first_date_str = "%d-%02d-01T12:00:00" % [current_view_month.year, current_view_month.month]
	var unix = Time.get_unix_time_from_datetime_string(first_date_str)
	var dt = Time.get_date_dict_from_unix_time(unix)
	var weekday = dt.weekday
	
	var days_in_month = 31
	if current_view_month.month in [4, 6, 9, 11]: days_in_month = 30
	elif current_view_month.month == 2:
		var y = current_view_month.year
		if (y % 4 == 0 and y % 100 != 0) or (y % 400 == 0): days_in_month = 29
		else: days_in_month = 28
	
	for i in range(weekday - 1):
		var spacer = Control.new()
		grid_days.add_child(spacer)
	
	for d in range(1, days_in_month + 1):
		var btn = Button.new()
		btn.text = str(d)
		btn.custom_minimum_size = Vector2(0, 60)
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		
		# Simpler Check für Farbe
		var date_key = "%02d.%02d.%d" % [d, current_view_month.month, current_view_month.year]
		if has_data_for_date(date_key):
			btn.modulate = Color(0.2, 0.9, 0.5)
		else:
			btn.modulate = Color(0.8, 0.8, 0.8)
		
		btn.pressed.connect(func(): open_day_details(d))
		grid_days.add_child(btn)

func has_data_for_date(date_str):
	if session_data.has(date_str) and session_data[date_str].has(current_customer):
		var types_data = session_data[date_str][current_customer]
		if not types_data.is_empty():
			return true
	return false

func _on_prev_month():
	current_view_month.month -= 1
	if current_view_month.month < 1:
		current_view_month.month = 12
		current_view_month.year -= 1
	build_calendar()

func _on_next_month():
	current_view_month.month += 1
	if current_view_month.month > 12:
		current_view_month.month = 1
		current_view_month.year += 1
	build_calendar()

# --- DETAILS LOGIK ---
func open_day_details(day: int):
	current_report_type_id = option_report_type.selected
	var date_str = "%d-%02d-%02dT12:00:00" % [current_view_month.year, current_view_month.month, day]
	current_detail_unix = Time.get_unix_time_from_datetime_string(date_str)
	update_detail_view()
	show_view(view_details)

func update_detail_view():
	var dt = Time.get_date_dict_from_unix_time(current_detail_unix)
	var date_str = "%02d.%02d.%d" % [dt.day, dt.month, dt.year]
	label_date_detail.text = date_str
	label_detail_customer.text = current_customer
	refresh_task_list()

func _on_report_type_changed(idx):
	current_report_type_id = idx
	refresh_task_list()

func _on_prev_day_details():
	current_detail_unix -= 86400
	update_detail_view()

func _on_next_day_details():
	current_detail_unix += 86400
	update_detail_view()

func _on_today_details():
	current_detail_unix = Time.get_unix_time_from_system()
	update_detail_view()

func refresh_task_list():
	for c in tasks_container.get_children():
		if c != task_template: c.queue_free()
	
	if current_report_type_id == 0: # Montage
		create_task("01", "Filterwechsel Typ A", 10, 2)
		create_task("02", "Reinigung Anlage", 5, 0)
	elif current_report_type_id == 1: # Reise
		create_task("R1", "Anfahrt (km)", 500, 0)
		create_task("R2", "Übernachtung", 1, 0)
	elif current_report_type_id == 2: # Kombi
		create_task("01", "Filterwechsel Typ A", 10, 2)
		create_task("R1", "Anfahrt (km)", 500, 0)

func create_task(pos_nr, title, total, done_prev):
	var date_key = label_date_detail.text
	if not session_data.has(date_key): session_data[date_key] = {}
	if not session_data[date_key].has(current_customer): session_data[date_key][current_customer] = {}
	
	var customer_data = session_data[date_key][current_customer]
	if not customer_data.has(current_report_type_id): customer_data[current_report_type_id] = {}
	
	var task_data_root = customer_data[current_report_type_id]
	if not task_data_root.has(pos_nr): task_data_root[pos_nr] = {}
	
	var user_values = task_data_root[pos_nr]
	
	var t = task_template.duplicate()
	t.visible = true
	t.get_node("MarginTpl/HBoxMain/VBoxLeft/HBoxTitle/PosNum").text = "#" + pos_nr
	t.get_node("MarginTpl/HBoxMain/VBoxLeft/HBoxTitle/PosTitle").text = title
	t.get_node("MarginTpl/HBoxMain/VBoxLeft/HBoxDetails/LabelTotal").text = "Gesamt: %d" % total
	
	var spin = t.get_node("MarginTpl/HBoxMain/VBoxInput/HBoxSpin/SpinBoxAmount")
	spin.max_value = 9999
	spin.value = user_values.get(current_employee_id, 0)
	
	var update = func(val):
		user_values[current_employee_id] = val
		var sum = done_prev
		for uid in user_values: sum += user_values[uid]
		
		t.get_node("MarginTpl/HBoxMain/VBoxLeft/HBoxDetails/LabelDonePrev").text = "Stand: %d" % sum
		t.get_node("MarginTpl/HBoxMain/VBoxLeft/ProgressBar").value = sum
		t.get_node("MarginTpl/HBoxMain/VBoxLeft/ProgressBar").max_value = total
		
		var rest = total - sum
		var lbl_rest = t.get_node("MarginTpl/HBoxMain/VBoxLeft/HBoxDetails/LabelRest")
		var lbl_status = t.get_node("MarginTpl/HBoxMain/VBoxLeft/HBoxTitle/StatusLabel")
		
		if rest == 0:
			lbl_rest.text = "Erledigt"
			lbl_status.text = "FERTIG"
			lbl_status.add_theme_color_override("font_color", Color(0.2, 0.9, 0.5))
		elif rest < 0:
			lbl_rest.text = "Mehrung: +%d" % abs(rest)
			lbl_status.text = "MEHRUNG"
			lbl_status.add_theme_color_override("font_color", Color(0.8, 0.4, 1.0))
		else:
			lbl_rest.text = "Offen: %d" % rest
			lbl_status.text = "IN ARBEIT"
			lbl_status.add_theme_color_override("font_color", Color(0.0, 0.8, 1.0))
		
		# NEU: Auto-Save Status anzeigen
		_show_autosave_status("Gespeichert (Entwurf)")
			
	spin.value_changed.connect(update)
	update.call(spin.value)
	tasks_container.add_child(t)

# NEU: Funktion zur Anzeige des Auto-Save-Status
func _show_autosave_status(text_to_show: String):
	if is_instance_valid(lbl_autosave_status):
		lbl_autosave_status.text = text_to_show
		lbl_autosave_status.modulate = Color(0.6, 1, 0.6, 1) # Grün, volle Deckkraft
		lbl_autosave_status.visible = true
		
		# Timer, um die Meldung nach 2.0 Sekunden auszublenden (Fade-Out)
		var tween = create_tween()
		tween.tween_property(lbl_autosave_status, "modulate", Color(0.6, 1, 0.6, 0.0), 2.0)

func _on_employee_change(idx):
	current_employee_id = option_employee.get_item_id(idx)
	refresh_task_list()

func _on_add_colleague():
	if colleagues.size() > 0:
		var c = colleagues.pop_front()
		option_employee.add_item(c, option_employee.item_count)
