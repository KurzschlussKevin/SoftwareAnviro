extends Control

# --- DATEN ---
var technicians = [
	{"id": 1, "name": "Max Mustermann", "role": "Meister"},
	{"id": 2, "name": "Lisa Prüfer", "role": "Technikerin"},
	{"id": 3, "name": "Tom Azubi", "role": "Lehrling"}
]

# Offene Jobs (Pool)
var jobs_pool = [
	{"id": "J1", "cust": "Müller GmbH", "task": "Montage Anlage X", "dur": 1, "col": Color(0.2, 0.4, 0.9, 0.8)},
	{"id": "J2", "cust": "Industrie AG", "task": "Wartung", "dur": 2, "col": Color(0.8, 0.5, 0.2, 0.8)},
	{"id": "J3", "cust": "Kfz Meier", "task": "Hebebühne", "dur": 1, "col": Color(0.2, 0.7, 0.4, 0.8)},
	{"id": "J4", "cust": "Büro West", "task": "E-Check", "dur": 3, "col": Color(0.6, 0.3, 0.6, 0.8)}
]

# Assignments: Key="TechID_DayIdx", Value=JobData
var assignments = {}

var days = ["Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"]

# --- UI REFERENZEN ---
# Diese Pfade passen exakt zu deinem "alten" Design (VBox/PlanContainer/...)
@onready var emp_list = $VBox/PlanContainer/LeftColEmployees/ScrollEmp/EmpList
@onready var header_days = $VBox/PlanContainer/RightColTimeline/HeaderDays
@onready var grid = $VBox/PlanContainer/RightColTimeline/ScrollTime/Grid
@onready var scroll_time = $VBox/PlanContainer/RightColTimeline/ScrollTime
@onready var scroll_emp = $VBox/PlanContainer/LeftColEmployees/ScrollEmp

func _ready():
	# Sync Scrolling: Wenn man rechts scrollt, scrollt links mit
	if scroll_time and scroll_emp:
		scroll_time.get_v_scroll_bar().value_changed.connect(func(val): scroll_emp.scroll_vertical = val)
	
	_build_header()
	_refresh_ui()

func _build_header():
	# Alte Header löschen
	for c in header_days.get_children(): c.queue_free()
	
	# Neuen Header bauen
	for d in days:
		var p = Panel.new()
		p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		p.custom_minimum_size.y = 50
		
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.1, 0.1, 0.15, 0.8)
		style.border_width_bottom = 2
		style.border_color = Color(0.2, 0.4, 0.8, 1)
		style.border_width_right = 1 # Trennstrich
		style.border_color = Color(1, 1, 1, 0.1)
		p.add_theme_stylebox_override("panel", style)
		
		var l = Label.new()
		l.text = d
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		l.set_anchors_preset(Control.PRESET_FULL_RECT)
		
		p.add_child(l)
		header_days.add_child(p)

func _refresh_ui():
	# 1. Linke Spalte: Pool & Mitarbeiter
	for c in emp_list.get_children(): c.queue_free()
	
	# -- POOL BEREICH --
	var pool_header = Label.new()
	pool_header.text = "--- POOL ---"
	pool_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pool_header.add_theme_color_override("font_color", Color(0.9, 0.6, 0.2))
	emp_list.add_child(pool_header)
	
	for job in jobs_pool:
		var ticket = DraggablePoolItem.new(job)
		ticket.drag_successful.connect(_on_job_assigned)
		emp_list.add_child(ticket)
		
	var sep = HSeparator.new()
	emp_list.add_child(sep)
	
	# -- MITARBEITER BEREICH --
	for tech in technicians:
		var p = PanelContainer.new()
		p.custom_minimum_size.y = 60
		
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.15, 0.15, 0.2, 1)
		style.border_width_left = 4
		style.border_color = Color(0, 0.96, 0.83, 1)
		style.content_margin_left = 10
		style.corner_radius_top_right = 6
		style.corner_radius_bottom_right = 6
		p.add_theme_stylebox_override("panel", style)
		
		var l = Label.new()
		l.text = tech.name
		l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		p.add_child(l)
		
		emp_list.add_child(p)

	# 2. Rechte Spalte: Timeline Grid
	for c in grid.get_children(): c.queue_free()
	
	# Dummy-Zeilen für den Pool-Bereich (damit Tech 1 auf gleicher Höhe startet)
	var pool_offset_count = jobs_pool.size() + 2
	for i in range(pool_offset_count): 
		var dummy = Control.new()
		dummy.custom_minimum_size.y = 60
		grid.add_child(dummy)
	
	# Grid Zeilen pro Techniker
	for tech in technicians:
		var row = HBoxContainer.new()
		row.custom_minimum_size.y = 60
		row.add_theme_constant_override("separation", 0)
		
		for i in range(days.size()):
			var slot = TimelineSlot.new(tech.id, i)
			slot.data_dropped_signal.connect(_on_job_assigned)
			slot.resize_signal.connect(_on_job_resized)
			
			var key = str(tech.id) + "_" + str(i)
			var job = assignments.get(key, null)
			
			if job:
				# Prüfen ob dies der Start-Tag des Jobs ist
				var start_day = -1
				for d in range(days.size()):
					if assignments.get(str(tech.id) + "_" + str(d)) == job:
						start_day = d
						break
				
				if i == start_day:
					slot.set_content(job, true) # Master (Start)
				else:
					slot.set_content(job, false) # Slave (Verlängerung)
			
			row.add_child(slot)
		
		grid.add_child(row)

# --- LOGIK ---

func _on_job_assigned(job_data, tech_id, day_index):
	# Aus Pool entfernen
	if jobs_pool.has(job_data): jobs_pool.erase(job_data)
	# Alte Position entfernen (falls verschoben)
	_remove_assignment(job_data)
	
	# Neue Zuweisung schreiben
	for i in range(job_data.dur):
		var t = day_index + i
		if t < days.size():
			assignments[str(tech_id) + "_" + str(t)] = job_data
			
	_refresh_ui()

func _on_job_resized(job_data, tech_id, new_end_day):
	# Start suchen
	var start_day = -1
	for d in range(days.size()):
		if assignments.get(str(tech_id) + "_" + str(d)) == job_data:
			start_day = d
			break
	
	if start_day == -1: return
	
	# Neue Dauer berechnen
	var new_dur = (new_end_day - start_day) + 1
	if new_dur < 1: new_dur = 1
	
	job_data.dur = new_dur
	
	_remove_assignment(job_data)
	for i in range(new_dur):
		var t = start_day + i
		if t < days.size():
			assignments[str(tech_id) + "_" + str(t)] = job_data
			
	_refresh_ui()

func _remove_assignment(job):
	var keys = []
	for k in assignments:
		if assignments[k] == job: keys.append(k)
	for k in keys: assignments.erase(k)


# ==========================================
# INTERNE KLASSEN (Design & DragDrop)
# ==========================================

# 1. Pool Item (Ticket links)
class DraggablePoolItem extends PanelContainer:
	var job
	signal drag_successful(job, tech, day)
	
	func _init(j):
		job = j
		custom_minimum_size.y = 60
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		
		var style = StyleBoxFlat.new()
		style.bg_color = job.col
		style.border_width_left = 4
		style.border_color = Color(1,1,1,0.5)
		style.corner_radius_top_right = 6
		style.corner_radius_bottom_right = 6
		add_theme_stylebox_override("panel", style)
		
		var l = Label.new()
		l.text = job.cust + "\n(" + str(job.dur) + " Tage)"
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		add_child(l)

	func _get_drag_data(at_position):
		var p = Label.new()
		p.text = job.cust
		set_drag_preview(p)
		return {"job": job, "source": "pool"}

