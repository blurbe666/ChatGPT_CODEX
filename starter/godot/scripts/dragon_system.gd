extends Node

class_name DragonSystem

@export_range(0.0, 1.0, 0.001) var base_rare_egg_chance: float = 0.01

var incubating_eggs: Array[Dictionary] = []

func try_generate_egg(biome_tag: String) -> Dictionary:
    var biome_bonus := biome_tag == "cosmic" ? 0.02 : 0.0
    var roll := randf()

    if roll > base_rare_egg_chance + biome_bonus:
        return {}

    var egg := {
        "species_id": biome_tag == "cosmic" ? "AION_DRACONIS" : "MISTFANG",
        "hatch_duration": biome_tag == "cosmic" ? 1800.0 : 600.0,
        "elapsed": 0.0
    }

    incubating_eggs.append(egg)
    print("New egg acquired: %s" % egg["species_id"])
    return egg

func _process(delta: float) -> void:
    for i in range(incubating_eggs.size() - 1, -1, -1):
        incubating_eggs[i]["elapsed"] += delta
        if incubating_eggs[i]["elapsed"] >= incubating_eggs[i]["hatch_duration"]:
            print("Egg hatched: %s" % incubating_eggs[i]["species_id"])
            incubating_eggs.remove_at(i)
