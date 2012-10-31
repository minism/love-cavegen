require 'entity'

guy = Entity:new()

function guy:gfx()
	love.graphics.setColor(0, 0, 255)
	love.graphics.circle('fill', 0, 0, 16)
end

function guy:update(dt)
	if     love.keyboard.isDown('w') or
		   love.keyboard.isDown('up') then
		self.y = self.y - 2
	elseif love.keyboard.isDown('a') or
		   love.keyboard.isDown('left') then
		self.x = self.x - 2
	elseif love.keyboard.isDown('s') or
		   love.keyboard.isDown('down') then
		self.y = self.y + 2
	elseif love.keyboard.isDown('d') or
		   love.keyboard.isDown('right') then
		self.x = self.x + 2
	end
end

function guy:keypressed(key, unicode)
	-- nop
end