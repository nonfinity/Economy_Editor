extends EcoNode

# Declare member variables here. Examples:
var model_LtoR: Economy.Route = null setget set_LtoR, get_LtoR
var model_RtoL: Economy.Route = null setget set_RtoL, get_RtoL

const styles = {
	"valid": preload("res://themes/route_valid.tres"),
	"invalid": preload("res://themes/route_invalid.tres"),
}


# Called when the node enters the scene tree for the first time.
func _ready():
	ecoType = TYPES.ROUTE
	max_connections = 1

# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
#	CALCULATOR FUCNTIONS
#	These functions calculate things, but do not change values
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *



# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
#	MUTATOR FUCNTIONS
#	These functions change values
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *



# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
#	SETGET DEFINITIONS
#	Functions identified as setters or getters
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
func set_LtoR(route: Economy.Route):
	model_LtoR = route
	var _x = model_LtoR.connect("name_changed", self, "_on_name_changed")
	var _y = model_LtoR.connect("validity_changed", self, "_on_validity_changed")

func get_LtoR() -> Economy.Route:
	return model_LtoR

func set_RtoL(route: Economy.Route):
	model_RtoL = route
	#var _x = model_RtoL.connect("name_changed", self, "_on_name_changed")
	var _y = model_RtoL.connect("validity_changed", self, "_on_validity_changed")

func get_RtoL() -> Economy.Route:
	return model_RtoL


# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
#	INHERITED ABSTRACT FUCNTIONS.
#	Classes this child  must define
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
func get_from_metadata(meta: Array):
	var out
	var temp: Economy.Route
	var local_meta = meta.duplicate(true)
	var direction = local_meta.pop_front()
	temp = model_LtoR if direction == "model_LtoR" else model_RtoL
	
	for i in local_meta:
		temp = temp[i]
	out = temp
	return out

func set_from_metadata(value, meta: Array):
	var temp: Economy.Route
	var local_meta = meta.duplicate(true)
	var direction = local_meta.pop_front()
	temp = model_LtoR if direction == "model_LtoR" else model_RtoL
	
	var length = local_meta.size()
	for i in local_meta:
		length -= 1
		if length > 0:
			temp = temp[i]
		else:
			temp[i] = value

func get_ecoItem_IDs() -> Array:
	var out: Array = []
	out.push_back(model_LtoR.get_instance_id())
	out.push_back(model_RtoL.get_instance_id())
	return out

func _add_connection_per_type(node: GraphNode, on_left: bool):
	var model_hub = node.model_hub
	
	model_LtoR.set_connection(model_hub, on_left)
	model_RtoL.set_connection(model_hub, not on_left)

func _remove_connection_per_type(_node: GraphNode, on_left: bool):
	model_LtoR.set_connection(null, on_left)
	model_RtoL.set_connection(null, not on_left)
	pass

func _get_style_for_update() -> StyleBox:
	var out: StyleBox
	
	out = styles.valid if is_valid else styles.invalid
	return out

# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
#	PARENT OVERRIDE  FUCNTIONS.
#	Child classes that override parent functions
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
func _on_name_changed(_which, new_name: String):
	#title = new_name
	hint_tooltip = new_name
	
	
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
#	ABSTRACT FUCNTIONS.
#	Child classes must define
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *


# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
#	LISTENER FUNCTIONS
#	Functions connected to signals
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *




