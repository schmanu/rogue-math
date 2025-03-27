local InfinityModule = require("modules/module_infinity")

local ModuleLibrary = {}
ModuleLibrary.__index = ModuleLibrary

function ModuleLibrary.new()
    local self = setmetatable({}, ModuleLibrary)
    self.moduleIds = {
        mod_infinity = "infinity",
    }

    return self
end

function ModuleLibrary:createModule(moduleId, x, y) 
    if moduleId == self.moduleIds.mod_infinity then
        return InfinityModule.new(moduleId, x, y)
    end
end

return ModuleLibrary