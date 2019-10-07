package world;

class Player extends Entity
{
    public var angle : Int;

    public var direction : Direction;

    public function new(_row : Int, _column : Int)
    {
        super(_row, _column);

        angle     = 0;
        direction = Up;
    }
}