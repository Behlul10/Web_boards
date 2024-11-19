extends Control

@onready var current_browser = null

func _ready():
	# Initialize CEF
	if !$CEF.initialize({
			"artifacts": "res://cef_artifacts/",
			"remote_debugging_port": 7777,
			"remote_allow_origin": "*"
		}):
		print("Failed to initialize CEF: ", $CEF.get_error())
		return

	# Create the default browser page
	current_browser = await create_browser("https://www.google.com")
	if current_browser == null:
		print("Failed to create browser.")

func create_browser(url):
	# Create a browser tab and link it to the TextureRect for display
	var browser = $CEF.create_browser(url, $TextureRect, {"javascript": true})
	if browser == null:
		print("Failed to create browser: ", $CEF.get_error())
		return null

	return browser

func _on_TextureRect_gui_input(event):
	if current_browser == null:
		return

	if event is InputEventMouseButton:
		# Handle mouse button events
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				current_browser.set_mouse_left_down()
			else:
				current_browser.set_mouse_left_up()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				current_browser.set_mouse_right_down()
			else:
				current_browser.set_mouse_right_up()
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			current_browser.set_mouse_wheel_vertical(2)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			current_browser.set_mouse_wheel_vertical(-2)

	elif event is InputEventMouseMotion:
		# Handle mouse motion events
		current_browser.set_mouse_moved(event.position.x, event.position.y)

func _input(event):
	if current_browser == null:
		return

	if event is InputEventKey:
		# Use event.keycode instead of event.scancode
		current_browser.set_key_pressed(
			event.keycode,
			event.pressed,
			event.shift,     # Check if Shift key is pressed
			event.alt,       # Check if Alt key is pressed
			event.control    # Check if Control key is pressed
		)




#func _on_TextureRect_gui_input(event):
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
		else:
			mouse_pressed = event.pressed
			if mouse_pressed:
				current_browser.set_mouse_middle_down()
			else:
				current_browser.set_mouse_middle_up()
	elif event is InputEventMouseMotion:
		if mouse_pressed:
			current_browser.set_mouse_left_down()
		current_browser.set_mouse_moved(event.position.x, event.position.y)
	pass
