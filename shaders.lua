local Shaders = {
    cardShader = nil
}

function Shaders.load()
    -- Card border shader with glow effect
    Shaders.cardShader = love.graphics.newShader[[
        extern vec3 borderColor;
        vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
            vec4 texcolor = Texel(tex, texture_coords);
            // Create a subtle glow effect
            vec3 glowColor = borderColor * (0.5 + 0.5 * max(0, sin(0.5 + texture_coords.y * 3.0)));
            return vec4(glowColor, 1) * texcolor;
        }
    ]]
    
    return true
end

return Shaders