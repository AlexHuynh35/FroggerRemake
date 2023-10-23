local class = require 'middleclass'
local Animate = require 'classes/animate'
local Turtle = class('Turtle')

function Turtle:initialize (x, y, v, length) 
	self.x = x * 8
	self.y = y * 8
	self.v = v
	self.length = length
	self.swimSpr = concatTable({TURTLE[1]}, TURTLE)
	self.diveSpr = {TURTLE[1], TURTLEDIVE[2], TURTLEDIVE[1], TURTLEDIVE[2], TURTLE[1]}
	self.currentSprNum = 1
	self.currentSprs = self.swimSpr
	self.framesPerDive = 600
	self.diving = false
	self.animateSwim = Animate:new (5, self.swimSpr)
	self.animateDive = Animate:new (60, self.diveSpr)
end

function Turtle:update ()
	self.x = self.x + self.v
	if self.x < OFFSCREENLEFT - self.length then self.x = OFFSCREENRIGHT end 
	if self.x > OFFSCREENRIGHT then self.x = OFFSCREENLEFT - self.length end 
	if not self.diving then
		self.framesPerDive = self.framesPerDive - 1
		self.animateSwim:play()
		self.currentSprNum = self.animateSwim.currentSpr
		if self.framesPerDive == 0 then 
			self.diving = true
			self.currentSprNum = 1
			self.currentSprs = self.diveSpr
		end
	else
		self.animateDive:play()
		self.currentSprNum = self.animateDive.currentSpr
		if self.animateDive.counter == self.animateDive.framesPerAni * (#self.animateDive.sprites - 1) then
			self.diving = false
			self.framesPerDive = 600
			self.currentSprNum = 1
			self.currentSprs = self.swimSpr
		end
	end
end 

function Turtle:draw ()
	for i = 0, self.length - 1 do
		spr(self.currentSprs[self.currentSprNum], self.x + i*8, self.y, 0)
		i = i + 1
	end
end 

return Turtle