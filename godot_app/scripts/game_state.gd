extends Node

const SAVE_PATH := "user://save_game.json"

var gold: int = 500
var food: int = 300
var aether: int = 100
var gems: int = 50

var town_hall_level: int = 1
var farm_level: int = 1
var mine_level: int = 1

var town_hall_upgrade_end_unix: int = 0
var farm_upgrade_end_unix: int = 0
var mine_upgrade_end_unix: int = 0

var clan_name: String = "Wyrmwardens"
var clan_points: int = 0

var dragons: Array[String] = []
var eggs: Array[Dictionary] = []

var last_login_day: String = ""
var daily_dialogue_index: int = -1

var story_stage: int = 0
var morality_power: int = 0
var morality_freedom: int = 0

var last_tick_unix: int = 0

func _ready() -> void:
    _load_or_init()
    _apply_offline_progress()
    save()

func now_unix() -> int:
    return int(Time.get_unix_time_from_system())

func today_key() -> String:
    var d := Time.get_datetime_dict_from_system()
    return "%04d-%02d-%02d" % [d.year, d.month, d.day]

func _load_or_init() -> void:
    if not FileAccess.file_exists(SAVE_PATH):
        _seed_new_player_state()
        return

    var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
    if file == null:
        _seed_new_player_state()
        return

    var parsed: Variant = JSON.parse_string(file.get_as_text())
    if typeof(parsed) != TYPE_DICTIONARY:
        _seed_new_player_state()
        return

    var data: Dictionary = parsed
    gold = int(data.get("gold", gold))
    food = int(data.get("food", food))
    aether = int(data.get("aether", aether))
    gems = int(data.get("gems", gems))

    town_hall_level = int(data.get("town_hall_level", town_hall_level))
    farm_level = int(data.get("farm_level", farm_level))
    mine_level = int(data.get("mine_level", mine_level))

    town_hall_upgrade_end_unix = int(data.get("town_hall_upgrade_end_unix", 0))
    farm_upgrade_end_unix = int(data.get("farm_upgrade_end_unix", 0))
    mine_upgrade_end_unix = int(data.get("mine_upgrade_end_unix", 0))

    clan_name = str(data.get("clan_name", clan_name))
    clan_points = int(data.get("clan_points", 0))

    dragons = data.get("dragons", [])
    eggs = data.get("eggs", [])

    last_login_day = str(data.get("last_login_day", ""))
    daily_dialogue_index = int(data.get("daily_dialogue_index", -1))

    story_stage = int(data.get("story_stage", 0))
    morality_power = int(data.get("morality_power", 0))
    morality_freedom = int(data.get("morality_freedom", 0))

    last_tick_unix = int(data.get("last_tick_unix", now_unix()))

func _seed_new_player_state() -> void:
    last_tick_unix = now_unix()
    if dragons.is_empty():
        dragons.append("Ember Wyrmling")

func _apply_offline_progress() -> void:
    var current := now_unix()
    var elapsed := max(0, current - last_tick_unix)

    var gold_rate := 2 + mine_level
    var food_rate := 2 + farm_level
    var aether_rate := 1 + int(town_hall_level / 2)

    gold += elapsed * gold_rate
    food += elapsed * food_rate
    aether += elapsed * aether_rate

    _resolve_building_timers(current)
    _resolve_eggs(current)

    last_tick_unix = current

func tick_one_second() -> void:
    gold += 2 + mine_level
    food += 2 + farm_level
    aether += 1 + int(town_hall_level / 2)

    var current := now_unix()
    _resolve_building_timers(current)
    _resolve_eggs(current)
    last_tick_unix = current

func _resolve_building_timers(current: int) -> void:
    if town_hall_upgrade_end_unix > 0 and current >= town_hall_upgrade_end_unix:
        town_hall_level += 1
        town_hall_upgrade_end_unix = 0

    if farm_upgrade_end_unix > 0 and current >= farm_upgrade_end_unix:
        farm_level += 1
        farm_upgrade_end_unix = 0

    if mine_upgrade_end_unix > 0 and current >= mine_upgrade_end_unix:
        mine_level += 1
        mine_upgrade_end_unix = 0

func _resolve_eggs(current: int) -> void:
    for i in range(eggs.size() - 1, -1, -1):
        var egg: Dictionary = eggs[i]
        if current >= int(egg.get("hatch_unix", current + 1)):
            dragons.append(str(egg.get("species", "Unknown Dragon")))
            eggs.remove_at(i)

