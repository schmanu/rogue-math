local Card = require("cards/card")
local NumberCard = setmetatable({}, {__index = Card})
NumberCard.__index = NumberCard

function NumberCard.new(id, value, x, y)
    local self = setmetatable(Card.new(id, x, y, "num_" .. value, "number"), NumberCard)
    self.value = value
    self.tooltip = "Number Card\n\nTypes " .. value .. " into the calculator when played"
    self.valueModifier = 0
    return self
end

function NumberCard:setModifier(modifier)
    self.valueModifier = modifier
end

function NumberCard:play(calculator)
    if not self.disabled then
        local result = tonumber(self.value) + tonumber(self.valueModifier)
        calculator:addInput(result)
        return true
    end
    return false
end

function NumberCard:draw()
    Card.draw(self)

    love.graphics.push()
    self:translateGraphics()

    love.graphics.setColor(0, 1, 0)
    if (self.valueModifier > 0) then
        love.graphics.printf("+" ..self.valueModifier, self.drawX + 48, self.drawY + 32, self.width - 48, "left")
    end

    love.graphics.pop()
end

return NumberCard 