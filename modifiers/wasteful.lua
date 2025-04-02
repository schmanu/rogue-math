local Modifier = require("modifiers.modifier")

local Wasteful = setmetatable({}, {__index = Modifier})
Wasteful.__index = Wasteful

function Wasteful.new()
    local self = setmetatable(Modifier.new(), Wasteful)
    self.name = "Wasteful"
    self.description = "Discard 20% of your deck at the start of the day."
    return self
end

function Wasteful:onDayStart()
    local discards = math.floor(GAME.deck:getCardCount() * 0.2)
    print("Wasteful:Discarding " .. discards .. " cards")
    GAME.deck:discardCards(discards)
end

function Wasteful:evaluate(result)
    -- No evaluation needed
end

return Wasteful 