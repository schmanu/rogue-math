local Modifier = require("modifiers.modifier")

local DecreasedHand = setmetatable({}, {__index = Modifier})
DecreasedHand.__index = DecreasedHand

function DecreasedHand.new()
    local self = setmetatable(Modifier.new(), DecreasedHand)
    self.name = "Decreased Hand"
    self.description = "Hand size reduced by 1."
    return self
end

function DecreasedHand:onDayStart()
    -- Note: Hand size reduction should be handled by the hand manager
end

function DecreasedHand:evaluate(game, result)
    -- No evaluation needed
end

return DecreasedHand 