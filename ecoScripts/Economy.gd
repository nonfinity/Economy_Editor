extends Node

class_name Economy

signal item_created(which, typecode)
signal item_deleted(which, typecode)
signal good_created(which)

var hubs: Array = []
var routes: Array = []
var shipments: Array = []
var goods: Array = []

var is_balanced: bool = false
var checksum: int  = 0
var rng = RandomNumberGenerator.new()

var step_count: int = 0
var TYPES = GraphElement.TYPES
var SHIPMENT_STATES = Shipment.STATES

var tick_speed: float = 1.0 # seconds per economy tick

func r(low, high) -> int:
	var wide5 = (high-low)/5
	return round(rng.randf() * wide5) * 5 + low

func get_type_set(type_id) -> Array:
	var out: Array = []
	match type_id:
		TYPES.HUB:
			out = hubs
		TYPES.ROUTE:
			out = routes
		TYPES.SHIPMENT: 
			out = shipments
		TYPES.GOOD:
			out = goods
		_:
			assert(false, "invalid item type!")
	return out

func get_item_by_name(which: String, item_type: int) -> GraphElement:
	var out: GraphElement
	var item_set: Array = get_type_set(item_type)
	
	for i in item_set:
		if i.name == which:
			out = i
			break
	return out

func get_item_by_id(which: int, item_type: int) -> GraphElement:
	var out: GraphElement
	var item_set: Array = get_type_set(item_type)
	
	for i in item_set:
		if i.id == which:
			out = i
			break
	return out

func add_item(new_item: GraphElement, item_type: int,  bypass_dirty_flag: bool = false):
	var item_set: Array = get_type_set(item_type)
	
	emit_signal("item_created", new_item, item_type)
	item_set.push_back(new_item)
	if not bypass_dirty_flag:
		set_dirty()

func remove_item(which: GraphElement, item_type: int):
	var item_set: Array = get_type_set(item_type)
	
	emit_signal("item_deleted", which, item_type)
	var idx: int = item_set.find(which)
	item_set.remove(idx)

func set_dirty():
	is_balanced = false

func next_id() -> int:
	return -1

func calculate_checksum() -> int:
	var out: int = 0
	
	#var hash_target: Array = []
	#for i in hubs:
	#	hash_target.push_back(i.price)
	#
	#out = hash(hash_target)
	return out

func tick(delta):
	# the process is to tick each GraphElement set and the work happens there	
	var gamespeed: float = delta / tick_speed
	
	# advance shipments (delivery logic in Shipments class)
	for i in shipments:
		i.tick(gamespeed)
			#shipments.remove(shipments.find(i))
	
	# tick them hubs
	for i in hubs:
		i.tick(gamespeed)
		
	# tick them routes
	for i in routes:
		i.tick(gamespeed, self)
	
	# now check shipments for removal
	for i in shipments:
		if i.state == SHIPMENT_STATES.ARCHIVE:
			remove_item(i, i.type)
	
	var new_checksum: int = calculate_checksum()
	if new_checksum != checksum:
		checksum = new_checksum
	elif shipments.size() == 0:
		is_balanced = true
		print("BALANCED THIS NETWORK!")

##### try some home grown new functions #####
func new_hub(set_name: String, set_id: int = -1) -> Hub:
	var out: Hub = Hub.new(set_name, set_id)
	add_item(out, TYPES.HUB)
	return out

func new_route(capacity: float, distance: float, source: Hub = null, sink: Hub = null, set_id:int = -1) -> Route:
	var out: Route = Route.new(capacity, distance, source, sink, set_id)
	add_item(out, TYPES.ROUTE)
	return out

func new_shipment() -> Shipment:
	var out: Shipment = null
	assert(false, "don't use this")
	#add_item(out, TYPES.SHIPMENT)
	return out

func new_good(set_name: String = "New Good") -> Good:
	var out: Good = Good.new(set_name)
	emit_signal("good_created", out)
	goods.push_back(out)
	return out

