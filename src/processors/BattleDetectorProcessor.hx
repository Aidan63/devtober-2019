package processors;

import components.PartyComponent;
import clay.Entity;
import components.PartyMemberSelectionComponent;
import components.InputComponent;
import components.DirectionComponent;
import components.CellComponent;
import components.EnemyBattleComponent;
import clay.Components;
import clay.Family;
import clay.Processor;

class BattleDetectorProcessor extends Processor
{
    var familyPlayer : Family;

    var familyEnemies : Family;

    var familyPartySelection : Family;

    var componentsCell : Components<CellComponent>;

    var componentsDirection : Components<DirectionComponent>;

    var componentsParty : Components<PartyComponent>;

    override function onadded()
    {
        familyPlayer         = families.get('family-movement');
        familyEnemies        = families.get('family-enemies');
        familyPartySelection = families.get('family-ui-party');

        componentsCell      = components.get_table(CellComponent);
        componentsDirection = components.get_table(DirectionComponent);
        componentsParty     = components.get_table(PartyComponent);
    }

    override function update(_dt : Float)
    {
        // Check to see if the user controlled player entities should enter a battle state.
        for (entity in familyPlayer)
        {
            final direction  = componentsDirection.get(entity);
            final playerCell = componentsCell.get(entity);
            
            for (enemy in familyEnemies)
            {
                final enemyCell = componentsCell.get(enemy);

                switch direction.facing
                {
                    case Up    : checkForBattle(playerCell.row - 2, playerCell.column, enemyCell.row, enemyCell.column, entity, enemy);
                    case Left  : checkForBattle(playerCell.row, playerCell.column - 2, enemyCell.row, enemyCell.column, entity, enemy);
                    case Down  : checkForBattle(playerCell.row + 2, playerCell.column, enemyCell.row, enemyCell.column, entity, enemy);
                    case Right : checkForBattle(playerCell.row, playerCell.column + 2, enemyCell.row, enemyCell.column, entity, enemy);
                }
            }
        }

        // Check to see if we should switch who's turn it is.
        for (entity in familyPartySelection)
        {
            final party = componentsParty.get(entity);
            var allDone = true;
            
            for (member in party.members)
            {
                if (!member.turnTaken)
                {
                    allDone = false;
                }
            }

            if (allDone)
            {
                components.remove(entity, PartyMemberSelectionComponent);
            }
        }

        // Check to see if the party or enemy is dead.
    }

    function checkForBattle(_playerRow : Float, _playerColumn : Float, _enemyRow : Float, _enemyColumn : Float, _player : Entity, _enemy : Entity)
    {
        if (_enemyColumn == _playerColumn && _enemyRow == _playerRow)
        {
            components.remove(_player, InputComponent);
            components.set(_player, new PartyMemberSelectionComponent());
            components.set(_enemy, new EnemyBattleComponent());
        }
    }
}