func queue_upgrade(building_id: String) -> bool:
    var current := now_unix()
    if building_id == "town_hall":
        if town_hall_upgrade_end_unix > 0:
            return false
        var cost_gold := 300 * town_hall_level
        var cost_food := 200 * town_hall_level
        if gold < cost_gold or food < cost_food:
            return false
        gold -= cost_gold
        food -= cost_food
        town_hall_upgrade_end_unix = current + (45 * town_hall_level)
        return true

    if building_id == "farm":
        if farm_upgrade_end_unix > 0:
            return false
        var cost_g := 180 * farm_level
        var cost_f := 120 * farm_level
        if gold < cost_g or food < cost_f:
            return false
        gold -= cost_g
        food -= cost_f
        farm_upgrade_end_unix = current + (30 * farm_level)
        return true

    if building_id == "mine":
        if mine_upgrade_end_unix > 0:
            return false
        var cost_mg := 220 * mine_level
        var cost_mf := 140 * mine_level
        if gold < cost_mg or food < cost_mf:
            return false
        gold -= cost_mg
        food -= cost_mf
        mine_upgrade_end_unix = current + (35 * mine_level)
        return true

    return false

func hunt_dragon() -> String:
    if food < 50:
        return "Need at least 50 Food for an expedition."

    food -= 50
    clan_points += 5

    var roll := randf()
    var species := ""
    if roll < 0.01:
        species = "Aion Draconis"
    elif roll < 0.08:
        species = "Graviton Basilisk"
    elif roll < 0.25:
        species = "Aurum Seraph"
    elif roll < 0.55:
        species = "Mistfang"

    if species == "":
        return "Hunt found relic traces, but no egg this time."

    var hatch_seconds := species == "Aion Draconis" ? 180 : 60
    eggs.append({
        "species": species,
        "hatch_unix": now_unix() + hatch_seconds
    })
    return "Egg secured: %s (hatches in %ds)." % [species, hatch_seconds]

func run_pve_mission() -> String:
    var power := town_hall_level + farm_level + mine_level + dragons.size()
    var enemy := 3 + randi_range(0, 8)
    if power >= enemy:
        gold += 120
        aether += 20
        story_stage += 1
        morality_freedom += 1
        return "PvE Victory! +120 Gold, +20 Aether, story advanced."

    gold = max(0, gold - 40)
    morality_power += 1
    return "PvE Defeat. -40 Gold, but you learned enemy tactics."

func run_pvp_raid() -> String:
    var atk := mine_level + dragons.size() + randi_range(0, 4)
    var def := town_hall_level + farm_level + randi_range(2, 7)

    if atk >= def:
        gold += 100
        food += 80
        clan_points += 10
        return "PvP Raid Success! Loot: +100 Gold, +80 Food."

    gold = max(0, gold - 60)
    return "PvP Raid Failed. -60 Gold. Adjust your layout and dragon lineup."

func claim_daily_dialogue() -> String:
    var dialogues := [
        "Ari: Power is a tool. Intent makes it sacred—or monstrous.",
        "Mira: A dragon that trusts you is not owned by you.",
        "Kael: Freedom without defense is just a delayed surrender.",
        "Nyx-7: If fate is code, who wrote the first exception?"
    ]

    var today := today_key()
    if last_login_day != today:
        last_login_day = today
        daily_dialogue_index = randi_range(0, dialogues.size() - 1)
        gems += 5
        return "%s\nDaily reward: +5 Gems" % dialogues[daily_dialogue_index]

    return "%s\nDaily already claimed." % dialogues[max(0, daily_dialogue_index)]

func make_story_choice(choice_id: String) -> String:
    if choice_id == "order":
        morality_power += 2
        morality_freedom -= 1
        return "You chose order. Stability rises, but freedom narrows."

    if choice_id == "freedom":
        morality_power -= 1
        morality_freedom += 2
        return "You chose freedom. Innovation rises, control weakens."

    return "No major decision made."

func save() -> void:
    var data := {
        "gold": gold,
        "food": food,
        "aether": aether,
        "gems": gems,
        "town_hall_level": town_hall_level,
        "farm_level": farm_level,
        "mine_level": mine_level,
        "town_hall_upgrade_end_unix": town_hall_upgrade_end_unix,
        "farm_upgrade_end_unix": farm_upgrade_end_unix,
        "mine_upgrade_end_unix": mine_upgrade_end_unix,
        "clan_name": clan_name,
        "clan_points": clan_points,
        "dragons": dragons,
        "eggs": eggs,
        "last_login_day": last_login_day,
        "daily_dialogue_index": daily_dialogue_index,
        "story_stage": story_stage,
        "morality_power": morality_power,
        "morality_freedom": morality_freedom,
        "last_tick_unix": last_tick_unix
    }

    var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file != null:
        file.store_string(JSON.stringify(data))
