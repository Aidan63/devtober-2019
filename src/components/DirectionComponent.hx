package components;

class DirectionComponent
{
    public var angle : Float;

    public var facing : Direction;

    public var direction : Int;

    public function new()
    {
        angle     = 0;
        direction = 0;
        facing    = Up;
    }
}