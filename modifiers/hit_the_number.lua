local Modifier = require("modifiers.modifier")

local HitTheNumber = setmetatable({}, {__index = Modifier})
HitTheNumber.__index = HitTheNumber

function HitTheNumber.new()
    local self = setmetatable(Modifier.new(), HitTheNumber)
    self.name = "Hit the Number"
    self.description = "Must reach exactly. Overshooting reduces grade."
    return self
end

function HitTheNumber:onDayStart()
    -- No need to set a flag, the instance will be stored in game.modifiers
end

function HitTheNumber:evaluate(game, result)
    if result ~= GAME.state.targetNumber then
        local diff = math.abs(result - GAME.state.targetNumber)
        GAME.grade:decreaseGrade(diff)
    end
end

return HitTheNumber 