using Godot;

namespace Indweller.Scripts.WorldGen;

[GlobalClass]
public partial class IslandSettings : Resource
{
    [Export] public Vector2I Position { get; private set; }
    [Export(PropertyHint.Range, "25,150,1")] public int MinSize { get; private set; }
    [Export(PropertyHint.Range, "25,150,1")] public int MaxSize { get; private set; }

    private int size = -1;

    public IslandSettings()
    {
        Position = Vector2I.Zero;
        MinSize = 25;
        MaxSize = 75;
    }

    public IslandSettings(Vector2I position, int minSize, int maxSize)
    {
        Position = position;
        MinSize = minSize;
        MaxSize = maxSize;
    }

    public int GetSize(System.Random pseudoRandom)
    {
        if (size < 25)
            size = pseudoRandom.Next(Mathf.Min(MinSize, MaxSize), Mathf.Max(MinSize, MaxSize));
        return size;
    }
}
