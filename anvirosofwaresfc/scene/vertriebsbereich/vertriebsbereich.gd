extends Control

# --- UI REFERENZEN RECHTS (Tabelle) ---
@onready var scroll_container_table = $HBox/RightCol/PositionsPanel/M/VBox/ScrollContainer
@onready var header_spacer = $HBox/RightCol/PositionsPanel/M/VBox/HeaderRow/HBox/ScrollbarSpacer

# --- UI REFERENZEN LINKS (Formular) ---
# Checkboxen / Buttons zum Umschalten
@onready var check_work_loc = $HBox/LeftCol/KundenPanel/M/ScrollContainer/VBox/CheckWorkLoc
@onready var check_ap2 = $HBox/LeftCol/KundenPanel/M/ScrollContainer/VBox/CheckAP2

# Die Container, die ein/ausgeblendet werden sollen
@onready var container_work_loc = $HBox/LeftCol/KundenPanel/M/ScrollContainer/VBox/ContainerWorkLoc
@onready var container_ap2 = $HBox/LeftCol/KundenPanel/M/ScrollContainer/VBox/ContainerAP2

func _ready():
	# 1. Tabellen-Fix (Scrollbar-Breite)
	await get_tree().process_frame
	var scrollbar_width = scroll_container_table.get_v_scroll_bar().size.x
	if scrollbar_width > 0:
		header_spacer.custom_minimum_size.x = scrollbar_width
	else:
		header_spacer.custom_minimum_size.x = 12.0
	
	# 2. Signale für Formular verbinden
	check_work_loc.toggled.connect(_on_work_loc_toggled)
	check_ap2.toggled.connect(_on_ap2_toggled)
	
	# 3. Initialzustand setzen (Alles eingeklappt)
	container_work_loc.visible = false
	container_ap2.visible = false

func _on_work_loc_toggled(toggled_on: bool):
	# Sanftes Einblenden wäre möglich, hier nutzen wir einfaches Umschalten
	container_work_loc.visible = toggled_on

func _on_ap2_toggled(toggled_on: bool):
	container_ap2.visible = toggled_on
