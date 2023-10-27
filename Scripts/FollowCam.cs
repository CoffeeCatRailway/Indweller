using System;
using Godot;

namespace Indweller.Scripts;

public partial class FollowCam : Camera2D
{
    [Export(PropertyHint.Range, "0,10,")] private int zoomLvl = 3;

    [ExportSubgroup("Follow Settings")]
    [Export] private Node2D followTarget;
    [Export] private float minFollowDist = .1f;
    [Export] private float cameraDamper = .1f;

    [ExportSubgroup("Tilemap Settings")]
    [Export] private int limitMargin = 1;
    private TileMapManager tilemap;// = TileMapManager.Instance;
    [Export] private bool useTilemapLimits = true;

    public override void _Ready()
    {
        tilemap = TileMapManager.Instance;
        UpdateCameraLimits();
    }

    public void UpdateCameraLimits()
    {
        if (useTilemapLimits)
        {
            Rect2I mapRect = tilemap.GetUsedRect().Grow(-limitMargin);
            LimitLeft = mapRect.Position.X * tilemap.CellQuadrantSize;
            LimitTop = mapRect.Position.Y * tilemap.CellQuadrantSize;
            LimitRight = mapRect.End.X * tilemap.CellQuadrantSize;
            LimitBottom = mapRect.End.Y * tilemap.CellQuadrantSize;
        }
    }

    public override void _Process(double delta)
    {
        if (Math.Abs(Zoom.X - zoomLvl) > .1f)
        {
            Vector2 zoom = Zoom;
            zoom.X = zoomLvl;
            zoom.Y = zoomLvl;
            Zoom = zoom;
        }

        if (Input.IsKeyPressed(Key.Q))
            UpdateCameraLimits();

        if (followTarget.Position.DistanceTo(Position) > minFollowDist)
        {
            Vector2 cameraPos = Position.Lerp(followTarget.Position, cameraDamper);
            Position = cameraPos;
        }
    }
}