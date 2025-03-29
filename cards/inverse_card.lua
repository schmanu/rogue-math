local Card = require("cards/card")
local InverseCard = setmetatable({}, {__index = Card})
InverseCard.__index = InverseCard

function InverseCard.new(id, x, y)
    local self = setmetatable(Card.new(id, x, y, "mod_inverse", "modifier"), InverseCard)
    self.type = "modifier"
    self.tooltip = "Inverse Card\n\nTurns the current number into its reciprocal (1/x)"
    return self
end

function InverseCard:play(calculator)
    if not self.disabled then
        -- Get the current display value
        local currentValue = calculator.display
        if currentValue ~= "" then
            -- Convert to number and double it
            local num = tonumber(currentValue)
            if num then
                -- Clear the display and add the doubled value
                calculator:clear()
                calculator:addInput(tostring(1 / num))
                return true
            end
        end
    end
    return false
end

return InverseCard 