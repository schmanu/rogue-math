local Module = require("modules/module")
local LessIsMoreModule = setmetatable({}, {__index = Module})
LessIsMoreModule.__index = LessIsMoreModule

function LessIsMoreModule.new(id, x, y)
    local self = setmetatable(Module.new(id, x, y, "module_less_more"), LessIsMoreModule)
    
    self.tooltip = "Less is More Module\n\nWhen substracting a number, draw that many cards. (max 4)"
    return self
end

function LessIsMoreModule:onCardPlayed(card)
    -- if the last cards played were a number and a substraction card, draw that many cards
    if #GAME.stats.round.lastCardsPlayed >= 2 
    and string.sub(GAME.stats.round.lastCardsPlayed[#GAME.stats.round.lastCardsPlayed].id, 1, 4) == "num_" 
    and GAME.stats.round.lastCardsPlayed[#GAME.stats.round.lastCardsPlayed-1].id == "op_sub" then
        GAME:drawNewCards(math.min(4, GAME.stats.round.lastCardsPlayed[#GAME.stats.round.lastCardsPlayed].value))
    end
end

return LessIsMoreModule 