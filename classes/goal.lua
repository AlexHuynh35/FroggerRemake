local class = require 'middleclass'
local Frog = require 'classes/frog'
local Goal = class('Frog')

function Goal:initialize (x, y)
	self.x = x 
    self.y = y
    self.completed = false 
    self.length = 1
end

function Goal:checkReached(frog)
    tempObj = {x = self.x, y = self.y, length = self.length}
    if collide(frog, tempObj) then 
		self.completed = true
        frog:reset()
        return true 
    end
    return false
end

function Goal:draw()
    if self.completed then spr(GOAL[1], self.x, self.y) end
end

return Goal