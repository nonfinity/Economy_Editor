extends GraphNode
class_name EcoNode

var connections: Dictionary = { "left": [], "right": [] }

#var ecoType: String = "EcoNode"
var max_connections: int = 0
var does_physics: bool = true
var grav_center: Vector2 setget set_grav_center,get_grav_center

#var model_object : Economy_Inventory.Hub

enum TYPES { DEFAULT, HUB, ROUTE, SHIPMENT, GOOD }
var ecoType: int = TYPES.DEFAULT
var is_valid: bool = true


func _ready():
	pass # Replace with function body.

func _process(_delta):
	pass

# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
#	CALCULATION FUCNTIONS
# 	These functions calculate things, but do not change values
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
func get_type_string() -> String:
	var out: String = ""
	match ecoType:
		TYPES.HUB:
			out = "Hub"
		TYPES.ROUTE:
			out = "Route"
		TYPES.SHIPMENT:
			out = "Shipment"
		TYPES.GOOD:
			out = "Good"
		_:
			assert(false, "Erroneous element type!")
	return out

func can_add_neighbor(is_left_side: bool) -> bool:
	var out: bool = false
	if is_left_side:
		out = connections.left.size() < max_connections
	else:
		out = connections.right.size() < max_connections
	
	out = out or max_connections < 0
	return  out

func get_port_position(is_left_side: bool) -> Vector2:
	var out: Vector2 = Vector2.ZERO
	
	out.x = offset.x
	out.x += 0.0 if is_left_side else rect_size.x
	
	out.y = offset.y + 30.0
	return out


# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
#	MUTATOR FUCNTIONS
# 	These functions change values
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
func add_connection(node: GraphNode, on_left: bool):
	_add_connection_per_type(node, on_left)
	if on_left:
		connections.left.push_back(node)
	else:
		connections.right.push_back(node)
	pass

func remove_connection(node: GraphNode, on_left: bool):
	_remove_connection_per_type(node, on_left)
	var set: Array = connections.left if on_left else connections.right
	var idx = set.find(node)
	
	if idx > -1:
		set.remove(idx)	
		if node != null:
			if "model_hub" in node:
				node.model_hub.test_validity()
			elif "model_LtoR" in node:
				node.model_LtoR.test_validity()
				node.model_RtoL.test_validity()
	pass

func update_style():
	var set_style: StyleBox
#	if not is_valid:
#		set_style = hub_styles.invalid
#	else:
#		match ecoType:
#			TYPES.HUB:
#				set_style = hub_styles.hub
#			TYPES.ROUTE:
#				set_style = hub_styles.route
#			_:
#				set_style = hub_styles.invalid
	set_style = _get_style_for_update()
	
	set("custom_styles/frame", set_style)
	set("slot/0/left_color", set_style.bg_color)
	set("slot/0/right_color", set_style.bg_color)

# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
#	ABSTRACT FUCNTIONS.
# 	Child classes must define
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
func get_from_metadata(_meta: Array):
	assert(false, "subclasses must define get_from_metadata() !")

func set_from_metadata(_value, _meta: Array):
	assert(false, "subclasses must define set_from_metadata() !")

func get_ecoItem_IDs() -> Array:
	var out: Array = []
	assert(false, "Child classes must define get_ecoItem_IDs() !")
	return out

func _add_connection_per_type(_node: GraphNode, _on_left: bool):
	assert(false, "Child classes must define _add_connection_per_type() !")

func _remove_connection_per_type(_node: GraphNode, _on_left: bool):
	assert(false, "Child classes must define _remove_connection_per_type() !")

func _get_style_for_update() -> StyleBox:
	var out: StyleBox = null
	assert(false, "Child classes must define _get_style_for_update() !")
	return out

# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
#	SETGET DEFINITIONS
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
func set_grav_center(val: Vector2):
	offset = val - (rect_size / 2)

func get_grav_center() -> Vector2:
	return offset + (rect_size / 2)


# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
#	LISTENER FUNCTIONS
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
func _on_name_changed(_which, new_name: String):
	title = new_name
	hint_tooltip = new_name

func _on_validity_changed(_which, isValid: bool):
	self.is_valid = isValid
	update_style()
