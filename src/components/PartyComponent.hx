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

    public var turnTaken : Bool;

    public final actions : Array<String>;

    public final abilities : Array<Ability>;

    public function new(_maxHealth : Float, _maxSpecial : Float)
    {
        maxHealth  = _maxHealth;
        maxSpecial = _maxSpecial;
        health     = maxHealth;
        special    = maxSpecial;
        turnTaken  = false;
        actions    = [ 'strike', 'ability', 'guard' ];
        abilities  = [
            new Ability('ability 1', 10),
            new Ability('ability 2', 18),
            new Ability('ability 3',  4),
            new Ability('ability 4', 12)
        ];
    }
}

private class Ability
{
    public final name : String;

    public final cost : Int;

    public function new(_name : String, _cost : Int)
    {
        name = _name;
        cost = _cost;
    }
}