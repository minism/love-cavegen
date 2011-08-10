require 'leaf'
leaf.import()
tween = require 'tween'

require 'guy'

game = {}

function game.load()
end

function game.update(dt)
end

function game.draw()
end

function game.mousepressed(x, y, button)
end

function game.mousereleased(x, y, button)
end

function game.keypressed(key, unicode)
    if key == 'f1' then
        -- Toggle fullscreen
        if game.fullscreen == nil then
            game.fullscreen = false
        end
        game.fullscreen = not game.fullscreen
        TLfres.setScreen({full=game.fullscreen})
    end
end

function game.quit()
end
