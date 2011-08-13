require 'math'
require 'os'
require 'leaf'
console = leaf.console
camera = leaf.camera
tween = require 'tween'

local debugFlags = 
{
    fps = true,
    showdebug = false,
}

local debugCommands = 
{
    {'f1', 'show fps',      function() 
                                debugFlags.fps = not debugFlags.fps 
                            end},
    {'f2', 'screenshot',    function() 
                                path = os.date('screenshot-%d-%m-%y.%H.%M.%S.bmp')
                                image = love.graphics.newScreenshot()
                                data = image:encode('bmp')
                                love.filesystem.write(path, data)
                                console.write('Saved screenshot', path)
                            end},
    {'f3', 'render mode',   function()
                                world:cycleRenderMode()
                            end},
    {'f4', 'generate world',function()
                                world:generate()
                            end},
    {'f11', 'fullscreen',   function()
                                -- TODO: Fix this on windows? 
                                -- love.graphics.toggleFullscreen() 
                            end},
    {'f12', 'show debug',   function() 
                                debugFlags.showdebug = not debugFlags.showDebug
                            end},
}


function love.load()
    -- Seed randomness
	math.randomseed(os.time())
	math.random() -- Dumbass OSX fix
	
	-- Load assets
	img = leaf.loader.loadImages('img')

    -- Load modules
    require 'world'
    require 'guy'

    -- Setup console
    console.color = {255, 100, 255}

	-- Generate new world
	world = World:new()
	world:generate()
	
	-- Setup camera
	camera.track(guy)
end

function love.update(dt)
	-- Top level updates
	world:update(dt)
	guy:update(dt)
	camera.update(dt)
end

function love.draw()
    -- Camera draws
    world:drawOverview()
	
	-- Static position draws
	console.draw()
    if debugFlags.fps then
        love.graphics.print('fps: ' .. love.timer.getFPS(), love.graphics.getWidth() - 50, 10)
    end
end 

function love.keypressed(key, unicode)
    if DEBUG then
        for i, table in pairs(debugCommands) do
            keycode, label, func = unpack(table)
            if key == keycode then
                func()
            end
        end
    end
end

function love.mousepressed(x, y, button)
	--
end

function love.mousereleased(x, y, button)
	--
end

function love.quit()
	--
end
