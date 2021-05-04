extends Control

### ### ## ## ## ### ###
### VARIABLES GALORE ###
### ### ## ## ## ### ###
const masters = {
	"hub": preload("res://elements/GraphHub.tscn"),
	"route": preload("res://elements/GraphRoute.tscn"),
	"shipment": preload("res://elements/Shipment.tscn"),
} 

onready var menu = $HSplitContainer/VBoxContainer/TopBar
onready var editor = $HSplitContainer/VBoxContainer/MainGraph
onready var sidebar = $HSplitContainer/SideBar

var new_hub_loc: Vector2 = Vector2.ZERO
var current_ecoNode: EcoNode setget set_current_ecoNode, get_current_ecoNode

var e: Economy = Economy.new()


### ### ### ### ## ### ### ###
### CORE PROCESS FUNCTIONS ###
### ### ### ### ## ### ### ###
func _ready():	
	add_eco_node("Hub", null)
	pass


func _process(_delta):
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var r_test: float = 1.0
	for i in editor.get_ecoNodes():
		r_test = rng.randf()
		if (i.ecoType == EcoNode.TYPES.ROUTE
				and i.is_valid
				and r_test < 0.01
				):
			if i.connections.left.size() > 0 and i.connections.right.size() > 0:
				launch_shipment(i)


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

func add_eco_node(type: String, next_to: EcoNode, load_args: Dictionary = {}):
	var n: EcoNode
	match type:
		"Hub":
			var obj = e.new_hub("New Hub")
			#var _x = obj.connect("validity_changed", self, "_on_validity_changed")
			
			n = masters.hub.instance()
			n.model_hub = obj
			n.title = str("New ", type)
		"Route":
			var LtoR = e.new_route(200.0, 20.0)
			var RtoL = e.new_route(200.0, 20.0)
			#var _x = LtoR.connect("validity_changed", self, "_on_validity_changed")
			#var _y = RtoL.connect("validity_changed", self, "_on_validity_changed")
			
			n = masters.route.instance()
			n.model_LtoR = LtoR
			n.model_RtoL = RtoL
			
			if load_args.size() > 0:
				editor.connect_node(load_args.left_connection, 0, n.name, 0)
				editor.connect_node(n.name, 0, load_args.left_connection, 0)
			
		_:
			assert(false, str("ERROR! Cannot add hub type ", type))
		
	editor.add_child(n)
	
	if next_to != null:
		n.offset = next_to.offset + next_to.rect_size * 1.5
		editor.connect_node(next_to.name, 0, n.name, 0)
		next_to.add_connection(n, false)
		n.add_connection(next_to, true)
	
	editor.set_selected(n)
	set_current_ecoNode(n)
	editor.wiggle_damper = 1.0
	return n


func launch_shipment(via_route: EcoNode):
	#var route: Economy.Route = node.model_LtoR
	var s = masters.shipment.instance()
	s.test_prep(via_route.connections.left[0], via_route.connections.right[0])
	s.grav_center = via_route.connections.left[0].get_port_position(false)
	editor.add_child(s)
	s.go()
	# don't worry about the model object yet ?
	#e.new_shipment()


func save_economy():
	#var save_str: String = to_json(e.serialize())
	var save_str: String = JSON.print(e.serialize(), " ")
	var save_path: String = "res://eco_map.save"
	
	var save_file = File.new()
	save_file.open(save_path, File.WRITE)
	save_file.store_string(save_str)
	save_file.close()


func load_economy():
	# clear all existing stuff
	e.queue_free()
	for i in editor.get_ecoNodes():
		i.queue_free()
	
	# read from file
	var load_path: String = "res://eco_map.save"
	var load_file = File.new()
	load_file.open(load_path, File.READ)
	
	var load_str = load_file.get_as_text()
	var new_state = parse_json(load_str)
	
	# load file data into economy varaible
	e = Economy.new()
	e.step_count = new_state.step_count
	e.tick_speed = new_state.tick_speed
	e.is_balanced = new_state.tick_speed
	e.checksum = new_state.tick_speed
	
	# construct matching nodes
	for i in new_state.goods:
		pass

	
	for i in new_state.hubs:
		var k: EcoNode = add_eco_node("Hub", null, {"grav": 0})
		i["new_id"] = k.get_instance_id()
		k.model_hub.subtype = i.subtype
		#
		# add sockets!
		#
	
	var done_pairs: Array = []
	for i in new_state.routes:
		var lower = min(i.source.id, i.sink.id)
		var upper = max(i.source.id, i.sink.id)
		# check if already done
		if not done_pairs.has([lower, upper]):
			done_pairs.push_back([lower, upper])
			
			var node_args = {
				"left_connection": i.source.name,
				"right_connection": i.sink.name,
			}
			var k: EcoNode = add_eco_node("Route", null, node_args)
			# update Left to Right
			i["new_id"] = k.get_instance_id()
			k.model_LtoR.name = i.name
			k.model_LtoR.distance = i.distance
			k.model_LtoR.capacity = i.capacity.duplicate(true)
			
			# find reverse flow entry and do update
			
			pass
		pass
	
	for i in new_state.shipments:
		pass
	
	editor.update()
	pass

# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
#	SETGET DEFINITIONS
#	Functions identified as setters or getters
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
func set_current_ecoNode(node: EcoNode):
	current_ecoNode = node
	sidebar.inspect_object(node)

func get_current_ecoNode():
	return current_ecoNode


# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
#	ABSTRACT FUCNTIONS.
#	Child classes must define
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *



# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
#	INHERITED ABSTRACT FUNCTIONS
#	Parent class functions this child MUST override
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *



# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
#	PARENT OVERRIDE FUNCTIONS
#	Parent class functions this child optionally overrides
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *



# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
#	LISTENER FUNCTIONS
#	Functions connected to signals
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
func _on_Neighbor_pressed():
	if current_ecoNode == null:
		set_current_ecoNode(editor.get_selected_node())
		
	if current_ecoNode != null:
		if current_ecoNode.can_add_neighbor(false):
			var new_type: String
			match current_ecoNode.ecoType:
				EcoNode.TYPES.HUB:
					new_type = "Route"
				EcoNode.TYPES.ROUTE:
					new_type = "Hub"
				_:
					assert(false, "ERROR! Cannot add neighbor to hub")
			add_eco_node(new_type, current_ecoNode)


func _on_Zoom_changed(zoom):
	editor.zoom = zoom


func _on_GraphEdit_connection_request(from, from_slot, to, to_slot):
	var from_obj: EcoNode = editor.get_node(from)
	var to_obj: EcoNode = editor.get_node(to)
	
	if from_obj.can_add_neighbor(false) and to_obj.can_add_neighbor(true):
		var from_type = from_obj.ecoType
		var to_type = to_obj.ecoType
		
		if (from_type == EcoNode.TYPES.HUB and to_type == EcoNode.TYPES.ROUTE or 
				from_type == EcoNode.TYPES.ROUTE and to_type == EcoNode.TYPES.HUB):
			editor.connect_node(from, from_slot, to, to_slot)
			from_obj.add_connection(to_obj, false)
			to_obj.add_connection(from_obj, true)


func _on_GraphEdit_node_selected(node: EcoNode):
	#print("graphe node selected")
	set_current_ecoNode(node)


func _on_GraphEdit_node_unselected(_node: EcoNode):
	# This usually gets called AFTER node selected
	# so if you clear the inspector with it, it clears AFTER it populates
	#set_current_ecoNode(null)
	pass


func _on_GraphEdit_disconnection_request(from, from_slot, to, to_slot):
	editor.disconnect_node(from, from_slot, to, to_slot)
	
	var from_obj: EcoNode = editor.get_node(from)
	var to_obj: EcoNode = editor.get_node(to)
	
	from_obj.remove_connection(to_obj, false)
	to_obj.remove_connection(from_obj, true)


func _on_SideBar_inspector_edited(node: EcoNode, tree_item: TreeItem):
	#print("Node edited code in MainEditor runs")
	match node.ecoType:
		EcoNode.TYPES.HUB:
			var m = tree_item.get_metadata(1)
			match m:
				["name"]:
					node.title = tree_item.get_text(1)
					node.set_from_metadata(tree_item.get_text(1), m) 
					# need way to set MODEL name
				["subtype"]:
					node.set_from_metadata(tree_item.get_range(1), m) 
					node.update_style()
		EcoNode.TYPES.ROUTE:
			var m = tree_item.get_metadata(1)
			match m:
				["model_LtoR","distance"], ["model_RtoL","distance"]:
					var new_dist = tree_item.get_range(1)
					node.set_from_metadata(tree_item.get_range(1), m)
	pass # Replace with function body.


func _on_validity_changed(which: Economy.GraphElement, _is_valid: bool):
	#print(str("validity changed! type: ", which.get_type_string(), " # ", which.get_instance_id(), " = ", is_valid))
	var node: GraphNode = editor.get_ecoNode_by_graphID(which.get_instance_id())
	node.update_style()


func _on_SideBar_new_good_pressed():
	var new_good = e.new_good()
	sidebar.new_good_added(new_good)
	pass # Replace with function body.


func _on_TopBar_test_shipment():
	var node: EcoNode = editor.get_selected_node()
	if node.ecoType == EcoNode.TYPES.ROUTE:
		#var route: Economy.Route = node.model_LtoR
		launch_shipment(node)
		# don't worry about the model object yet ?
		#e.new_shipment()
		
	pass # Replace with function body.


func _on_TopBar_save_button_pressed():
	save_economy()


func _on_TopBar_load_button_pressed():
	load_economy()
