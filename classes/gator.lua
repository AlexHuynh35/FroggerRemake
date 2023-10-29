local class = require 'middleclass'
local Animate = require 'classes/animate'
local Gator = class('Gator')

function Gator:initialize (x, y, v, logLength) 
	self.x = 0
	self.y = y * 8
	self.v = v
    self.length = 3
	self.logLength = logLength
    self.active = false
	self.body = GATORBODY
    self.head = concatTable({GATORHEAD[1]}, GATORHEAD)
    self.animateHead = Animate:new (120, self.head)
    self.startX = x * 8
end

function Gator:update ()
    if self.active then
        self.x = self.x + self.v
        if self.x < OFFSCREENLEFT - self.logLength * 8 then self.x = OFFSCREENRIGHT end 
        if self.x > OFFSCREENRIGHT then self.x = OFFSCREENLEFT - self.logLength * 8 end
        self.animateHead:play()
    end
end

function Gator:draw ()
    if self.active then
        spr(self.body[1], self.x, self.y, 0)
        spr(self.body[2], self.x + 8, self.y, 0)
        spr(self.head[self.animateHead.currentSpr], self.x + 16, self.y, 0)
    end
end

function Gator:changeV (speed)
    self.v = self.v * speed
end

function Gator:activate ()
    self.x = self.startX
    self.active = true
end

function Gator:deactivate ()
    self.active = false
end

function Gator:touchingHead (frog)
    local d = (frog.x - (self.x + 20))^2 + (frog.realY - self.y)^2
	if d < 64 then return true end
	return false
end

function Gator:resetPosition ()
	self.x = self.startX
end

function Gator:isActive ()
    return self.active
end 

return Gator