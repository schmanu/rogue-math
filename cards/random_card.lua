local Card = require("cards/card")
local RandomCard = setmetatable({}, {__index = Card})
RandomCard.__index = RandomCard

function RandomCard.new(id, x, y)
    local self = setmetatable(Card.new(id, x, y, "num_rand", "number"), RandomCard)
    self.type = "number"
    self.tooltip = "Random Card\n\nTypes a random number between 1 and 16 into the calculator when played"
    self.valueModifier = 0
    return self
end

function RandomCard:setModifier(modifier)
    self.valueModifier = modifier
end

function RandomCard:play(calculator)
    if not self.disabled then
        local randomValue = math.random(0, 17)
        calculator:addInput(randomValue + self.valueModifier)
        return true
    end
    return false
end

function RandomCard:draw()
    Card.draw(self)

    love.graphics.push()
    self:translateGraphics()

    love.graphics.setColor(0, 1, 0)
    if self.valueModifier > 0 then
        love.graphics.printf("+" .. self.valueModifier, self.drawX + 48, self.drawY + 32, self.width - 48, "left")
    end

    love.graphics.pop()
end
return RandomCard 