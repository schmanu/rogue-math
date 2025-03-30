local InfinityModule = require("modules/module_infinity")   
local CountModule = require("modules/module_count")
local BalanceModule = require("modules/module_balance")

local ModuleLibrary = {}
ModuleLibrary.__index = ModuleLibrary

function ModuleLibrary.new()
    local self = setmetatable({}, ModuleLibrary)
    self.moduleIds = {
        infinity = "infinity",
        count = "count",
        balance = "balance",
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
    end
end

return ModuleLibrary