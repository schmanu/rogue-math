local Card = require("cards/card")
local NumberCard = setmetatable({}, {__index = Card})
NumberCard.__index = NumberCard

function NumberCard.new(id, value, x, y)
    local self = setmetatable(Card.new(id, x, y, "num_" .. value, "number"), NumberCard)
    self.value = value
    return self
end

function NumberCard:play(calculator)
    if not self.disabled then
        calculator:addInput(self.value)
        return true
    end
    return false
end

return NumberCard 