extends Node

@onready var gui = $/root/GUI
@onready var search_bar = $/root/GUI/SearchBar

var SAVED_PAGE

var non_fading_overlays = []
var active_overlay = null

var user_data = {
	"first_time_opening": true,
	"color": Color.BLACK.to_html(false),
	"search_engine": 0
}

func _ready():
#	file_dialog.connect("file_selected", _dialog_file_selected)
	non_fading_overlays.append(search_bar)
	load_user_data()

#	if user_data["first_time_opening"]:
#		toggle_input()

func _process(delta):
	if Input.is_action_just_pressed("search"): toggle_overlay(search_bar)
	if Input.is_action_just_pressed("back"): gui.current_browser.previous_page()
	if Input.is_action_just_pressed("forward"): gui.current_browser.next_page()
	if Input.is_action_just_pressed("home"): gui.current_browser.load_url(gui.HOME_PAGE)
	if Input.is_action_just_pressed("refresh"): gui.current_browser.reload()
	if Input.is_action_just_pressed("new"):
		var browser = await gui.create_browser("file://" + ProjectSettings.globalize_path(gui.DEFAULT_PAGE))
		gui.current_browser = browser

#func toggle_input():
#	if not welcome_screen.visible:
#		welcome_screen.show()
#	else:
#		welcome_screen.hide()
	

func toggle_overlay(new_overlay):
	var tween = create_tween()
	var tween_duration = 0.2

	if new_overlay.visible:
		# Fade out the active overlay
		fade_out(tween, new_overlay, tween_duration)
		active_overlay = null
	else:
		# If another overlay is active, fade it out
		if active_overlay and active_overlay != new_overlay:
			fade_out(tween, active_overlay, tween_duration)
		# Fade in the new overlay
		fade_in(tween, new_overlay, tween_duration)
		new_overlay.set_initial_state()
		active_overlay = new_overlay
	tween.play()

func fade_in(tween, node, duration):
	node.visible = true
	if node not in non_fading_overlays:
		node.modulate.a = 0.0
		tween.parallel().tween_property(node, "modulate:a", 1.0, duration)
	else:
		node.modulate.a = 1.0

func fade_out(tween, node, duration):
	if node not in non_fading_overlays:
		tween.parallel().tween_property(node, "modulate:a", 0.0, duration)
	tween.tween_callback(func(): node.visible = false)

func load_user_data():
	
	if FileAccess.file_exists("user://user_data.dat"):
		var save_file = FileAccess.open("user://user_data.dat", FileAccess.READ)
		user_data = save_file.get_var()
		save_file.close()

func save_user_data():
	var save_file = FileAccess.open("user://user_data.dat", FileAccess.WRITE)
	save_file.store_var(user_data)
	save_file.close()

func _on_saving_page():
	print(SAVED_PAGE.replace("{TAB_TITLE}", gui.current_browser.get_title()))
	var file = FileAccess.open(SAVED_PAGE.replace("{TAB_TITLE}", gui.current_browser.get_title()), FileAccess.WRITE)
	if file != null:
		var html = gui.current_browser.get_html()
		print(html)
		file.store_string(html)
		file.close()

func _dialog_file_selected(path: String):
	SAVED_PAGE = path
	_on_saving_page()
