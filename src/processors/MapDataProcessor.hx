package processors;

import clay.Entity;
import clay.Components;
import clay.Processor;
import clay.Family;
import components.MapDataComponent;
import components.CellComponent;

class MapDataProcessor extends Processor
{
    var familyMapData : Family;

    var familyCells : Family;

    var componentsMapData : Components<MapDataComponent>;

    var componentsCells : Components<CellComponent>;

    override function onadded()
    {
        familyMapData     = families.get('family-map-data');
        familyCells       = families.get('family-cells');
        componentsMapData = components.get_table(MapDataComponent);
        componentsCells   = components.get_table(CellComponent);

        familyCells.onadded.add(onCellAdded);
        familyCells.onadded.add(onCellRemoved);
    }

    function onCellAdded(_entity : Entity)
    {
        for (map in familyMapData)
        {
            final mapData = componentsMapData.get(map);
            final cell    = componentsCells.get(_entity);

            mapData.data[cell.column][cell.row] = _entity.id;
        }
    }

    function onCellRemoved(_entity : Entity)
    {
        for (map in familyMapData)
        {
            final mapData = componentsMapData.get(map);
            final cell    = componentsCells.get(_entity);

            mapData.data[cell.column][cell.row] = Entity.ID_NULL;
        }
    }
}