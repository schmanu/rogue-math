local Assets = require("assets")
local Shaders = require("shaders")

local Card = {}
Card.__index = Card

function Card.new(id, x, y, sprite, type)
    local self = setmetatable({}, Card)
    self.id = id
    self.x = x
    self.y = y
    self.width = 60
    self.height = 90
    self.dragging = false
    self.dragOffsetX = 0
    self.dragOffsetY = 0
    self.hovered = false
    self.selected = false
    self.disabled = false
    self.sprite = sprite
    self.type = type
    self.objectName = "Card"
    self.tooltip = ""
    -- Add animation state
    self.animationState = {
        rotation = 0,
        scale = 1,
        targetRotation = 0,
        targetScale = 1,
        animating = false,
        duration = 0.3,
        elapsed = 0
    }
    return self
end

function Card:update(dt)
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

    -- Update animation
    if self.animationState.animating then
        self.animationState.elapsed = self.animationState.elapsed + dt
        local progress = self.animationState.elapsed / self.animationState.duration
        
        if progress >= 1 then
            self.animationState.rotation = self.animationState.targetRotation
            self.animationState.scale = self.animationState.targetScale
            self.animationState.animating = false
        else
            -- Use smooth easing function
            progress = 1 - math.cos(progress * math.pi / 2)  -- Ease out
            self.animationState.rotation = self.animationState.rotation + (self.animationState.targetRotation - self.animationState.rotation) * progress
            self.animationState.scale = self.animationState.scale + (self.animationState.targetScale - self.animationState.scale) * progress
        end
    end

    -- set animation rotation to rotation if not dragging or hovering   
    if not self.dragging and not self.hovered then
        self.animationState.rotation = self.rotation or 0
    end
end

function Card:startDragging()
    if not self.disabled then
        self.dragging = true
        local mx, my = love.mouse.getPosition()
        self.dragOffsetX = self.x - mx
        self.dragOffsetY = self.y - my
        -- Start animation
        self.animationState.animating = true
        self.animationState.elapsed = 0
        self.animationState.targetRotation = 0
        self.animationState.targetScale = 1.1
    end
end

function Card:stopDragging()
    self.dragging = false
    -- Start animation back to normal
    self.animationState.animating = true
    self.animationState.elapsed = 0
    self.animationState.targetRotation = self.rotation or 0
    self.animationState.targetScale = 1
end

function Card:setHovered(hovered)
    if self.hovered ~= hovered then
        self.hovered = hovered
        -- Start animation
        self.animationState.animating = true
        self.animationState.elapsed = 0
        if hovered or self.dragging then
            self.animationState.targetRotation = 0
            self.animationState.targetScale = 1.1
        else
            self.animationState.targetRotation = self.rotation or 0
            self.animationState.targetScale = 1
        end
        if hovered then
            if GAME.uiState.hoveredElement and GAME.uiState.hoveredElement ~= self then
                GAME.uiState.hoveredElement:setHovered(false)
            end
            GAME.uiState.hoveredElement = self
        end
    end
end

function Card:setSelected(selected)
    self.selected = selected
end

function Card:isSelected()
    return self.selected
end

function Card:setDisabled(disabled)
    self.disabled = disabled
end

function Card:isDisabled()
    return self.disabled
end

function Card:containsPoint(x, y)
    return x >= self.x and x < self.x + self.width and
           y >= self.y and y < self.y + self.height
end

-- Abstract play function that should be overridden by subclasses
function Card:play(calculator, game)

end

function Card:onRoundStart()

end

function Card:draw()
    -- Draw card sprite
    love.graphics.setColor(1, 1, 1)
    local sprite = Assets.cardSprites[self.sprite]
    if sprite then
        local spriteWidth, spriteHeight = sprite:getDimensions()
        local scale = 1
        -- Update card dimensions to match sprite scaled up by 2
        self.width = spriteWidth * scale
        self.height = spriteHeight * scale
        
        -- Save the current graphics state
        love.graphics.push()
        
        -- Move to card center, rotate, then move back
        love.graphics.translate(self.x + self.width/2, self.y + self.height/2)
        love.graphics.rotate(math.rad(self.animationState.rotation))
        love.graphics.scale(self.animationState.scale, self.animationState.scale)
        love.graphics.translate(-(self.x + self.width/2), -(self.y + self.height/2))
        
        -- Set background shader
        local bgColor = self.hovered and {0.4, 0.4, 0.4} or {0.3, 0.3, 0.3}
        love.graphics.setShader(Shaders.cardShader)
        
        -- Set border shader
        local borderColor
        if self.selected then
            borderColor = {1, 0.8, 0}  -- Gold border for selected cards
        elseif self.disabled then
            borderColor = {0.5, 0.5, 0.5}  -- Gray border for disabled cards
        else
            borderColor = {1, 1, 1}  -- White border for normal cards
        end

        Shaders.cardShader:send("borderColor", borderColor)
        -- Draw sprite scaled up by 2
        love.graphics.draw(sprite, self.x, self.y, 0, scale, scale)
        
        -- Restore the graphics state
        love.graphics.setShader()
        love.graphics.pop()

        -- Draw tooltip
        if self.hovered then
            love.graphics.setColor(0, 0, 0, 0.8)
            local padding = 16
            local tooltipWidth = love.graphics.getFont():getWidth(self.tooltip) + padding * 2
            local tooltipHeight = love.graphics.getFont():getHeight() * 5 + padding
            
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
    end
end

return Card 