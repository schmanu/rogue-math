local Assets = require("assets")
local Shaders = require("shaders")

local Module = {}
Module.__index = Module

function Module.new(id, x, y, sprite)
    local self = setmetatable({}, Module)
    self.id = id
    self.x = x
    self.y = y
    self.width = 60
    self.height = 90
    self.dragging = false
    self.dragOffsetX = 0
    self.dragOffsetY = 0
    self.sprite = sprite
    return self
end

function Module:update(dt)
    -- Update card position if being dragged
    if self.dragging then
        local mx, my = love.mouse.getPosition()
        self.x = mx + self.dragOffsetX
        self.y = my + self.dragOffsetY
    end
end

function Module:startDragging()
    if not self.disabled then
        self.dragging = true
        local mx, my = love.mouse.getPosition()
        self.dragOffsetX = self.x - mx
        self.dragOffsetY = self.y - my
    end
end

function Module:stopDragging()
    self.dragging = false
end

function Module:setHovered(hovered)
    self.hovered = hovered
end

function Module:containsPoint(x, y)
    return x >= self.x and x < self.x + self.width and
           y >= self.y and y < self.y + self.height
end


function Module:draw()
    -- Draw card sprite
    love.graphics.setColor(1, 1, 1)
    local sprite = Assets.moduleSprites[self.sprite]
    if sprite then
        local spriteWidth, spriteHeight = sprite:getDimensions()
        local scale = 1
        -- Update card dimensions to match sprite scaled up by 2
        self.width = spriteWidth * scale
        self.height = spriteHeight * scale
        
        -- Draw sprite
        love.graphics.draw(sprite, self.x, self.y, 0, scale, scale)
        
    else 
    end
end

return Module 