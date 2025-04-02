local Card = require("cards/card")
local HexCard = setmetatable({}, {__index = Card})
HexCard.__index = HexCard

function HexCard.new(id, x, y)
    local self = setmetatable(Card.new(id, x, y, "mod_hex", "modifier"), HexCard)
    self.type = "modifier" 
    self.tooltip = "Hex Card\n\nInterprets your number as hexadecimal to create a larger decimal value."
    return self
end

function HexCard:play(calculator)
    if not self.disabled then
        -- Get the current display value
        local currentValue = calculator.currentValue
        if currentValue ~= "" then
            -- Convert to number
            -- Clear the display and add the reversed value
            calculator:clear()
            calculator:addInput(tonumber(currentValue, 16))
            return true
        end
    end
    return false
end

return HexCard