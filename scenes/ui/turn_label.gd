extends Label
## Shows "Round 2 - Monsters turn". Set `turn_manager` in the inspector.

@export var turn_manager: TurnManager

var _round := 1
var _faction: StringName = &""


func _ready() -> void:
	turn_manager.round_started.connect(_on_round_started)
	turn_manager.group_started.connect(_on_group_started)


func _on_round_started(n: int) -> void:
	_round = n


func _on_group_started(faction: StringName) -> void:
	_faction = faction
	text = "Round %d - %s turn" % [_round, String(_faction).capitalize()]
