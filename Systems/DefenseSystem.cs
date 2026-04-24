using System;
using Godot;

public partial class DefenseSystem : Node
{
    public float TotalFloorDPS = 500.0f;
    public float FrontZombieHealth = 100.0f;
    public int FrontZombieId = 0;

    public void ProcessCombat(float delta)
    {
        float damageThisFrame = TotalFloorDPS * delta;
        FrontZombieHealth -= damageThisFrame;

        if (FrontZombieHealth <= 0)
        {
            // The math is done. Now we trigger the visual effect.
            EmitSignal(Events_cs.SignalName.OnZombieKilled, FrontZombieId);
            // Load the next zombie's health into the front of the queue
            FrontZombieId = GetNextZombieId();
            FrontZombieHealth = GetZombieHealth(FrontZombieId);
        }
    }

    private float GetZombieHealth(int id) { return 100.0f; /* Placeholder */ }
    private int GetNextZombieId() { return 1; /* Placeholder */ }
}