extends Control

# Szenen laden
var scene_dashboard = preload("res://scene/dashboard/dashboard.tscn")
var scene_kunden = preload("res://scene/kundenverwaltung/kundenverwaltung.tscn")
var scene_vertrieb = preload("res://scene/vertriebsbereich/vertriebsbereich.tscn")
var scene_profil = preload("res://scene/profil/profil.tscn")
var scene_planung = preload("res://scene/planung/planung.tscn")
var scene_mitarbeiter = preload("res://scene/mitarbeiterverwaltung/mitarbeiterverwaltung.tscn")
var scene_arbeitsnachweis = preload("res://scene/arbeitsnachweis/arbeitsnachweis.tscn")
var scene_dokumentation = preload("res://scene/dokumentation/dokumentation.tscn")
var scene_export = preload("res://scene/reportexport/report_export.tscn")
var scene_einstellungen = preload("res://scene/einstellungen/einstellungen.tscn")
var scene_pruefmittel = preload("res://scene/pruefmittel/pruefmittel.tscn")
@onready var content_container = $HBoxContainer/ContentArea/MainContent/SceneContainer
@onready var page_title = $HBoxContainer/ContentArea/TopBar/Margin/HBox/PageTitle

# Sidebar
@onready var btn_dashboard = $HBoxContainer/Sidebar/VBox/NavButtons/BtnDashboard
@onready var btn_kunden = $HBoxContainer/Sidebar/VBox/NavButtons/BtnKunden
@onready var btn_vertrieb = $HBoxContainer/Sidebar/VBox/NavButtons/BtnVertrieb
@onready var btn_planung = $HBoxContainer/Sidebar/VBox/NavButtons/BtnPlanung
@onready var btn_mitarbeiter = $HBoxContainer/Sidebar/VBox/NavButtons/BtnMitarbeiter
@onready var btn_arbeitsnachweis = $HBoxContainer/Sidebar/VBox/NavButtons/BtnArbeitsnachweis
@onready var btn_dokumentation = $HBoxContainer/Sidebar/VBox/NavButtons/BtnDokumentation
@onready var btn_export = $HBoxContainer/Sidebar/VBox/NavButtons/BtnExport
@onready var btn_logout = $HBoxContainer/Sidebar/VBox/LogoutArea/BtnLogout
@onready var btn_einstellungen: Button = $HBoxContainer/Sidebar/VBox/NavButtons/BtnEinstellungen
@onready var btn_pruefmittel: Button = $HBoxContainer/Sidebar/VBox/NavButtons/Btnpruefmittel

# NEU: Alert Center Referenzen
@onready var btn_alerts = $HBoxContainer/ContentArea/TopBar/Margin/HBox/AlertButtonContainer/BtnAlerts
@onready var alert_badge_container = $HBoxContainer/ContentArea/TopBar/Margin/HBox/AlertButtonContainer/AlertBadge
@onready var lbl_alert_count = $HBoxContainer/ContentArea/TopBar/Margin/HBox/AlertButtonContainer/AlertBadge/LabelCount


func _ready():
	# Navigation verbinden
	btn_dashboard.pressed.connect(func(): load_scene(scene_dashboard, "Dashboard"))
	btn_kunden.pressed.connect(func(): load_scene(scene_kunden, "Kundenverwaltung"))
	btn_vertrieb.pressed.connect(func(): load_scene(scene_vertrieb, 
"Vertriebsbereich"))
	btn_planung.pressed.connect(func(): load_scene(scene_planung, "Einsatzplanung"))
	btn_mitarbeiter.pressed.connect(func(): load_scene(scene_mitarbeiter, "Mitarbeiter"))
	btn_arbeitsnachweis.pressed.connect(func(): load_scene(scene_arbeitsnachweis, "Arbeitsnachweis"))
	btn_dokumentation.pressed.connect(func(): load_scene(scene_dokumentation, "Dokumentation"))
	btn_export.pressed.connect(func(): load_scene(scene_export, "Export & Berichte"))
	btn_einstellungen.pressed.connect(func(): load_scene(scene_einstellungen, "Einstellungen"))
	btn_pruefmittel.pressed.connect(func(): load_scene(scene_pruefmittel, "Prüfmittelverwaltung"))
	btn_logout.pressed.connect(func(): print("Logout"))
	
	# NEU: Alert Button Logik
	if btn_alerts:
		btn_alerts.pressed.connect(func(): print("Alerts Pop-up anzeigen"))
	
	load_scene(scene_dashboard, "Dashboard")
	
	# NEU: Alerts nach dem initialen Laden des Dashboards prüfen
	update_alerts_badge()

