local Card = require("cards/card")
local RandomCard = setmetatable({}, {__index = Card})
RandomCard.__index = RandomCard

function RandomCard.new(id, x, y)
    local self = setmetatable(Card.new(id, x, y, "num_rand", "number"), RandomCard)
    self.type = "number"
    self.tooltip = "Random Card\n\nTypes a random number between 1 and 16 into the calculator when played"
    return self
end

function RandomCard:play(calculator)
    if not self.disabled then
        local randomValue = math.random(0, 17)
        calculator:addInput(tostring(randomValue))
        return true
    end
    return false
end

return RandomCard 