extends Control

# --- UI REFERENZEN ---
@onready var blur_layer = $BlurLayer
@onready var view_select = $ViewSelect
@onready var view_calendar = $ViewCalendar
@onready var view_details = $ViewDetails

# --- SELECT ---
@onready var option_customer_select = $ViewSelect/Panel/M/VBox/OptionCustomerSelect
@onready var btn_start = $ViewSelect/Panel/M/VBox/BtnStart

# --- CALENDAR ---
@onready var label_selected_cust = $ViewCalendar/Panel/M/VBox/HBoxHeader/LabelSelectedCustomer
@onready var label_month_year = $ViewCalendar/Panel/M/VBox/HBoxNav/LabelMonthYear
@onready var btn_prev_month = $ViewCalendar/Panel/M/VBox/HBoxNav/BtnPrevMonth
@onready var btn_next_month = $ViewCalendar/Panel/M/VBox/HBoxNav/BtnNextMonth
@onready var btn_back_select = $ViewCalendar/Panel/M/VBox/HBoxHeader/BtnBackToSelect
@onready var grid_days = $ViewCalendar/Panel/M/VBox/GridDays

# --- DETAILS ---
@onready var tasks_container = $ViewDetails/ScrollContainer/TaskList/Margin/VBoxTasks
@onready var task_template = $ViewDetails/ScrollContainer/TaskList/Margin/VBoxTasks/TaskTemplate
@onready var label_detail_customer = $ViewDetails/HeaderInfo/M/HBox/VBoxInfo/LabelDetailCustomer
@onready var btn_back_cal = $ViewDetails/HeaderInfo/M/HBox/BtnBackToCal
@onready var btn_finish = $ViewDetails/FooterBar/M/HBox/BtnFinish

@onready var option_employee = $ViewDetails/HeaderInfo/M/HBox/VBoxInfo/HBoxUser/OptionEmployee
@onready var btn_add_colleague = $ViewDetails/HeaderInfo/M/HBox/VBoxInfo/HBoxUser/BtnAddColleague

# Datums-Steuerung (Detailansicht)
@onready var label_date_detail = $ViewDetails/HeaderInfo/M/HBox/DateSelector/LabelDate
@onready var btn_prev_day = $ViewDetails/HeaderInfo/M/HBox/DateSelector/BtnPrevDay
@onready var btn_next_day = $ViewDetails/HeaderInfo/M/HBox/DateSelector/BtnNextDay
@onready var btn_today = $ViewDetails/HeaderInfo/M/HBox/DateSelector/BtnToday

# --- DATA ---
var current_customer = ""
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
	
	# Signale verbinden
	btn_start.pressed.connect(_on_start_pressed)
	btn_back_select.pressed.connect(func(): show_view(view_select))
	btn_back_cal.pressed.connect(func(): show_view(view_calendar))
	
	btn_prev_month.pressed.connect(_on_prev_month)
	btn_next_month.pressed.connect(_on_next_month)
	
	# Details Navigation
	btn_prev_day.pressed.connect(_on_prev_day_details)
	btn_next_day.pressed.connect(_on_next_day_details)
	btn_today.pressed.connect(_on_today_details)
	btn_back_cal.pressed.connect(func(): show_view(view_calendar))
	btn_finish.pressed.connect(func(): show_view(view_calendar))
	
	option_employee.item_selected.connect(_on_employee_change)
	btn_add_colleague.pressed.connect(_on_add_colleague)

func show_view(target_view):
	view_select.visible = false
	view_calendar.visible = false
	view_details.visible = false
	target_view.visible = true
	
	# Blur Logik: Unscharf bei Auswahl & Kalender (Overlay-Feeling)
	# Scharf bei Details (Arbeitsmodus)
	if target_view == view_select or target_view == view_calendar:
		blur_layer.visible = true
	else:
		blur_layer.visible = true # Ich lasse es an, sieht meist besser aus. Setze auf false wenn nicht gewünscht.
	
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
	# Erstelle Zeitstempel für den gewählten Tag
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
	create_task("01", "Filterwechsel", 10, 2)
	create_task("02", "Reinigung", 5, 0)

func create_task(pos_nr, title, total, done_prev):
	var date_key = label_date_detail.text
	if not session_data.has(date_key): session_data[date_key] = {}
	if not session_data[date_key].has(current_customer): session_data[date_key][current_customer] = {}
	var task_data_root = session_data[date_key][current_customer]
	if not task_data_root.has(pos_nr): task_data_root[pos_nr] = {}
	var user_values = task_data_root[pos_nr]
	
	var t = task_template.duplicate()
	t.visible = true
	
	t.get_node("M/HBoxMain/VBoxLeft/HBoxTitle/PosNum").text = "#" + pos_nr
	t.get_node("M/HBoxMain/VBoxLeft/HBoxTitle/PosTitle").text = title
	t.get_node("M/HBoxMain/VBoxLeft/HBoxDetails/LabelTotal").text = "Gesamt: %d" % total
	
	var spin = t.get_node("M/HBoxMain/VBoxInput/HBoxSpin/SpinBoxAmount")
	spin.max_value = 9999
	spin.value = user_values.get(current_employee_id, 0)
	
	var update = func(val):
		user_values[current_employee_id] = val
		var sum = done_prev
		for uid in user_values: sum += user_values[uid]
		
		t.get_node("M/HBoxMain/VBoxLeft/HBoxDetails/LabelDonePrev").text = "Stand: %d" % sum
		t.get_node("M/HBoxMain/VBoxLeft/ProgressBar").value = sum
		t.get_node("M/HBoxMain/VBoxLeft/ProgressBar").max_value = total
		
		var rest = total - sum
		var lbl_rest = t.get_node("M/HBoxMain/VBoxLeft/HBoxDetails/LabelRest")
		var lbl_status = t.get_node("M/HBoxMain/VBoxLeft/HBoxTitle/StatusLabel")
		
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
			
	spin.value_changed.connect(update)
	update.call(spin.value)
	tasks_container.add_child(t)

func _on_employee_change(idx):
	current_employee_id = option_employee.get_item_id(idx)
	refresh_task_list()

func _on_add_colleague():
	if colleagues.size() > 0:
		var c = colleagues.pop_front()
		option_employee.add_item(c, option_employee.item_count)