func load_scene(scene_resource: PackedScene, title: String) -> Node:
	page_title.text = title
	for child in content_container.get_children():
		child.queue_free()
	
	var new_scene = scene_resource.instantiate()
	new_scene.name = title # NEU: Szene benennen, damit sie über get_loaded_scene gefunden werden kann
	new_scene.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	new_scene.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	# WICHTIG: Signal vom Dashboard weiterleiten!
	if new_scene.has_signal("request_navigation"):
		new_scene.request_navigation.connect(_on_navigation_requested)
	
	content_container.add_child(new_scene)
	update_alerts_badge() # Alerts nach Szenenwechsel aktualisieren
	return new_scene

# NEU: Hilfsfunktion zum Suchen einer geladenen Szene (im SceneContainer)
func get_loaded_scene(scene_title: String) -> Control:
	for child in content_container.get_children():
		if child.name == scene_title:
			return child
	return null

# NEU: Alert Center Logik
func update_alerts_badge():
	var total_alerts = 0
	
	# Da Szenen nur bei Klick geladen werden, müssen wir sie für den Alert-Check
	# temporär instanziieren, wenn sie noch nicht im Baum sind.
	
	# 1. Prüfmittel Alerts
	var pruefmittel_scene = get_loaded_scene("Prüfmittelverwaltung")
	var temp_pruefmittel_scene = null
	if not pruefmittel_scene:
		temp_pruefmittel_scene = scene_pruefmittel.instantiate()
		pruefmittel_scene = temp_pruefmittel_scene
		add_child(temp_pruefmittel_scene)
		
	if pruefmittel_scene.has_method("get_overdue_pruefmittel_count"):
		total_alerts += pruefmittel_scene.get_overdue_pruefmittel_count()
	
	if is_instance_valid(temp_pruefmittel_scene):
		temp_pruefmittel_scene.queue_free()

	# 2. Kunden-Fristen Alerts
	var customer_scene = get_loaded_scene("Kundenverwaltung")
	var temp_customer_scene = null
	if not customer_scene:
		temp_customer_scene = scene_kunden.instantiate()
		customer_scene = temp_customer_scene
		add_child(temp_customer_scene)

	if customer_scene.has_method("get_overdue_customer_recall_count"):
		total_alerts += customer_scene.get_overdue_customer_recall_count()
	
	if is_instance_valid(temp_customer_scene):
		temp_customer_scene.queue_free()
		
	if lbl_alert_count:
		lbl_alert_count.text = str(total_alerts)
		alert_badge_container.visible = total_alerts > 0
		
	if total_alerts > 0:
		print("!!! SYSTEM ALERT: ", total_alerts, " Fristen überfällig/Geräte zur Kalibrierung fällig.")

func _on_navigation_requested(target_name: String, mode: String = ""):
	var current_scene = null
	
	match target_name:
		"Kundenverwaltung":
			current_scene = load_scene(scene_kunden, "Kundenverwaltung")
			# HIER WAR DER FEHLER IN DEINER VERSION:
			# Dashboard sendet "create", nicht "create_customer"
			# Und die Funktion heißt jetzt "start_new_customer"
			if mode == "create" and current_scene.has_method("start_new_customer"):
				current_scene.start_new_customer()
				
		"Vertriebsbereich":
			current_scene = load_scene(scene_vertrieb, "Vertriebsbereich")
			if mode == "create" and current_scene.has_method("start_new_offer"):
				current_scene.start_new_offer()
		
		"Profil":
			load_scene(scene_profil, "Mein Profil & Statistik")
			
		"Export & Berichte":
			load_scene(scene_export, "Export & Berichte")
			
		"Einsatzplanung": load_scene(scene_planung, "Einsatzplanung")
		"Dashboard": load_scene(scene_dashboard, "Dashboard")
		_: print("Unbekanntes Ziel: ", target_name)
