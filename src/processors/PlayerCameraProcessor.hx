package processors;

import components.DirectionComponent;
import components.CellComponent;
import components.PositionComponent;
import clay.Components;
import clay.Family;
import clay.Processor;

using tweenxcore.Tools;

class PlayerCameraProcessor extends Processor
{
    var family : Family;

    var cellComponents : Components<CellComponent>;

    var directionComponents : Components<DirectionComponent>;

    var positionComponents : Components<PositionComponent>;

    public function new()
    {
        super();
    }

    override function onadded()
    {
        family = families.get('family-smooth-movement');
        cellComponents      = components.get_table(CellComponent);
        directionComponents = components.get_table(DirectionComponent);
        positionComponents  = components.get_table(PositionComponent);
    }

    override function update(_dt : Float)
    {
        for (entity in family)
        {
            final cell      = cellComponents.get(entity);
            final direction = directionComponents.get(entity);
            final position  = positionComponents.get(entity);

            direction.angle = 0.5.linear().lerp(direction.angle, direction.direction * 90);
            position.x = 0.5.linear().lerp(position.x, 8 + cell.column * 16);
            position.y = 8;
            position.z = 0.5.linear().lerp(position.z, 8 + cell.row * 16);
        }
    }
}