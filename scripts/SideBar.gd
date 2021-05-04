extends PanelContainer

signal inspector_edited(node, tree)
signal new_good_pressed()
signal good_edited(tree_item)


func inspect_object(object: EcoNode):
	$TabContainer/Current/Inspector.inspect_object(object)

func new_good_added(good: Economy.Good):
	$TabContainer/GoodsPanel.new_good_added(good)

func _on_Inspector_inspector_edited(node, tree_item):
	emit_signal("inspector_edited", node, tree_item)
	pass # Replace with function body.


func _on_GoodsPanel_new_good_pressed():
	emit_signal("new_good_pressed")
	pass # Replace with function body.


func _on_GoodsPanel_good_edited(good, tree_item):
	emit_signal("good_edited", good, tree_item)
	pass # Replace with function body.
