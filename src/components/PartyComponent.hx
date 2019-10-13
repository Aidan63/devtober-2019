package components;

class PartyComponent
{
    public final members : Array<PartyMember>;

    public var selected : Int;

    public function new()
    {
        selected = 0;
        members  = [
            new PartyMember(100,  25),
            new PartyMember( 75, 100),
            new PartyMember( 72,  75)
        ];
    }
}

private class PartyMember
{
    public var maxHealth : Float;

    public var health : Float;

    public var maxSpecial : Float;

    public var special : Float;

    public function new(_maxHealth : Float, _maxSpecial : Float)
    {
        maxHealth  = _maxHealth;
        maxSpecial = _maxSpecial;
        health     = maxHealth;
        special    = maxSpecial;
    }
}