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

GAME = {
    stats = {
        round = {
            cardsPlayed = 0,
        },
    },
    uiState = {
        hoveredElement = nil,
    },
    availableModules = {},
    drawPile = {},
    discardPile = {},
    hand = {},
    cardLibrary = CardLibrary.new(),
    calculator = nil,
    draggedElement = nil,
    deck = {},
    font = nil,
    seed = nil,
    game = nil,  -- Will be initialized in love.load
    drawPileUI = {
        x = 12,  -- Keep left side position
        y = 710,  -- Same y as hand cards
        width = 128,
        height = 90,
        draw = function(self)
            -- Draw card count
            love.graphics.setColor(1, 1, 1)
            local drawPileCount = self.parent.drawPile and #self.parent.drawPile or 0
            local discardPileCount = self.parent.discardPile and #self.parent.discardPile or 0
            local handCount = self.parent.hand and #self.parent.hand or 0
            love.graphics.printf(drawPileCount .. "/" .. discardPileCount + drawPileCount + handCount, self.x, self.y, self.width, "center")
        end
    },
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

function GAME:initializeDeck(seed)
    -- Create draw pile with limited number of cards
    self.drawPile = {}
    self.discardPile = {}
    
    -- Create a limited number of cards (enough for 2-3 hands)
    for i = 1, #self.cardLibrary.initialCardIds do
        local cardId = self.cardLibrary.initialCardIds[i]
        table.insert(self.drawPile, self:createCard(cardId, 0, 0)) -- Position will be set by updateHandPosition
    end
    
    -- Shuffle draw pile
    for i = #self.drawPile, 2, -1 do
        local j = math.random(i)
        self.drawPile[i], self.drawPile[j] = self.drawPile[j], self.drawPile[i]
    end
    
    -- Clear and redraw hand (limited to 5 cards)
    self.hand = {}
    for i = 1, 5 do
        if #self.drawPile > 0 then
            local card = table.remove(self.drawPile)
            table.insert(self.hand, card)
        end
    end
    
    -- Update hand positions
    self:updateHandPosition()
end

function GAME:updateHandPosition()
    local centerX = love.graphics.getWidth() / 2 - 100
    local baseY = 500
    local handWidth = 450
    local maxRotation = 15  -- Maximum rotation in degrees
    
    -- Handle single card case
    if #self.hand == 1 then
        self.hand[1].x = centerX
        self.hand[1].y = baseY
        self.hand[1].rotation = 0
        return
    end
    
    -- Calculate hand width and spacing for multiple cards
    local cardSpacing = handWidth / (#self.hand - 1)


    for i, card in ipairs(self.hand) do
        -- Calculate position along a curve
        local t = (i - 1) / (#self.hand - 1)  -- 0 to 1
        local curveOffset = math.sin(t * math.pi) * 20  -- Creates a slight curve
        local x = centerX - handWidth/2 + (i-1) * cardSpacing
        local y = baseY - curveOffset
        
        -- Calculate rotation (cards on edges are rotated more)
        local rotation = (t - 0.5) * 2 * maxRotation  -- -maxRotation to maxRotation
        
        card.x = x
        card.y = y
        card.rotation = rotation
    end
end

function GAME:drawNewCards(count)
    -- Draw new cards from draw pile
    for i = 1, count do
        if #self.drawPile > 0 then
            local card = table.remove(self.drawPile)
            table.insert(self.hand, card)
        end
    end
    
    -- Update hand positions
    self:updateHandPosition()
end

function GAME:removeCard(card)
    for i, c in ipairs(self.hand) do
        if c == card then
            table.remove(self.hand, i)
            break
        end
    end
    
    -- Update hand positions
    self:updateHandPosition()
end

function GAME:discardSelectedCards()
    local selectedCount = 0
    for i = #self.hand, 1, -1 do
        if self.hand[i]:isSelected() then
            -- Add card to discard pile before removing from hand
            table.insert(self.discardPile, self.hand[i])
            table.remove(self.hand, i)
            selectedCount = selectedCount + 1
        end
    end
    
    if selectedCount > 0 then
        -- Reposition remaining cards
        for i, card in ipairs(self.hand) do
            card.x = 130 + (i-1) * 65
        end
        
        -- Draw new cards
        self:drawNewCards(selectedCount)
        
        -- Decrease discards
        self.game.discards = self.game.discards - 1
        if (self.game.discards == 0) then
            self.discardButton.enabled = false
        end
    end
end

function GAME:addCardToDrawPile(cardId)
    table.insert(self.drawPile, self:createCard(cardId, 0, 0))
end

function GAME:resetGame()
    GAME.calculator:reset()
    GAME.game:reset()
end

function GAME:prepareNextLevel()
    GAME.stats.round.cardsPlayed = 0
    GAME.calculator:reset()
    GAME.game:startNextLevel()

    
    -- Combine draw, discard piles and hand
    for _, card in ipairs(GAME.discardPile) do
        table.insert(GAME.drawPile, card)
    end
    for _, card in ipairs(GAME.hand) do
        table.insert(GAME.drawPile, card)
    end
    GAME.discardPile = {}  -- Clear discard pile
    
    -- Reshuffle combined draw pile for new level
    for i = #GAME.drawPile, 2, -1 do
        local j = math.random(i)
        GAME.drawPile[i], GAME.drawPile[j] = GAME.drawPile[j], GAME.drawPile[i]
    end


    
    -- Draw new hand
    GAME.hand = {}

    for i = 1, 5 do
        if #GAME.drawPile > 0 then
            local card = table.remove(GAME.drawPile)
            -- unselect card
            card:setSelected(false)
            table.insert(GAME.hand, card)
        end
    end

    GAME:updateHandPosition()

    -- Enable discard button
    GAME.discardButton.enabled = true
end

function love.load()
    print("Test: " .. loadstring("return 4 * (1 .. 0)")())
    -- Load pixel font
    local pixelFont = love.graphics.newFont("sprites/PixelFont.ttf", 16)
    love.graphics.setFont(pixelFont)
    
    -- Set the seed
    GAME.seed = os.time()
    math.randomseed(GAME.seed)

    -- Initialize game state
    GAME.game = Game.new()
    GAME.game.cardLibrary = GAME.cardLibrary  -- Pass card library reference
    
    -- Initialize calculator
    GAME.calculator = Calculator.new(392, 64, GAME.game)
    
    -- Set parent references for UI elements
    GAME.drawPileUI.parent = GAME
    
    -- Initialize deck and hand
    GAME:initializeDeck()

    GAME.game:initializeLevel()
    
    -- Load assets
    Assets.load()
    Shaders.load()
end

function love.update(dt)

    -- Get mouse position
    local mx, my = love.mouse.getPosition()

    -- combine all possible shown cards: hand and reward cards
    local allCards = {}
    for _, card in ipairs(GAME.hand) do
        table.insert(allCards, card)
    end
    for _, card in ipairs(GAME.game.rewards.rewardState.cards) do
        table.insert(allCards, card)
    end

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

    -- Update all cards (hand and rewards) in reverse order
    for _, card in ipairs(allCards) do
        card:update(dt)
    end

    -- Update all modules (tabs and calculator)
    for _, module in ipairs(allModules) do
        module:update(dt)
    end
    
    -- Update calculator
    GAME.calculator:update(dt)

    -- Update tabs
    GAME.game.tabs:update(dt)
    
    -- Update button hover states
    GAME.endTurnButton:updateHoverState(mx, my)
    GAME.discardButton:updateHoverState(mx, my)
    
    -- Update card disabled state based on calculator state
    for _, card in ipairs(GAME.hand) do
        if GAME.game.gameState == "playing" then
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
    if GAME.game.gameState == "gameOver" then
        love.graphics.draw(Assets.gameOverSprite, 0, 0)
        love.graphics.setColor(0,0,0,0.5)
        love.graphics.rectangle("fill", 32, love.graphics.getHeight() / 2 - 32, love.graphics.getWidth() - 64, 196)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("You were sent to boarding school due to your bad grades.", 0, love.graphics.getHeight() / 2, love.graphics.getWidth(), "center")
        love.graphics.printf("Days Survived: " .. GAME.game.level, 0, love.graphics.getHeight() / 2 + 64, love.graphics.getWidth(), "center")
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
    
    -- Draw draw pile UI
    GAME.drawPileUI:draw()
    
    -- Draw hand cards
    for _, card in ipairs(GAME.hand) do
        card:draw()
    end
    
    
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
    love.graphics.printf("(" .. GAME.game.discards .. ")", GAME.discardButton.x + GAME.discardButton.width + 8, GAME.discardButton.y + GAME.discardButton.height / 2 - 8, 64, "left")
    
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
        -- Check if clicking end turn button
        if GAME.endTurnButton:containsPoint(x, y) then
            GAME.calculator:endTurn()
            return
        end
        
        -- Check if clicking discard button
        if GAME.game.discards > 0 and GAME.discardButton:containsPoint(x, y) then
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
        for i = #GAME.hand, 1, -1 do
            local card = GAME.hand[i]
            if card:containsPoint(x, y) then
                if not card:isDisabled() then
                    card:startDragging()
                    GAME.draggedElement = card
                end
                card:setSelected(not card:isSelected())
                break
            end
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
                    -- Add card to discard pile before removing from hand
                    table.insert(GAME.discardPile, GAME.draggedElement)
                    -- Remove card from hand
                    GAME:removeCard(GAME.draggedElement)

                    -- trigger onCardPlayed on calculator
                    print("onCardPlayed " .. GAME.draggedElement.id)
                    GAME.calculator:onCardPlayed(GAME.draggedElement)
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
            for i, card in ipairs(GAME.hand) do
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
        -- Update hand positions
       GAME:updateHandPosition()
    end
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "r" then
        -- Reset the game with a new random seed
        GAME:initializeDeck()
        GAME.calculator:reset()
    elseif key == "s" then
        -- Reset the game with the same seed (for testing)
        GAME:initializeDeck(GAME.seed)
        GAME.calculator:reset()
    end
end


