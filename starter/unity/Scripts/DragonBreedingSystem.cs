using System;
using System.Collections.Generic;
using UnityEngine;

[Serializable]
public class DragonEgg
{
    public string speciesId;
    public float hatchDuration;
    public float elapsed;
}

public class DragonBreedingSystem : MonoBehaviour
{
    [Range(0f, 1f)]
    public float baseRareEggChance = 0.01f;

    private readonly List<DragonEgg> incubatingEggs = new();

    public DragonEgg TryGenerateEgg(string biomeTag)
    {
        float biomeBonus = biomeTag == "cosmic" ? 0.02f : 0f;
        float roll = UnityEngine.Random.value;

        if (roll > baseRareEggChance + biomeBonus)
            return null;

        DragonEgg egg = new DragonEgg
        {
            speciesId = biomeTag == "cosmic" ? "AION_DRACONIS" : "MISTFANG",
            hatchDuration = biomeTag == "cosmic" ? 1800f : 600f,
            elapsed = 0f
        };

        incubatingEggs.Add(egg);
        Debug.Log($"New egg acquired: {egg.speciesId}");
        return egg;
    }

    private void Update()
    {
        float dt = Time.deltaTime;
        for (int i = incubatingEggs.Count - 1; i >= 0; i--)
        {
            incubatingEggs[i].elapsed += dt;
            if (incubatingEggs[i].elapsed >= incubatingEggs[i].hatchDuration)
            {
                Debug.Log($"Egg hatched: {incubatingEggs[i].speciesId}");
                incubatingEggs.RemoveAt(i);
            }
        }
    }
}
