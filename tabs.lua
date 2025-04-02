local Assets = require("assets")
local ModuleLibrary = require("modules/module_library")

local Tabs = {}
Tabs.__index = Tabs

function Tabs.new(x, y)
    local self = setmetatable({}, Tabs)
    self.x = x
    self.y = y
    self.width = 256
    self.height = 512

    self.translate_x_collapsed = 224
    self.is_expanded = false

    self.moduleLibrary = ModuleLibrary.new()

    -- Animation properties
    self.animation = {
        progress = 0,  -- 0 to 1
        speed = 10,     -- Animation speed
        isAnimating = false
    }

    self.modules = { self.moduleLibrary:createModule(self.moduleLibrary.moduleIds.chaos, 0, 0) }
    return self
end

function Tabs:update(dt)
    if self.animation.isAnimating then
        local target = self.is_expanded and 1 or 0
        local diff = target - self.animation.progress
        
        -- Move towards target
        self.animation.progress = self.animation.progress + diff * dt * self.animation.speed
        
        -- Check if we're close enough to target to stop
        if math.abs(diff) < 0.01 then
            self.animation.progress = target
            self.animation.isAnimating = false
        end
    end

    for i, module in ipairs(self.modules) do
        local moduleX = self.x + 96 - self.translate_x_collapsed * self.animation.progress
        module:updatePosition(moduleX, self.y + 32 + (i - 1) * 96)
        module:update(dt)
    end
end

function Tabs:addModule(module)
    table.insert(self.modules, module)
end

function Tabs:removeModule(module)
    for i, m in ipairs(self.modules) do
        if m == module then
            table.remove(self.modules, i)
        end
    end
end

function Tabs:toggle()
    self.is_expanded = not self.is_expanded
    self.animation.isAnimating = true
end

function Tabs:draw()
    -- Calculate interpolated values
    local currentX = self.x - self.translate_x_collapsed * self.animation.progress
    
    -- Draw the tab with interpolated width
    love.graphics.draw(Assets.tabs.expanded, currentX, self.y, 0)
    

    for _, module in ipairs(self.modules) do
        module:draw()
    end
end

function Tabs:containsPoint(x, y)
    if self.is_expanded then
        return x >= self.x - self.translate_x_collapsed  and x < self.x- self.translate_x_collapsed  + self.width and
               y >= self.y and y < self.y + self.height
    else
        return x >= self.x and x < self.x + self.width and
               y >= self.y and y < self.y + self.height
    end
end

return Tabs 