World = Object:extend('World')

-- Defs
local MAPSIZE 	= 100	-- 100x100
local TILESIZE	= 32	-- 8x8

local T_NONE	= 1
local T_WALL	= 2

-- Sprite mapping
local sprTable =
{
	[T_NONE] = 'none.png',
	[T_WALL] = 'wall.png'
}

function World:init()
	-- Init map array
	self.map = {}
	for i = 1, MAPSIZE + 1 do
		self.map[i] = {}
		for j = 1, MAPSIZE + 1 do
			self.map[i][j] = T_WALL
		end
	end
end

function World:generate()

end

function World:update(dt)

end

function World:draw()
	-- Draw tiles
	love.graphics.setColor(255, 255, 255)
	for i = 1, MAPSIZE + 1 do 
		for j = 1, MAPSIZE + 1 do
			console.write(x, y)
			local x, y, tile = i * TILESIZE, j * TILESIZE, self.map[i][j]
			love.graphics.draw(img[sprTable[tile]], x, y, 0, 4, 4)
		end 
	end
end
