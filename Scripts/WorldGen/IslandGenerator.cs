using Godot;
using Godot.Collections;

namespace Indweller.Scripts.WorldGen;

// [Tool]
public partial class IslandGenerator : Node
{
    [Export] private Camera2D cam;
    // private TileMapManager tilemap;
    [Export] private int worldSize = 150;

    [Export] private IslandSettings spawnIslandSettings = new IslandSettings();
    [Export] private IslandSettings[] islandSettings = new IslandSettings[0];

    [ExportSubgroup("Island Noise Settings")]
    private bool useRandomSeed = false;
    private string seed = "0";
    [Export]
    private bool UseRandomSeed
    {
        set
        {
            useRandomSeed = value;
            if (Engine.IsEditorHint())
                UpdatePseudoRandom();
        }
        get => useRandomSeed;
    }
    [Export]
    private string Seed
    {
        set
        {
            seed = value;
            if (Engine.IsEditorHint())
                UpdatePseudoRandom();
        }
        get => seed;
    }

    [Export(PropertyHint.Range, "0,10,0.1")] private float fallOffPercent = 5f;
    [Export(PropertyHint.Range, "0.35,0.5,0.05")] private float randomFillPercent = .475f;
    [Export(PropertyHint.Range, "0,10,")] private int smoothLevel = 5;
    [Export(PropertyHint.Range, "0,1,0.05")] private float validIslandChance = .5f;

    private System.Random pseudoRandom;
    private bool[] validIslands;

    private void UpdatePseudoRandom()
    {
        if (useRandomSeed)
            seed = System.DateTime.Now.ToString();

        pseudoRandom = new System.Random(seed.GetHashCode());

        // Choose what islands are "valid"
        validIslands = new bool[islandSettings.Length];
        for (int i = 0; i < islandSettings.Length; i++)
            validIslands[i] = pseudoRandom.NextDouble() > validIslandChance;
    }

    private void ResetTileMap()
    {
        TileMapManager manager = TileMapManager.Instance;
        manager.Clear();

        int halfSize = worldSize / 2;
        Vector2I pos = Vector2I.Zero;
        Array<Vector2I> posArray = new() { };

        for (int x = -halfSize; x < halfSize; x++)
        {
            for (int y = -halfSize; y < halfSize; y++)
            {
                pos.X = x;
                pos.Y = y;
                posArray.Add(pos);

                manager.SetWater(pos, false);
            }
        }

        manager.SetCellsTerrainConnect((int)TileMapManager.Layers.Grass, posArray, (int)TileMapManager.Terrains.TerrainSet, (int)TileMapManager.Terrains.GrassOutline);
        manager.SetCellsTerrainConnect((int)TileMapManager.Layers.GrassHill, posArray, (int)TileMapManager.Terrains.TerrainSet, (int)TileMapManager.Terrains.GrassHillOutline);

        manager.SetCellsTerrainConnect((int)TileMapManager.Layers.Sand, posArray, (int)TileMapManager.Terrains.TerrainSet, (int)TileMapManager.Terrains.SandOutline);
        manager.SetCellsTerrainConnect((int)TileMapManager.Layers.SandHill, posArray, (int)TileMapManager.Terrains.TerrainSet, (int)TileMapManager.Terrains.SandHillOutline);

        manager.SetCellsTerrainConnect((int)TileMapManager.Layers.Dirt, posArray, (int)TileMapManager.Terrains.TerrainSet, (int)TileMapManager.Terrains.DirtOutline);

        ((FollowCam)cam).UpdateCameraLimits();
    }

    public override void _Ready()
    {
        ResetTileMap();
    }
}
