package components;

class EnemyComponent
{
    public final maxHealth : Float;

    public var health : Float;

    public var name : String;

    public function new()
    {
        maxHealth = health = 100;
        name = 'agitated old knight';
    }
}