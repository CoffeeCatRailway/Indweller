using Godot;

namespace Indweller.Scripts;

public partial class GameCharacter : CharacterBody2D
{
    [Export] private float speed = 70f;

    protected Vector2 Movement = Vector2.Zero;

    protected Sprite2D Sprite2D;
    protected AnimationPlayer AnimPlayer;

    private Facing facing = Facing.Down;

    public Facing IsFacing
    {
        get => facing;
        set
        {
            OnIsFacingChanged(facing, value);
            facing = value;
        }
    }

    public override void _Ready()
    {
        Sprite2D = GetNode<Sprite2D>("Sprite2D");
        AnimPlayer = GetNode<AnimationPlayer>("AnimationPlayer");
    }

    public override void _Process(double delta)
    {
        HandleFacing();
        HandleAnimations();
    }

    protected virtual void HandleFacing()
    {
        if (Movement != Vector2.Zero)
        {
            if (Movement.X < 0)
                IsFacing = Facing.Left;
            else if (Movement.X > 0)
                IsFacing = Facing.Right;
            else if (Movement.Y < 0)
                IsFacing = Facing.Up;
            else if (Movement.Y > 0)
                IsFacing = Facing.Down;
        }
    }

    protected virtual void HandleAnimations()
    {
        if (Movement != Vector2.Zero)
            Sprite2D.FlipH = IsFacing == Facing.Left;
    }

    protected virtual void OnIsFacingChanged(Facing old, Facing @new)
    {
    }

    public override void _PhysicsProcess(double delta)
    {
        // Move
        Velocity = Movement * speed;
        MoveAndSlide();
    }

    public enum Facing
    {
        Up, Down, Left, Right
    }
}