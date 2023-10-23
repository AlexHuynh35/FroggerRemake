local class = require 'middleclass'
local Log = require 'classes/log'
local LogRow = class('LogRow')

function LogRow:initialize (xList, y, v, length)
	local tempObjList = {}
	local newObj
	for index, x in pairs(xList) do 
		newObj = Log:new(x, y, v, length)
		table.insert(tempObjList, newObj)
	end
	self.waterObjs = tempObjList
	self.y = y * 8
	self.v = v
end

return LogRow