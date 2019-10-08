package components;

class InputComponent
{
    public var up : Bool;

    public var down : Bool;

    public var strafeLeft : Bool;

    public var strafeRight : Bool;
    
    public var turnLeft : Bool;

    public var turnRight : Bool;

    public function new()
    {
        up          = false;
        down        = false;
        strafeLeft  = false;
        strafeRight = false;
        turnLeft    = false;
        turnRight   = false;
    }
}