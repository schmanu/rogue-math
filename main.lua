local NumberCard = require("cards/number_card")
local OperatorCard = require("cards/operator_card")
local DoubleCard = require("cards/double_card")
local RandomCard = require("cards/random_card")
local ReverseCard = require("cards/reverse_card")
local Calculator = require("calculator")
local Card = require("cards/card")
local Assets = require("assets")
local Shaders = require("shaders")
local CardLibrary = require("cards/card_library")
local Game = require("game")
local Deck = require("deck")

GAME = {
    stats = {
        round = {
            cardsPlayed = 0,
            lastCardsPlayed = {},
        },
    },
    state = {
        gameState = "playing",
        discards = 1,
        handSize = 5,
        targetNumber = 0,
        level = 0,
    },
    uiState = {
        hoveredElement = nil,
    },
    availableModules = {},
    deck = Deck.new(),
    cardLibrary = CardLibrary.new(),
    calculator = nil,
    draggedElement = nil,
    font = nil,
    seed = nil,
    game = nil,  -- Will be initialized in love.load
    endTurnButton = {
        x = 800,  -- Align with discard pile
        y = 516,  -- Move up above the cards
        width = 144,
        height = 48,
        hovered = false,
        updateHoverState = function(self, x, y)
            self.hovered = x >= self.x and x <= self.x + self.width and
                          y >= self.y and y <= self.y + self.height
        end,
        containsPoint = function(self, x, y)
            return x >= self.x and x <= self.x + self.width and
                   y >= self.y and y <= self.y + self.height
        end
    },
    discardButton = {
        x = 800,  -- Align with discard pile
        y = 580,  -- Move down below the cards
        width = 144,
        height = 48,
        hovered = false,
        enabled = true,
        updateHoverState = function(self, x, y)
            self.hovered = x >= self.x and x <= self.x + self.width and
                          y >= self.y and y <= self.y + self.height
        end,
        containsPoint = function(self, x, y)
            return x >= self.x and x <= self.x + self.width and
                   y >= self.y and y <= self.y + self.height
        end,
        draw = function(self)
            if self.enabled then
                love.graphics.setColor(0.3, 0.9, 0.3)
            else
                love.graphics.setColor(0.5, 0.5, 0.5)
            end
            love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf("Discard", self.x, self.y + 10, self.width, "center")
        end
    }
}

function GAME:createCard(cardId, x, y)    
    return self.cardLibrary:createCard(cardId, x, y)
end

function GAME:drawNewCards(count)
   GAME.deck:drawCards(count)
end

function GAME:removeCard(card)
    GAME.deck:discardCard(card)
end

function GAME:discardSelectedCards()
    GAME.deck:discardSelectedCards()
    
    -- Decrease discards
    GAME.state.discards = GAME.state.discards - 1
    if (GAME.state.discards == 0) then
        GAME.discardButton.enabled = false
    end
end

function GAME:addCardToDrawPile(cardId)
    GAME.deck:addToDrawPile(GAME:createCard(cardId, GAME.deck.drawPilePosition.x, GAME.deck.drawPilePosition.y - 200))
end

function GAME:resetGame()
    GAME.calculator:reset()
    GAME.game:reset()
end

function GAME:prepareNextLevel()
    GAME.stats.round.cardsPlayed = 0
    GAME.stats.round.lastCardsPlayed = {}
    GAME.calculator:reset()
    GAME.game:startNextLevel()

    -- Combine piles, shuffle and draw new hand
    GAME.deck:resetDrawPile()
    GAME.deck:shuffleDrawPile()
    GAME.deck:drawCards(GAME.state.handSize)
    
    -- Apply modules that trigger on round start
    if GAME.calculator.modules.slot1 then GAME.calculator.modules.slot1:onStartOfTurn() end
    if GAME.calculator.modules.slot2 then GAME.calculator.modules.slot2:onStartOfTurn() end

    -- Enable discard button
    GAME.discardButton.enabled = true
end

