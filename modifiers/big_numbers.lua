local Modifier = require("modifiers.modifier")

local BigNumbers = setmetatable({}, {__index = Modifier})
BigNumbers.__index = BigNumbers

function BigNumbers.new()
    local self = setmetatable(Modifier.new(), BigNumbers)
    self.name = "Big Numbers"
    self.description = "Target doubled."
    return self
end

function BigNumbers:onDayStart()
    GAME.state.targetNumber = GAME.state.targetNumber * 2

end

function BigNumbers:evaluate(game, result)
    -- No evaluation needed
end

return BigNumbers 