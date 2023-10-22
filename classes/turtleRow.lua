local class = require 'middleclass'
local Turtle = require 'classes/turtle'
local TurtleRow = class('TurtleRow')

function TurtleRow:initialize (xList, y, v, length)
	local tempObjList = {}
	local newObj
	for index, x in pairs(xList) do 
		newObj = Turtle:new(x, y, v, length)
		table.insert(tempObjList, newObj)
	end
	self.waterObjs = tempObjList
	self.y = y * 8
	self.v = v
end

return TurtleRow