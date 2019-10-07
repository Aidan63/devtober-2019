package;

import world.World;
import uk.aidanlee.flurry.api.resources.Resource.TextResource;
import uk.aidanlee.flurry.FlurryConfig;
import uk.aidanlee.flurry.Flurry;
import format.tmx.Reader;

class Game extends Flurry
{
    var world : World;

    var drawer : WorldDrawer;

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
        final reader = new Reader();
        reader.resolveTSX = _s -> reader.readTSX(Xml.parse(resources.get(_s, TextResource).content));
        final tilemap = reader.read(Xml.parse(resources.get('map', TextResource).content));

        world  = new World(tilemap);
        drawer = new WorldDrawer(renderer, resources, world);
    }

    override function onUpdate(_dt: Float)
    {
        world.update(input);
        drawer.update(_dt, display.width / display.height);
    }
}