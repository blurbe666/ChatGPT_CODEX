extends Control

@onready var resources_label: Label = %ResourcesLabel
@onready var buildings_label: Label = %BuildingsLabel
@onready var dragons_label: Label = %DragonsLabel
@onready var social_label: Label = %SocialLabel
@onready var log_label: RichTextLabel = %LogLabel
@onready var timer: Timer = %TickTimer

func _ready() -> void:
    randomize()
    timer.timeout.connect(_on_tick)
    _push_log("Welcome to Epoch of Embers Prototype.")
    _push_log(GameState.claim_daily_dialogue())
    _refresh_ui()

func _notification(what: int) -> void:
    if what == NOTIFICATION_WM_CLOSE_REQUEST:
        GameState.save()

func _on_tick() -> void:
    GameState.tick_one_second()
    _refresh_ui()

func _refresh_ui() -> void:
    resources_label.text = "Gold: %d  Food: %d  Aether: %d  Gems: %d" % [
        GameState.gold,
        GameState.food,
        GameState.aether,
        GameState.gems
    ]

    buildings_label.text = "Town Hall Lv%d %s\nFarm Lv%d %s\nMine Lv%d %s" % [
        GameState.town_hall_level,
        _timer_text(GameState.town_hall_upgrade_end_unix),
        GameState.farm_level,
        _timer_text(GameState.farm_upgrade_end_unix),
        GameState.mine_level,
        _timer_text(GameState.mine_upgrade_end_unix)
    ]

    var egg_lines: Array[String] = []
    for egg in GameState.eggs:
        var left := max(0, int(egg["hatch_unix"]) - GameState.now_unix())
        egg_lines.append("%s (%ss)" % [str(egg["species"]), left])

    var egg_text := egg_lines.is_empty() ? "No eggs incubating" : ", ".join(egg_lines)
    dragons_label.text = "Dragons (%d): %s\nEggs: %s" % [
        GameState.dragons.size(),
        ", ".join(GameState.dragons),
        egg_text
    ]

    social_label.text = "Clan: %s | Points: %d\nStory Stage: %d | Power vs Freedom: %d / %d" % [
        GameState.clan_name,
        GameState.clan_points,
        GameState.story_stage,
        GameState.morality_power,
        GameState.morality_freedom
    ]

func _timer_text(end_unix: int) -> String:
    if end_unix <= 0:
        return "(idle)"
    return "(%ss left)" % max(0, end_unix - GameState.now_unix())

func _push_log(message: String) -> void:
    log_label.append_text("• %s\n" % message)

func _on_upgrade_town_hall_pressed() -> void:
    var ok := GameState.queue_upgrade("town_hall")
    _push_log(ok ? "Town Hall upgrade started." : "Town Hall upgrade failed (busy/insufficient resources).")
    _refresh_ui()

func _on_upgrade_farm_pressed() -> void:
    var ok := GameState.queue_upgrade("farm")
    _push_log(ok ? "Farm upgrade started." : "Farm upgrade failed (busy/insufficient resources).")
    _refresh_ui()

func _on_upgrade_mine_pressed() -> void:
    var ok := GameState.queue_upgrade("mine")
    _push_log(ok ? "Mine upgrade started." : "Mine upgrade failed (busy/insufficient resources).")
    _refresh_ui()

func _on_dragon_hunt_pressed() -> void:
    _push_log(GameState.hunt_dragon())
    _refresh_ui()

func _on_pve_pressed() -> void:
    _push_log(GameState.run_pve_mission())
    _refresh_ui()

func _on_pvp_pressed() -> void:
    _push_log(GameState.run_pvp_raid())
    _refresh_ui()

func _on_choice_order_pressed() -> void:
    _push_log(GameState.make_story_choice("order"))
    _refresh_ui()

func _on_choice_freedom_pressed() -> void:
    _push_log(GameState.make_story_choice("freedom"))
    _refresh_ui()

func _on_save_pressed() -> void:
    GameState.save()
    _push_log("Progress saved.")
