extends Control

# URL Constants
const DEFAULT_PAGE = "user://default_page.html"
const HOME_PAGE = "https://google.com"

# Variables for handling the browser
var current_browser = null
var mouse_pressed: bool = false

@onready var node_container = $NodeOrganizer  # A `Node2D` node under your main scene

func _on_add_button_pressed():
	var sticky_note_scene = preload("res://Scenes/StickyNote.tscn")  # Path to your sticky note scene
	var new_sticky_note = sticky_note_scene.instantiate()
	new_sticky_note.global_position = Vector2(200, 200)  # Example starting position
	node_container.add_child(new_sticky_note)



# Function to create a default HTML page
func create_default_page():
	var file = FileAccess.open(DEFAULT_PAGE, FileAccess.WRITE)
	file.store_string("<html><body bgcolor=\"white\"><h2>Welcome to gdCEF!</h2><p>This is a generated page.</p></body></html>")
	file.close()

# Function to create the browser instance
func create_browser(url):
	# Wait one frame for the texture rect to get its size
	await get_tree().create_timer(0.0).timeout

	var browser = $CEF.create_browser(url, $Panel/VBox/TextureRect, {"javascript": true})
	if browser == null:
		print("Error: " + $CEF.get_error())
		#$Panel/VBox/HBox2/Info.set_text($CEF.get_error())
		return null
	current_browser = browser

	return browser


# Input event handling for mouse events
func _on_texture_rect_gui_input(event: InputEvent) -> void:
	if current_browser == null:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			current_browser.set_mouse_wheel_vertical(2)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			current_browser.set_mouse_wheel_vertical(-2)
		elif event.button_index == MOUSE_BUTTON_LEFT:
			mouse_pressed = event.pressed
			if mouse_pressed:
				current_browser.set_mouse_left_down()
			else:
				current_browser.set_mouse_left_up()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			mouse_pressed = event.pressed
			if mouse_pressed:
				current_browser.set_mouse_right_down()
			else:
				current_browser.set_mouse_right_up()
	elif event is InputEventMouseMotion:
		if mouse_pressed:
			current_browser.set_mouse_left_down()
		current_browser.set_mouse_moved(event.position.x, event.position.y)


# Input event handling for keyboard events
func _input(event):
	if current_browser == null:
		return
	if event is InputEventKey:
		current_browser.set_key_pressed(
			event.unicode if event.unicode != 0 else event.keycode,
			event.pressed,
			event.shift_pressed,
			event.alt_pressed,
			event.is_command_or_control_pressed()
		)

# Ready function to set up the scene
func _ready():
	create_default_page()

	if !$CEF.initialize({
			"locale": "en-US",
			"enable_media_stream": true,
		}):
		print("Error: " + $CEF.get_error())
		return
	
	print("CEF version: " + $CEF.get_full_version())

	# Create the browser and load the home page
	current_browser = await create_browser(HOME_PAGE)

#--------------SAVING DATA------------------------------------------------------------
func save_data():
	var data = []
	for child in node_container.get_children():
		if child is Node2D:
			data.append({
				"type": child.name,  # e.g., "StickyNote"
				"position": child.global_position,
				"content": child.get_child(0).get_child(0).text  # Assuming TextEdit
			})
	var file = FileAccess.open("user://save_data.json", FileAccess.WRITE)
	var json = JSON.new()  # Create an instance of JSON
	file.store_string(json.stringify(data))  # Use json.stringify() to serialize the data
	file.close()

func load_data():
	if FileAccess.file_exists("user://save_data.json"):
		var file = FileAccess.open("user://save_data.json", FileAccess.READ)
		var json = JSON.new()  # Create an instance of JSON
		var result = json.parse(file.get_as_text())  # Use json.parse() to deserialize the data
		file.close()

		if result.error == OK:
			var data = result.result
			for item in data: 
				if item["type"] == "StickyNote":
					var sticky_note_scene = preload("res://Scenes/StickyNote.tscn")
					var sticky_note = sticky_note_scene.instantiate()
					sticky_note.global_position = item["position"]
					sticky_note.get_child(0).get_child(0).text = item["content"]  # Assuming TextEdit
					node_container.add_child(sticky_note)
		else:
			print("Error parsing JSON: ", result.error_string)
