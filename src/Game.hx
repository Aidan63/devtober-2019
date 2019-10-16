package;

import processors.PartyActionMenuProcessor;
import slide.Slide;
import clay.Entity;
import processors.MovementProcessor;
import processors.PlayerCameraProcessor;
import processors.InputProcessor;
import processors.WorldRendererProcessor;
import processors.PartyRendererProcessor;
import processors.MapDataProcessor;
import processors.PartyBattleMenuProcessor;
import components.BillboardComponent;
import components.UVComponent;
import components.PositionComponent;
import components.CellComponent;
import components.DirectionComponent;
import components.InputComponent;
import components.MapFloorComponent;
import components.MapDataComponent;
import components.PartyComponent;
import components.PartyMemberSelectionComponent;
import components.PartyMemberActionComponent;
import components.PartyMemberAbilityComponent;
import clay.core.ProcessorManager;
import clay.core.FamilyManager;
import clay.core.ComponentManager;
import clay.core.EntityManager;
import uk.aidanlee.flurry.FlurryConfig;
import uk.aidanlee.flurry.Flurry;
import uk.aidanlee.flurry.api.resources.Resource.TextResource;
import uk.aidanlee.flurry.api.resources.Resource.ShaderResource;
import uk.aidanlee.flurry.api.gpu.batcher.Batcher;
import uk.aidanlee.flurry.api.gpu.camera.Camera2D;
import uk.aidanlee.flurry.api.maths.Rectangle;
import uk.aidanlee.flurry.api.maths.Vector;
import format.tmx.Reader;

class Game extends Flurry
{
    var entities : EntityManager;

    var components : ComponentManager;

    var families : FamilyManager;

    var processors : ProcessorManager;

    var uiCamera : Camera2D;

    var uiBatcher : Batcher;

    var player : Entity;

    var ui : Entity;

    override function onConfig(_config : FlurryConfig) : FlurryConfig
    {
        _config.window.title  = 'Doom';
        _config.window.width  = 320;
        _config.window.height = 240;

        _config.renderer.clearColour.fromRGBA(0.278, 0.176, 0.235, 1.0);

        _config.resources.preload = PrePackaged('preload');

        return _config;
    }

    override function onReady()
    {
        uiCamera  = new Camera2D(160, 120);
        uiBatcher = renderer.createBatcher({
            camera : uiCamera,
            shader : resources.get('textured', ShaderResource),
            depth  : 1
        });

        entities   = new EntityManager(16384);
        components = new ComponentManager(entities);
        families   = new FamilyManager(components);
        processors = new ProcessorManager(entities, components, families);
        
        families.create('family-input', [ InputComponent ]);
        families.create('family-cells', [ CellComponent ]);
        families.create('family-party', [ PartyComponent ]);
        families.create('family-movement', [ InputComponent, DirectionComponent, CellComponent ]);
        families.create('family-smooth-movement', [ CellComponent, DirectionComponent, PositionComponent ]);
        families.create('family-walls', [ CellComponent, UVComponent ], [ BillboardComponent ]);
        families.create('family-billboards', [ CellComponent, UVComponent, BillboardComponent ]);
        families.create('family-map-floor', [ MapFloorComponent ]);
        families.create('family-map-data', [ MapDataComponent ]);

        families.create('family-ui-party'           , [ PartyComponent ]);
        families.create('family-ui-member-selection', [ PartyComponent, PartyMemberSelectionComponent ]);
        families.create('family-ui-member-action'   , [ PartyComponent, PartyMemberActionComponent ], [ PartyMemberSelectionComponent ]);
        families.create('family-ui-member-ability'  , [ PartyComponent, PartyMemberAbilityComponent ], [ PartyMemberActionComponent, PartyMemberSelectionComponent ]);

        processors.add(new MapDataProcessor(), 0);
        processors.add(new InputProcessor(input), 1);
        processors.add(new MovementProcessor(), 2);
        processors.add(new PlayerCameraProcessor(), 3);
        processors.add(new WorldRendererProcessor(renderer, resources), 4);
        processors.add(new PartyRendererProcessor(resources, uiBatcher), 5);
        processors.add(new PartyActionMenuProcessor(input, resources, uiBatcher), 6);
        processors.add(new PartyBattleMenuProcessor(input, resources, uiBatcher), 7);

        // create map entities.
        createMap();

        // create player entity.
        player = entities.create();
        components.set_many(player, [
            new InputComponent(),
            new DirectionComponent(),
            new CellComponent(1, 1),
            new PositionComponent()
        ]);

        // Entity which will hold components relating to the menu state
        ui = entities.create();
        components.set_many(ui, [
            new PartyComponent(),
            new PartyMemberSelectionComponent()
        ]);
    }

    override function onUpdate(_dt: Float)
    {
        Slide.step(_dt);

        uiCamera.viewport.set(0, 0, display.width, display.height);
        uiCamera.update(_dt);

        processors.update(_dt);
    }

    function createMap()
    {
        final reader = new Reader();
        reader.resolveTSX = _s -> reader.readTSX(Xml.parse(resources.get(_s, TextResource).content));
        final tilemap = reader.read(Xml.parse(resources.get('map', TextResource).content));

        components.set(entities.create(), new MapDataComponent(tilemap.width, tilemap.height));

        for (layer in tilemap.layers)
        {
            switch layer
            {
                case LTileLayer(layer):
                    switch layer.name
                    {
                        case 'Walls', 'Billboards':
                            for (row in 0...layer.height)
                            {
                                for (col in 0...layer.width)
                                {
                                    final gid = layer.data.tiles[(col * layer.height) + row].gid;
                                    if (gid != 0)
                                    {
                                        final spriteRow = Std.int(gid / tilemap.tilesets[0].columns);
                                        final spriteCol = (gid % tilemap.tilesets[0].columns) - 1;

                                        final comps : Array<Dynamic> = [
                                            new CellComponent(row, col),
                                            new UVComponent(
                                                (spriteCol * tilemap.tileWidth),
                                                (spriteRow * tilemap.tileHeight),
                                                tilemap.tileWidth,
                                                tilemap.tileHeight)
                                        ];
                                        if (layer.name == 'Billboards')
                                        {
                                            comps.push(new BillboardComponent());
                                        }

                                        components.set_many(entities.create(), comps);
                                    }
                                }
                            }
                        case 'Floor':
                            final pos = [];
                            final uvs = [];

                            for (row in 0...layer.height)
                            {
                                for (col in 0...layer.width)
                                {
                                    final gid = layer.data.tiles[(col * layer.height) + row].gid;
                                    if (gid != 0)
                                    {
                                        final spriteRow = Std.int(gid / tilemap.tilesets[0].columns);
                                        final spriteCol = (gid % tilemap.tilesets[0].columns) - 1;

                                        pos.push(new Vector(col * tilemap.tileWidth, row * tilemap.tileHeight));
                                        uvs.push(new Rectangle(
                                            (spriteCol * tilemap.tileWidth),
                                            (spriteRow * tilemap.tileHeight),
                                            tilemap.tileWidth,
                                            tilemap.tileHeight));
                                    }
                                }
                            }

                            components.set(entities.create(), new MapFloorComponent(pos, uvs));
                    }
                case LObjectGroup(group):
                case LImageLayer(layer):
                case LGroup(group):
            }
        }
    }
}