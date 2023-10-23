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