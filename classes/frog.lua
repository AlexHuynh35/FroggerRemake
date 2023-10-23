local class = require 'middleclass'
local Animate = require 'classes/animate'
local Frog = class('Frog')

function Frog:initialize ()
	self.x = XSTART 
	self.y = YSTART
	self.realY = YSTART
	self.framesPerStep = 2
	self.movementTimer = 4 * self.framesPerStep
	self.moving = false
	self.direction = 0
	self.animateJump = Animate:new (self.framesPerStep, {FROG[1], FROG[2], FROG[3], FROG[2], FROG[1]})
end

function Frog:update () 
	if self.moving then
		self.animateJump:play()
		if (self.direction == 3 and self.x > LEFTBOUND and self.movementTimer%self.framesPerStep == 0) then 
			self.x=self.x-2
		end
		if (self.direction == 1 and self.x < RIGHTBOUND and self.movementTimer%self.framesPerStep == 0) then
			self.x=self.x+2
		end
		if (self.direction == 0 and self.movementTimer%self.framesPerStep == 0) then 
			self.y=self.y-2
		end
		if (self.direction == 2 and self.movementTimer%self.framesPerStep == 0) then 
			self.y=self.y+2
		end
		self.movementTimer = self.movementTimer - 1
		if self.movementTimer == 0 then
			self.movementTimer = 4 * self.framesPerStep
			self.moving = false
		end
	else
		if btnp(CONTROL.left) then
			self.moving = true
			self.direction = 3
		end
		if btnp(CONTROL.right) then
			self.moving = true
			self.direction = 1
		end
		if btnp(CONTROL.up) then
			self.moving = true
			self.direction = 0
			self.realY = self.realY - 8
		end
		if btnp(CONTROL.down) then
			self.moving = true
			self.direction = 2
			self.realY = self.realY + 8
		end
	end
end

function Frog:drawFrog ()
	spr(self.animateJump.sprites[self.animateJump.currentSpr], self.x, self.y, 0, 1, 0, self.direction)
end

function Frog:reset ()
	self.x = XSTART 
  	self.y = YSTART
  	self.realY = YSTART
	self.moving = false
	self.direction = 0
end

return Frog