local class = require 'middleclass'
local Goal = require 'classes/goal'
local GoalRow = class('GoalRow')

function GoalRow:initialize (xList, y)
    local tempObjList = {}
	local newObj
	for index, x in pairs(xList) do 
		newObj = Goal:new(x, y)
		table.insert(tempObjList, newObj)
	end
	self.goalObjs = tempObjList
    self.y = y * 8
end

function GoalRow:checkReached(frog)
    for index, goal in pairs(self.goalObjs) do 
        if goal:checkReached(frog) then 
            return true 
        end 
    end 
    return false 
end 

function GoalRow:reset()
    for index, goal in pairs(self.goalObjs) do 
        goal.completed = false 
    end 
end 

return GoalRow