local Card = require("cards/card")
local LoadCard = require("cards/load_card")
local StoreCard = setmetatable({}, {__index = Card})
StoreCard.__index = StoreCard

function StoreCard.new(id, x, y)
    local self = setmetatable(Card.new(id, x, y, "mod_store", "modifier"), StoreCard)
    self.type = "modifier"
    self.tooltip = "Store Card\n\nSets calculator to 0.\nCreates a load card in your hand."
    return self
end

function StoreCard:play(calculator)
    if not self.disabled then
        -- Get the current display value
        local currentValue = calculator.currentValue
        calculator:clear()
        local loadCard = LoadCard.new("num_load", self.x, self.y, currentValue)
        table.insert(GAME.hand, loadCard)
        return true
    end
    return false
end

return StoreCard 