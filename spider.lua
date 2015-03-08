local class = require "middleclass"
local Vector = require "vector"
local Spider = class "Spider"

function Spider:initialize(x, y, world)
  self.image = love.graphics.newImage("data/spider.png")
  self.imageWidth = self.image:getWidth()
  self.imageHeight = self.image:getHeight()
  self.position = {x=x, y=y}
  self.direction = {x=-x, y=-y}
  self.time = 0.0
  self.shape = world:addCircle(x, y, 32)
  self.shape.object = self
  self.doUpdate = true
  self.maxHealth = 3.0
  self.health = self.maxHealth
end

function Spider:receiveDamage(damage)
  self.health = self.health - damage
end

function Spider:setDoUpdate (value)
  self.doUpdate = value
end

function Spider:draw()
  local x, y = self.shape:center()
  
  love.graphics.setColor(255, 255, 255, 255)
  self.shape:draw("line")
  love.graphics.draw(self.image, x - self.imageWidth*0.5, y - self.imageHeight*0.5) 
  
  love.graphics.rectangle("line", x - self.imageWidth*0.5, y - self.imageHeight*0.5 - 10, self.imageWidth, 8)
  love.graphics.rectangle("fill", x - self.imageWidth*0.5+1, y - self.imageHeight*0.5 - 9, (self.imageWidth-2)*self.health/self.maxHealth, 6)
end

function Spider:update(dt)  
  if self.doUpdate then
    
    self.time = self.time + dt           
    
    -- correct target direction after possible collision position
    local x,y = self.shape:center()
    self.direction = Vector.normalize({x=-x, y=-y})
    local delta = Vector.scale(self.direction, dt * 0.1)
    self.shape:move(delta.x, delta.y)
  else
  end
  return self.health > 0.0
end

return Spider
