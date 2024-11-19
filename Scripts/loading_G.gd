extends Control

# The current browser as Godot node
@onready var current_browser = null

# ==============================================================================

func _ready():
	# Initialize CEF
	if !$CEF.initialize({
			"artifacts": "res://cef_artifacts/",  # Adjust the path if needed
			"remote_debugging_port": 7777,
			"remote_allow_origin": "*"
		}):
		print("Failed to initialize CEF: ", $CEF.get_error())
		return

	# Create the default browser page
	current_browser = await create_browser("https://www.google.com")

# ==============================================================================

func create_browser(url):
	# Create a browser tab and link it to the TextureRect for display
	var browser = $CEF.create_browser(url, $TextureRect, {"javascript": true})
	if browser == null:
		print("Failed to create browser: ", $CEF.get_error())
		return null
	return browser

# ==============================================================================

# Function to handle mouse input for the browser (if needed)
func _on_TextureRect_gui_input(event):
	if current_browser == null:
		return
	# Handle mouse input events here if necessary

# ==============================================================================

# Function to handle keyboard input for the browser (if needed)
func _input(event):
	if current_browser == null:
		return
	# Handle keyboard input events here if necessary

# ==============================================================================

# Add any additional functions you might need for your application here...
