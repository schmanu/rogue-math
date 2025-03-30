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
Assets.tabs = {
    expanded = nil,
    collapsed = nil,
}
Assets.cardSprites = {}
Assets.moduleSprites = {}
Assets.backgroundSprite = nil
Assets.gameOverSprite = nil
Assets.calculatorSprites = {
    front = nil,
    back = nil,
    button_flip = nil,
    modules = {
        empty = nil,
    }
}

Assets.gradeSprite = love.graphics.newImage("sprites/grade.png")

-- Card dimensions
Assets.card = {
    width = 60,
    height = 90,
    cornerRadius = 5,
    borderWidth = 2
}

function Assets.load()
    print("Loading assets")

    -- background
    Assets.backgroundSprite = love.graphics.newImage("sprites/background.png")

    -- tabs
    Assets.tabs = {
        expanded = love.graphics.newImage("sprites/module_tab_expanded.png"),
        collapsed = love.graphics.newImage("sprites/module_tab.png"),
    }


    -- calculator
    Assets.calculatorSprite = love.graphics.newImage("sprites/calculator.png")
    Assets.calculatorSprites = {
        front = love.graphics.newImage("sprites/calculator.png"),
        back = love.graphics.newImage("sprites/calculator_back.png"),
        button_flip = love.graphics.newImage("sprites/flip_calc.png"),
        modules = {
            empty = love.graphics.newImage("sprites/modules/module_empty.png"),
        }
    }

    -- game over screen
    Assets.gameOverSprite = love.graphics.newImage("sprites/game_over.png")

    -- Load card sprites
    Assets.cardSprites = {}

    -- Load number sprites
    for i = 0, 9 do
        Assets.cardSprites["num_" .. i] = love.graphics.newImage("sprites/cards/num_" .. i .. ".png")
    end

    Assets.cardSprites["num_rand"] = love.graphics.newImage("sprites/cards/num_rand.png")
    Assets.cardSprites["num_0.001"] = love.graphics.newImage("sprites/cards/num_0001.png")
    Assets.cardSprites["num_100"] = love.graphics.newImage("sprites/cards/num_100.png")
    Assets.cardSprites["num_pow2"] = love.graphics.newImage("sprites/cards/num_pow2.png")
    Assets.cardSprites["num_load"] = love.graphics.newImage("sprites/cards/num_load.png")

    -- Load operator sprites
    Assets.cardSprites["op_plus"] = love.graphics.newImage("sprites/cards/op_plus.png")
    Assets.cardSprites["op_multiply"] = love.graphics.newImage("sprites/cards/op_multiply.png")
    Assets.cardSprites["op_divide"] = love.graphics.newImage("sprites/cards/op_divide.png")
    Assets.cardSprites["op_exp"] = love.graphics.newImage("sprites/cards/op_exp.png")
    Assets.cardSprites["op_sub"] = love.graphics.newImage("sprites/cards/op_sub.png")
    Assets.cardSprites["op_concat"] = love.graphics.newImage("sprites/cards/op_concat.png")
    Assets.cardSprites["op_plus1"] = love.graphics.newImage("sprites/cards/op_plus1.png")
    -- Modifiers
    Assets.cardSprites["mod_x2"] = love.graphics.newImage("sprites/cards/mod_x2.png")
    Assets.cardSprites["mod_reverse"] = love.graphics.newImage("sprites/cards/mod_reverse.png")
    Assets.cardSprites["mod_prime"] = love.graphics.newImage("sprites/cards/mod_pN.png")
    Assets.cardSprites["mod_inverse"] = love.graphics.newImage("sprites/cards/mod_inverse.png")
    Assets.cardSprites["mod_store"] = love.graphics.newImage("sprites/cards/mod_store.png")

    -- Special cards
    Assets.cardSprites["sp_draw3"] = love.graphics.newImage("sprites/cards/sp_draw3.png")

    -- Load module sprites
    Assets.moduleSprites = {}
    Assets.moduleSprites["module_infinity"] = love.graphics.newImage("sprites/modules/module_infinity.png")
    Assets.moduleSprites["module_count"] = love.graphics.newImage("sprites/modules/module_count.png")
    Assets.moduleSprites["module_balance"] = love.graphics.newImage("sprites/modules/module_balance.png")
    return true
end

return Assets 