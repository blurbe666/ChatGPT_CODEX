extends Node

@export var gold: int = 500
@export var food: int = 300
@export var aether: int = 100
@export var tick_interval_seconds: float = 5.0

var _tick_timer: float = 0.0

func _process(delta: float) -> void:
    _tick_timer += delta
    if _tick_timer >= tick_interval_seconds:
        _tick_timer = 0.0
        _run_economy_tick()

func _run_economy_tick() -> void:
    gold += 20
    food += 12
    aether += 4
    print("[Tick] Gold:%d Food:%d Aether:%d" % [gold, food, aether])

func spend_resources(gold_cost: int, food_cost: int, aether_cost: int) -> bool:
    if gold < gold_cost or food < food_cost or aether < aether_cost:
        return false

    gold -= gold_cost
    food -= food_cost
    aether -= aether_cost
    return true
