local class = require 'middleclass'
local Car = require 'classes/car'
local CarRow = class('CarRow')

function CarRow:initialize (xList, y, v, sprites)
	local tempCarList = {}
	for index, x in pairs(xList) do 
		newCar = Car:new(x, y, v, sprites)
		table.insert(tempCarList, newCar)
	end
	self.cars = tempCarList
	self.y = y * 8
end 

return CarRow