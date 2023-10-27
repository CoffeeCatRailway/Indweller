using System;
using Godot;
using Godot.Collections;

namespace Indweller.Scripts;

public partial class TileMapManager : TileMap
{
    public static TileMapManager Instance { get; private set; }

    public enum Layers
    {
        Grass = 1,
        GrassHill = 0,
        Sand = 2,
        SandHill = 5,
        Dirt = 3,
        Water = 6,

        Rocks = 4 // Decorations
    }

    // Terrain set ids
    public enum Terrains
    {
        TerrainSet = 0,
        GrassOutline = 0,
        GrassInner = 1,
        GrassHillOutline = 6,
        SandOutline = 4,
        SandInner = 5,
        SandHillOutline = 7,
        DirtOutline = 2,
        DirtInner = 3,

        BuildableSet = 1,
        Fence = 0
    }

    // Tileset (source) ids
    public const int RocksSource = 4;
    public const int WaterSource = 6;

    private Vector2I lastCellPos;

    public override void _EnterTree()
    {
        if (Instance == null)
            Instance = this;
        else
            throw new Exception("TileMapManager instance already exists!");
    }

    public override void _Process(double delta)
    {
        Vector2 mousePos = GetLocalMousePosition();
        Vector2I cellPos = LocalToMap(mousePos);
        if (cellPos != lastCellPos)
        {
            Array<Vector2I> cellPosArray = new() { cellPos };

            if (Input.IsMouseButtonPressed(MouseButton.Left))
            {
                // SetCellsTerrainConnect((int)Layers.Grass, cellPosArray, TerrainSet, -1);
                // SetCell((int)Layers.Grass, cellPos, 0, new Vector2I(0, 0)); // Blank grass tile
                SetCellsTerrainConnect((int)Layers.Grass, cellPosArray, (int)Terrains.TerrainSet, (int)Terrains.GrassInner); // Random grass 'terrain' tile
                SetWater(cellPos);
                lastCellPos = cellPos;
            }
            else if (Input.IsMouseButtonPressed(MouseButton.Right))
            {
                SetCellsTerrainConnect((int)Layers.Grass, cellPosArray, (int)Terrains.TerrainSet, (int)Terrains.GrassOutline);
                SetWater(cellPos, true);
                lastCellPos = cellPos;
            }
        }
    }

    public void SetWater(Vector2I cellPos, bool solid = false)
    {
        SetCell((int)Layers.Water, cellPos, WaterSource, Vector2I.Zero, solid ? 1 : 0);
    }
}