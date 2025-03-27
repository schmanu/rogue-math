local Module = require("modules/module")
local InfinityModule = setmetatable({}, {__index = Module})
InfinityModule.__index = InfinityModule

function InfinityModule.new(id, x, y)
    local self = setmetatable(Module.new(id, x, y, "module_infinity"), InfinityModule)
    return self
end

return InfinityModule 