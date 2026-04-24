using System.Collections.Generic;
using Godot;

public partial class EnemyManager : Node
{
    [Export]
    public PackedScene EnemyScene;

    private Dictionary<int, ZombieVisual> _activeZombies = new();
    private Queue<ZombieVisual> _zombiePool = new();

    public override void _Ready()
    {
        // Listen to backend
        Events_cs.Instance.OnZombieSpawned += HandleZombieSpawn;
        Events_cs.Instance.OnZombieKilled += HandleZombieDeath;
    }

    private void HandleZombieSpawn(int zombieId, Vector2 spawnPosition)
    {

    }

    private void HandleZombieDeath(int zombieId)
    {

    }

    public void ReturnToPool(ZombieVisual zombie)
    {
        // Put the node to sleep
        zombie.Visible = false;
        zombie.SetProcess(false);

        // Enqueue it for later use
        _zombiePool.Enqueue(zombie);
    }
}