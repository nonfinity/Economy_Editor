extends PanelContainer


# Declare member variables here. Examples:
signal zoom_changed(zoom)

var zoom: float = 0.8

# Called when the node enters the scene tree for the first time.
func _ready():	
	update_zoom_text_display()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_ZoomOut_pressed():
	update_zoom_from_button(false)


func _on_ZoomIn_pressed():
	update_zoom_from_button(true)

func _on_TextInput_text_entered(new_text):
	var prop_zoom: float = float(new_text)
	if not prop_zoom == null:
		zoom = prop_zoom
		emit_signal("zoom_changed", zoom)
		update_zoom_text_display()

func update_zoom_from_button(is_zoomIN: bool):
	var prop_zoom: float = zoom
#	if prop_zoom > 2.5:
#		prop_zoom += 0.5 * (1 if is_zoomIN else -1)
#	elif prop_zoom > 0.5:
#		prop_zoom += 0.1 * (1 if is_zoomIN else -1)
#	else:
#		var step = max(0.025, prop_zoom * 0.1)
#		prop_zoom += step * (1 if is_zoomIN else -1)
	
	var step = 0.1
	prop_zoom += step * (1 if is_zoomIN else -1)
	
	var z_min = 0.5
	var z_max = 2.0
	prop_zoom = max(z_min, min(z_max, prop_zoom))
	
	zoom = round(prop_zoom * 500) / 500
	
	emit_signal("zoom_changed", zoom)
	update_zoom_text_display()

func update_zoom_text_display():
	var mask: String = "%.0f"
	if zoom < 0.9999:
		mask = "%.1f"
	
	$HBoxContainer/TextInput.text = str(mask % (zoom * 100), "%")