function love.load()
    -- Load pixel font
    local pixelFont = love.graphics.newFont("sprites/PixelFont.ttf", 16)
    love.graphics.setFont(pixelFont)
    
    -- Set the seed
    GAME.seed = os.time()
    math.randomseed(GAME.seed)

    -- Initialize game state
    GAME.game = Game.new()
    GAME.game.cardLibrary = GAME.cardLibrary  -- Pass card library reference

    -- Initialize deck
    GAME.deck:reset()
    
    -- Initialize calculator
    GAME.calculator = Calculator.new(392, 64, GAME.game)
    
    GAME.game:initializeLevel()
    GAME:prepareNextLevel()
    
    -- Load assets
    Assets.load()
    Shaders.load()
end

function love.update(dt)

    -- Get mouse position
    local mx, my = love.mouse.getPosition()

    -- combine all possible shown modules: modules in tabs and modules in calculator
    local allModules = {}
    for _, module in ipairs(GAME.game.tabs.modules) do
        table.insert(allModules, module)
    end
    if (GAME.calculator.flipped) then
        if (GAME.calculator.modules.slot1) then
            table.insert(allModules, GAME.calculator.modules.slot1)
        end
        if (GAME.calculator.modules.slot2) then
            table.insert(allModules, GAME.calculator.modules.slot2)
        end
    end
    if (GAME.game.rewards.rewardState.active) then
        for _, module in ipairs(GAME.game.rewards.rewardState.modules) do
            table.insert(allModules, module)
        end
    end

    -- Update all modules (tabs and calculator)
    for _, module in ipairs(allModules) do
        module:update(dt)
    end

    -- Update deck and cards
    GAME.deck:update(dt)
    
    -- Update calculator
    GAME.calculator:update(dt)

    -- Update game
    GAME.game:update(dt)

    -- Update tabs
    GAME.game.tabs:update(dt)
    
    -- Update button hover states
    GAME.endTurnButton:updateHoverState(mx, my)
    GAME.discardButton:updateHoverState(mx, my)
    
    -- Update card disabled state based on calculator state
    for _, card in ipairs(GAME.deck.hand) do
        if GAME.state.gameState == "playing" then
            -- Disable cards based on expected input type
            if GAME.calculator:getExpectedInputType() == "number" then
                card:setDisabled(card.type == "operator" or card.type == "modifier")
            else
                card:setDisabled(card.type == "number")
            end
        else
            -- Disable all cards when not in playing state
            card:setDisabled(true)
        end
    end
end

