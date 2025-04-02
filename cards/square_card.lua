local Card = require("cards/card")
local SquareCard = setmetatable({}, {__index = Card})
SquareCard.__index = SquareCard

function SquareCard.new(id, x, y)
    local self = setmetatable(Card.new(id, x, y, "mod_square", "modifier"), SquareCard)
    self.type = "modifier"
    self.tooltip = "Square Card\n\nSquares the current value of the calculator"
    return self
end

function SquareCard:play(calculator)
    if not self.disabled then
        -- Get the current display value
        local currentValue = calculator.currentValue
        
        -- Clear the display and add the squared value
        calculator:clear()
        calculator:addInput(currentValue * currentValue)
        return true
    end
    return false
end

return SquareCard 