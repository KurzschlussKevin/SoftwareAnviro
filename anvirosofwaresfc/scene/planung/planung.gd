extends Control

# --- SZENEN (Alles ausgelagert!) ---
const PackedJobTicket   = preload("res://scene/planung/job_ticket.tscn")
const PackedTimelineSlot= preload("res://scene/planung/timeline_slot.tscn")
const PackedHeaderItem  = preload("res://scene/planung/header_item.tscn")
const PackedEmployeeItem= preload("res://scene/planung/employee_item.tscn")

# --- DATEN ---
var technicians = [
	{"id": 1, "name": "Max Mustermann", "role": "Meister"},
	{"id": 2, "name": "Lisa Prüfer", "role": "Technikerin"},
	{"id": 3, "name": "Tom Azubi", "role": "Lehrling"}
]

var jobs_pool = [
	{"id": "J1", "cust": "Müller GmbH", "task": "Montage", "dur": 1, "col": Color(0.2, 0.4, 0.9)},
	{"id": "J2", "cust": "Industrie AG", "task": "Wartung", "dur": 2, "col": Color(0.8, 0.5, 0.2)},
	{"id": "J3", "cust": "Kfz Meier", "task": "Hebebühne", "dur": 1, "col": Color(0.2, 0.7, 0.4)},
	{"id": "J4", "cust": "Büro West", "task": "E-Check", "dur": 3, "col": Color(0.6, 0.3, 0.6)}
]

var assignments = {} 
var days = ["Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"]

# --- STATE ---
var is_resizing = false
var resizing_job = null
var resizing_tech_id = -1
var resizing_start_day = -1

# --- UI REFERENZEN ---
@onready var emp_list = %EmpList
@onready var header_days = %HeaderDays
@onready var grid = %Grid
@onready var scroll_time = %ScrollTime
@onready var pool_container = %PoolContainer
@onready var scroll_emp = $MainHBox/RightSide/PlanContainer/LeftColEmployees/ScrollEmp

func _ready():
	if scroll_time and scroll_emp:
		scroll_time.get_v_scroll_bar().value_changed.connect(func(val): scroll_emp.scroll_vertical = val)
	_build_header()
	_refresh_ui()

func _input(event):
	if is_resizing and event is InputEventMouseButton:
		if not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_end_resizing()

func _build_header():
	for c in header_days.get_children(): c.queue_free()
	
	# Header via Szene erstellen
	for d in days:
		var item = PackedHeaderItem.instantiate()
		item.get_node("Label").text = d
		header_days.add_child(item)

func _refresh_ui():
	# 1. POOL
	for c in pool_container.get_children(): c.queue_free()
	for job in jobs_pool:
		var ticket = PackedJobTicket.instantiate()
		ticket.setup(job)
		ticket.drag_successful.connect(_on_job_assigned)
		pool_container.add_child(ticket)
	
	# 2. MITARBEITER (Links)
	for c in emp_list.get_children(): c.queue_free()
	for tech in technicians:
		var item = PackedEmployeeItem.instantiate()
		item.get_node("NameLabel").text = tech.name
		emp_list.add_child(item)

	# 3. TIMELINE GRID (Rechts)
	for c in grid.get_children(): c.queue_free()
	
	for tech in technicians:
		var row = HBoxContainer.new()
		row.custom_minimum_size.y = 60
		row.add_theme_constant_override("separation", 0)
		
		for i in range(days.size()):
			var slot = PackedTimelineSlot.instantiate()
			slot.setup(tech.id, i)
			
			slot.data_dropped_signal.connect(_on_job_assigned)
			slot.slot_entered_signal.connect(_on_slot_hovered_during_resize)
			slot.resize_start_signal.connect(_start_resizing)
			
			var key = str(tech.id) + "_" + str(i)
			var job = assignments.get(key, null)
			
			if job:
				var start_day = -1
				for d in range(days.size()):
					if assignments.get(str(tech.id) + "_" + str(d)) == job:
						start_day = d
						break
				var is_master = (i == start_day)
				var is_end = (i == (start_day + job.dur - 1))
				slot.set_content(job, is_master, is_end)
			
			row.add_child(slot)
		grid.add_child(row)

# --- LOGIK (Unverändert) ---
func _on_job_assigned(job_data, tech_id, day_index):
	if jobs_pool.has(job_data): jobs_pool.erase(job_data)
	_remove_assignment(job_data)
	
	for i in range(job_data.dur):
		var t = day_index + i
		if t < days.size():
			assignments[str(tech_id) + "_" + str(t)] = job_data
	_refresh_ui()

func _start_resizing(job, tech_id):
	is_resizing = true
	resizing_job = job
	resizing_tech_id = tech_id
	for d in range(days.size()):
		if assignments.get(str(tech_id) + "_" + str(d)) == job:
			resizing_start_day = d
			break

func _on_slot_hovered_during_resize(hover_tech_id, hover_day_index):
	if not is_resizing or resizing_job == null: return
	if hover_tech_id != resizing_tech_id: return
	
	var new_end_day = max(hover_day_index, resizing_start_day)
	var new_dur = (new_end_day - resizing_start_day) + 1
	
	if resizing_job.dur != new_dur:
		resizing_job.dur = new_dur
		_remove_assignment(resizing_job)
		for i in range(new_dur):
			var t = resizing_start_day + i
			if t < days.size():
				assignments[str(resizing_tech_id) + "_" + str(t)] = resizing_job
		_refresh_ui()

func _end_resizing():
	is_resizing = false
	resizing_job = null
	resizing_tech_id = -1
	resizing_start_day = -1

func _remove_assignment(job):
	var keys = []
	for k in assignments:
		if assignments[k] == job: keys.append(k)
	for k in keys: assignments.erase(k)