func save_to_file(_filepath: String):
	pass

func serialize() -> Dictionary:
	var out: Dictionary = {}
	
	out.step_count = step_count
	out.tick_speed = tick_speed
	out.is_balanced = is_balanced
	out.checksum  = checksum
	
	out.hubs = []
	for i in hubs:
		out.hubs.push_back(i.serialize())
	
	out.routes = []
	for i in routes:
		out.routes.push_back(i.serialize())
	
	out.shipments = []
	for i in shipments:
		out.shipments.push_back(i.serialize())
	
	out.goods = []
	for i in goods:
		out.goods.push_back(i.serialize())
	
	return out

# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
#		GraphElement DEFINITION
# _init(set_id, set_type, set_name)
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
class GraphElement:
	var id: int
	var name: String	setget _set_name, _get_name
	var type: int
	var subtype: int = -1
	var is_valid: bool = true
	
	signal validity_changed(which, is_valid)
	signal name_changed(which, new_name)
	
	# must defined here instead of in the main Economy class
	# to avoid a cyclic dependency
	enum TYPES { HUB, ROUTE, SHIPMENT, GOOD }
	
	####### SET GETS #######
	func _set_name(val: String):
		name = val
		emit_signal("name_changed", self, val)
	
	func _get_name() -> String:
		return name
	
	func _init(set_id: int, set_type: int, set_name: String = ""):
		id = get_instance_id() if set_id == -1 else set_id
		name = set_name
		type = set_type
		test_validity()
	
	# Economy version of _process() but decoupled to allow variable game speed
	func tick(_delta, _econ = null):
		assert(false, str("Class ", self.get_class(), " must define function tick(delta) !"))
		pass
	
	# this is the list of checks
	func validity_checklist() -> Array:
		assert(false, str("Class ", self.get_class(), " must define function validity_checklist() !"))
		return []
	
	func test_validity():
		var valid_check: bool = true
		
		var check_array = validity_checklist()
		for i in check_array:
			valid_check = valid_check and i
		
		if valid_check != is_valid:
			# validity changed! update value before emitting signal
			is_valid = valid_check
			emit_signal("validity_changed", self, is_valid)
	
	func serialize() -> Dictionary:
		assert(false, "child classes must define serialize() !")
		var out: Dictionary = {}
		return out
	
	func get_type_string() -> String:
		var out: String = ""
		match type:
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

# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
#		HUB DEFINITION
# _init(hub_name, [set_id])
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
class Hub:
	extends GraphElement
	
	var routes: Array = []
	var shipments: Array = []
	var sockets: Dictionary = {}
	
	enum SUBTYPES { CITY, LAND, SEA, RIVER }
	
	######## SETGET OVERRIDES ######## 
	func _set_name(val: String):
		name = val
		for i in routes:
			i.update_name()
	
	func _init(set_name: String, set_id: int = -1).(set_id, TYPES.HUB, set_name):
		subtype = SUBTYPES.CITY
		#price = calculate_price()
		pass
	
	func tick(delta, _econ = null):
		if name == "Valencia":
			pass
		#populate_socket_neighborhoods()
		pop_neighborhoods_02()
		for i in sockets.values():
			i.tick(delta)
	
	func validity_checklist() -> Array:
		var out: Array =  [
			routes.size() > 0,
#			sockets.size() > 0,
		]
		return out
	
	func serialize() -> Dictionary:
		var out: Dictionary = {}
		
		out.id = id
		out.name = name
		out.type = type
		out.subtype = subtype
		out.is_valid = is_valid
		
		out.sockets = []
		for i in sockets:
			out.sockets.push_back(i.serialize())
		
		return out
	
	func add_socket(for_good: Good, prod_rate: float, cons_rate: float):
		assert(not sockets.has(for_good.name), "Duplicate socket added!")
		var s: GoodSocket = GoodSocket.new(for_good, prod_rate, cons_rate)
		sockets[for_good.name] = s
	
	func add_route(which: Route):
		routes.push_back(which)
	
	func remove_route(which: Route):
		var idx: int = 0
		while idx != -1:
			idx = routes.find(which)
			if idx != -1:
				routes.remove(idx)
	
	func populate_socket_neighborhoods(depth: int = 1):
		if depth > 0:
			populate_socket_neighborhoods(depth - 1)
			
			for s in sockets.keys():
				var t = { "prod": 0.0, "cons": 0.0, "supply": 0.0, "demand": 0.0 }
				for i in routes:
					match self:
						i.source:
							var loc = i.sink.sockets[s]
							t.prod += loc.production.get_value(depth - 1)
							#t.supply += max(0, -loc.inventory)
							t.supply += max(0, -loc.inventory.get_value(depth - 1))
						i.sink:
							var loc = i.source.sockets[s]
							t.cons += loc.consumption.get_value(depth - 1)
							#t.demand += max(0, loc.inventory)
							t.demand += max(0, loc.inventory.get_value(depth - 1))
						_:
							assert(false, "route not assigned to source or sink!")
				
				sockets[s].production.set_value(t.prod, depth)
				sockets[s].consumption.set_value(t.cons, depth)
				sockets[s].supply.set_value(t.supply, depth)
				sockets[s].demand.set_value(t.demand, depth)
		
		pass
	
	func pop_neighborhoods_02(depth: int = 2):
		var t = {}
		if depth > 0:
			pop_neighborhoods_02(depth - 1)
			
			for s in sockets.keys():
				t[s] = { "prod": {}, "cons": {}, "supply": {}, "demand": {} }
				for i in routes:
					match self:
						i.source:
							var loc = i.sink
							t[s].prod[loc.name] = loc.sockets[s].production.get_value(depth - 1)
							#t.prod += loc.production.get_value(depth - 1)
							#t.supply += max(0, -loc.inventory)
							t[s].supply[loc.name] = max(0, loc.sockets[s].inventory.get_value(depth - 1))
							#t.supply += max(0, -loc.inventory.get_value(depth - 1))
						i.sink:
							var loc = i.source
							t[s].cons[loc.name] = loc.sockets[s].consumption.get_value(depth - 1)
							#t.cons += loc.consumption.get_value(depth - 1)
							#t.demand += max(0, loc.inventory)
							t[s].demand[loc.name] = max(0, -loc.sockets[s].inventory.get_value(depth - 1))
							#t.demand += max(0, loc.inventory.get_value(depth - 1))
						_:
							assert(false, "route not assigned to source or sink!")
				
				var x: float
				x = 0.0
				x += sockets[s].production.get_value(depth - 1)
				for i in t[s].prod.values(): x += i
				sockets[s].production.set_value(x, depth)
				
				x = 0.0
				x += sockets[s].consumption.get_value(depth - 1)
				for i in t[s].cons.values(): x += i
				sockets[s].consumption.set_value(x, depth)
				
				x = 0.0
				x += sockets[s].supply.get_value(depth - 1)
				for i in t[s].supply.values(): x += i
				sockets[s].supply.set_value(x, depth)
				
				x = 0.0
				x += sockets[s].demand.get_value(depth - 1)
				for i in t[s].demand.values(): x += i
				sockets[s].demand.set_value(x, depth)
				
		else: # depth <= 0
			assert(depth == 0, "depth is negative! oh no!")
			
			for s in sockets.values():
				var inv = s.inventory.get_value(depth)
				s.supply.set_value( max(0,  inv), depth)
				s.demand.set_value( max(0, -inv), depth)
			
		pass
	
	func calculate_route_shares(which: Route) -> Dictionary:
		var out: Dictionary = {}
		#var depth = 1
		
		# calculate uncapped route shares
		for i in sockets.keys():
			var d_tot: float = 0.0
			var d_cur: float = 0.0
			var new_item: Dictionary
			
			for r in routes:
				if r.source == self:	# only care about outgoing routes
					d_tot += r.sink.sockets[i].get_requested() #depth)
					if r == which:
						d_cur += r.sink.sockets[i].get_requested() #depth)
			
			var r_pct = 0
			if d_tot > 0:
				r_pct = d_cur / d_tot
			
			# Format for cargo array
			# { "good": Good class item, "quantity": 0.0 }
			var qty_f = r_pct * sockets[i].supply.get_value()
			new_item = {
				"good": sockets[i].good,
				"quantity": round(qty_f * 10) / 10
			}
			out[i] = new_item
		
		# rescale route shares to fit route capacity
		var route_max: float = which.available_capacity()
		var total_pull: float = 0.0
		
		for i in out.values():
			total_pull += i.quantity
		
		if total_pull > 0:
			for i in out.keys():
				out[i].quantity = out[i].quantity * min(1.0, route_max / total_pull)
		
		# done! *hands up*
		return out
		# out format = { "goodName" : quantity }

	func process_shipment(which: Shipment, is_arrival: bool):
		var value_sign: float = 1 if is_arrival else -1
		
		if name == "Valencia":
			pass
		
		var is_at_beg: bool = which.distance.remain == which.distance.total
		var is_at_end: bool = which.distance.remain <= 0.0
		assert(is_at_beg or is_at_end, "Cannot process shipment not at beg or end!")
		
		# increment capacity taken & queued on route
		which.route.capacity.taken += which.cargo_total * -value_sign
		
		# increment inventories at hub
		for i in which.cargo:
			var key = i.good.name
			sockets[key].add_inventory(i.quantity * value_sign)
		pass

# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
#		ROUTE DEFINITION
# _init(set_capacity, set_distance, [source], [sink], [route_id])
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
class Route:
	extends GraphElement
	
	var source: Hub = null
	var sink: Hub = null
	var distance: float
	
	# flow only occurs from source -> sink
	var capacity = {
		'total': 0.0,
		'queued': 0.0,
		'taken': 0.0,
	}

	func _init(set_capacity: float, set_dist: float, src_hub: Hub = null, snk_hub: Hub = null, set_id:int = -1).(set_id, TYPES.ROUTE):
		
		capacity.total = set_capacity
		distance = set_dist
		
		if src_hub != null:
			source = src_hub
			source.add_route(self)
			source.test_validity()
		
		if snk_hub != null:
			sink = snk_hub
			sink.add_route(self)
			sink.test_validity()
		
		update_name()
		test_validity()
	
	func tick(_delta, econ = null):
		if not is_valid:
			return
		var try_shipment: Shipment = calculate_shipment()
		if not try_shipment == null: # does this work???
			econ.add_item(try_shipment, TYPES.SHIPMENT)
	
	func validity_checklist() -> Array:
		var out: Array =  [
			source != null,
			sink != null,
			distance >= 0.0,
			capacity.total >= 0.0,
		]
		return out
	
	func set_connection(hub: Hub, is_source: bool):
		if is_source:
			if hub == null:
				source.remove_route(self)
			source = hub
		else:
			if hub == null:
				sink.remove_route(self)
			sink = hub
		
		if hub != null:
			hub.add_route(self)
			hub.test_validity()
		
		update_name()
		test_validity()
	
	func update_name():
		if source == null and sink == null:
			name = "Orphan Route"
		else:
			var src_text: String = "Nowhere" if source == null else source.name
			var snk_text: String = "Nowhere" if sink == null else sink.name
			
			name = src_text + " to " + snk_text
		emit_signal("name_changed", self, name)
	
	func available_capacity() -> float:
		if not is_valid:
			return 0.0
		
		return capacity.total - capacity.taken - capacity.queued
	
	func calculate_shipment() -> Shipment:
		var out: Shipment = null
		if not is_valid:
			return out
		
		if source.name == "Spain Roads":
			pass
		
		# for now, there is no minimum or maximum size of a transport
		# nor any limiatations on shipping units together or whatever
		# so take the route share and load it on a Shipment
		var shares = source.calculate_route_shares(self)
		var cargo: Array = []
		
		# 15% chance a shipment is prepared 
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		var vcheck: bool = rng.randf() < 0.10 or source.name == "Spain Roads"
		if vcheck:
			# compile cargo argument
			var shipment_quantiy: float = 0.0
			for i in shares.values():
				cargo.push_back(i)
				shipment_quantiy += i.quantity
			
			if shipment_quantiy > 0:
				out = Shipment.new(self, 5.0, cargo)
		
		return out
	
	func serialize() -> Dictionary:
		var out: Dictionary = {}
		
		out.id = id
		out.name = name
		out.type = type
		out.subtype = subtype
		out.is_valid = is_valid
		out.distance = distance
		out.capacity = capacity.duplicate(true)
		
		out.source = { "id": source.id, "name": source.name }
		out.sink = { "id": sink.id, "name": sink.name }
		
		return out

# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
#		Shipment DEFINITION
# _init(on_route, at_speed, with_goods)
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
class Shipment:
	extends GraphElement
	
	var route: Route
	var speed: float
	var cargo: Array = []
	var cargo_total: float = 0.0
	var state: int
	# Format for cargo array
	# { "good": Good class item, "quantity": 0.0 }
	
	enum STATES { AT_START, IN_TRANSIT, DELIVERED, ARCHIVE }
	
	var distance = { "total": 0.0, "remain": 0.0 }
	
	func _init(on_route: Route, at_speed: float, with_goods: Array).(-1, TYPES.SHIPMENT):
		route = on_route
		speed = at_speed
		cargo = with_goods
		state = STATES.AT_START
		
		distance.total = route.distance
		distance.remain = route.distance
		
		cargo_total = calculate_cargo_total()
		#route.capacity.queued += cargo_total # now done in hub proceessing
		# queue goods at route sink?
		
		# register yourself with the economy? how?
		pass
	
	func tick(delta, _econ = null):
		if state == STATES.ARCHIVE:
			return # ignore
		
		if state == STATES.AT_START:
			route.source.process_shipment(self, false)
		
		distance.remain -= speed * delta
		
		if distance.remain <= 0.0:
			state = STATES.DELIVERED
		elif state != STATES.IN_TRANSIT:
			state = STATES.IN_TRANSIT
		
		if state == STATES.DELIVERED:
			route.sink.process_shipment(self, true)
			state = STATES.ARCHIVE
	
	func calculate_cargo_total() -> float:
		var out: float = 0.0
		for i in cargo:
			out += i.quantity
		return out
	
	func get_progress() -> float:
		var out: float = 0.0
		match state:
			STATES.AT_START:
				out = 0.0
			STATES.IN_TRANSIT:
				if distance.total == 0.0:
					out = 1.0
				else:
					out = distance.remain / distance.total
			STATES.DELIVERED, STATES.DELIVERED:
				out = 1.0
		return out

	func serialize() -> Dictionary:
		var out: Dictionary = {}
		
		out.id = id
		out.name = name
		out.type = type
		out.subtype = subtype
		out.is_valid = is_valid
		
		out.speed = speed
		out.distance = distance
		out.cargo = cargo
		out.state = state
		
		out.route = { "id": route.id, "name": route.name }
		
		return out

# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
#		Good DEFINITION
# _init(set_name, s_coeff, s_int, d_coeff, d_int)
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
class Good:
	var name: String
	var category: String = "All"
	var graph_color: Color
	var supply = { "coeff": 0.0, "intercept": 0.0 }
	var demand = { "coeff": 0.0, "intercept": 0.0 }
	
	signal new_good_created(which)
	
	func _init(set_name: String):
		name = set_name
