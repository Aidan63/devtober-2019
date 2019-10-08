package processors;

import clay.Entity;
import components.MapDataComponent;
import clay.Family;
import components.CellComponent;
import components.InputComponent;
import components.DirectionComponent;
import clay.Components;
import clay.Processor;

class MovementProcessor extends Processor
{
    var familyMovement : Family;

    var familyWalls : Family;

    var familyMap : Family;

    var inputComponents : Components<InputComponent>;

    var cellComponents : Components<CellComponent>;

    var directionComponents : Components<DirectionComponent>;

    var mapComponent : Components<MapDataComponent>;

    override function onadded()
    {
        familyMovement      = families.get('family-movement');
        familyWalls         = families.get('family-walls');
        familyMap           = families.get('family-map-data');
        inputComponents     = components.get_table(InputComponent);
        cellComponents      = components.get_table(CellComponent);
        directionComponents = components.get_table(DirectionComponent);
        mapComponent        = components.get_table(MapDataComponent);
    }

    override function update(_dt : Float)
    {
        for (entity in familyMovement)
        {
            final cell      = cellComponents.get(entity);
            final input     = inputComponents.get(entity);
            final direction = directionComponents.get(entity);

            if (input.turnLeft) direction.direction++;
            if (input.turnRight) direction.direction--;

            switch direction.facing
            {
                case Up:
                    if (input.up) move(entity, cell, cell.column, cell.row - 1);
                    if (input.down) move(entity, cell, cell.column, cell.row + 1);
                    if (input.strafeLeft) move(entity, cell, cell.column - 1, cell.row);
                    if (input.strafeRight) move(entity, cell, cell.column + 1, cell.row);
                    if (input.turnLeft) direction.facing = Left;
                    if (input.turnRight) direction.facing = Right;
                case Left:
                    if (input.up) move(entity, cell, cell.column - 1, cell.row);
                    if (input.down) move(entity, cell, cell.column + 1, cell.row);
                    if (input.strafeLeft) move(entity, cell, cell.column, cell.row + 1);
                    if (input.strafeRight) move(entity, cell, cell.column, cell.row - 1);
                    if (input.turnLeft) direction.facing = Down;
                    if (input.turnRight) direction.facing = Up;
                case Down:
                    if (input.up) move(entity, cell, cell.column, cell.row + 1);
                    if (input.down) move(entity, cell, cell.column, cell.row - 1);
                    if (input.strafeLeft) move(entity, cell, cell.column + 1, cell.row);
                    if (input.strafeRight) move(entity, cell, cell.column - 1, cell.row);
                    if (input.turnLeft) direction.facing = Right;
                    if (input.turnRight) direction.facing = Left;
                case Right:
                    if (input.up) move(entity, cell, cell.column + 1, cell.row);
                    if (input.down) move(entity, cell, cell.column - 1, cell.row);
                    if (input.strafeLeft) move(entity, cell, cell.column, cell.row - 1);
                    if (input.strafeRight) move(entity, cell, cell.column, cell.row + 1);
                    if (input.turnLeft) direction.facing = Up;
                    if (input.turnRight) direction.facing = Down;
            }
        }
    }

    function move(_entity : Entity, _cell : CellComponent, _column : Int, _row : Int)
    {
        for (entity in familyMap)
        {
            var map = mapComponent.get(entity);

            if (map.data[_column][_row] == Entity.ID_NULL)
            {
                map.data[_cell.column][_cell.row] = Entity.ID_NULL;

                _cell.row    = _row;
                _cell.column = _column;

                map.data[_cell.column][_cell.row] = _entity.id;
            }
        }
    }
}