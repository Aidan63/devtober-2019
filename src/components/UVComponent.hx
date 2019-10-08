package components;

class UVComponent
{
    public var u1 : Int;

    public var v1 : Int;

    public var u2 : Int;

    public var v2 : Int;

    public function new(_u1 : Int = 0, _v1 : Int = 0, _u2 : Int = 1, _v2 : Int = 1)
    {
        u1 = _u1;
        u2 = _u2;
        v1 = _v1;
        v2 = _v2;
    }
}