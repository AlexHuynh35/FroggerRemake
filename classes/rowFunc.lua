local class = require 'middleclass'
local RowFunc = class('RowFunc')

function RowFunc:initialize ()

end

function RowFunc:updateObjectRow (objectList) 
	for index, object in pairs(objectList) do 
		object:update()
	end 
end 

function RowFunc:drawObjectRow (objectList)
	for index, object in pairs(objectList) do 
		object:draw() 
	end 
end 

function RowFunc:rowCollision (frog, objectList)
	for index, object in pairs(objectList) do 
		if collide(frog, object) and object.hasCol then 
			return true 
		end 
	end 
	return false 
end

function RowFunc:increaseRowV (objectList, speed)
	for index, object in pairs(objectList) do 
		object:increaseV(speed) 
	end
end

return RowFunc