using Godot;

public partial class Events_cs : Node
{
    public static Events_cs Instance { get; private set; }


    [Signal]
    public delegate void OnZombieSpawnedEventHandler(int zombieId, Vector2 position);
    [Signal]
    public delegate void OnZombieKilledEventHandler(int zombieId);

    public override void _Ready()
    {
        Instance = this;
    }
}