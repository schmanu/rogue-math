local Card = {}
Card.__index = Card

function Card.new(value, x, y, sprite)
    local self = setmetatable({}, Card)
    self.value = value
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
    
    -- Determine card type
    if value == "rand" or tonumber(value) then
        self.type = "number"
    else
        self.type = "operator"
    end
    
    return self
end

function Card:draw()
    -- Draw card shadow
    love.graphics.setColor(0, 0, 0, 0.2)
    love.graphics.rectangle("fill", self.x + 2, self.y + 2, self.width, self.height)
    
    -- Draw card background
    if self.disabled then
        love.graphics.setColor(0.5, 0.5, 0.5, 1.0)
    elseif self.type == "number" then
        love.graphics.setColor(0.7, 0.8, 1.0, 1.0)  -- Light blue for numbers
    elseif self.type == "operator" then
        love.graphics.setColor(1.0, 0.8, 0.8, 1.0)  -- Light red for operators
    else
        love.graphics.setColor(0.8, 0.7, 1.0, 1.0)  -- Light purple for special cards
    end
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    
    -- Draw card border
    if self.selected then
        love.graphics.setColor(1.0, 0.8, 0.2, 1.0)  -- Golden border for selected cards
    else
        love.graphics.setColor(0.2, 0.2, 0.2, 1.0)
    end
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    
    -- Draw card value
    love.graphics.setColor(0.2, 0.2, 0.2, 1.0)
    love.graphics.printf(self.value, self.x, self.y + 15, self.width, "center")
    
    -- Draw card type
    local typeLabel = self.type == "number" and "NUM" or "OP"
    love.graphics.printf(typeLabel, self.x, self.y + 40, self.width, "center")
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

return Card 