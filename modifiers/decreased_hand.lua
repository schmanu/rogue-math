local Modifier = require("modifiers.modifier")

local DecreasedHand = setmetatable({}, {__index = Modifier})
DecreasedHand.__index = DecreasedHand

function DecreasedHand.new()
    local self = setmetatable(Modifier.new(), DecreasedHand)
    self.name = "Smol hands"
    self.description = "Hand size reduced by 1."
    return self
end

function DecreasedHand:onDayStart()
    GAME.state.handSize = GAME.state.handSize - 1
end

function DecreasedHand:evaluate(result)
    -- No evaluation neede
end

return DecreasedHand 