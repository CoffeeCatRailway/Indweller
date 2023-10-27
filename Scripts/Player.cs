using Godot;

namespace Indweller.Scripts;

public partial class Player : GameCharacter
{
    [Export(hint: PropertyHint.Range, hintString: "0,1,0.05")] private float deadzone = .25f;
    [Export] private bool calcDeadzone = false;

    public override void _Ready()
    {
        base._Ready();
        if (calcDeadzone)
        {
            float left = InputMap.ActionGetDeadzone("left");
            float right = InputMap.ActionGetDeadzone("right");
            float up = InputMap.ActionGetDeadzone("up");
            float down = InputMap.ActionGetDeadzone("down");
            deadzone = (left + right + up + down) / 4f;
        }
    }

    public override void _Process(double delta)
    {
        HandleFacing();
        HandleInput();
        HandleAnimations();
    }

    private void HandleInput()
    {
        // Get movement input
        Movement = Input.GetVector("left", "right", "up", "down").LimitLength();

        if (Movement.Length() < deadzone)
            Movement = Vector2.Zero;
        else
            Movement *= (Movement.Length() - deadzone) / (1f - deadzone);

        if (Input.IsKeyPressed(Key.Key1))
            ((ShaderMaterial)Material).SetShaderParameter("paletteIdx", 0);
        else if (Input.IsKeyPressed(Key.Key2))
            ((ShaderMaterial)Material).SetShaderParameter("paletteIdx", 1);
        else if (Input.IsKeyPressed(Key.Key3))
            ((ShaderMaterial)Material).SetShaderParameter("paletteIdx", 2);
        else if (Input.IsKeyPressed(Key.Key4))
            ((ShaderMaterial)Material).SetShaderParameter("paletteIdx", 3);
    }

    protected override void OnIsFacingChanged(Facing old, Facing @new)
    {
        Sprite2D.FlipH = @new == Facing.Left;
    }

    protected override void HandleAnimations()
    {
        // Update animations
        if (Movement == Vector2.Zero)
        {
            switch (IsFacing)
            {
                case Facing.Left:
                    AnimPlayer.Play("idleRight");
                    break;
                case Facing.Right:
                    AnimPlayer.Play("idleRight");
                    break;
                case Facing.Up:
                    AnimPlayer.Play("idleUp");
                    break;
                default:
                case Facing.Down:
                    AnimPlayer.Play("idleDown");
                    break;
            }
        }
        else
        {
            switch (IsFacing)
            {
                case Facing.Left:
                    AnimPlayer.Play("walkRight");
                    break;
                case Facing.Right:
                    AnimPlayer.Play("walkRight");
                    break;
                case Facing.Up:
                    AnimPlayer.Play("walkUp");
                    break;
                default:
                case Facing.Down:
                    AnimPlayer.Play("walkDown");
                    break;
            }
        }
    }

    // public override void _PhysicsProcess(double delta)
    // {
    //     base._PhysicsProcess(delta);
    //     // HandleCollisions();
    // }

    private void HandleCollisions()
    {
        for (int i = 0; i < GetSlideCollisionCount(); i++)
        {
            KinematicCollision2D collision = GetSlideCollision(i);
            GodotObject collider = collision.GetCollider();
            GD.Print(collider);
        }
    }

    public void _on_hit_box_area_entered(Area2D area)
    {
        if (area.Name == "HitBox")
        {
            GD.Print(area.GetParent().Name);
        }
    }
}