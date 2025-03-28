local Card = require("cards/card")
local ReverseCard = setmetatable({}, {__index = Card})
ReverseCard.__index = ReverseCard

function ReverseCard.new(id, x, y)
    local self = setmetatable(Card.new(id, x, y, "mod_reverse", "modifier"), ReverseCard)
    self.type = "modifier" 
    self.tooltip = "Reverse Card\n\nReverses the current value on the calculator."
    return self
end

function ReverseCard:play(calculator)
    if not self.disabled then
        -- Get the current display value
        local currentValue = calculator.display
        if currentValue ~= "" then
            -- Reverse the string
            local reversed = string.reverse(currentValue)
            -- Convert to number
            -- Clear the display and add the reversed value
            calculator:clear()
            calculator:addInput(reversed)
            return true
        end
    end
    return false
end

return ReverseCard