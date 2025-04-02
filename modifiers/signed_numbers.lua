local Modifier = require("modifiers.modifier")

local SignedNumbers = setmetatable({}, {__index = Modifier})
SignedNumbers.__index = SignedNumbers

function SignedNumbers.new()
    local self = setmetatable(Modifier.new(), SignedNumbers)
    self.name = "Signed Numbers"
    self.description = "All numbers are signed."
    return self
end

function SignedNumbers:onDayStart()
    -- half the target and set the start number to -targetNumber
    GAME.state.targetNumber = math.ceil(GAME.state.targetNumber / 2)
    GAME.calculator.currentValue = -GAME.state.targetNumber
    GAME.calculator.display = tostring(-GAME.state.targetNumber)
    GAME.calculator.expectedInputType = "operator"
end

function SignedNumbers:evaluate(result)
    -- No evaluation needed
end

return SignedNumbers 