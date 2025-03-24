local Card = require("cards/card")
local RandomCard = setmetatable({}, {__index = Card})
RandomCard.__index = RandomCard

function RandomCard.new(x, y)
    local self = setmetatable(Card.new("rand", x, y, "num_rand"), RandomCard)
    self.type = "number"  -- New type for special cards
    return self
end

function RandomCard:play(calculator)
    if not self.disabled then
        local randomValue = math.random(1, 16)
        print("Random value to use: " .. randomValue)
        calculator:addInput(tostring(randomValue))
        return true
    end
    return false
end

return RandomCard 