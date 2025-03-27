local Card = require("cards/card")
local Draw3Card = setmetatable({}, {__index = Card})
Draw3Card.__index = Draw3Card

function Draw3Card.new(id, x, y)
    local self = setmetatable(Card.new(id, x, y, "sp_draw3", "special"), Draw3Card)
    self.type = "special"  -- New type for special cards
    return self
end

function Draw3Card:play(calculator, game)
    if not self.disabled then
        game:drawNewCards(3)
        return true
    end
    return false
end

return Draw3Card 