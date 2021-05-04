extends GraphEdit


### ### ## ## ## ### ###
### VARIABLES GALORE ###
### ### ## ## ## ### ###

export var enable_wiggle: bool = true
export var wiggle_damper: float = 1.0

const wiggle_decay: float = 5.0
const grav_const: float = 400.0
const grav_range: float = 500.0
const max_range: float = 5000.0
const spring_k: float = 0.80
const spring_l: float = 10.0
const rel_forces: Dictionary = { # repel(+) or attract(-) force 
	'same': 100.0,			# objects of same type
	'other': 50.0,			# objects of different type
}


### ### ### ### ## ### ### ###
### CORE PROCESS FUNCTIONS ###
### ### ### ### ## ### ### ###
func _ready():
	get_zoom_hbox().visible = false
	pass # Replace with function body.

func _process(delta):
	wiggle_damper = max(0.0, wiggle_damper - delta / wiggle_decay)
	if enable_wiggle and wiggle_damper > 0.0:
		perform_wiggles(delta)

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


# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
#	LISTENER FUNCTIONS
#	Functions connected to signals
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *

func get_selected_node() -> GraphNode:
	var out: GraphNode = null
	for i in get_children():
		if i is GraphNode:
			if i.selected == true:
				out = i
				break
	return out

func selected_count(except: GraphNode = null) -> int:
	var out: int = 0
	for i in get_children():
		if i is GraphNode:
			if i.selected == true and i != except:
				out += 1
	return out

func get_ecoNodes(ofType: int = -1) -> Array:
	var out: Array = []
	
	for i in get_children():
		if "ecoType" in i:
			if i.ecoType == ofType or ofType == -1:
				out.push_back(i)
	return out

func get_ecoNode_by_graphID(id: int) -> EcoNode:
	var out: EcoNode = null
	for i in get_ecoNodes():
		for j in i.get_ecoItem_IDs():
			if j == id:
				out = i
	return out

func _on_MainGraph__end_node_move():
	wiggle_damper = 1.0


# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
#		WIGGLE FUNCTIONS
# _init(hub_name, [set_id])
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
func perform_wiggles(delta):
	for i in get_children():
		if i is EcoNode:
			#i.offset = calculate_wiggle_position(i, delta)
			i.grav_center = calculate_wiggle_position(i, delta)

func calculate_wiggle_position(node: EcoNode, delta) -> Vector2:
	var out: Vector2 = Vector2.ZERO
	var net_repel = calc_repel_forces(node)
	var net_spring = calc_spring_forces(node)
	var net_force = (net_repel + net_spring)
	
	var deadband: float = 50.0
	net_force.x = 0 if abs(net_force.x) < deadband else net_force.x
	net_force.y = 0 if abs(net_force.y) < deadband else net_force.y
	net_force *= wiggle_damper
	
	#var new_position = node.offset + net_force * delta
	var new_position = node.grav_center + net_force * delta
	new_position = new_position.clamped(max_range)
	
	new_position.x = round(new_position.x * 50) / 50
	new_position.y = round(new_position.y * 50) / 50
	
	out = new_position
	return out


#func grav_center(node: EcoNode) -> Vector2:
#	return node.offset + node.rect_size / 2

func calc_repel_forces(node: EcoNode) -> Vector2:
	var out: Vector2 = Vector2.ZERO
	for i in get_children():
		if "ecoType" in i:
			if i != node:
				out += calc_repel_from_obj(node, i)
	
	return out

func calc_repel_from_obj(node: EcoNode, from_obj: EcoNode) -> Vector2:
	var out: Vector2 = Vector2.ZERO
	if not (node.does_physics and from_obj.does_physics):
		return out

#	var d_rng: float = grav_center(from_obj).distance_to(grav_center(node))
#	var d_dir: Vector2 = grav_center(from_obj).direction_to(grav_center(node))
	var d_rng: float = from_obj.grav_center.distance_to(node.grav_center)
	var d_dir: Vector2 = from_obj.grav_center.direction_to(node.grav_center)
	var relate_force: float = 0.0
	var g_force: float = 0.0
	
	if d_rng >= grav_range:
		return out
		
	relate_force = rel_forces.same if from_obj.ecoType == node.ecoType else rel_forces.other
	
	d_rng = max(10.0, d_rng * 1)
	g_force = 1 / d_rng * grav_const * relate_force
	
	if d_dir.x == 0.0 and d_dir.y == 0.0:
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		d_dir = Vector2(rng.randf() * 2 - 1, rng.randf() * 2 - 1)
	
	out = d_dir * g_force
	return out

func calc_spring_forces(node: EcoNode) -> Vector2:
	var out: Vector2 = Vector2.ZERO
	
	for i in (node.connections.left + node.connections.right):
		out += calc_spring_from_obj(node, i)
	return out

func calc_spring_from_obj(node: EcoNode, from_obj: EcoNode) -> Vector2:
	var out: Vector2 = Vector2.ZERO
	

	var d_rng: float = from_obj.grav_center.distance_to(node.grav_center)
	var d_dir: Vector2 = from_obj.grav_center.direction_to(node.grav_center)
	
	var spring_length: float
	if node.ecoType == EcoNode.TYPES.ROUTE:
		spring_length = node.model_LtoR.distance * 5
	if from_obj.ecoType == EcoNode.TYPES.ROUTE:
		spring_length = from_obj.model_LtoR.distance * 5
	
	#var force = spring_k * (spring_l - d_rng)
	var force = spring_k * (spring_length - d_rng)

	out = d_dir * force
	return out
