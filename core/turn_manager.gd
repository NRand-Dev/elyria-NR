class_name TurnManager extends Node
## Runs combat in faction groups: player -> monsters -> bandits -> townfolk -> repeat.
## Within a group, units act in any order. The group ends when every unit
## has acted or passed. Groups with no units are skipped.
## Add as a Node in your map scene. Finds units via the "units" node group.

signal round_started(round_number: int)
signal group_started(faction: StringName)
signal group_ended(faction: StringName)
signal combat_ended

@export var auto_start := true
@export var ai_delay := 0.3   # pause between AI units so you can follow along

var group_order: Array[StringName] = [&"player", &"monsters", &"bandits", &"townfolk"]
var units_by_group: Dictionary = {}   # faction -> Array of Unit
var current_index := 0
var round_number := 0
var running := false


func _ready() -> void:
	if auto_start:
		start_combat.call_deferred()   # deferred so sibling units finish _ready first


func start_combat() -> void:
	units_by_group.clear()
	for u in get_tree().get_nodes_in_group("units"):
		if not units_by_group.has(u.faction):
			units_by_group[u.faction] = []
		units_by_group[u.faction].append(u)
		if not u.turn_done.is_connected(_on_unit_turn_done):
			u.turn_done.connect(_on_unit_turn_done)
	running = true
	current_index = 0
	round_number = 1
	print("=== Round %d ===" % round_number)
	round_started.emit(round_number)
	_begin_group()


func _living(faction: StringName) -> Array:
	return units_by_group.get(faction, []).filter(func(u): return is_instance_valid(u))


func _advance_index() -> void:
	current_index = (current_index + 1) % group_order.size()
	if current_index == 0:
		round_number += 1
		print("=== Round %d ===" % round_number)
		round_started.emit(round_number)


func _begin_group() -> void:
	# Skip groups with nobody in them. If every group is empty, combat is over.
	var skipped := 0
	while _living(group_order[current_index]).is_empty():
		_advance_index()
		skipped += 1
		if skipped >= group_order.size():
			running = false
			combat_ended.emit()
			return

	var faction := group_order[current_index]
	var units := _living(faction)
	for u in units:
		u.begin_turn()
	print("-- %s turn --" % faction)
	group_started.emit(faction)

	if faction != &"player":
		_run_ai_group(units)
	# The player group just waits for input.


func _run_ai_group(units: Array) -> void:
	for u in units:
		if not is_instance_valid(u):
			continue
		await u.take_ai_turn()
		await get_tree().create_timer(ai_delay).timeout
	_check_group_done()


func _on_unit_turn_done(_unit: Unit) -> void:
	# AI groups are checked at the end of _run_ai_group, so only the
	# player group reacts to individual units finishing.
	if running and group_order[current_index] == &"player":
		_check_group_done()


func _check_group_done() -> void:
	if not running:
		return
	var faction := group_order[current_index]
	var units := _living(faction)
	if not units.all(func(u): return u.is_done()):
		return
	for u in units:
		u.end_group_turn()
	group_ended.emit(faction)
	_advance_index()
	_begin_group()
