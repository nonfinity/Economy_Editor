extends EcoNode

# Declare member variables here. Examples:
var model_shipment: Economy.Shipment = null setget set_model_shipment, get_model_shipment
var beg_node: EcoNode
var end_node: EcoNode

var tween: Tween

######## SETGET DEFINITIONS ########
func set_model_shipment(shipment: Economy.Shipment):
	model_shipment = shipment
	#var _x = model_hub.connect("name_changed", self, "_on_name_changed")
	#var _y = model_hub.connect("validity_changed", self, "_on_validity_changed")

func get_model_shipment() -> Economy.Shipment:
	return model_shipment

# Called when the node enters the scene tree for the first time.
func _ready():
	ecoType = TYPES.SHIPMENT
	max_connections = 0
	does_physics = false

func test_prep(start: EcoNode, finish: EcoNode):
	beg_node = start
	end_node = finish
	
	tween = Tween.new()
	var _x = tween.interpolate_property(
		self,
		"grav_center",
		beg_node.get_port_position(false),
		end_node.get_port_position(true),
		1.0,
		Tween.TRANS_SINE,
		Tween.EASE_IN_OUT
	)
	var _y = tween.connect("tween_all_completed", self, "_on_tween_finished")
	add_child(tween)

func go():
	assert(tween.start(), "oops!")

func _add_connection_per_type(_node: GraphNode, _on_left: bool):
	#model_hub.add_route(node.model_LtoR)
	#model_hub.add_route(node.model_RtoL)
	pass

func _remove_connection_per_type(_node: GraphNode, _on_left: bool):
	#model_hub.add_route(node.model_LtoR)
	#model_hub.add_route(node.model_RtoL)
	pass


func get_ecoItem_IDs() -> Array:
	var out: Array = []
	out.push_back(model_shipment.get_instance_id())
	return out

func get_from_metadata(meta: Array):
	var out
	var temp = model_shipment
	
	for i in meta:
		temp = temp[i]
	
	out = temp
	return out

func set_from_metadata(value, meta: Array):
	var length = meta.size()
	var temp = model_shipment
	
	for i in meta:
		length -= 1
		if length > 0:
			temp = temp[i]
		else:
			temp[i] = value

func _on_tween_finished():
	queue_free()