#		supply.coefficient = s_coeff
#		supply.intercept = s_int
#		demand.coefficient = d_coeff
#		demand.intercept = d_int
		
		# maybe do a random initialization?
		emit_signal("new_good_created", self)
	
	func set_supply(coeff: float, intercept: float):
		supply.coeff = coeff
		supply.intercept = intercept
	
	func set_demand(coeff: float, intercept: float):
		demand.coeff = coeff
		demand.intercept = intercept
	
	func calculate_price(inv: float) -> float:
		var out: float = 0.0
		var adjX: float = 0.0
		
		if (demand.coeff - supply.coeff) == 0:
			return -INF
		
		adjX += inv * (supply.coeff + demand.coeff)
		adjX += supply.intercept - demand.intercept
		adjX /= (demand.coeff - supply.coeff)
		
		out = round(100 * (supply.coeff * (inv + adjX) + supply.intercept))
		out /= 100 # get them pennies!
		
		return out

	func serialize() -> Dictionary:
		var out: Dictionary = {}
		
		out.name = name
		out.category = category
		out.graph_color = graph_color.to_html()
		
		out.supply = supply
		out.demand = demand
		
		return out


# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
#		GoodSocket DEFINITION
# _init(which, base_prod, base_cons)
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
class GoodSocket:
	var good: Good
	var hub: Hub
	var production: GoodAspect
	var consumption: GoodAspect
	var supply: GoodAspect
	var demand: GoodAspect
	var inventory: GoodAspect
	#var inventory: float = 0.0
	var price: float
	
	var inv_min: float = -190.0
	var inv_max: float = 190.0
	
	func _init(which: Good, base_prod: float, base_cons: float):
		good = which
		production = GoodAspect.new(base_prod)
		consumption = GoodAspect.new(base_cons)
		supply = GoodAspect.new(0.0)
		demand = GoodAspect.new(0.0)
		inventory = GoodAspect.new(0.0)
	
	func tick(delta):
		var inc_prod = production.get_value() * delta
		var inc_cons = consumption.get_value() * delta
		add_inventory(inc_prod - inc_cons)
		price = good.calculate_price(inventory.get_value())
	
	func add_inventory(amount: float):
		#inventory += amount
		#var x1 = inventory.get_value() + amount
		#var x2 = min(inv_max, x1)
		#var x3 = max(inv_min, x2)
		var x = max(inv_min, min(inv_max, inventory.get_value() + amount))
		#var x = x3
		inventory.set_value(x)
	
	func get_requested(depth: int = 1) -> float:
		return demand.get_value(depth)
		
	func get_provided(depth: int = 1) -> float:
		return supply.get_value(depth)

	func serialize() -> Dictionary:
		var out: Dictionary = {}
		
		out.good = { "name": good.name }
		out.production = production.serialize()
		out.consumption = consumption.serialize()
		out.supply = supply.serialize()
		out.demand = demand.serialize()
		out.inventory = inventory.serialize()
		
		out.inv_min = inv_min
		out.inv_max = inv_max
		
		return out

# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
#		GoodAspect DEFINITION
# _init(set_base)
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
# ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *
class GoodAspect:
	var base_value: float = 0.0
	var mods_total: float = 0.0
	
	var region_totals = {
		"degree0": 0.0,
		"degree1": 0.0,
		"degree2": 0.0
	}
	
	var mods: Array = []
	
	func _init(set_base: float):
		base_value = set_base
		region_totals.degree0 = set_base
	
	func set_value(val: float, degree: int = 0):
		var key: String = "degree%01d" % degree
		assert(region_totals.has(key), "aspect has no valid region total!")
		region_totals[key] = val
	
	func get_value(degree: int = 0) -> float:
		var key: String = "degree%01d" % degree
		assert(region_totals.has(key), "aspect has no valid region total!")
		return region_totals[key]

	func serialize() -> Dictionary:
		var out: Dictionary = {}
		
		out.base_value = base_value
		out.mods = mods
		
		return out
