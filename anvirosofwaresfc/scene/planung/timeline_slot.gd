extends Panel

const PackedBar = preload("res://scene/planung/job_bar_segment.tscn")

signal data_dropped_signal(job, tech, day)
signal slot_entered_signal(tech, day)
signal resize_start_signal(job, tech)

var tech_id = -1
var day_index = -1
var current_job = null

func setup(t_id, d_id):
	tech_id = t_id
	day_index = d_id
	mouse_filter = Control.MOUSE_FILTER_PASS
	mouse_entered.connect(func(): slot_entered_signal.emit(tech_id, day_index))

func set_content(job, is_master, is_end):
	current_job = job
	
	# Instanziere die Balken-Szene
	var bar = PackedBar.instantiate()
	add_child(bar)
	
	# Konfiguriere sie
	bar.setup(job, is_master, is_end)
	
	# Signal weiterleiten
	bar.resize_pressed_signal.connect(func(): resize_start_signal.emit(job, tech_id))

func clear_content():
	current_job = null
	for c in get_children():
		c.queue_free()

# --- DRAG & DROP ---
func _can_drop_data(_pos, data):
	return data.has("job")

func _drop_data(_pos, data):
	if data.has("job"):
		data_dropped_signal.emit(data["job"], tech_id, day_index)

func _get_drag_data(_pos):
	if current_job:
		var p = Label.new()
		p.text = current_job.cust
		
		var style = StyleBoxFlat.new()
		style.bg_color = current_job.col
		style.content_margin_left = 10
		style.content_margin_right = 10
		p.add_theme_stylebox_override("normal", style)
		
		set_drag_preview(p)
		return {"job": current_job, "source": "timeline"}
	return null
