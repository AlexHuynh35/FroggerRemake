local class = require 'middleclass'
local Log = class('Log')

function Log:initialize (x, y, v, length) 
	self.x = x * 8
	self.y = y * 8
	self.v = v
	self.length = length
	self.hasCol = true
	self.sprites = self:fillSprList()
end

function Log:update ()
	self.x = self.x + self.v
	if self.x < OFFSCREENLEFT - self.length * 8 then self.x = OFFSCREENRIGHT end 
	if self.x > OFFSCREENRIGHT then self.x = OFFSCREENLEFT - self.length * 8 end 
end 

function Log:fillSprList ()
	local sprList = {}
	table.insert(sprList, LOG[1])
	for i = 2, self.length - 1 do
		table.insert(sprList, LOG[2])
	end
	table.insert(sprList, LOG[3])
	return sprList
end

function Log:draw ()
	local i = 0
	for index, sprite in pairs(self.sprites) do
		spr(sprite, self.x + i*8, self.y, 0)
		i = i + 1
	end
end 

function Log:increaseV (speed)
	self.v = self.v * speed
end

return Log