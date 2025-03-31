local Module = require("modules/module")
local BalanceModule = setmetatable({}, {__index = Module})
BalanceModule.__index = BalanceModule

function BalanceModule.new(id, x, y)
    local self = setmetatable(Module.new(id, x, y, "module_balance"), BalanceModule)
    
    self.tooltip = "Balance Module\n\nAt the beginning of each day\nCreate random operator or number card."
    return self
end

function BalanceModule:onStartOfTurn()
    -- create a random temporary number or operator based on which you have less in your hand
    local numCards = 0
    local opCards = 0
    for i, card in ipairs(GAME.deck.hand) do
        if card.id:sub(1,4) == "num_" then
            numCards = numCards + 1
        elseif card.id:sub(1,3) == "op_" then
            opCards = opCards + 1
        end
    end

    print("Balance module: numCards = " .. numCards .. ", opCards = " .. opCards)

    if numCards < opCards then
        -- Get all number cards from CardLibrary
        local numCards = {}
        for id, _ in pairs(GAME.cardLibrary.cardIds) do
            if id:sub(1,4) == "num_" and id ~= "num_load" then
                table.insert(numCards, id)
            end
        end
        local randomNum = numCards[math.random(#numCards)]
        local card = GAME:createCard(randomNum, self.x, self.y)
        card:setTemporary(true)
        table.insert(GAME.deck.hand, card)
    else
        -- Get all operator cards from CardLibrary
        local opCards = {}
        for id, _ in pairs(GAME.cardLibrary.cardIds) do
            if id:sub(1,3) == "op_" then
                table.insert(opCards, id)
            end
        end
        local randomOp = opCards[math.random(#opCards)]
        local card = GAME:createCard(randomOp, self.x, self.y)
        card:setTemporary(true)
        table.insert(GAME.deck.hand, card)
    end
    
end

return BalanceModule 