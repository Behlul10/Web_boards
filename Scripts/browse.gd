extends Control

# URL Constants
const DEFAULT_PAGE = "user://default_page.html"
const HOME_PAGE = "https://google.com"

# Variables for handling the browser
var current_browser = null
var mouse_pressed: bool = false

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
