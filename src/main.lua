require 'math'
require 'os'
require 'leaf'
leaf.import()
tween = require 'tween'

require 'world'
require 'guy'

function love.load()
    -- Seed randomness
	math.randomseed(os.time())
	math.random() -- Dumbass OSX fix
	
	-- Load assets
	img = loader.loadImages('img')

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
    world:draw()
	
	-- Static position draws
	console.draw()
    love.graphics.print('fps: ' .. love.timer.getFPS(), love.graphics.getWidth() - 50, 10)
end 

function love.keypressed(key, unicode)
    if key == 'f1' then
		love.graphics.toggleFullscreen()
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
