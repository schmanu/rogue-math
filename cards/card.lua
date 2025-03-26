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

return Card 