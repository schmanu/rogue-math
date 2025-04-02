local Module = require("modules/module")
local TutoringModule = setmetatable({}, {__index = Module})
TutoringModule.__index = TutoringModule

function TutoringModule.new(id, x, y)
    local self = setmetatable(Module.new(id, x, y, "module_tutoring"), TutoringModule)
    
    self.tooltip = "Tutor Module\n\nAt the beginning of each day increase grade by 2"
    return self
end

function TutoringModule:onStartOfTurn()
    print("Tutor module: increasing grade by 2")
    GAME.game.grade:updateGrade(2)
end

return TutoringModule 