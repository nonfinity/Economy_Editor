extends PanelContainer

signal add_neighbor()
signal zoom_changed(zoom)
signal test_shipment()
signal save_button_pressed()
signal load_button_pressed()

func _ready():
	$HBoxContainer/Neighbor.text = "+ Neighbor"


func _on_Neighbor_pressed():
	emit_signal("add_neighbor")


func _on_Zoom_zoom_changed(zoom):
	emit_signal("zoom_changed", zoom)


func _on_ShipTest_pressed():
	emit_signal("test_shipment")


func _on_SaveButton_pressed():
	emit_signal("save_button_pressed")


func _on_LoadButton_pressed():
	emit_signal("load_button_pressed")
