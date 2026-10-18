class_name Unit extends GridUnit
## A GridUnit that takes part in turn-based combat.
## Tracks its faction (which turn group it belongs to), a movement budget,
## and whether it has acted or passed this turn.

signal turn_done(unit: Unit)
signal state_changed   # UI (like the range overlay) listens to refresh itself

@export var faction: StringName = &"monsters"
@export var move_range := 4

var moves_left := 0
var is_active := false   # true only during this unit's group turn
var has_acted := false   # spent its whole movement budget
var passed := false      # chose to end its turn early


func _ready() -> void:
	super()
	add_to_group("units")


# --- Called by TurnManager -------------------------------------------------

func begin_turn() -> void:
	moves_left = move_range
	has_acted = false
	passed = false
	is_active = true
	state_changed.emit()
	# Later milestones: tick status effects here.


func end_group_turn() -> void:
	is_active = false
	state_changed.emit()


## Override in enemy scripts. Awaitable, so AI can move then finish.
func take_ai_turn() -> void:
	pass_turn()


# --- Turn state ------------------------------------------------------------

func is_done() -> bool:
	return has_acted or passed


func can_act() -> bool:
	return is_active and not is_done() and not is_moving


func pass_turn() -> void:
	if not is_active or is_done():
		return
	passed = true
	state_changed.emit()
	turn_done.emit(self)


# --- Movement with a budget ------------------------------------------------

func try_move(dir: Vector2i) -> bool:
	if not can_act() or moves_left <= 0:
		return false
	var ok := super(dir)
	if ok:
		moves_left -= 1
		state_changed.emit()
	return ok


func _on_move_done() -> void:
	# Mark the turn finished BEFORE super() emits move_finished, so anything
	# awaiting that signal (enemy AI) already sees the correct state.
	var budget_spent := moves_left <= 0 and is_active and not is_done()
	if budget_spent:
		has_acted = true
	super()
	if budget_spent:
		turn_done.emit(self)
