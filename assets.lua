local Assets = {}

-- Card colors and styles
Assets.colors = {
    number = {
        background = {0.7, 0.8, 1.0, 1.0},  -- Light blue
        border = {0.3, 0.4, 0.6, 1.0},      -- Darker blue
        text = {0.2, 0.2, 0.2, 1.0}         -- Dark gray
    },
    operator = {
        background = {1.0, 0.8, 0.8, 1.0},  -- Light red
        border = {0.6, 0.3, 0.3, 1.0},      -- Darker red
        text = {0.2, 0.2, 0.2, 1.0}         -- Dark gray
    },
    disabled = {
        background = {0.5, 0.5, 0.5, 1.0},  -- Gray
        border = {0.3, 0.3, 0.3, 1.0},      -- Darker gray
        text = {0.7, 0.7, 0.7, 1.0}         -- Light gray
    }
}

Assets.cardSprites = {}
Assets.backgroundSprite = nil

-- Card dimensions
Assets.card = {
    width = 60,
    height = 90,
    cornerRadius = 5,
    borderWidth = 2
}

function Assets.load()
    print("Loading assets")
    Assets.backgroundSprite = love.graphics.newImage("sprites/background.png")
    -- Load card sprites
    Assets.cardSprites = {}

    -- Load number sprites
    for i = 0, 9 do
        Assets.cardSprites["num_" .. i] = love.graphics.newImage("sprites/cards/num_" .. i .. ".png")
    end
    -- Load operator sprites
    Assets.cardSprites["op_plus"] = love.graphics.newImage("sprites/cards/op_plus.png")
    Assets.cardSprites["op_multiply"] = love.graphics.newImage("sprites/cards/op_multiply.png")
    Assets.cardSprites["op_divide"] = love.graphics.newImage("sprites/cards/op_divide.png")
    Assets.cardSprites["op_exp"] = love.graphics.newImage("sprites/cards/op_exp.png")
    Assets.cardSprites["op_sub"] = love.graphics.newImage("sprites/cards/op_sub.png")
    Assets.cardSprites["mod_x2"] = love.graphics.newImage("sprites/cards/mod_x2.png")
    Assets.cardSprites["num_rand"] = love.graphics.newImage("sprites/cards/num_rand.png")
    Assets.cardSprites["mod_reverse"] = love.graphics.newImage("sprites/cards/mod_reverse.png")
    Assets.cardSprites["mod_prime"] = love.graphics.newImage("sprites/cards/mod_pN.png")   
    return true
end

return Assets 