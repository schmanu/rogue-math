local Card = require("cards/card")
local PlusOneCard = setmetatable({}, {__index = Card})
PlusOneCard.__index = PlusOneCard

function PlusOneCard.new(id, x, y)
    local self = setmetatable(Card.new(id, x, y, "op_plus1", "operator"), PlusOneCard)
    self.tooltip = "Plus one Card\n\nApplies the + operator. \nAdds a temporary 1 to your hand."
    return self
end

function PlusOneCard:play(calculator)
    if not self.disabled then
        local operation = function(firstValue, secondValue)
            return firstValue + secondValue
        end
        calculator:setOperatorMode(operation, "+")

        -- Add a temporary 1 to the hand
        local card = GAME:createCard("num_1", self.x, self.y)
        card:setTemporary(true)
        table.insert(GAME.hand, card)
        return true
    end
    return false
end

return PlusOneCard 