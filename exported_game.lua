do
local _ENV = _ENV
package.preload[ "classes/animate" ] = function( ... ) local arg = _G.arg;
local class = require 'middleclass'
local Animate = class('Animate')

function Animate:initialize (frames, sprList)
	self.framesPerAni = frames
	self.counter = self.framesPerAni * (#sprList - 1)
	self.currentSpr = 1
	self.sprites = sprList
end

function Animate:play ()
	if self.counter%self.framesPerAni == 0 then
		self.currentSpr = self.currentSpr + 1
	end
	self.counter = self.counter-1
	if self.counter == 0 then
		self.counter = self.framesPerAni * (#self.sprites - 1)
		self.currentSpr = 1
	end
end

return Animate
end
end

do
local _ENV = _ENV
package.preload[ "classes/car" ] = function( ... ) local arg = _G.arg;
local class = require 'middleclass'
local Car = class('Car')

function Car:initialize (x, y, v, sprites)
	self.x = x * 8
	self.y = y * 8
	self.v = v
	self.sprites = sprites
	self.length = #sprites
end 

function Car:update () 
	self.x = self.x + self.v
	if self.x < OFFSCREENLEFT then self.x = OFFSCREENRIGHT end 
	if self.x > OFFSCREENRIGHT then self.x = OFFSCREENLEFT end 
end

function Car:draw ()
	local i = 0
	for index, sprite in pairs(self.sprites) do
		spr(sprite, self.x + i*8, self.y, 0)
		i = i + 1
	end 
end

return Car
end
end

do
local _ENV = _ENV
package.preload[ "classes/carRow" ] = function( ... ) local arg = _G.arg;
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
end
end

do
local _ENV = _ENV
package.preload[ "classes/frog" ] = function( ... ) local arg = _G.arg;
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

-- returns whether frog jumped up
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
			return true 
		end
		if btnp(CONTROL.down) then
			self.moving = true
			self.direction = 2
			self.realY = self.realY + 8
		end
	end
	return false 
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
end
end

do
local _ENV = _ENV
package.preload[ "classes/goal" ] = function( ... ) local arg = _G.arg;
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
    if self.completed then return false end
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
end
end

do
local _ENV = _ENV
package.preload[ "classes/goalRow" ] = function( ... ) local arg = _G.arg;
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
end
end

do
local _ENV = _ENV
package.preload[ "classes/log" ] = function( ... ) local arg = _G.arg;
local class = require 'middleclass'
local Log = class('Log')

function Log:initialize (x, y, v, length) 
	self.x = x * 8
	self.y = y * 8
	self.v = v
	self.length = length
	self.sprites = self:fillSprList()
end

function Log:update ()
	self.x = self.x + self.v
	if self.x < OFFSCREENLEFT - self.length then self.x = OFFSCREENRIGHT end 
	if self.x > OFFSCREENRIGHT then self.x = OFFSCREENLEFT - self.length end 
end 

function Log:fillSprList ()
	local sprList = {}
	table.insert(sprList, LOG[1])
	for i = 2, self.length - 1 do
		table.insert(sprList, LOG[2])
	end
	table.insert(sprList, LOG[3])
	return sprList
end

function Log:draw ()
	local i = 0
	for index, sprite in pairs(self.sprites) do
		spr(sprite, self.x + i*8, self.y, 0)
		i = i + 1
	end
end 

return Log
end
end

do
local _ENV = _ENV
package.preload[ "classes/logRow" ] = function( ... ) local arg = _G.arg;
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
end
end

do
local _ENV = _ENV
package.preload[ "classes/rowFunc" ] = function( ... ) local arg = _G.arg;
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
		if collide(frog, object) then 
			return true 
		end 
	end 
	return false 
end

return RowFunc
end
end

do
local _ENV = _ENV
package.preload[ "classes/turtle" ] = function( ... ) local arg = _G.arg;
local class = require 'middleclass'
local Animate = require 'classes/animate'
local Turtle = class('Turtle')

function Turtle:initialize (x, y, v, length) 
	self.x = x * 8
	self.y = y * 8
	self.v = v
	self.length = length
	self.swimSpr = concatTable({TURTLE[1]}, TURTLE)
	self.diveSpr = {TURTLE[1], TURTLEDIVE[2], TURTLEDIVE[1], TURTLEDIVE[2], TURTLE[1]}
	self.currentSprNum = 1
	self.currentSprs = self.swimSpr
	self.framesPerDive = 600
	self.diving = false
	self.animateSwim = Animate:new (5, self.swimSpr)
	self.animateDive = Animate:new (60, self.diveSpr)
end

function Turtle:update ()
	self.x = self.x + self.v
	if self.x < OFFSCREENLEFT - self.length then self.x = OFFSCREENRIGHT end 
	if self.x > OFFSCREENRIGHT then self.x = OFFSCREENLEFT - self.length end 
	if not self.diving then
		self.framesPerDive = self.framesPerDive - 1
		self.animateSwim:play()
		self.currentSprNum = self.animateSwim.currentSpr
		if self.framesPerDive == 0 then 
			self.diving = true
			self.currentSprNum = 1
			self.currentSprs = self.diveSpr
		end
	else
		self.animateDive:play()
		self.currentSprNum = self.animateDive.currentSpr
		if self.animateDive.counter == self.animateDive.framesPerAni * (#self.animateDive.sprites - 1) then
			self.diving = false
			self.framesPerDive = 600
			self.currentSprNum = 1
			self.currentSprs = self.swimSpr
		end
	end
end 

function Turtle:draw ()
	for i = 0, self.length - 1 do
		spr(self.currentSprs[self.currentSprNum], self.x + i*8, self.y, 0)
		i = i + 1
	end
end 

return Turtle
end
end

do
local _ENV = _ENV
package.preload[ "classes/turtleRow" ] = function( ... ) local arg = _G.arg;
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
end
end

do
local _ENV = _ENV
package.preload[ "middleclass" ] = function( ... ) local arg = _G.arg;
local middleclass = {
    _VERSION     = 'middleclass v4.1.1',
    _DESCRIPTION = 'Object Orientation for Lua',
    _URL         = 'https://github.com/kikito/middleclass',
    _LICENSE     = [[
      MIT LICENSE
  
      Copyright (c) 2011 Enrique García Cota
  
      Permission is hereby granted, free of charge, to any person obtaining a
      copy of this software and associated documentation files (the
      "Software"), to deal in the Software without restriction, including
      without limitation the rights to use, copy, modify, merge, publish,
      distribute, sublicense, and/or sell copies of the Software, and to
      permit persons to whom the Software is furnished to do so, subject to
      the following conditions:
  
      The above copyright notice and this permission notice shall be included
      in all copies or substantial portions of the Software.
  
      THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
      OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
      MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
      IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
      CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
      TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
      SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
    ]]
  }
  
  local function _createIndexWrapper(aClass, f)
    if f == nil then
      return aClass.__instanceDict
    elseif type(f) == "function" then
      return function(self, name)
        local value = aClass.__instanceDict[name]
  
        if value ~= nil then
          return value
        else
          return (f(self, name))
        end
      end
    else -- if  type(f) == "table" then
      return function(self, name)
        local value = aClass.__instanceDict[name]
  
        if value ~= nil then
          return value
        else
          return f[name]
        end
      end
    end
  end
  
  local function _propagateInstanceMethod(aClass, name, f)
    f = name == "__index" and _createIndexWrapper(aClass, f) or f
    aClass.__instanceDict[name] = f
  
    for subclass in pairs(aClass.subclasses) do
      if rawget(subclass.__declaredMethods, name) == nil then
        _propagateInstanceMethod(subclass, name, f)
      end
    end
  end
  
  local function _declareInstanceMethod(aClass, name, f)
    aClass.__declaredMethods[name] = f
  
    if f == nil and aClass.super then
      f = aClass.super.__instanceDict[name]
    end
  
    _propagateInstanceMethod(aClass, name, f)
  end
  
  local function _tostring(self) return "class " .. self.name end
  local function _call(self, ...) return self:new(...) end
  
  local function _createClass(name, super)
    local dict = {}
    dict.__index = dict
  
    local aClass = { name = name, super = super, static = {},
                     __instanceDict = dict, __declaredMethods = {},
                     subclasses = setmetatable({}, {__mode='k'})  }
  
    if super then
      setmetatable(aClass.static, {
        __index = function(_,k)
          local result = rawget(dict,k)
          if result == nil then
            return super.static[k]
          end
          return result
        end
      })
    else
      setmetatable(aClass.static, { __index = function(_,k) return rawget(dict,k) end })
    end
  
    setmetatable(aClass, { __index = aClass.static, __tostring = _tostring,
                           __call = _call, __newindex = _declareInstanceMethod })
  
    return aClass
  end
  
  local function _includeMixin(aClass, mixin)
    assert(type(mixin) == 'table', "mixin must be a table")
  
    for name,method in pairs(mixin) do
      if name ~= "included" and name ~= "static" then aClass[name] = method end
    end
  
    for name,method in pairs(mixin.static or {}) do
      aClass.static[name] = method
    end
  
    if type(mixin.included)=="function" then mixin:included(aClass) end
    return aClass
  end
  
  local DefaultMixin = {
    __tostring   = function(self) return "instance of " .. tostring(self.class) end,
  
    initialize   = function(self, ...) end,
  
    isInstanceOf = function(self, aClass)
      return type(aClass) == 'table'
         and type(self) == 'table'
         and (self.class == aClass
              or type(self.class) == 'table'
              and type(self.class.isSubclassOf) == 'function'
              and self.class:isSubclassOf(aClass))
    end,
  
    static = {
      allocate = function(self)
        assert(type(self) == 'table', "Make sure that you are using 'Class:allocate' instead of 'Class.allocate'")
        return setmetatable({ class = self }, self.__instanceDict)
      end,
  
      new = function(self, ...)
        assert(type(self) == 'table', "Make sure that you are using 'Class:new' instead of 'Class.new'")
        local instance = self:allocate()
        instance:initialize(...)
        return instance
      end,
  
      subclass = function(self, name)
        assert(type(self) == 'table', "Make sure that you are using 'Class:subclass' instead of 'Class.subclass'")
        assert(type(name) == "string", "You must provide a name(string) for your class")
  
        local subclass = _createClass(name, self)
  
        for methodName, f in pairs(self.__instanceDict) do
          if not (methodName == "__index" and type(f) == "table") then
            _propagateInstanceMethod(subclass, methodName, f)
          end
        end
        subclass.initialize = function(instance, ...) return self.initialize(instance, ...) end
  
        self.subclasses[subclass] = true
        self:subclassed(subclass)
  
        return subclass
      end,
  
      subclassed = function(self, other) end,
  
      isSubclassOf = function(self, other)
        return type(other)      == 'table' and
               type(self.super) == 'table' and
               ( self.super == other or self.super:isSubclassOf(other) )
      end,
  
      include = function(self, ...)
        assert(type(self) == 'table', "Make sure you that you are using 'Class:include' instead of 'Class.include'")
        for _,mixin in ipairs({...}) do _includeMixin(self, mixin) end
        return self
      end
    }
  }
  
  function middleclass.class(name, super)
    assert(type(name) == 'string', "A name (string) is needed for the new class")
    return super and super:subclass(name) or _includeMixin(_createClass(name), DefaultMixin)
  end
  
  setmetatable(middleclass, { __call = function(_, ...) return middleclass.class(...) end })
  
  return middleclass
end
end

-- title:   Frogger Remake
-- author:  Summit Pradhan and Alex Huynh
-- desc:    remake of the arcade Frogger
-- site:    website link
-- license: MIT License (change this to your license of choice)
-- version: 0.1
-- script:  lua

t=0
x=96
y=24
CONTROL = {up = 0, down = 1, left = 2, right = 3}
XSTART = 15 * 8
YSTART = 15 * 8
LEFTBOUND = 6 * 8
RIGHTBOUND = 23 * 8
OFFSCREENLEFT = 32
OFFSCREENRIGHT = 192
LIVESPOS = {x = 6 * 8, y = 16 * 8}

FROG = {256, 257, 258}
Car1 = {259}
Car2 = {260}
Car3 = {261, 262}
Car4 = {263}
Car5 = {264}
COLDEATH = {320, 321, 322, 304}
WATDEATH = {305, 306, 307, 304}
LOG = {390, 391, 392}
TURTLE = {338, 339, 340}
TURTLEDIVE = {336, 337}
GOAL = {353, 354}

local class = require 'middleclass'
local Frog = require 'classes/frog'
local Animate = require 'classes/animate'
local Car = require 'classes/car'
local Log = require 'classes/log'
local Turtle = require 'classes/turtle'
local Goal = require 'classes/goal'
local RowFunc = require 'classes/rowFunc'
local CarRow = require 'classes/carRow'
local LogRow = require 'classes/logRow'
local TurtleRow = require 'classes/turtleRow'
local GoalRow = require 'classes/goalRow'

--debug variables
local NOCOLLISIONS = false

function initBorder ()
	for i=0,5 do
		for j=0,16 do
			spr(511, i*8, j*8, 15)
		end
	end
	for i=24,29 do
		for j=0,16 do
			spr(511, i*8, j*8, 15)
		end
	end
end

function concatTable(t1, t2)
    for i = 1, #t2 do
        table.insert(t1, t2[i])
    end
    return t1
end

function collide (frog, object)
	for i = 0, object.length - 1 do 
		local d = (frog.x - (object.x + i*8))^2 + (frog.realY - object.y)^2
		if d < 64 then return true end
	end
	return false
end

colDeath = false
watDeath = false
hasDied = false
frogLastLoc = {}
frog = Frog:new ()
rowFunc = RowFunc:new ()
animateColDeath = Animate:new (20, concatTable({COLDEATH[1]}, COLDEATH))
animateWatDeath = Animate:new (20, concatTable({WATDEATH[1]}, WATDEATH))
carRow1 = CarRow:new ({7, 12.5, 15, 20.5}, 14, -.4, Car1)
carRow2 = CarRow:new ({10, 17, 24}, 13, .4, Car2)
carRow3 = CarRow:new ({7, 12.5, 15, 20.5}, 12, -.4, Car4)
carRow4 = CarRow:new ({8.5, 12}, 11, .8, Car5)
carRow5 = CarRow:new ({8, 15, 22}, 10, -.3, Car3)
carRows = {carRow1, carRow2, carRow3, carRow4, carRow5}
turtleRow1 = TurtleRow:new ({6, 11, 16, 21}, 8, -.5, 3)
logRow2 = LogRow:new ({6, 11, 16, 21}, 7, .3, 3)
logRow3 = LogRow:new ({6, 16}, 6, .6, 6)
turtleRow4 = TurtleRow:new ({6, 10, 14, 18, 22}, 5, -.5, 2)
logRow5 = LogRow:new ({6, 12, 18}, 4, .4, 4)
waterRows = {turtleRow1, logRow2, logRow3, turtleRow4, logRow5}
goalRow = GoalRow:new ({56, 88, 120, 152, 176}, 24)
goalsCompleted = 0
level = 1
lives = 3
roundStartTime = 0
points = 0

function TIC()
	cls(3)
	map(0, 0, 240, 136, 0, 0)
	-- Time Display
	timeLeft = 30 - ((time() - roundStartTime) / 1000)
	timeWidth = (timeLeft / 30) * (6 * 8)
	print("TIME:", 15 * 8, 16 * 8 + 1, 12)
	rect(18 * 8, 16 * 8 + 2, timeWidth, 3, 6)
	-- Points Display
	print("POINTS:", 16 * 8, 0, 12, 1, 1)
	print(tostring(points), 16 * 8, 1 * 8, 12, 1, 1)
	-- Level Display
	print("LEVEL:", 6 * 8, 0, 12, 1, 1)
	print(tostring(level), 6 * 8, 1 * 8, 12, 1, 1)
	-- Lives Display
	for i = 0, lives-1 do
		spr(FROG[1], LIVESPOS.x + (i * 8), LIVESPOS.y, 0)
	end
	-- Death
	if hasDied then 
		lives = lives - 1
		hasDied = false 
	end 
	if colDeath then
		animateColDeath:play()
		spr(animateColDeath.sprites[animateColDeath.currentSpr], frogLastLoc[1], frogLastLoc[2], 0)
		if animateColDeath.counter == animateColDeath.framesPerAni * (#animateColDeath.sprites - 1) then
			colDeath = false
		end
	end
	if watDeath then
		animateWatDeath:play()
		spr(animateWatDeath.sprites[animateWatDeath.currentSpr], frogLastLoc[1], frogLastLoc[2], 0)
		if animateWatDeath.counter == animateWatDeath.framesPerAni * (#animateWatDeath.sprites - 1) then
			watDeath = false
		end
	end
	-- Game Over 
	if (lives <= 0) and not colDeath and not watDeath then
		exit()
		trace("Game Over! You Score " .. tostring(points) .. " points!")
	end
	-- Frog Update
	if not colDeath and not watDeath then 
		-- If frog jumps forward, then add points
		if frog:update() then
			points = points + 10
		end
	end
	-- Row Updates
	for i = 1, 5 do 
		rowFunc:updateObjectRow(carRows[i].cars)
		rowFunc:updateObjectRow(waterRows[i].waterObjs)
	end 
	for i = 1, 5 do 
		rowFunc:drawObjectRow(carRows[i].cars)
		rowFunc:drawObjectRow(waterRows[i].waterObjs) 
	end
	-- Collision Check
	if not colDeath and not watDeath then frog:drawFrog() end
	if not NOCOLLISIONS then 
		for i = 1, 5 do 
			if rowFunc:rowCollision(frog, carRows[i].cars) then 
				colDeath = true
				hasDied = true
				frogLastLoc = {frog.x, frog.y}
				roundStartTime = time()
				frog:reset()
			end
			if (not rowFunc:rowCollision(frog, waterRows[i].waterObjs)) and frog.realY == waterRows[i].y then 
				watDeath = true
				hasDied = true
				frogLastLoc = {frog.x, frog.y}
				roundStartTime = time()
				frog:reset()
			elseif rowFunc:rowCollision(frog, waterRows[i].waterObjs) then
				frog.x = frog.x + waterRows[i].v
			end
		end
	end 
	-- Reached Goal
	if goalRow:checkReached(frog) then 
		goalsCompleted = goalsCompleted + 1
		points = points + 10 * math.floor(timeLeft / .5)
		points = points + 50
		roundStartTime = time()
	elseif frog.realY <= 24 then 
		colDeath = true 
		hasDied = true
		frogLastLoc = {frog.x, frog.y}
		frog:reset()
	end 
	rowFunc:drawObjectRow(goalRow.goalObjs)
	-- Finished Level
	if goalsCompleted == 5 then 
		level = level + 1
		points = points + 1000
		goalRow:reset() 
		if lives < 4 then
			lives = lives + 1
		end
		goalsCompleted = 0
	end 
	-- Time ran out
	if timeLeft < 0 then 
		colDeath = true 
		hasDied = true
		roundStartTime = time()
		frogLastLoc = {frog.x, frog.y}
		frog:reset()
	end 
	-- Border create
	initBorder()
end

-- <TILES>
-- 000:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 001:1191119119291929119111911111112111111191119119291929119111911121
-- 002:66666666666f33666666f666666666666f33666666f666666666f33666666f66
-- 003:8888888888888888888888888888888888888888888888888888888888888888
-- 005:ffffffffffffffffffffffff6666666666666666ffffffffffffffffffffffff
-- 016:5ff55ff554455445544554455ff55ff5ffffffffffffffffffffffffffffffff
-- 017:11911191192919291191119111111121222f222ff2fff2fff2fff2fff2ff222f
-- 018:66666666666f33666666f666666666666f33666666f666666666f33622622f22
-- 032:5ff5ffff5445ffff5445ffff5ff5ffffffffffffffffffffffffffffffffffff
-- 033:119111911929192911911191111111212ff2f2222222f2ff2f22f22f2ff2f222
-- 034:66666662666f33626666f662666666626f33666666f666626666f33222622f22
-- 048:ffffffffffffffffffffffffffffffff66666666666666666666666666666666
-- 049:11911191192919291191119111111121f222ff2ff2fff2f2f222f2f2f222ff2f
-- 050:26666666266f33666666f666266666662f33666626f666662666f33622622f22
-- 064:ffffffffffffffffffffffffffffffffff666666ff666666ff666666ff666666
-- 065:11911191192919291191119111111121f2f2f222f2f2f22ff222fff2fff2f22f
-- 080:ffffffffffffffffffffffffffffffffffff6666ffff6666ffff6666ffff6666
-- 081:11911191192919291191119111111121f222ff2fff22f2f2fff2f2f2f222ff2f
-- 096:ffffffffffffffffffffffffffffffffffffff66ffffff66ffffff66ffffff66
-- 097:11911191192919291191119111111121ffffffffffffffffffffffffffffffff
-- 112:ffffffffffffffffffffffffffffffff444f444ff4fff4fff4fff4fff4ff444f
-- 128:f22fffff5555ffff5555fffff55fffff4ff4f4444444f4ff4f44f44f4ff4f444
-- </TILES>

-- <SPRITES>
-- 000:5005500550255205505445050544445000464400055645505005500550000005
-- 001:5005500550255205505445050544445000464400055645505005500505000050
-- 002:0005500050255205505445050544445000464400055645505005500500000000
-- 003:2200002222444422441144444114434341144343441144442244442222000022
-- 004:222200026006055cccc5c002c555c00cc555c002ccc5c00c600605522222000c
-- 005:0005505502ccc0cc2cccc0cc2cccc2cc2cccc2cc2cccc0cc02ccc0cc00055055
-- 006:00000550cccccccccccccccccccccccccccccccccccccccccccccccc00000550
-- 007:005500550b111011b11bb1bbb1bb11bbb1bb11bbb11bb1bb0b11101100550055
-- 008:2200002222000022555c55cc222cc55c222cc55c555c55cc2200002222000022
-- 016:b00bb00bb05bb50bb0b11b0b0b1111b0001a11000bba1bb0b00bb00bb000000b
-- 017:b00bb00bb05bb50bb0b11b0b0b1111b0001a11000bba1bb0b00bb00b0b0000b0
-- 018:000bb000b05bb50bb0b11b0b0b1111b0001a11000bba1bb0b00bb00b00000000
-- 032:4004400440244204404114040411114000131100044314404004400440000004
-- 033:4004400440244204404114040411114000131100044314404004400404000040
-- 034:0004400040244204404114040411114000131100044314404004400400000000
-- 048:0044440000044000004444004004400404000040004004000004400000400400
-- 049:0000400004011040001111004111111001111114001111000401104000040000
-- 050:0000400004000040004114004011110000111104004114000400004000040000
-- 051:0000400004000040004004004001100000011004004004000400004000040000
-- 064:0000000000400400044114400021120000311300044114400040040000000000
-- 065:0040040004111140412112140121121001311310411111140411114000400400
-- 066:0411114041111114133113311231132111111111111111114111111404111140
-- 080:000cc0000c0000c000066000c066660cc066d60c000660000c0000c0000cc000
-- 081:0c0000c0c000000c00066600006666600066dd6000066600c000000c0c0000c0
-- 082:006222600022222006222220662222266622222606222d200022dd2000622260
-- 083:066222660022222006222220662222266622222606222d200022dd2006622266
-- 084:c66222660022222c06222220662222266622222606222d200022dd2cc6622266
-- 096:000000000000bbb0035bbb3005bb333555bb3335035bbb300000bbb000000000
-- 097:66600666622662266666666600266200606226066b6666b666b33b66666bb666
-- 098:66600666622662266666666600222200606226066b6666b666b33b66666bb666
-- 112:000000000000000000000000300000333300333e0333e333ccc000000000ccc0
-- 113:0000000000030030303333333333e3333e33333e33333e33003000000330cc03
-- 114:0000033f00cc3e0c33cc3c0c33330c00e33e0000333330c030003333e00ccc00
-- 115:0000000000cc000033cc00003333300fe33e3e3333333ccc30003333e00ccc00
-- 116:00000000000333300033cc3c00333333033333333333333033333330cc0000cc
-- 117:000033300003cc330003330c03333330333333003333330033333330cc000cc0
-- 128:0000000003500000555500000255500025555600550055560000055500000000
-- 129:0000000000000000000000000000000000655005555556555500055000000000
-- 130:0000000000000000035000005555500022555555550055560000000000000000
-- 131:0000000000000000000000000055500055655550550006550000000000000000
-- 132:0000000000000000000000000350000055555600005555565500055500000000
-- 133:0000000000000000000000000000000000655005555556555500055000000000
-- 134:000000000333333333333dd33333333333dd3333333333d30333333300000000
-- 135:00000000333333333dd333d333333333333ddd333d3333333333333300000000
-- 136:0000000033333dd033d3d33d3333d33d3333d3cd3dd3d33d33333dd000000000
-- </SPRITES>

-- <MAP>
-- 000:404040404040303030303030303030303030303030303030404040404040303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 001:404040404040303030303030303030303030303030303030404040404040303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 002:404040404040202120202021202020212020202120202120404040404040303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 003:404040404040223023212230232122302321223023223023404040404040303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 004:404040404040303030303030303030303030303030303030404040404040303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 005:404040404040303030303030303030303030303030303030404040404040303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 006:404040404040303030303030303030303030303030303030404040404040303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 007:404040404040303030303030303030303030303030303030404040404040303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 008:404040404040303030303030303030303030303030303030404040404040303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 009:404040404040101010101010101010101010101010101010404040404040303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 010:404040404040000000000000000000000000000000000000404040404040303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 011:404040404040000000000000000000000000000000000000404040404040303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 012:404040404040000000000000000000000000000000000000404040404040303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 013:404040404040000000000000000000000000000000000000404040404040303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 014:404040404040000000000000000000000000000000000000404040404040303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 015:404040404040101010101010101010101010101010101010404040404040303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 016:404040404040000000000000000000000000000000000000404040404040303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 017:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 018:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 019:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 020:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 021:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 022:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 023:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 024:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 025:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 026:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 027:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 028:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 029:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 030:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 031:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 032:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 033:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 034:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 035:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 036:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 037:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 038:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 039:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 040:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 041:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 042:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 043:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 044:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 045:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 046:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 047:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 048:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 049:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 050:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 051:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 052:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 053:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 054:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 055:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 056:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 057:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 058:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 059:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 060:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 061:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 062:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 063:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 064:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 065:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 066:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 067:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 068:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 069:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 070:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 071:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 072:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 073:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 074:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 075:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 076:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 077:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 078:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 079:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 080:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 081:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 082:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 083:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 084:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 085:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 086:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 087:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 088:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 089:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 090:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 091:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 092:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 093:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 094:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 095:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 096:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 097:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 098:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 099:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 100:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 101:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 102:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 103:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 104:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 105:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 106:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 107:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 108:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 109:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 110:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 111:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 112:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 113:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 114:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 115:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 116:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 117:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 118:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 119:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 120:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 121:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 122:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 123:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 124:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 125:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 126:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 127:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 128:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 129:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 130:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 131:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 132:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 133:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 134:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- 135:303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030
-- </MAP>

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <SFX>
-- 000:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000304000000000
-- </SFX>

-- <TRACKS>
-- 000:100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </TRACKS>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

