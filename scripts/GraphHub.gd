extends EcoNode

# Declare member variables here. Examples:
var model_hub: Economy.Hub = null setget set_model_hub, get_model_hub

const styles = {
	"city": preload("res://themes/hub_city.tres"),
	"land": preload("res://themes/hub_land.tres"),
	"river": preload("res://themes/hub_river.tres"),
	"sea": preload("res://themes/hub_sea.tres"),
	"invalid": preload("res://themes/hub_invalid.tres"),
}

######## SETGET DEFINITIONS ########
func set_model_hub(hub: Economy.Hub):
	model_hub = hub
	var _x = model_hub.connect("name_changed", self, "_on_name_changed")
	var _y = model_hub.connect("validity_changed", self, "_on_validity_changed")

func get_model_hub() -> Economy.Hub:
	return model_hub

# Called when the node enters the scene tree for the first time.
func _ready():
	ecoType = TYPES.HUB
	max_connections = -1

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



# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
#	ABSTRACT FUCNTIONS.
#	Child classes must define
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
func get_from_metadata(meta: Array):
	var out
	var temp = model_hub
	
	for i in meta:
		temp = temp[i]
	out = temp
	return out

func set_from_metadata(value, meta: Array):
	var length = meta.size()
	var temp = model_hub
	
	for i in meta:
		length -= 1
		if length > 0:
			temp = temp[i]
		else:
			temp[i] = value

func get_ecoItem_IDs() -> Array:
	var out: Array = []
	out.push_back(model_hub.get_instance_id())
	return out

func _add_connection_per_type(_node: GraphNode, _on_left: bool):
	pass

func _remove_connection_per_type(_node: GraphNode, _on_left: bool):
	pass

func _get_style_for_update() -> StyleBox:
	var out: StyleBox
	
	if not is_valid:
		out = styles.invalid
	else:
		match model_hub.subtype:
			Economy.Hub.SUBTYPES.LAND:
				out = styles.land
			Economy.Hub.SUBTYPES.CITY:
				out = styles.city
			Economy.Hub.SUBTYPES.RIVER:
				out = styles.river
			Economy.Hub.SUBTYPES.SEA:
				out = styles.sea
			_:
				assert(false, "INVALID SUBTYPE !!")
	return out

# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
#	LISTENER FUNCTIONS
#	Functions connected to signals
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *










