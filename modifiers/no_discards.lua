local Modifier = require("modifiers.modifier")

local NoDiscards = setmetatable({}, {__index = Modifier})
NoDiscards.__index = NoDiscards

function NoDiscards.new()
    local self = setmetatable(Modifier.new(), NoDiscards)
    self.name = "No Discards"
    self.description = "Start with 0 discards. Target divided by 4."
    return self
end

function NoDiscards:onDayStart()
    GAME.state.discards = 0
    GAME.state.targetNumber = math.floor(GAME.state.targetNumber / 4)
end

function NoDiscards:evaluate(result)
    -- No evaluation needed
end

return NoDiscards 