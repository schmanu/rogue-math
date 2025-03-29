local Module = require("modules/module")
local CountModule = setmetatable({}, {__index = Module})
CountModule.__index = CountModule

function CountModule.new(id, x, y)
    local self = setmetatable(Module.new(id, x, y, "module_count"), CountModule)
    
    self.tooltip = "Count Module\n\nIncreases the value of each card played by 1"
    return self
end

function CountModule:onCardPlayed(card)
    print("Count Module: onCardPlayed " .. card.id)
    print(string.sub(card.id, 1, 4) == "num_")
    if string.sub(card.id, 1, 4) == "num_" then
        card:setModifier(card.valueModifier + 1)
    end
end

return CountModule 