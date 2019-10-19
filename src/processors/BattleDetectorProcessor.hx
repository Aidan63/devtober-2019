package processors;

import components.PartyMemberSelectionComponent;
import components.InputComponent;
import components.DirectionComponent;
import components.CellComponent;
import clay.Components;
import clay.Family;
import clay.Processor;

class BattleDetectorProcessor extends Processor
{
    var familyPlayer : Family;

    var familyEnemies : Family;

    var componentsCell : Components<CellComponent>;

    var componentsDirection : Components<DirectionComponent>;

    override function onadded()
    {
        familyPlayer  = families.get('family-movement');
        familyEnemies = families.get('family-enemies');

        componentsCell      = components.get_table(CellComponent);
        componentsDirection = components.get_table(DirectionComponent);
    }

    override function update(_dt : Float)
    {
        for (party in familyPlayer)
        {
            final direction  = componentsDirection.get(party);
            final playerCell = componentsCell.get(party);
            
            for (enemy in familyEnemies)
            {
                final enemyCell = componentsCell.get(enemy);

                switch direction.facing
                {
                    case Up:
                        if (enemyCell.column == playerCell.column && enemyCell.row == playerCell.row - 2)
                        {
                            components.remove(party, InputComponent);
                            components.set(party, new PartyMemberSelectionComponent());
                        }
                    case Left:
                        if (enemyCell.column == playerCell.column - 2 && enemyCell.row == playerCell.row)
                        {
                            components.remove(party, InputComponent);
                            components.set(party, new PartyMemberSelectionComponent());
                        }
                    case Down:
                        if (enemyCell.column == playerCell.column && enemyCell.row == playerCell.row + 2)
                        {
                            components.remove(party, InputComponent);
                            components.set(party, new PartyMemberSelectionComponent());
                        }
                    case Right:
                        if (enemyCell.column == playerCell.column + 2 && enemyCell.row == playerCell.row)
                        {
                            components.remove(party, InputComponent);
                            components.set(party, new PartyMemberSelectionComponent());
                        }
                }
            }
        }
    }
}