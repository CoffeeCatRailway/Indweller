using Godot;

namespace Indweller.Scripts;

public partial class Slime : GameCharacter
{
    protected override void HandleAnimations()
    {
        if (Velocity == Vector2.Zero)
        {
            AnimPlayer.Play("idle");
        }
        else
        {
            AnimPlayer.Play("walkSide");
            Sprite2D.FlipH = Velocity.X < 0;
        }
    }

    // public override void _Process(double delta)
    // {
    //     HandleAnimations();
    // }
}