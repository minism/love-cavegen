require 'miner'

World = leaf.Object:extend('World')

-- Defs
local MAPSIZE 	= 512
local TILESIZE	= 32

-- Tiles
local T_NONE	= 1
local T_WALL	= 2

-- Sprite mapping
local sprTable =
{
	[T_NONE] = img['none.png'],
	[T_WALL] = img['wall.png']
}

-- Color mapping (for overview)
local colorTable = 
{
	[T_NONE] = {0, 0, 0},
	[T_WALL] = {255, 255, 255}
}

local ovModes =
{
	'framebuffer',    
	'imagedata' 
}

----------------------------------------

function World:init()
	-- Init map array
	self.map = {}
	self:fill(T_NONE)

	self.ovMode = 1  -- Set mode to framebuffer

	-- Framebuffer to hold overview
	self.ovBuf = love.graphics.newFramebuffer(MAPSIZE, MAPSIZE)
	self:updateOverview()
end

function World:fill(tile)
	for i = 1, MAPSIZE do
		self.map[i] = {}
		for j = 1, MAPSIZE do
			self.map[i][j] = tile
		end
	end
end

function World:generate()
	console.write('Generating new cave')

	-- Fill map
	self:fill(T_WALL)

	-- Miner properties
	local miner_limit = 200
	local fork_chance = 0.1
	local miners = {}

	-- Miner methods
	local UP, LEFT, DOWN, RIGHT = 1, 2, 3, 4
	local function spawn()
		x, y = math.random(1, MAPSIZE+1), math.random(1, MAPSIZE+1)
		table.insert(miners, {x=x, y=y, active=true})
	end

	local function peek(miner, dir)
		-- Return the tile next to a miner
		if dir == UP then
			x, y = miner.x, miner.y - 1
			if y < 1 then y = MAPSIZE end
		elseif dir == LEFT then
			x, y = miner.x - 1, miner.y
			if x < 1 then x = MAPSIZE end
		elseif dir == DOWN then
			x, y = miner.x, miner.y % MAPSIZE + 1
		elseif dir == RIGHT then
			x, y = miner.x % MAPSIZE + 1, miner.y
		end
		return self.map[x][y], x, y
	end

	local function dig(miner)
		-- If there are no walls around me, deactivate
		if peek(miner, UP) == T_NONE and
		   peek(miner, LEFT) == T_NONE and
		   peek(miner, DOWN) == T_NONE and
		   peek(miner, RIGHT) == T_NONE
		then
			miner.active = false
		else
			dir = 0
			while dir == 0 or peek(miner, dir) == T_NONE do
				dir = math.random(1, 4)
			end
			_, x, y = peek(miner, dir)
			-- Remove the wall
			self.map[x][y] = T_NONE
			-- Move the miner
			miner.x, miner.y = x, y
		end
	end

	-- Create initial miner
	spawn()
	testminer = miners[1]

	-- Run mining loop
	while testminer.active do
		dig(testminer)
	end

	self:updateOverview()
end

function World:update(dt)

end

function World:draw()
	-- Draw tiles
	love.graphics.setColor(255, 255, 255)
	for i = 1, MAPSIZE do 
		for j = 1, MAPSIZE do
			console.write(x, y)
			local x, y, tile = i * TILESIZE, j * TILESIZE, self.map[i][j]
			love.graphics.draw(img[sprTable[tile]], x, y, 0, 4, 4)
		end 
	end
end

--- Draw 1px-per-tile overview of map
function World:drawOverview()
	local t =
	{
		framebuffer = function()
			love.graphics.draw(self.ovBuf)
		end,
		imagedata = function()
			-- NOP
		end
	}

	love.graphics.push()
		love.graphics.setColor(255, 255, 255)
		love.graphics.translate((love.graphics.getWidth() - MAPSIZE) / 2,
								(love.graphics.getHeight() - MAPSIZE) / 2)
		t[ovModes[self.ovMode]]()
	love.graphics.pop()
end

--- Render map to framebuffer
function World:updateOverview()
	love.graphics.setRenderTarget(self.ovBuf)
	for i = 1, MAPSIZE do
		for j = 1, MAPSIZE do
			local x, y, tile = i, j, self.map[i][j]
			love.graphics.setColor(unpack(colorTable[tile]))
			love.graphics.rectangle('fill', x, y, 1, 1)
		end
	end
	love.graphics.setRenderTarget()
end

function World:keypressed(key, unicode)
	--
end

function World:cycleRenderMode()
	self.ovMode = self.ovMode % #ovModes + 1 
	console.write('Overview render mode', ovModes[self.ovMode])
end