# 2. Timeline Slot (Tag im Raster)
class TimelineSlot extends Panel:
	var tech_id
	var day_index
	signal data_dropped_signal(job, tech, day)
	signal resize_signal(job, tech, day_end)
	
	var style_normal = StyleBoxFlat.new()
	var style_hover = StyleBoxFlat.new()
	
	var current_job = null
	
	func _init(tid, did):
		tech_id = tid
		day_index = did
		size_flags_horizontal = Control.SIZE_EXPAND_FILL
		mouse_filter = Control.MOUSE_FILTER_PASS
		
		# Style mit STRICH RECHTS
		style_normal.bg_color = Color(1, 1, 1, 0.03)
		style_normal.border_width_right = 1
		style_normal.border_color = Color(1, 1, 1, 0.1) # Sichtbarer Strich
		style_normal.border_width_bottom = 1
		style_normal.border_color = Color(1, 1, 1, 0.1)
		
		style_hover.bg_color = Color(1, 1, 1, 0.1)
		style_hover.border_width_right = 1
		style_hover.border_color = Color(1, 1, 1, 0.3)
		
		add_theme_stylebox_override("panel", style_normal)

	func set_content(job, master):
		current_job = job
		
		var task_panel = PanelContainer.new()
		task_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
		task_panel.offset_top = 4
		task_panel.offset_bottom = -4
		task_panel.mouse_filter = Control.MOUSE_FILTER_PASS
		
		var style = StyleBoxFlat.new()
		style.bg_color = job.col
		style.border_width_top = 2
		style.border_width_bottom = 2
		style.border_color = Color(0.4, 0.6, 1, 1)
		
		if master:
			style.border_width_left = 2
			style.corner_radius_top_left = 6
			style.corner_radius_bottom_left = 6
			
			var l = Label.new()
			l.text = job.cust
			l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			l.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
			l.add_theme_font_size_override("font_size", 11)
			task_panel.add_child(l)
		else:
			style.border_width_left = 0
			style.corner_radius_top_left = 0
			style.corner_radius_bottom_left = 0
			
		style.border_width_right = 0
		style.corner_radius_top_right = 0
		style.corner_radius_bottom_right = 0
		
		# --- RESIZE GRIFF (Rechts) ---
		var resize_handle = ResizeHandle.new(job)
		resize_handle.custom_minimum_size.x = 15
		resize_handle.set_anchors_preset(Control.PRESET_RIGHT_WIDE)
		
		task_panel.add_child(resize_handle)
		add_child(task_panel)

	# --- DRAG & DROP ---
	func _get_drag_data(at_position):
		if current_job:
			var p = Label.new()
			p.text = current_job.cust
			set_drag_preview(p)
			return {"job": current_job, "source": "timeline"}
		return null

	func _can_drop_data(at_position, data):
		if data.has("resize_job"):
			return true
		add_theme_stylebox_override("panel", style_hover)
		return data.has("job")

	func _drop_data(at_position, data):
		if data.has("resize_job"):
			resize_signal.emit(data["resize_job"], tech_id, day_index)
		elif data.has("job"):
			data_dropped_signal.emit(data["job"], tech_id, day_index)
		add_theme_stylebox_override("panel", style_normal)

	func _notification(what):
		if what == NOTIFICATION_DRAG_END:
			if not get_rect().has_point(get_global_mouse_position()):
				add_theme_stylebox_override("panel", style_normal)

# HILFSKLASSE FÜR DEN GRIFF
class ResizeHandle extends Control:
	var job_ref
	
	func _init(job):
		job_ref = job
		# FIX: Wir nutzen direkt den Integer-Wert 10 (für H_SPLIT)
		mouse_default_cursor_shape = 10 
		mouse_filter = Control.MOUSE_FILTER_STOP
	
	func _get_drag_data(at_position):
		var p = ColorRect.new()
		p.custom_minimum_size = Vector2(4, 60)
		p.color = Color(1, 1, 1, 0.5)
		set_drag_preview(p)
		
		return {"resize_job": job_ref}
	
	func _draw():
		var color = Color(0, 0, 0, 0.3)
		draw_rect(Rect2(4, 10, 4, 40), color)
