
local Vector = require "vector"
local HadronCollider = require "hadroncollider"
assert(HadronCollider, "Unable to load hadron collider")
local Gamestate = require "gamestate"

local inGameState = {}

-- Require entity types
local Crystal = require "crystal"
local Bullet = require "bullet"
local Player = require "player"
local Spider = require "spider"
local Spawner = require "spawner"
local TiledLoader = require "tiledloader"
local Camera = require "camera"
local MouseKeyboardInput = require "mousekeyboardinput"
local ControllerInput = require "controllerinput"
local Score = require "score"

local function segmentTrace(world, x, y, dx, dy)
  local ax, ay=x ,y
  local bx, by=ax+dx, ay+dy
  
  if ax > bx then
    ax, bx = bx, ax
  end
  
  if ay > by then
    ay, by = by, ay
  end
  
  local result=nil
  local bestLambda=1.0
  for shape in pairs(world.collider:shapesInRange(ax,ay,bx,by)) do
    local intersecting, lambda = shape:intersectsRay(x, y, dx, dy)
    if intersecting and lambda < bestLambda then
      result = shape
      bestLambda = lambda
    end
  end

  return result
end

local function incrementKillScore (world, score)
  if world and world.killScore and score then
    world.killScore = world.killScore + score
  end    
end

function inGameState:contactCallback(dt, shape_one, shape_two, dx, dy)
end

function inGameState:init()
  -- Create and empty list for all game objects
  self.objectList = {}
  
  self.world = {}
  self.world.map = TiledLoader:new(require "map")
  self.world.collider = HadronCollider(100, function(...) self:contactCallback(...) end)
  self.world.segmentTrace = segmentTrace
  self.world.killScore = 0
  self.world.incrementKillScore = incrementKillScore
  
  self.score = Score:new(self.world)
    
  -- Add the eponymous crystal
  self.world.crystal = Crystal:new(self.world)
  table.insert(self.objectList, self.world.crystal)
  self.world.crystal.onDestroy = function(score)
    Gamestate.switch(require "gameoverstate", score)
  end
  
  -- Add the camera
  self.world.camera = Camera:new()
  
  -- Add players
  local mouseKeyboardInput=MouseKeyboardInput:new({'w', 'a', 's', 'd', 'up', 'left', 'down', 'right'}, true)
  local gamepadInput=nil
  
  if love.joystick.getJoystickCount() > 0 then
    gamepadInput=ControllerInput:new(love.joystick.getJoysticks()[1])
  end
  
  table.insert(self.objectList, Player:new(self.world, -100, 50, mouseKeyboardInput))
  table.insert(self.objectList, Player:new(self.world, 100, 50, gamepadInput))
  -- And the monster spawner
  table.insert(self.objectList, Spawner:new({Spider}, self.objectList, self.world))
end

function inGameState:draw()
  self.world.camera:setupDrawing()
      
  -- Draw background
  love.graphics.push()
  love.graphics.scale(2,2)
  love.graphics.setColor(255,255,255,255)
  self.world.map:draw()
  love.graphics.pop()
  
  for i=1,#self.objectList do
    if self.objectList[i].draw then
      self.objectList[i]:draw()
    end
  end
  
  self.score:draw()
  
end

function inGameState:update(dt) 
  
  -- Update game physics
  self.world.collider:update(dt)
  
  -- Temporary object list for new objects
  local newObjectList={}
  
  -- Update and move alive entities to the front
  local dst=1
  local N = #self.objectList
  for i=1,N do
    local currentObject=self.objectList[i]
    
    if (not currentObject.update) or currentObject:update(dt, newObjectList) then
      self.objectList[dst] = currentObject
      dst = dst + 1
    end
  end
  
  self.score:update(dt)
  
  for i=dst,N do
    table.remove(self.objectList)
  end
  
  for i=1, #newObjectList do
    table.insert(self.objectList, newObjectList[i])
  end
end

return inGameState