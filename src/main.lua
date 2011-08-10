require 'tlfres'
require 'game'
require 'math'
require 'os'

function love.load()
    -- Seed randomness
	math.randomseed(os.time())
	math.random() -- Dumbass OSX fix

    -- Setup video
    TLfres.setScreen({
        w=640,
        h=480,
        full=false, 
        vsync=false,
        aa=0}, 640, 480) 

    state = game
	state.load()
end

function love.update(dt)
	state.update(dt)
end

function love.draw()
    TLfres.transform()
    love.graphics.setColor(255, 255, 255)
	state.draw()
    TLfres.letterbox(4, 3)
end 

function love.keypressed(key, unicode)
	state.keypressed(key, unicode)
end

function love.mousepressed(x, y, button)
	state.mousepressed(x, y, button)
end

function love.quit()
    state.quit()
end
