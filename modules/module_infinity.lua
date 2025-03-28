local Module = require("modules/module")
local InfinityModule = setmetatable({}, {__index = Module})
InfinityModule.__index = InfinityModule

function InfinityModule.new(id, x, y)
    local self = setmetatable(Module.new(id, x, y, "module_infinity"), InfinityModule)
    
    self.tooltip = "Infinity Module\n\nDraw 4 cards if your hand is empty"
    return self
end

function InfinityModule:onCardPlayed()
    -- if the hand is empty, draw 4 cards
    if #GAME.hand == 0 then
        GAME:drawNewCards(4)
    end
end

return InfinityModule 