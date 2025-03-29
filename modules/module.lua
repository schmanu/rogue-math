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
    self.objectName = "Module"
    self.hovered = false
    self.tooltip = ""
    return self
end

function Module:update(dt)
    local mx, my = love.mouse.getPosition()

    -- Update card position if being dragged
    if self.dragging then
        self.x = mx + self.dragOffsetX
        self.y = my + self.dragOffsetY
    end

    if not GAME.draggedElement then
        if self:containsPoint(mx, my) then
            self:setHovered(true)
        else
            self:setHovered(false)
        end
    else
        self:setHovered(false)
    end
end

function Module:updatePosition(x, y)
    self.x = x
    self.y = y
end

function Module:startDragging()
    self.dragging = true
    local mx, my = love.mouse.getPosition()
    self.dragOffsetX = self.x - mx
    self.dragOffsetY = self.y - my
end 

function Module:stopDragging()
    self.dragging = false
end

function Module:setHovered(hovered)
    self.hovered = hovered
    if hovered then
        if GAME.uiState.hoveredElement and GAME.uiState.hoveredElement ~= self then
            GAME.uiState.hoveredElement:setHovered(false)
        end
        GAME.uiState.hoveredElement = self
    end
end

function Module:containsPoint(x, y)
    return x >= self.x and x < self.x + self.width and
           y >= self.y and y < self.y + self.height
end

function Module:onCardPlayed(card)
    -- can be overridden by subclasses
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
        -- Draw tooltip
        if self.hovered then
            love.graphics.setColor(0, 0, 0, 0.8)
            local padding = 16
            local tooltipWidth = love.graphics.getFont():getWidth(self.tooltip) + padding * 2
            local tooltipHeight = love.graphics.getFont():getHeight() * 3 + padding
            
            -- Get screen dimensions
            local screenWidth = love.graphics.getWidth()
            local screenHeight = love.graphics.getHeight()
            
            -- Calculate tooltip position centered under module
            local tooltipX = self.x + (self.width/2) - (tooltipWidth/2)
            local tooltipY = self.y + self.height + 10
            
            -- Adjust X position if tooltip would go off screen edges
            if tooltipX + tooltipWidth > screenWidth then
                tooltipX = screenWidth - tooltipWidth
            elseif tooltipX < 0 then
                tooltipX = 0
            end
            
            -- Adjust Y position if tooltip would go off bottom edge
            if tooltipY + tooltipHeight > screenHeight then
                tooltipY = self.y - tooltipHeight - 10 -- Show above instead
            end
            
            love.graphics.rectangle("fill", tooltipX, tooltipY, tooltipWidth, tooltipHeight)
            love.graphics.setColor(1, 1, 1)
            love.graphics.print(self.tooltip, tooltipX + padding, tooltipY + padding/2)
        end
    else 
    end
end

return Module 