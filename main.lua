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

local game = {
    drawPile = {},
    discardPile = {},
    hand = {},
    cardLibrary = CardLibrary.new(),
    calculator = nil,
    draggedCard = nil,
    deck = {},
    font = nil,
    seed = nil,
    game = nil,  -- Will be initialized in love.load
    drawPileUI = {
        x = 36,  -- Keep left side position
        y = 710,  -- Same y as hand cards
        width = 128,
        height = 90,
        draw = function(self)
            -- Draw card count
            love.graphics.setColor(1, 1, 1)
            local drawPileCount = self.parent.drawPile and #self.parent.drawPile or 0
            local discardPileCount = self.parent.discardPile and #self.parent.discardPile or 0
            local handCount = self.parent.hand and #self.parent.hand or 0
            love.graphics.printf(drawPileCount .. "/" .. discardPileCount + drawPileCount + handCount, self.x, self.y, self.width, "left")
        end
    },
    endTurnButton = {
        x = 800,  -- Align with discard pile
        y = 500,  -- Move up above the cards
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
        y = 560,  -- Move down below the cards
        width = 144,
        height = 48,
        hovered = false,
        enabled = false,
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
    },
    canDiscard = true
}

function game:createCard(cardId, x, y)    
    return self.cardLibrary:createCard(cardId, x, y)
end

function game:initializeDeck(seed)
    -- Create draw pile with limited number of cards
    self.drawPile = {}
    self.discardPile = {}
    
    -- Create a limited number of cards (enough for 2-3 hands)
    for i = 1, #self.cardLibrary.initialCardIds do
        local cardId = self.cardLibrary.initialCardIds[i]
        table.insert(self.drawPile, cardId)  -- Store just the cardId, not the card object
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
            local cardId = table.remove(self.drawPile)
            local card = self:createCard(cardId, 0, 0)  -- Position will be set by updateHandPosition
            table.insert(self.hand, card)
        end
    end
    
    -- Update hand positions
    self:updateHandPosition()
end

