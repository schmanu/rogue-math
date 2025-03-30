local Modifier = require("modifiers.modifier")

local DividableBy = setmetatable({}, {__index = Modifier})
DividableBy.__index = DividableBy

function DividableBy.new()
    local self = setmetatable(Modifier.new(), DividableBy)
    self.value = math.random(2, 10)
    self.name = "Dividable by " .. self.value
    self.description = "Result must be dividable by " .. self.value
    return self
end

function DividableBy:onDayStart()
end

function DividableBy:evaluate(game, result)
    if result % self.value ~= 0 then
        game.grade:decreaseGrade(3)
    end
end

function DividableBy:getDescription()
    return self.description
end

return DividableBy 