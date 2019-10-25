package processors;

import components.PartyMemberAbilityComponent;
import components.PartyMemberActionComponent;
import components.EnemyBattleComponent;
import components.EnemyComponent;
import components.PartyComponent;
import clay.Entity;
import components.PartyMemberSelectionComponent;
import components.InputComponent;
import components.DirectionComponent;
import components.CellComponent;
import components.EnemyTurnComponent;
import clay.Components;
import clay.Family;
import clay.Processor;

class BattleDetectorProcessor extends Processor
{
    var familyPlayer : Family;

    var familyEnemies : Family;

    var familyPartySelection : Family;

    var familyActiveEnemies : Family;

    var familyEnemyTurns : Family;

    var componentsCell : Components<CellComponent>;

    var componentsDirection : Components<DirectionComponent>;

    var componentsParty : Components<PartyComponent>;

    var componentsEnemyTurn : Components<EnemyTurnComponent>;

    var componentsEnemies : Components<EnemyComponent>;

    override function onadded()
    {
        familyPlayer         = families.get('family-movement');
        familyEnemies        = families.get('family-enemies');
        familyPartySelection = families.get('family-ui-party');
        familyActiveEnemies  = families.get('family-opponents');
        familyEnemyTurns     = families.get('family-enemy-turns');

        componentsCell      = components.get_table(CellComponent);
        componentsDirection = components.get_table(DirectionComponent);
        componentsParty     = components.get_table(PartyComponent);
        componentsEnemyTurn = components.get_table(EnemyTurnComponent);
        componentsEnemies   = components.get_table(EnemyComponent);
    }

    override function update(_dt : Float)
    {
        checkForAdjacentEnemies();
        checkPlayersTurnIsOver();
        checkOpponentsTurnIsOver();
        checkForDefeatedOpponent();
    }

    function checkForAdjacentEnemies()
    {
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

    function checkPlayersTurnIsOver()
    {
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

                for (enemy in familyActiveEnemies)
                {
                    components.set(enemy, new EnemyTurnComponent());
                }
            }
        }
    }

    function checkOpponentsTurnIsOver()
    {
        for (entity in familyEnemyTurns)
        {
            components.remove(entity, EnemyTurnComponent);

            for (player in familyPartySelection)
            {
                final party = componentsParty.get(player);
                for (member in party.members) member.turnTaken = false;

                components.set(player, new PartyMemberSelectionComponent());
            }
        }
    }

    function checkForDefeatedOpponent()
    {
        for (entity in familyEnemies)
        {
            final enemy = componentsEnemies.get(entity);

            if (enemy.health <= 0)
            {
                entities.destroy(entity);

                for (player in familyPartySelection)
                {
                    final party = componentsParty.get(player);
                    for (member in party.members) member.turnTaken = false;

                    components.remove(player, PartyMemberSelectionComponent);
                    components.remove(player, PartyMemberActionComponent);
                    components.remove(player, PartyMemberAbilityComponent);
                    components.set(player, new InputComponent());
                }
            }
        }
    }
}