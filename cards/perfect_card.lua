local Card = require("cards/card")
local PerfectCard = setmetatable({}, {__index = Card})
PerfectCard.__index = PerfectCard

function PerfectCard.new(id, x, y)
    local self = setmetatable(Card.new(id, x, y, "mod_perfect", "modifier"), PerfectCard)
    self.type = "modifier"  -- New type for special cards
    self.tooltip = "Perfect Card\n\nSets value to target score, then destroys this card."
    return self
end

function PerfectCard:play(calculator)
    if not self.disabled then
        -- Clear the display and add the doubled value
        calculator:clear()
        calculator:addInput(GAME.state.targetNumber)

        -- Making the card temporary will effectively destroy it
        self.temporary = true
        return true
    end
    return false
end

return PerfectCard 