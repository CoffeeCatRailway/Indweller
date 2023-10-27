using Godot;
using System;

[Tool]
public partial class Water : Sprite2D
{
    public override void _Process(double delta)
    {
        ((ShaderMaterial) Material).SetShaderParameter("yZoom", GetViewportTransform().Scale.Y);
    }

    public void _on_item_rect_changed()
    {
        ((ShaderMaterial) Material).SetShaderParameter("scale", Scale);
    }
}
