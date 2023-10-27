local class = require 'middleclass'
local CarRow = require 'classes/carRow'
local LogRow = require 'classes/logRow'
local TurtleRow = require 'classes/turtleRow'
local RowFunc = require 'classes/rowFunc'
local RowPattern = class('RowPattern')

function RowPattern:initialize ()
    self.speed = 1
    self.func = RowFunc:new ()
    self.pattern1 = self:createPatternOne ()
    self.pattern2 = self:createPatternTwo ()
    self.pattern3 = self:createPatternThree ()
    self.pattern4 = self:createPatternFour ()
    self.pattern5 = self:createPatternFive ()
end

function RowPattern:increaseSpeed ()
    self.speed = self.speed + .5
    for i = 1, 5 do
        for j = 1, 5 do
            self.func:increaseRowV(self:returnPattern(i%5)[1][j].cars, self.speed)
            self:returnPattern(i%5)[2][j].v = self:returnPattern(i%5)[2][j].v * self.speed
            self.func:increaseRowV(self:returnPattern(i%5)[2][j].waterObjs, self.speed)
        end
    end
end

function RowPattern:returnPattern (n)
    if n == 1 then return self.pattern1 end
    if n == 2 then return self.pattern2 end
    if n == 3 then return self.pattern3 end
    if n == 4 then return self.pattern4 end
    if n == 0 then return self.pattern5 end
end

function RowPattern:createPatternOne ()
    carRow1 = CarRow:new ({7, 15}, 14, -.2, Car1)
    carRow2 = CarRow:new ({10, 20.5}, 13, .2, Car2)
    carRow3 = CarRow:new ({7, 15}, 12, -.2, Car4)
    carRow4 = CarRow:new ({8.5}, 11, .4, Car5)
    carRow5 = CarRow:new ({8, 18.5}, 10, -.15, Car3)
    carRows = {carRow1, carRow2, carRow3, carRow4, carRow5}
    turtleRow1 = TurtleRow:new ({6, 11, 16, 21}, 8, -.25, 3)
    logRow2 = LogRow:new ({6, 11, 16, 21}, 7, .15, 3)
    logRow3 = LogRow:new ({6, 16}, 6, .3, 6)
    turtleRow4 = TurtleRow:new ({6, 10, 14, 18, 22}, 5, -.25, 2)
    logRow5 = LogRow:new ({6, 12, 18}, 4, .2, 4)
    waterRows = {turtleRow1, logRow2, logRow3, turtleRow4, logRow5}
    return {carRows, waterRows}
end

function RowPattern:createPatternTwo ()
    carRow1 = CarRow:new ({7, 13, 19}, 14, -.2, Car1)
    carRow2 = CarRow:new ({10, 20.5}, 13, .2, Car2)
    carRow3 = CarRow:new ({7, 13, 19}, 12, -.2, Car4)
    carRow4 = CarRow:new ({8.5}, 11, .4, Car5)
    carRow5 = CarRow:new ({8, 18.5}, 10, -.15, Car3)
    carRows = {carRow1, carRow2, carRow3, carRow4, carRow5}
    turtleRow1 = TurtleRow:new ({6, 11, 16, 21}, 8, -.25, 3)
    logRow2 = LogRow:new ({6, 11, 16, 21}, 7, .15, 3)
    logRow3 = LogRow:new ({6, 16}, 6, .3, 6)
    turtleRow4 = TurtleRow:new ({6, 10, 14, 18, 22}, 5, -.25, 2)
    logRow5 = LogRow:new ({6, 12, 18}, 4, .2, 4)
    waterRows = {turtleRow1, logRow2, logRow3, turtleRow4, logRow5}
    return {carRows, waterRows}
end

function RowPattern:createPatternThree ()
    carRow1 = CarRow:new ({7, 13, 19}, 14, -.2, Car1)
    carRow2 = CarRow:new ({10, 20.5}, 13, .2, Car2)
    carRow3 = CarRow:new ({7, 13, 19}, 12, -.2, Car4)
    carRow4 = CarRow:new ({8.5, 12}, 11, .4, Car5)
    carRow5 = CarRow:new ({8, 15, 22}, 10, -.15, Car3)
    carRows = {carRow1, carRow2, carRow3, carRow4, carRow5}
    turtleRow1 = TurtleRow:new ({6, 11, 16, 21}, 8, -.25, 3)
    logRow2 = LogRow:new ({6, 11, 16, 21}, 7, .15, 3)
    logRow3 = LogRow:new ({6, 16}, 6, .3, 6)
    turtleRow4 = TurtleRow:new ({6, 10, 14, 18, 22}, 5, -.25, 2)
    logRow5 = LogRow:new ({6, 12, 18}, 4, .2, 4)
    waterRows = {turtleRow1, logRow2, logRow3, turtleRow4, logRow5}
    return {carRows, waterRows}
end

function RowPattern:createPatternFour ()
    carRow1 = CarRow:new ({7, 12.5, 15, 20.5}, 14, -.2, Car1)
    carRow2 = CarRow:new ({10, 17, 24}, 13, .2, Car2)
    carRow3 = CarRow:new ({7, 12.5, 15, 20.5}, 12, -.2, Car4)
    carRow4 = CarRow:new ({8.5, 12}, 11, .4, Car5)
    carRow5 = CarRow:new ({8, 15, 22}, 10, -.15, Car3)
    carRows = {carRow1, carRow2, carRow3, carRow4, carRow5}
    turtleRow1 = TurtleRow:new ({6, 11, 16, 21}, 8, -.25, 3)
    logRow2 = LogRow:new ({6, 11, 16, 21}, 7, .15, 3)
    logRow3 = LogRow:new ({6, 16}, 6, .3, 6)
    turtleRow4 = TurtleRow:new ({6, 10, 14, 18, 22}, 5, -.25, 2)
    logRow5 = LogRow:new ({6, 12, 18}, 4, .2, 4)
    waterRows = {turtleRow1, logRow2, logRow3, turtleRow4, logRow5}
    return {carRows, waterRows}
end

function RowPattern:createPatternFive ()
    carRow1 = CarRow:new ({7, 12.5, 15, 20.5}, 14, -.2, Car1)
    carRow2 = CarRow:new ({10, 17, 24}, 13, .2, Car2)
    carRow3 = CarRow:new ({7, 12.5, 15, 20.5}, 12, -.2, Car4)
    carRow4 = CarRow:new ({8.5, 12, 15.5}, 11, .4, Car5)
    carRow5 = CarRow:new ({8, 15, 22}, 10, -.15, Car3)
    carRows = {carRow1, carRow2, carRow3, carRow4, carRow5}
    turtleRow1 = TurtleRow:new ({6, 11, 16, 21}, 8, -.25, 3)
    logRow2 = LogRow:new ({6, 11, 16, 21}, 7, .15, 3)
    logRow3 = LogRow:new ({6, 16}, 6, .3, 6)
    turtleRow4 = TurtleRow:new ({6, 10, 14, 18, 22}, 5, -.25, 2)
    logRow5 = LogRow:new ({6, 12, 18}, 4, .2, 4)
    waterRows = {turtleRow1, logRow2, logRow3, turtleRow4, logRow5}
    return {carRows, waterRows}
end

return RowPattern