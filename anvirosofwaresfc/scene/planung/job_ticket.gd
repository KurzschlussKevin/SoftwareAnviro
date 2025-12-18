extends PanelContainer

signal drag_successful(job, tech, day)

var job_data = null

func setup(job):
	job_data = job
	tooltip_text = job.cust + " (" + str(job.dur) + " Tage)"
	
	# Einheitliche Höhe erzwingen (passt zu den Zeilen in planung.gd)
	custom_minimum_size.y = 50 
	
	# Style dynamisch setzen
	var style = StyleBoxFlat.new()
	style.bg_color = job.col
	style.border_width_left = 4
	style.border_color = Color(1, 1, 1, 0.4)
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_right = 6
	style.content_margin_left = 10
	
	add_theme_stylebox_override("panel", style)
	
	var l = find_child("Label")
	if l:
		l.text = job.cust + "\n(" + str(job.dur) + " Tage)"
		l.add_theme_font_size_override("font_size", 14)

func _get_drag_data(_at_position):
	var p = Label.new()
	p.text = job_data.cust
	
	# Preview Style (Gleicher Look wie Timeline Drag)
	var style = StyleBoxFlat.new()
	style.bg_color = job_data.col
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 4
	style.content_margin_left = 10
	style.content_margin_right = 10
	p.add_theme_stylebox_override("normal", style)
	
	set_drag_preview(p)
	return {"job": job_data, "source": "pool"}