function game:updateHandPosition()
    local centerX = love.graphics.getWidth() / 2 - 100
    local baseY = 500
    local cardSpacing = 90
    local maxRotation = 15  -- Maximum rotation in degrees
    
    -- Handle single card case
    if #self.hand == 1 then
        self.hand[1].x = centerX
        self.hand[1].y = baseY
        self.hand[1].rotation = 0
        return
    end
    
    -- Calculate hand width and spacing for multiple cards
    local handWidth = (#self.hand - 1) * cardSpacing
    
    for i, card in ipairs(self.hand) do
        print("Card " .. card.id)
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

function game:drawNewCards(count)
    -- Draw new cards from draw pile
    for i = 1, count do
        if #self.drawPile > 0 then
            local cardId = table.remove(self.drawPile)
            local card = self:createCard(cardId, 0, 0)  -- Position will be set by updateHandPosition
            table.insert(self.hand, card)
        end
    end
    
    -- Update hand positions
    self:updateHandPosition()
end

function game:removeCard(card)
    for i, c in ipairs(self.hand) do
        if c == card then
            table.remove(self.hand, i)
            break
        end
    end
    
    -- Update hand positions
    self:updateHandPosition()
end

function game:discardSelectedCards()
    print("Discarding selected cards...")
    if not self.canDiscard then 
        print("Cannot discard - already discarded this turn")
        return 
    end

    local selectedCount = 0
    for i = #self.hand, 1, -1 do
        if self.hand[i]:isSelected() then
            print("Removing card:", self.hand[i].id)
            -- Add card to discard pile before removing from hand
            table.insert(self.discardPile, self.hand[i].id)
            table.remove(self.hand, i)
            selectedCount = selectedCount + 1
        end
    end
    
    print("Selected cards removed:", selectedCount)
    
    if selectedCount > 0 then
        -- Reposition remaining cards
        for i, card in ipairs(self.hand) do
            card.x = 130 + (i-1) * 65
        end
        
        -- Draw new cards
        self:drawNewCards(selectedCount)
        
        -- Disable discarding for the rest of the turn
        self.canDiscard = false
        self.discardButton.enabled = false
        print("Discard button disabled")
    end
end

function love.load()
    -- Load pixel font
    local pixelFont = love.graphics.newFont("sprites/PixelFont.ttf", 16)
    love.graphics.setFont(pixelFont)
    
    -- Set the seed
    game.seed = os.time()
    math.randomseed(game.seed)

    -- Initialize game state
    game.game = Game.new()
    game.game.cardLibrary = game.cardLibrary  -- Pass card library reference
    
    -- Initialize calculator
    game.calculator = Calculator.new(100, 50, game.game)
    
    -- Set parent references for UI elements
    game.drawPileUI.parent = game
    
    -- Initialize deck and hand
    game:initializeDeck()

    game.game:initializeLevel()
    
    -- Load assets
    Assets.load()
    Shaders.load()
    
    -- Initialize discard button state
    game.canDiscard = true
    game.discardButton.enabled = true
end

function love.update(dt)
    -- Update cards in hand only
    for _, card in ipairs(game.hand) do
        card:update(dt)
    end
    
    -- Update hover state
    local mx, my = love.mouse.getPosition()
    game.hoveredCard = nil
    
    -- Only check hover state if not dragging
    if not game.draggedCard then
        for _, card in ipairs(game.hand) do
            if card:containsPoint(mx, my) then
                game.hoveredCard = card
                break
            end
        end
    end
    
    -- Update card hover states
    for _, card in ipairs(game.hand) do
        card:setHovered(card == game.hoveredCard)
    end
    
    -- Update calculator
    game.calculator:update(dt)
    
    -- Update button hover states
    game.endTurnButton:updateHoverState(mx, my)
    game.discardButton:updateHoverState(mx, my)
    game.calculator:updateHoverState(mx, my)
    
    -- Update card disabled state based on calculator state
    for _, card in ipairs(game.hand) do
        if game.calculator.gameState == "playing" then
            -- Disable cards based on expected input type
            if game.calculator:getExpectedInputType() == "number" then
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
    -- Draw background
    love.graphics.setColor(1, 1, 1)
    love.graphics.setShader()
    if Assets.backgroundSprite then
        love.graphics.draw(Assets.backgroundSprite, 0, 0)
    end
    
    -- Draw calculator
    game.calculator:draw()
    
    -- Draw draw pile UI
    game.drawPileUI:draw()
    
    -- Draw hand cards
    for _, card in ipairs(game.hand) do
        card:draw()
    end
    
    
    -- Draw end turn button
    if game.endTurnButton.hovered then
        love.graphics.setColor(0.3, 0.9, 0.3)
    else
        love.graphics.setColor(0.2, 0.8, 0.2)
    end
    love.graphics.rectangle("fill", game.endTurnButton.x, game.endTurnButton.y,
                          game.endTurnButton.width, game.endTurnButton.height)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("End Turn", game.endTurnButton.x, game.endTurnButton.y + 10,
                        game.endTurnButton.width, "center")
    
    -- Draw discard button
    game.discardButton:draw()
    
    -- Draw seed (for debugging)
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.printf("Seed: " .. game.seed, love.graphics.getWidth() - 300, love.graphics.getHeight() - 50, 300, "right")
end

function love.mousepressed(x, y, button)
    if button == 1 then  -- Left click
        -- Check if clicking end turn button
        if game.endTurnButton:containsPoint(x, y) then
            game.calculator:endTurn()
            game.canDiscard = true  -- Reset discard ability here instead
            game.discardButton.enabled = true
            return
        end
        
        -- Check if clicking discard button
        if game.discardButton.enabled and game.canDiscard and game.discardButton:containsPoint(x, y) then
            print("Discard button clicked")
            print("Button enabled:", game.discardButton.enabled)
            print("Can discard:", game.canDiscard)
            game:discardSelectedCards()
            return
        end
        
        -- Check if clicking reward cards
        if game.game.rewardState.active then
            if game.calculator:handleRewardClick(x, y) then
                -- Add selected card to draw pile
                if game.game.rewardState.selectedCard then
                    print("Stats before reward selection: " .. #game.drawPile .. " " .. #game.discardPile .. " " .. #game.hand)

                    -- Add the new card to the draw pile
                    table.insert(game.drawPile, game.game.rewardState.selectedCard.id)
                    
                    -- Start next level and draw new hand
                    game.game.rewardState.active = false
                    game.calculator:reset()
                    game.game:startNextLevel()

                    
                    -- Combine draw, discard piles and hand
                    for _, card in ipairs(game.discardPile) do
                        table.insert(game.drawPile, card)
                    end
                    for _, card in ipairs(game.hand) do
                        table.insert(game.drawPile, card.id)
                    end
                    game.discardPile = {}  -- Clear discard pile
                    
                    -- Reshuffle combined draw pile for new level
                    for i = #game.drawPile, 2, -1 do
                        local j = math.random(i)
                        game.drawPile[i], game.drawPile[j] = game.drawPile[j], game.drawPile[i]
                    end


                    
                    -- Draw new hand
                    game.hand = {}
                    print("Stats after combining piles and hand " .. #game.drawPile .. " " .. #game.discardPile .. " " .. #game.hand)

                    for i = 1, 5 do
                        if #game.drawPile > 0 then
                            local cardId = table.remove(game.drawPile)
                            print("Drawing card: " .. cardId)
                            local card = game:createCard(cardId, 130 + (i-1) * 65, 500)
                            table.insert(game.hand, card)
                        end
                    end


                    game:updateHandPosition()
                end
            end
            return
        end
        
        -- Check if clicking on a card in hand
        for i = #game.hand, 1, -1 do
            local card = game.hand[i]
            if card:containsPoint(x, y) then
                if not card:isDisabled() then
                    card:startDragging()
                    game.draggedCard = card
                end
                card:setSelected(not card:isSelected())
                break
            end
        end
    end
end

function love.mousereleased(x, y, button)
    if button == 1 and game.draggedCard then
        -- Check if dropped on calculator
        if game.calculator:containsPoint(x, y) then
            -- Play the card
            if game.draggedCard:play(game.calculator) then
                -- Add card to discard pile before removing from hand
                table.insert(game.discardPile, game.draggedCard.id)
                -- Remove card from hand
                game:removeCard(game.draggedCard)
            end
        else
            -- Return card to hand
            local index = 1
            for i, card in ipairs(game.hand) do
                if card == game.draggedCard then
                    index = i
                    break
                end
            end
            game.draggedCard.x = 130 + (index-1) * 65
            game.draggedCard.y = 500
        end
        game.draggedCard:stopDragging()
        game.draggedCard = nil
        -- Update hand positions
       game:updateHandPosition()
    end
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "return" then
        game.calculator:evaluate()
    elseif key == "c" then
        game.calculator:clear()
    elseif key == "r" then
        -- Reset the game with a new random seed
        game:initializeDeck()
        game.calculator:reset()
    elseif key == "s" then
        -- Reset the game with the same seed (for testing)
        game:initializeDeck(game.seed)
        game.calculator:reset()
    elseif key == "space" and game.discardButton.enabled and game.canDiscard then
        game:discardSelectedCards()
    end
end


