local Card = require("cards/card")
local DoubleCard = setmetatable({}, {__index = Card})
DoubleCard.__index = DoubleCard

function DoubleCard.new(id, x, y)
    local self = setmetatable(Card.new(id, x, y, "mod_x2", "modifier"), DoubleCard)
    self.type = "modifier"  -- New type for special cards
    self.tooltip = "Double Card\n\nDoubles the current value of the calculator"
    return self
end

function DoubleCard:play(calculator)
    if not self.disabled then
        -- Get the current display value
        local currentValue = calculator.currentValue
        -- Clear the display and add the doubled value
        calculator:clear()
        calculator:addInput(currentValue * 2)
        return true
    end
    return false
end

return DoubleCard 