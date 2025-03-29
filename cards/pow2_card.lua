local Card = require("cards/card")
local PowerOf2Card = setmetatable({}, {__index = Card})
PowerOf2Card.__index = PowerOf2Card

function PowerOf2Card.new(id, x, y)
    local self = setmetatable(Card.new(id, x, y, "num_pow2", "number"), PowerOf2Card)
    self.type = "number"
    self.tooltip = "Number Square Card\n\nDoubles its value for every card played this turn."
    self.valueModifier = 2
    return self
end

function PowerOf2Card:setModifier(modifier)
    self.valueModifier = modifier
end

function PowerOf2Card:play(calculator)
    Card.play(self)
    if not self.disabled then
        local currentValue = self.valueModifier ^ (GAME.stats.round.cardsPlayed + 1)
        calculator:addInput(tostring(currentValue))
        return true
    end
    return false
end



function PowerOf2Card:draw()
    Card.draw(self)

    local currentValue = self.valueModifier ^ (GAME.stats.round.cardsPlayed + 1)


    love.graphics.push()
    love.graphics.translate(self.x + self.width/2, self.y + self.height/2)
    love.graphics.rotate(math.rad(self.rotation or 0))
    love.graphics.translate(-(self.x + self.width/2), -(self.y + self.height/2))

    love.graphics.setColor(0, 1, 0)
    if (self.valueModifier > 0) then
        love.graphics.printf("=" ..currentValue, self.x + 56, self.y + 32, self.width - 56, "left")
    end

    love.graphics.pop()
end


return PowerOf2Card 