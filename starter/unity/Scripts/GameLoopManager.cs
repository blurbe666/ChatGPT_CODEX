using UnityEngine;

public class GameLoopManager : MonoBehaviour
{
    [Header("Core Resources")]
    public int gold = 500;
    public int food = 300;
    public int aether = 100;

    [Header("Timers")]
    public float tickIntervalSeconds = 5f;
    private float tickTimer;

    private void Update()
    {
        tickTimer += Time.deltaTime;
        if (tickTimer >= tickIntervalSeconds)
        {
            tickTimer = 0f;
            RunEconomyTick();
        }
    }

    private void RunEconomyTick()
    {
        gold += 20;
        food += 12;
        aether += 4;
        Debug.Log($"[Tick] Gold:{gold} Food:{food} Aether:{aether}");
    }

    public bool SpendResources(int goldCost, int foodCost, int aetherCost)
    {
        if (gold < goldCost || food < foodCost || aether < aetherCost)
            return false;

        gold -= goldCost;
        food -= foodCost;
        aether -= aetherCost;
        return true;
    }
}
