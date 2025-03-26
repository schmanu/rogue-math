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
    return self
end

function Card:update(dt)
    -- Update card position if being dragged
    if self.dragging then
        local mx, my = love.mouse.getPosition()
        self.x = mx + self.dragOffsetX
        self.y = my + self.dragOffsetY
    end
end

function Card:startDragging()
    if not self.disabled then
        self.dragging = true
        local mx, my = love.mouse.getPosition()
        self.dragOffsetX = self.x - mx
        self.dragOffsetY = self.y - my
    end
end

function Card:stopDragging()
    self.dragging = false
end

function Card:setHovered(hovered)
    self.hovered = hovered
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
function Card:play(calculator)
    error("Card:play() is abstract and must be implemented by subclasses")
end

function Card:draw()
    -- Draw card sprite
    love.graphics.setColor(0, 0, 0)
    local sprite = Assets.cardSprites[self.sprite]
    if sprite then
        local spriteWidth, spriteHeight = sprite:getDimensions()
        local scale = 4
        -- Update card dimensions to match sprite scaled up by 2
        self.width = spriteWidth * scale
        self.height = spriteHeight * scale
        
        -- Save the current graphics state
        love.graphics.push()
        
        -- Move to card center, rotate, then move back
        love.graphics.translate(self.x + self.width/2, self.y + self.height/2)
        love.graphics.rotate(math.rad(self.rotation or 0))
        love.graphics.translate(-(self.x + self.width/2), -(self.y + self.height/2))
        
        -- Set background shader
        local bgColor = self.hovered and {0.4, 0.4, 0.4} or {0.3, 0.3, 0.3}
        love.graphics.setShader(Shaders.cardShader)
        
        -- Set border shader
        local borderColor
        if self.selected then
            borderColor = {1, 0.8, 0}  -- Gold border for selected cards
        elseif self.disabled then
            borderColor = {0.4, 0.4, 0.4}  -- Gray border for disabled cards
        else
            borderColor = {1, 1, 1}  -- White border for normal cards
        end

        Shaders.cardShader:send("borderColor", borderColor)
        -- Draw sprite scaled up by 2
        love.graphics.draw(sprite, self.x, self.y, 0, scale, scale)
        
        -- Restore the graphics state
        love.graphics.setShader()
        love.graphics.pop()
    else 
    end
end

return Card 