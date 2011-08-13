require 'leaf.polygon'

require 'miner'

World = leaf.Object:extend('World')

-- Defs
local MAPSIZE 	= 320
local TILESIZE	= 32
local OV_SCALE  = 2

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

--- Mouse delta stuff for overview panning
local mx, my, pmx, pmy = 0, 0, 0, 0
local mdelta = false

----------------------------------------

function World:init()
	-- Init map array
	self.map = {}
	for i = 1, MAPSIZE do
		self.map[i] = {}
	end
	self:fill(T_NONE)

	-- Overview data
	self.ovMode = 1  -- Set mode to framebuffer
	self.ovBuf = love.graphics.newFramebuffer(MAPSIZE * OV_SCALE, MAPSIZE * OV_SCALE)
	self.ovWrap = {0, 0}
	self.ovRect = leaf.Rect:new(MAPSIZE * OV_SCALE, MAPSIZE * OV_SCALE)
	self.ovRect:translate(25, 25)
	self:updateOverview()
end

function World:fill(tile)
	for i = 1, MAPSIZE do
		for j = 1, MAPSIZE do
			self.map[i][j] = tile
		end
	end
end

function World:generate(args)
	console.write('Generating new cave')

	-- Algorithm parameters
	args = args or {}
	local miner_limit = args.miner_limit or 300
	local fork_chance = args.fork_chance or 0.1
	local sources	  = args.sources or 1


	-- Fill map
	self:fill(T_WALL)
	local UP, LEFT, DOWN, RIGHT = 1, 2, 3, 4

	-- Miner properties
	local inactive_count = 0
	local miners = {}

	-- Miner methods
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

	local function spawn(miner)
		-- Spawn a new miner in a random direction
		dir = math.random(1, 4)
		_, x, y = peek(miner, dir)
		table.insert(miners, {x=x, y=y, active=true})
		inactive_count = inactive_count + 1
	end

	local function dig(miner)
		-- If there are no walls around me, deactivate
		if peek(miner, UP) == T_NONE and
		   peek(miner, LEFT) == T_NONE and
		   peek(miner, DOWN) == T_NONE and
		   peek(miner, RIGHT) == T_NONE
		then
			inactive_count = inactive_count - 1
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
			-- Chance to spawn a new miner?
			if math.random() < fork_chance then
				spawn(miner)
			end
		end
	end

	-- Create initial miner(s)
	for i=1, sources do
		table.insert(miners, {x=math.random(1, MAPSIZE),
							  y=math.random(1, MAPSIZE), active=true})
	end
	inactive_count = sources

	-- Run mining loop
	while #miners <= miner_limit * sources and inactive_count > 0 do
		for i = 1, #miners do
			local miner = miners[i]
			if miner.active then
				dig(miner)
			end
		end
	end

	self:updateOverview()
end

function World:update(dt)
	if love.mouse.isDown('l') and mdelta then
		-- Track mouse
		mx, my = love.mouse.getX(), love.mouse.getY()
	end
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

--- Draw overview of map
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
		love.graphics.translate(self.ovRect.left, self.ovRect.top)
		t[ovModes[self.ovMode]]()
	love.graphics.pop()

	-- Draw mouse delta?
	if mdelta then
		love.graphics.setLineWidth(1)
		love.graphics.setColor(255, 0, 0)
		love.graphics.line(pmx, pmy, mx, my)
	end

	-- Extra text
	love.graphics.setColor(255, 255, 255)
	love.graphics.print('Click and drag to pan', self.ovRect.left, self.ovRect.bottom + 5)
end

--- Render map to framebuffer optionally using a wrap offset
function World:updateOverview(offx, offy)
	love.graphics.setRenderTarget(self.ovBuf)
	for i = 1, MAPSIZE do
		for j = 1, MAPSIZE do
			-- Shift lookup by offset if specified
			local _i = (i + self.ovWrap[1] - 1) % MAPSIZE + 1
			local _j = (j + self.ovWrap[2] - 1) % MAPSIZE + 1
			local x, y, tile = i * OV_SCALE, j * OV_SCALE, self.map[_i][_j]
			love.graphics.setColor(unpack(colorTable[tile]))
			love.graphics.rectangle('fill', x, y, OV_SCALE, OV_SCALE)
		end
	end
	love.graphics.setRenderTarget()
end

function World:keypressed(key, unicode)
	--
end

function World:mousepressed(x, y, button)
	if self.ovRect:contains(x, y) then
		mdelta = true
		pmx = x
		pmy = y
	else
		mdelta = false
	end
end

function World:mousereleased(x, y, button)
	if mdelta then
		mdelta = false
		local dx, dy = mx - pmx, my - pmy
		self.ovWrap = {self.ovWrap[1] - dx,
					   self.ovWrap[2] - dy}
		self:updateOverview()
	end
end

function World:cycleRenderMode()
	self.ovMode = self.ovMode % #ovModes + 1 
	console.write('Overview render mode', ovModes[self.ovMode])
end