function love.draw()
    if GAME.state.gameState == "gameOver" then
        love.graphics.draw(Assets.gameOverSprite, 0, 0)
        love.graphics.setColor(0,0,0,0.5)
        love.graphics.rectangle("fill", 32, love.graphics.getHeight() / 2 - 32, love.graphics.getWidth() - 64, 196)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("You were sent to boarding school due to your bad grades.", 0, love.graphics.getHeight() / 2, love.graphics.getWidth(), "center")
        love.graphics.printf("Days Survived: " .. GAME.state.level - 1, 0, love.graphics.getHeight() / 2 + 64, love.graphics.getWidth(), "center")
        love.graphics.printf("Press R to restart", 0, love.graphics.getHeight() / 2 + 96, love.graphics.getWidth(), "center")
        return
    end
    
    -- Draw background
    love.graphics.setColor(1, 1, 1)
    love.graphics.setShader()
    if Assets.backgroundSprite then
        love.graphics.draw(Assets.backgroundSprite, 0, 0)
    end
    
    -- Draw calculator
    GAME.calculator:draw()
    
    -- Draw deck and cards
    GAME.deck:draw()
    
    -- Draw end turn button
    if GAME.endTurnButton.hovered then
        love.graphics.setColor(0.3, 0.9, 0.3)
    else
        love.graphics.setColor(0.2, 0.8, 0.2)
    end
    love.graphics.rectangle("fill", GAME.endTurnButton.x, GAME.endTurnButton.y,
                          GAME.endTurnButton.width, GAME.endTurnButton.height)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("End Turn", GAME.endTurnButton.x, GAME.endTurnButton.y + 10,
                        GAME.endTurnButton.width, "center")
    
    -- Draw discard button
    GAME.discardButton:draw()
    love.graphics.printf("(" .. GAME.state.discards .. ")", GAME.discardButton.x + GAME.discardButton.width + 8, GAME.discardButton.y + GAME.discardButton.height / 2 - 8, 64, "left")
    
    -- Draw seed (for debugging)
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.printf("Seed: " .. GAME.seed, love.graphics.getWidth() - 300, love.graphics.getHeight() - 50, 300, "right")

    -- Draw game state
    GAME.game:draw()

    if GAME.uiState.hoveredElement then
        GAME.uiState.hoveredElement:draw()
    end

    -- Draw dragged element again such that it is on top of everything
    if GAME.draggedElement then
        GAME.draggedElement:draw()
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then  -- Left click 
        -- Check if clicking discard button
        if GAME.state.discards > 0 and GAME.discardButton:containsPoint(x, y) then
            GAME:discardSelectedCards()
            return
        end

        -- Check if clicking flip button
        if GAME.calculator:flipButtonContainsPoint(x, y) then
            GAME.calculator:flip()
            return
        end

        -- Check if clicking module
        for _, module in ipairs(GAME.game.tabs.modules) do
            if module:containsPoint(x, y) then
                module:startDragging()
                GAME.draggedElement = module
                return
            end
        end

        -- Check if clicking tabs
        if GAME.game.tabs:containsPoint(x, y) then
            GAME.game.tabs:toggle()
            return
        end
        
        -- Check if clicking reward cards
        if GAME.game.rewards.rewardState.active then
            if GAME.game.rewards:handleRewardClick(x, y) then
                return
            end
        end
        
        -- Check if clicking on a card in hand
        for i = #GAME.deck.hand, 1, -1 do
            local card = GAME.deck.hand[i]
            if card:containsPoint(x, y) then
                if not card:isDisabled() then
                    card:startDragging()
                    GAME.draggedElement = card
                end
                card:setSelected(not card:isSelected())
                break
            end
        end

        -- Check if clicking end turn button
        if GAME.endTurnButton:containsPoint(x, y) then
            GAME.game:onTurnEnd()
            return
        end
    end
end

function love.mousereleased(x, y, button)
    if button == 1 and GAME.draggedElement then
        -- Check if dropped on calculator
        if GAME.calculator:containsPoint(x, y) then
            if GAME.draggedElement.objectName == "Card" then
            -- Play the card
                if GAME.draggedElement:play(GAME.calculator, GAME) then

                    -- Record that a card was played
                    GAME.stats.round.cardsPlayed = GAME.stats.round.cardsPlayed + 1
                    table.insert(GAME.stats.round.lastCardsPlayed, GAME.draggedElement)

                    -- Remove card from hand and discard it
                    GAME:removeCard(GAME.draggedElement)

                    -- trigger onCardPlayed on calculator
                    print("onCardPlayed " .. GAME.draggedElement.id)
                    GAME.calculator:onCardPlayed(GAME.draggedElement)
                    
                    GAME.draggedElement.drawX = GAME.deck.drawPilePosition.x
                    GAME.draggedElement.drawY = GAME.deck.drawPilePosition.y - 200
                end
            elseif GAME.draggedElement.objectName == "Module" then
                -- add to calculator
                GAME.calculator:installModule(GAME.draggedElement, x, y)
                -- remove from tabs
                GAME.game.tabs:removeModule(GAME.draggedElement)
            end
        else
            -- Return card to hand
            local index = 1
            for i, card in ipairs(GAME.deck.hand) do
                if card == GAME.draggedElement then
                    index = i
                    break
                end
            end
            GAME.draggedElement.x = 130 + (index-1) * 65
            GAME.draggedElement.y = 500
        end
        GAME.draggedElement:stopDragging()
        GAME.draggedElement = nil
    end
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "r" then
        GAME:resetGame()
    end
end


