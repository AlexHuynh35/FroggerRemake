require "math"
local class = require 'middleclass'
local Animate = require 'classes/animate'
local Snake = class('Snake')

function Snake:initialize (x, y) 
	self.x = x
    self.startX = x * 8
	self.y = y * 8
	self.v = 0.3
    self.direction = 1
    self.length = 2
    self.active = false
    self.head = concatTable({SNAKEHEAD[1]}, SNAKEHEAD)
    self.tail = concatTable({SNAKETAIL[1]}, SNAKETAIL)
	self.animateHead = Animate:new (5, self.head)
	self.animateTail = Animate:new (5, self.tail)
end

function Snake:update ()
    if self.active then
        self.x = self.x + self.direction * self.v
        if self.x < OFFSCREENLEFT + 16 then self.direction = self.direction * -1 end 
        if self.x > OFFSCREENRIGHT - 16 then self.direction = self.direction * -1 end 
        self.animateHead:play()
        self.animateTail:play()
    end
end 

function Snake:draw ()
    if self.active then
        if self.direction == 1 then
            spr(self.head[self.animateHead.currentSpr], self.x + 8, self.y, 0, 1, 1)
            spr(self.tail[self.animateHead.currentSpr], self.x, self.y, 0, 1, 1)
        else
            spr(self.head[self.animateHead.currentSpr], self.x, self.y, 0, 1, 0)
            spr(self.tail[self.animateHead.currentSpr], self.x + 8, self.y, 0, 1, 0)
        end
    end
end 

function Snake:activate ()
    self.active = true
end

function Snake:deactivate ()
    self.active = false
end

function Snake:resetPosition ()
    self.x = self.startX
end

function Snake:isActive ()
    return self.active
end 

return Snake