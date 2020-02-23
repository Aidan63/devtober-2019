package processors;

import uk.aidanlee.flurry.api.gpu.textures.ImageRegion;
import components.EnemyComponent;
import clay.Components;
import uk.aidanlee.flurry.api.resources.Resource.TextResource;
import uk.aidanlee.flurry.api.importers.bmfont.BitmapFontParser;
import uk.aidanlee.flurry.api.importers.bmfont.BitmapFontData;
import uk.aidanlee.flurry.api.gpu.geometry.shapes.TextGeometry;
import uk.aidanlee.flurry.api.gpu.geometry.shapes.QuadGeometry;
import geometry.NineSlice;
import clay.Entity;
import clay.Family;
import uk.aidanlee.flurry.api.resources.Resource.ImageResource;
import uk.aidanlee.flurry.api.gpu.batcher.Batcher;
import uk.aidanlee.flurry.api.resources.ResourceSystem;
import uk.aidanlee.flurry.api.maths.Rectangle;
import uk.aidanlee.flurry.api.maths.Vector3;
import clay.Processor;

class BattleRendererProcessor extends Processor
{
    final batcher : Batcher;

    final resources : ResourceSystem;

    final texture : ImageResource;

    final font : BitmapFontData;

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
            texture  : texture,
            uv : new Rectangle(16, 0, 48, 48),
            left : 4, right : 4, top : 4, bottom : 4,
            x : 16, y : 16, width : 128, height : 16
        });
        geomHealthBar = new QuadGeometry({
            batchers : [ batcher ],
            texture  : texture,
            region : new ImageRegion(texture, 3, 19, 10, 3),
            x : 19, y : 19, width : 122, height : 10
        });
        geomTitle = new TextGeometry({
            batchers : [ batcher ],
            texture  : resources.get('small.png', ImageResource),
            font     : font,
            text     : enemy.name
        });
        geomTitle.position.set_xy(20, 6);
    }

    function onBattleEnded(_entity : Entity)
    {
        batcher.removeGeometry(geomHealthBarFrame);
        batcher.removeGeometry(geomHealthBar);
        batcher.removeGeometry(geomTitle);
    }

    override function update(_dt : Float)
    {
        for (entity in familyOpponents)
        {
            final enemy = componentsEnemy.get(entity);

            geomHealthBar.set(19, 19, 122 * (enemy.health / enemy.maxHealth), 10);
        }
    }
}