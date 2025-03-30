local Card = require("cards/card")
local LoadCard = setmetatable({}, {__index = Card})
LoadCard.__index = LoadCard

function LoadCard.new(id, x, y, value)
    local self = setmetatable(Card.new(id, x, y, "num_load", "number"), LoadCard)
    self.type = "number"
    self.value = value
    self.valueModifier = 0
    self.tooltip = "Load Card\n\nTypes " .. self.value .. " into the calculator."
    self:setTemporary(true)
    return self
end

function LoadCard:play(calculator)
    if not self.disabled then
        calculator:addInput(self.value)
        return true
    end
    return false
end

return LoadCard 