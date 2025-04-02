local InfinityModule = require("modules/module_infinity")   
local CountModule = require("modules/module_count")
local BalanceModule = require("modules/module_balance")
local LessIsMoreModule = require("modules/module_less_more")
local TutoringModule = require("modules/module_tutoring")
local ChaosModule = require("modules/module_chaos")

local ModuleLibrary = {}
ModuleLibrary.__index = ModuleLibrary

function ModuleLibrary.new()
    local self = setmetatable({}, ModuleLibrary)
    self.moduleIds = {
        infinity = "infinity",
        count = "count",
        balance = "balance",
        less_more = "less_more",
        tutoring = "tutoring",
        chaos = "chaos",
    }

    return self
end

function ModuleLibrary:createModule(moduleId, x, y) 
    if moduleId == self.moduleIds.infinity then
        return InfinityModule.new(moduleId, x, y)
    elseif moduleId == self.moduleIds.count then
        return CountModule.new(moduleId, x, y)
    elseif moduleId == self.moduleIds.balance then
        return BalanceModule.new(moduleId, x, y)
    elseif moduleId == self.moduleIds.less_more then
        return LessIsMoreModule.new(moduleId, x, y)
    elseif moduleId == self.moduleIds.tutoring then
        return TutoringModule.new(moduleId, x, y)
    elseif moduleId == self.moduleIds.chaos then
        return ChaosModule.new(moduleId, x, y)
    end
end

return ModuleLibrary