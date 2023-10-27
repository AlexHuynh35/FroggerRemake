local class = require 'middleclass'
local Car = class('Car')

function Car:initialize (x, y, v, sprites)
	self.x = x * 8
	self.y = y * 8
	self.v = v
	self.hasCol = true
	self.sprites = sprites
	self.length = #sprites
end 

function Car:update () 
	self.x = self.x + self.v
	if self.x < OFFSCREENLEFT then self.x = OFFSCREENRIGHT end 
	if self.x > OFFSCREENRIGHT then self.x = OFFSCREENLEFT end 
end

function Car:draw ()
	local i = 0
	for index, sprite in pairs(self.sprites) do
		spr(sprite, self.x + i*8, self.y, 0)
		i = i + 1
	end 
end

function Car:increaseV (speed)
	self.v = self.v * speed
end

return Car