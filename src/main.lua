require 'math'
require 'os'

require 'leaf'
leaf.import()
tween = require 'tween'

function love.load()
    -- Seed randomness
	math.randomseed(os.time())
	math.random() -- Dumbass OSX fix
	
	-- Load assets
	img = loader.loadImages('img')

	-- Generate new world
	require 'world'
	world = World:new()
	world:generate()
	
	-- Setup camera
	require 'guy'
	camera.track(guy)
end

function love.update(dt)
	-- Top level updates
	world:update(dt)
	guy:update(dt)
	camera.update(dt)
end

function love.draw()
	love.graphics.push()
		-- Apply camera transformation
		camera.apply()
		world:draw()
		guy:draw()
	love.graphics.pop()
	
	-- Misc draws
	console.draw()
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
