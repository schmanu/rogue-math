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
    self.drawX = x
    self.drawY = y
    self.hovered = false
    self.selected = false
    self.disabled = false
    self.sprite = sprite
    self.type = type
    self.objectName = "Card"
    self.tooltip = ""
    self.temporary = false

    -- Add animation state
    self.hoverAnimation = {
        rotation = 0,
        scale = 1,
        targetRotation = 0,
        targetScale = 1,
        animating = false,
        duration = 0.3,
        elapsed = 0
    }

    self.followAnimation = {
        maxVelocity = 2000,
        acceleration = 80,
        velocity = 0,
    }
    return self
end

function Card:setTemporary(temporary)
    self.temporary = temporary
end

function Card:isTemporary()
    return self.temporary
end


function Card:update(dt)
    local mx, my = love.mouse.getPosition()

    if self.dragging then
        self.x = mx + self.dragOffsetX
        self.y = my + self.dragOffsetY

        -- Rotate based on distance from target position
        local dx = self.x - self.drawX
        local maxTilt = 20
        local tiltFactor = math.min(1, math.abs(dx) / 200)  -- Normalize over larger distance for smoother tilt
        
        -- Tilt negative if target is to the right, positive if to the left
        local tiltDirection = (dx < 0) and -1 or 1
        if dx ~= 0 then print(dx) end
        self.hoverAnimation.rotation = maxTilt * tiltFactor * tiltDirection
    end



    -- Update card position if being dragged
    local distance = math.sqrt((self.drawX - self.x)^2 + (self.drawY - self.y)^2)
    if distance > 0 then
        if distance < 1 then
            -- If very close, snap to final position
            self.drawX = self.x
            self.drawY = self.y
            self.followAnimation.velocity = 0
        else
            -- Calculate direction vector
            local dx = self.x - self.drawX
            local dy = self.y - self.drawY
            -- Normalize direction
            local dirX = dx / distance
            local dirY = dy / distance
            
            -- Quadratic acceleration based on distance
            local acceleration = (distance * distance) * self.followAnimation.acceleration -- Adjust multiplier as needed
            self.followAnimation.velocity = math.min(
                self.followAnimation.maxVelocity,
                self.followAnimation.velocity + acceleration * dt
            )
            
            -- Move in the calculated direction with smooth velocity falloff
            local velocityFactor = math.min(1, distance / 100) -- Smooth falloff over 100 pixels
            local currentVelocity = self.followAnimation.velocity * velocityFactor
            
            self.drawX = self.drawX + dirX * currentVelocity * dt
            self.drawY = self.drawY + dirY * currentVelocity * dt
        end
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
    if self.hoverAnimation.animating then
        self.hoverAnimation.elapsed = self.hoverAnimation.elapsed + dt
        local progress = self.hoverAnimation.elapsed / self.hoverAnimation.duration
        
        if progress >= 1 then
            self.hoverAnimation.rotation = self.hoverAnimation.targetRotation
            self.hoverAnimation.scale = self.hoverAnimation.targetScale
            self.hoverAnimation.animating = false
        else
            -- Use smooth easing function
            progress = 1 - math.cos(progress * math.pi / 2)  -- Ease out
            self.hoverAnimation.rotation = self.hoverAnimation.rotation + (self.hoverAnimation.targetRotation - self.hoverAnimation.rotation) * progress
            self.hoverAnimation.scale = self.hoverAnimation.scale + (self.hoverAnimation.targetScale - self.hoverAnimation.scale) * progress
        end
    end

    -- set animation rotation to rotation if not dragging or hovering   
    if not self.dragging and not self.hovered then
        self.hoverAnimation.rotation = self.rotation or 0
    end
end

function Card:startDragging()
    if not self.disabled then
        self.dragging = true
        local mx, my = love.mouse.getPosition()
        self.dragOffsetX = self.drawX - mx
        self.dragOffsetY = self.drawY - my
        -- Start animation
        self.hoverAnimation.animating = true
        self.hoverAnimation.elapsed = 0
        self.hoverAnimation.targetRotation = 0
        self.hoverAnimation.targetScale = 1.1

        self.followAnimation.velocity = 0

        GAME.uiState.hoveredElement = nil
    end
end

function Card:stopDragging()
    self.dragging = false
    -- Start animation back to normal
    self.hoverAnimation.animating = true
    self.hoverAnimation.elapsed = 0
    self.hoverAnimation.targetRotation = self.rotation or 0
    self.hoverAnimation.targetScale = 1
end

function Card:setHovered(hovered)
    if self.hovered ~= hovered then
        self.hovered = hovered
        -- Start animation
        self.hoverAnimation.animating = true
        self.hoverAnimation.elapsed = 0
        if hovered or self.dragging then
            self.hoverAnimation.targetRotation = 0
            self.hoverAnimation.targetScale = 1.1
        else
            self.hoverAnimation.targetRotation = self.rotation or 0
            self.hoverAnimation.targetScale = 1
        end
        if hovered then
            if GAME.uiState.hoveredElement and GAME.uiState.hoveredElement ~= self then
                GAME.uiState.hoveredElement:setHovered(false)
            end
            GAME.uiState.hoveredElement = self
        elseif GAME.uiState.hoveredElement == self then
            GAME.uiState.hoveredElement = nil
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

function Card:translateGraphics()
    -- Move to card center, rotate, then move back
    love.graphics.translate(self.drawX + self.width/2, self.drawY + self.height/2)
    love.graphics.rotate(math.rad(self.hoverAnimation.rotation))
    love.graphics.scale(self.hoverAnimation.scale, self.hoverAnimation.scale)
    love.graphics.translate(-(self.drawX + self.width/2), -(self.drawY + self.height/2))
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

        self:translateGraphics()
        
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

        if self.temporary then
            Shaders.cardShader:send("modifierColor", {0.16, 0.67, 1, 0.66})
        else
            Shaders.cardShader:send("modifierColor", {1, 1, 1, 1})
        end

        Shaders.cardShader:send("borderColor", borderColor)
        -- Draw sprite scaled up by 2
        love.graphics.draw(sprite, self.drawX, self.drawY, 0, scale, scale)
        
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
            local tooltipX = self.drawX + (self.width/2) - (tooltipWidth/2)
            local tooltipY = self.drawY + self.height + 10
            
            -- Adjust X position if tooltip would go off screen edges
            if tooltipX + tooltipWidth > screenWidth then
                tooltipX = screenWidth - tooltipWidth
            elseif tooltipX < 0 then
                tooltipX = 0
            end
            
            -- Adjust Y position if tooltip would go off bottom edge
            if tooltipY + tooltipHeight > screenHeight then
                tooltipY = self.drawY - tooltipHeight - 10 -- Show above instead
            end
            
            love.graphics.rectangle("fill", tooltipX, tooltipY, tooltipWidth, tooltipHeight)
            love.graphics.setColor(1, 1, 1)
            love.graphics.print(self.tooltip, tooltipX + padding, tooltipY + padding/2)
            if self.temporary then
                local labelWidth = love.graphics.getFont():getWidth("Temporary")
                love.graphics.setColor(0.16, 0.67, 1)
                love.graphics.print("Temporary", tooltipX + tooltipWidth - (labelWidth + padding), tooltipY + padding/2)
                love.graphics.setColor(1,1,1)
            end

        end
    end
end

return Card 