local Card = require("cards/card")
local DoubleCard = setmetatable({}, {__index = Card})
DoubleCard.__index = DoubleCard

function DoubleCard.new(id, x, y)
    local self = setmetatable(Card.new(id, x, y, "mod_x2", "modifier"), DoubleCard)
    self.type = "operator"  -- New type for special cards
    return self
end

function DoubleCard:play(calculator)
    if not self.disabled then
        -- Get the current display value
        local currentValue = calculator.display
        if currentValue ~= "" then
            -- Convert to number and double it
            local num = tonumber(currentValue)
            if num then
                print("Double card played: " .. num * 2)
                -- Clear the display and add the doubled value
                calculator:clear()
                calculator:addInput(tostring(num * 2))
                return true
            end
        end
    end
    return false
end

return DoubleCard 