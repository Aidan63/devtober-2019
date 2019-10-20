package processors;

import components.EnemyComponent;
import clay.Components;
import uk.aidanlee.flurry.api.resources.Resource.TextResource;
import uk.aidanlee.flurry.api.importers.bmfont.BitmapFontParser;
import uk.aidanlee.flurry.api.importers.bmfont.BitmapFontData;
import uk.aidanlee.flurry.api.gpu.geometry.Color;
import uk.aidanlee.flurry.api.gpu.geometry.shapes.TextGeometry;
import uk.aidanlee.flurry.api.gpu.geometry.shapes.QuadGeometry;
import geometry.NineSlice;
import clay.Entity;
import clay.Family;
import uk.aidanlee.flurry.api.resources.Resource.ImageResource;
import uk.aidanlee.flurry.api.gpu.batcher.Batcher;
import uk.aidanlee.flurry.api.resources.ResourceSystem;
import uk.aidanlee.flurry.api.maths.Rectangle;
import uk.aidanlee.flurry.api.maths.Vector;
import clay.Processor;

class BattleRendererProcessor extends Processor
{
    final batcher : Batcher;

    final resources : ResourceSystem;

    final texture : ImageResource;

    final font : BitmapFontData;

    final colour : Color;

    var familyOpponents : Family;

    var componentsEnemy : Components<EnemyComponent>;

    var geomHealthBarFrame : NineSlice;

    var geomHealthBar : QuadGeometry;

    var geomTitle : TextGeometry;
    
    public function new(_resources : ResourceSystem, _batcher : Batcher)
    {
        super();

        resources = _resources;
        batcher   = _batcher;
        font      = BitmapFontParser.parse(_resources.get('small.fnt', TextResource).content);
        colour    = new Color(207 / 255, 198 / 255, 184 / 255);
        texture   = resources.get('ui', ImageResource);
    }

    override function onadded()
    {
        componentsEnemy = components.get_table(EnemyComponent);

        familyOpponents = families.get('family-opponents');
        familyOpponents.onadded.add(onBattleStarted);
        familyOpponents.onremoved.add(onBattleEnded);
    }

    function onBattleStarted(_entity : Entity)
    {
        final enemy = componentsEnemy.get(_entity);

        geomHealthBarFrame = new NineSlice({
            batchers : [ batcher ],
            textures : [ texture ],
            uv : new Rectangle(16, 0, 48, 48),
            left : 4, right : 4, top : 4, bottom : 4,
            x : 16, y : 16, w : 128, h : 16
        });
        geomHealthBar = new QuadGeometry({
            batchers : [ batcher ],
            textures : [ texture ],
            uv : new Rectangle(
                3 / texture.width,
                19 / texture.height,
                13 / texture.width,
                23 / texture.height
            ),
            x : 19, y : 19, w : 122, h : 10
        });
        geomTitle = new TextGeometry({
            batchers : [ batcher ],
            textures : [ resources.get('small.png', ImageResource) ],
            color    : colour,
            font     : font,
            text     : enemy.name,
            position : new Vector(20, 6)
        });
    }

    function onBattleEnded(_entity : Entity)
    {
        geomHealthBar.drop();
        geomHealthBarFrame.drop();
        geomTitle.drop();
    }

    override function update(_dt : Float)
    {
        for (entity in familyOpponents)
        {
            final enemy = componentsEnemy.get(entity);

            geomHealthBar.set_xywh(19, 19, 122 * (enemy.health / enemy.maxHealth), 10);
        }
    }
}