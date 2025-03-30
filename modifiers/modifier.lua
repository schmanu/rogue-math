local Modifier = {}
Modifier.__index = Modifier

function Modifier.new()
    local self = setmetatable({}, Modifier)
    self.name = "Base Modifier"
    self.description = "Base modifier description"
    return self
end

function Modifier:onDayStart()
    -- Override in subclasses
end

function Modifier:evaluate(game, result)
    -- Override in subclasses
end

function Modifier:getDescription(game)
    return self.description
end

return Modifier 