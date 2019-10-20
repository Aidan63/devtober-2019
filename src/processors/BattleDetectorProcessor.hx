package processors;

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
                    case Up    : checkForBattle(playerCell.row - 2, playerCell.column, enemyCell.row, enemyCell.column, party, enemy);
                    case Left  : checkForBattle(playerCell.row, playerCell.column - 2, enemyCell.row, enemyCell.column, party, enemy);
                    case Down  : checkForBattle(playerCell.row + 2, playerCell.column, enemyCell.row, enemyCell.column, party, enemy);
                    case Right : checkForBattle(playerCell.row, playerCell.column + 2, enemyCell.row, enemyCell.column, party, enemy);
                }
            }
        }
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