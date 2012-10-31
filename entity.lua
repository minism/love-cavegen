require 'leaf.object'
require 'leaf.polygon'

local Object = leaf.Object
local Rect = leaf.Rect

Entity = Object:extend('Entity')

function Entity:init(w, h)
	self.x = 0 
	self.y = 0
    self.bb = Rect:new(w, h) 
	self.rot = 0
    self.scale = 1
    self.children = nil
end

--- Sets up camera transformations and calls default render method
function Entity:draw()
	love.graphics.push()
		love.graphics.translate(self.x, self.y)
		love.graphics.scale(self.scale, self.scale)
		love.graphics.rotate(self.rot)
		self:gfx()
	love.graphics.pop()
end

--- Need to override this method to draw the entity
function Entity:gfx()
    -- nop
end

--- Called every frame
function Entity:update(dt)
	-- Update children
    if self.children then
	    self.children.update(dt)
    end
end

----[[ Tranformation methods ]]----

function Entity:setSize(w, h)
	self.bb.right = w
	self.bb.bottom = h
end

function Entity:moveTo(x, y)
	self.x = x
	self.y = y
end

function Entity:setScale(s)
	self.scale = s
end

function Entity:setOrientation(rot)
	self.rot = rot
end

function Entity:translate(x, y)
    self.x = self.x + x
    self.y = self.y + y
end

function Entity:rotate(amt)
	self.rot = self.rot + amt
end

function Entity:scale(s)
    self.scale = self.scale * s
end

