
local Vector = require "vector"

local inGameState = {}

-- Require entity types
local Crystal = require "crystal"
local Bullet = require "bullet"
local Player = require "player"
local Spider = require "spider"

local function beginContact(a, b, contact)
  if a:getUserData().type == "Spider" and b:getUserData().type == "Crystal" then
    spider = a:getUserData()
  elseif a:getUserData().type == "Crystal" and b:getUserData().type == "Spider" then 
    spider = b:getUserData()
  end
  
  if spider then
    spider:setDoUpdate (false)
  end
end

function inGameState:init()
  -- Create and empty list for all game objects
  self.objectList = {}
  
  love.physics.setMeter(32)
  self.world = love.physics.newWorld(0, 0, true)
  self.world:setCallbacks(beginContact)
  
  local width = love.graphics.getWidth()
  local height = love.graphics.getHeight()
  
  table.insert(self.objectList, Crystal:new(self.world))
  table.insert(self.objectList, Player:new(self.world, -100, 50, {'w', 'a', 's', 'd', 'up', 'left', 'down', 'right'}))
  table.insert(self.objectList, Player:new(self.world, 100, 50))
  table.insert(self.objectList, Spider:new(-width / 3, -height / 3, self.world))
end


function inGameState:draw()
  local width = love.graphics.getWidth()
  local height = love.graphics.getHeight()
  love.graphics.translate(width/2, height/2)
  
  love.graphics.setBackgroundColor({128,128,128,255})
  
  for i=1,#self.objectList do
    self.objectList[i]:draw()
  end
end

function inGameState:update(dt) 
  
  -- Update game physics
  self.world:update(dt)
  
  -- Update and move alive entities to the front
  local dst=1
  local N = #self.objectList
  for i=1,N do
    local currentObject=self.objectList[i]
    
    if (not currentObject.update) or currentObject:update(dt, self.objectList) then
      self.objectList[dst] = currentObject
      dst = dst + 1
    end
  end

  for i=dst,N do
    table.remove(self.objectList)
  end
  
end

return inGameState