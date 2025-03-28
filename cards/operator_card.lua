local Card = require("cards/card")
local OperatorCard = setmetatable({}, {__index = Card})
OperatorCard.__index = OperatorCard

function OperatorCard.new(id, value, x, y)
    local spriteName = value
    if value == "+" then
        spriteName = "plus"
    elseif value == "x" then
        spriteName = "multiply"
    elseif value == "/" then
        spriteName = "divide"
    elseif value == "^" then
        spriteName = "exp"
    elseif value == "-" then
        spriteName = "sub"
    end
    local self = setmetatable(Card.new(id, x, y, "op_" .. spriteName, "operator"), OperatorCard)
    self.value = value
    self.tooltip = "Operator Card\n\nApplies the " .. value .. " operator. \nA number card must be played afterwards."
    return self
end

function OperatorCard:play(calculator)
    if not self.disabled then
        local operation = function(firstValue, secondValue)
            if self.value == "+" then
                return firstValue + secondValue
            elseif self.value == "-" then
                return firstValue - secondValue
            elseif self.value == "x" then
                return firstValue * secondValue
            elseif self.value == "/" then
                return firstValue / secondValue
            elseif self.value == "^" then
                return firstValue ^ secondValue
            end
            return firstValue
        end
        calculator:setOperatorMode(operation, self.value)
        return true
    end
    return false
end

return OperatorCard 