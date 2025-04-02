local Shaders = {
    cardShader = nil
}

function Shaders.load()
    -- Card border shader with glow effect
    Shaders.cardShader = love.graphics.newShader[[
        extern vec3 borderColor;
        extern vec4 modifierColor;

        extern vec2 mousePos;
        extern float time;

        extern bool dragging;

        #define PI 3.14159265358979323846
        #define RADIUS 300
        #define SPEED 2

        vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
            vec4 texcolor = Texel(tex, texture_coords);

            if (dragging) {
                float height = texture_coords.y;
                float intensity = 0.5 + 0.5 * max(0, cos(time / 2)*sin(time * SPEED + texture_coords.y * texture_coords.x * 3.5));
                vec3 glowColor = borderColor * intensity * 2;
                return vec4(borderColor, 1) * texcolor * modifierColor * vec4(glowColor, 1);
            }

            if (mousePos.x == 0 && mousePos.y == 0) {
                vec3 glowColor = borderColor * (0.5 + 0.5 * max(0, sin(0.5 + texture_coords.y * 3.0))) * 2;
                return vec4(borderColor, 1) * texcolor * modifierColor * vec4(glowColor, 1);
            } else {
                // compute distance from screen_coords to mousePos
                float distance = distance(screen_coords, mousePos);
                // Normalize distance between 0 and 1
                float normalizedDistance = distance / RADIUS;
                vec3 glowColor = borderColor * (max(0, sin(normalizedDistance * (PI / 2) + PI / 2))) * 2;
                return vec4(borderColor, 1) * texcolor * modifierColor * vec4(glowColor, 1);
            }
        }
    ]]
    
    return true
end

return Shaders