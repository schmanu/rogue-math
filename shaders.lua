local Shaders = {
    cardShader = nil
}

function Shaders.load()
    -- Card border shader with glow effect
    Shaders.cardShader = love.graphics.newShader[[
        extern vec3 borderColor;
        extern vec4 modifierColor;
        vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
            vec4 texcolor = Texel(tex, texture_coords);
            // Create a subtle glow effect
            // vec3 glowColor = borderColor * (0.5 + 0.5 * max(0, sin(0.5 + texture_coords.y * 3.0)));
            return vec4(borderColor, 1) * texcolor * modifierColor;
        }
    ]]
    
    return true
end

return Shaders