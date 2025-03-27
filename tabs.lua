local Assets = require("assets")

local Tabs = {}
Tabs.__index = Tabs

function Tabs.new(x, y)
    local self = setmetatable({}, Tabs)
    self.x = x
    self.y = y
    self.width = 32
    self.height = 96

    self.width_expanded = 256
    self.height_expanded = 512

    self.x_expanded = x - (self.width_expanded - self.width)
    self.y_expanded = y - 352
    self.is_expanded = false

    return self
end

function Tabs:toggle()
    self.is_expanded = not self.is_expanded
end
function Tabs:draw()
    if self.is_expanded then
        love.graphics.draw(Assets.tabs.expanded, self.x_expanded, self.y_expanded, 0)
    else
        love.graphics.draw(Assets.tabs.collapsed, self.x, self.y, 0)
    end
end

function Tabs:containsPoint(x, y)
    if self.is_expanded then
        return x >= self.x_expanded and x < self.x_expanded + self.width_expanded and
               y >= self.y_expanded and y < self.y_expanded + self.height_expanded
    else
        return x >= self.x and x < self.x + self.width and
               y >= self.y and y < self.y + self.height
    end
end

return Tabs 