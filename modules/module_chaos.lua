local Module = require("modules/module")
local ChaosModule = setmetatable({}, {__index = Module})
ChaosModule.__index = ChaosModule

function ChaosModule.new(id, x, y)
    local self = setmetatable(Module.new(id, x, y, "module_chaos"), ChaosModule)
    
    self.tooltip = "Chaos Module\n\nPlays 4 random cards at the beginning of each day"
    return self
end

function ChaosModule:onStartOfTurn()
    -- create a random temporary number or operator based on which you have less in your hand
    local cardsPlayed = 0
    local cardTypeRequired = "number"
    for i, card in ipairs(GAME.deck.drawPile) do
        local didPlayCard = false
        if cardsPlayed >= 4 then
            break
        end
        print("Chaos module: trying to play card " .. card.id)
        if cardTypeRequired == "number" then
            if card.type == "number" or card.type == "special" then
                table.insert(GAME.deck.autoPlayStack, card)
                print("Chaos module: playing card " .. card.id)
                cardsPlayed = cardsPlayed + 1
                didPlayCard = true
            end
        elseif cardTypeRequired == "operator" then
            if card.type ~= "number" then
                table.insert(GAME.deck.autoPlayStack, card)
                print("Chaos module: playing card " .. card.id)
                cardsPlayed = cardsPlayed + 1
                didPlayCard = true
            end
        end

        if didPlayCard then
            if card.type == "number" then
                cardTypeRequired = "operator"
            elseif card.type == "operator" then
                cardTypeRequired = "number"
            end
        end
        print("Type required now: " .. cardTypeRequired)
    end

    -- set autoPlayStart to current time
    GAME.deck.lastCardPlayedTime = love.timer.getTime() + 1
end

return ChaosModule 