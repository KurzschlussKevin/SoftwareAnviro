extends PanelContainer

@export var title: String = "Titel" :
	set(value):
		title = value
		if is_node_ready(): %LabelTitle.text = title

@export var value: String = "0" :
	set(v):
		value = v
		if is_node_ready(): %LabelValue.text = value

@export_group("Fortschritt")
@export var show_progress: bool = false :
	set(v):
		show_progress = v
		if is_node_ready(): update_visibility()

@export var progress_value: float = 0.0 :
	set(v):
		progress_value = v
		if is_node_ready(): %ProgressBar.value = v

@export var progress_text: String = "" :
	set(v):
		progress_text = v
		if is_node_ready(): %LabelProgText.text = v

func _ready():
	# Initiale Werte setzen
	%LabelTitle.text = title
	%LabelValue.text = value
	%ProgressBar.value = progress_value
	%LabelProgText.text = progress_text
	update_visibility()

func update_visibility():
	%ProgressContainer.visible = show_progress
	%SpacerTitle.visible = show_progress
	%LabelProgText.visible = show_progress
