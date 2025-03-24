local NumberCard = require("cards/number_card")
local OperatorCard = require("cards/operator_card")
local DoubleCard = require("cards/double_card")
local RandomCard = require("cards/random_card")
local Calculator = require("calculator")
local Card = require("cards/card")
local Assets = require("assets")

local game = {

    drawPile = {},
    discardPile = {},
    hand = {},
    calculator = nil,
    draggedCard = nil,
    deck = {},
    font = nil,
    seed = nil,
    drawPileUI = {
        x = 50,
        y = 500,  -- Same y as hand cards
        width = 60,
        height = 90,
        draw = function(self)
            -- Draw card back
            love.graphics.setColor(0.2, 0.4, 0.8)  -- Blue card back
            love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
            
            -- Draw card border
            love.graphics.setColor(0.1, 0.2, 0.4)
            love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
            
            -- Draw card count
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf(self.parent.drawPile and #self.parent.drawPile or 0, self.x, self.y + 35, self.width, "center")
            
            -- Draw label
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf("Draw", self.x, self.y - 20, self.width, "center")
        end
    },
    discardPileUI = {
        x = 500,  -- Moved from 450 to 500
        y = 500,  -- Same y as hand cards
        width = 60,
        height = 90,
        draw = function(self)
            -- Draw card back
            love.graphics.setColor(0.8, 0.2, 0.2)  -- Red card back
            love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
            
            -- Draw card border
            love.graphics.setColor(0.4, 0.1, 0.1)
            love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
            
            -- Draw card count
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf(self.parent.discardPile and #self.parent.discardPile or 0, self.x, self.y + 35, self.width, "center")
            
            -- Draw label
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf("Discard", self.x, self.y - 20, self.width, "center")
        end
    },
    endTurnButton = {
        x = 650,  -- Moved from 600 to 650
        y = 500,  -- Same y as cards
        width = 120,
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
        x = 650,  -- Moved from 600 to 650
        y = 560,  -- Just below end turn button
        width = 120,
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

function game:createCard(value, x, y)
    if (value == "rand") then 
        return RandomCard.new(x, y)
    elseif value == "x2" then
        return DoubleCard.new(x, y)
    elseif value:match("%d") then
        return NumberCard.new(value, x, y)
    elseif value == "+" or value == "-" or value == "x" or value == "÷" then
        return OperatorCard.new(value, x, y)
    end
    error("Invalid card value: " .. tostring(value))
end

function game:initializeDeck(seed)
    -- Set the seed
    self.seed = seed or os.time()
    math.randomseed(self.seed)
    
    -- Create draw pile with limited number of cards
    self.drawPile = {}
    self.discardPile = {}
    local cardValues = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "+", "+"}
    
    -- Create a limited number of cards (enough for 2-3 hands)
    for i = 1, #cardValues do
        local value = cardValues[i]
        table.insert(self.drawPile, value)  -- Store just the value, not the card object
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
            local value = table.remove(self.drawPile)
            local card = self:createCard(value, 130 + (i-1) * 65, 500)  -- Reduced padding from 140 to 130 and spacing from 70 to 65
            table.insert(self.hand, card)
        end
    end
end

function game:drawNewCards(count)
    -- Draw new cards from draw pile
    for i = 1, count do
        if #self.drawPile > 0 then
            local value = table.remove(self.drawPile)
            local card = self:createCard(value, 130 + (#self.hand) * 65, 500)  -- Reduced padding from 140 to 130 and spacing from 70 to 65
            table.insert(self.hand, card)
        end
    end
end

function game:removeCard(card)
    for i, c in ipairs(self.hand) do
        if c == card then
            table.remove(self.hand, i)
            -- Reposition remaining cards
            for j = i, #self.hand do
                self.hand[j].x = 130 + (j-1) * 65  -- Reduced padding from 140 to 130 and spacing from 70 to 65
            end
            break
        end
    end
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
            print("Removing card:", self.hand[i].value)
            -- Add card to discard pile before removing from hand
            table.insert(self.discardPile, self.hand[i].value)
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
    -- Initialize calculator
    local Calculator = require("calculator")
    game.calculator = Calculator.new(100, 50)  -- Moved up from 100 to 50
    game.calculator.game = game  -- Pass game reference to calculator
    
    -- Set parent references for UI elements
    game.drawPileUI.parent = game
    game.discardPileUI.parent = game
    
    -- Initialize deck and hand
    game:initializeDeck()
    
    -- Load assets
    Assets.load()
    
    -- Load card sprites
    game.cardSprites = {}
    -- Load number sprites
    for i = 0, 9 do
        game.cardSprites["num_" .. i] = love.graphics.newImage("sprites/cards/num_" .. i .. ".png")
    end
    -- Load operator sprites
    game.cardSprites["op_plus"] = love.graphics.newImage("sprites/cards/op_plus.png")
    game.cardSprites["op_multiply"] = love.graphics.newImage("sprites/cards/op_multiply.png")
    game.cardSprites["op_divide"] = love.graphics.newImage("sprites/cards/op_divide.png")
    game.cardSprites["op_x2"] = love.graphics.newImage("sprites/cards/op_x2.png")
    game.cardSprites["num_rand"] = love.graphics.newImage("sprites/cards/num_rand.png")
    
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
                card:setDisabled(card.type == "operator")
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
    love.graphics.setColor(0.1, 0.1, 0.1)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    -- Draw calculator
    game.calculator:draw()
    
    -- Draw draw pile UI
    game.drawPileUI:draw()
    
    -- Draw hand cards
    for _, card in ipairs(game.hand) do
        card:draw()
    end
    
    -- Draw discard pile UI (moved after hand cards to ensure it's on top)
    game.discardPileUI:draw()
    
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
    love.graphics.printf("Seed: " .. game.seed, 10, 10, 200, "left")
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
        
        -- Check if clicking calculator buttons
        if game.calculator:handleButtonClick(x, y) then
            return
        end
        
        -- Check if clicking reward cards
        if game.calculator.rewardState.active then
            if game.calculator:handleRewardClick(x, y) then
                -- Add selected card to draw pile
                if game.calculator.rewardState.selectedCard then
                    -- Add the new card to the draw pile
                    table.insert(game.drawPile, game.calculator.rewardState.selectedCard.value)
                    
                    -- Start next level and draw new hand
                    game.calculator.rewardState.active = false
                    game.calculator:startNextLevel()
                    
                    -- Combine draw, discard piles and hand
                    for _, card in ipairs(game.discardPile) do
                        table.insert(game.drawPile, card)
                    end
                    for _, card in ipairs(game.hand) do
                        table.insert(game.drawPile, card.value)
                    end
                    game.discardPile = {}  -- Clear discard pile
                    
                    -- Reshuffle combined draw pile for new level
                    for i = #game.drawPile, 2, -1 do
                        local j = math.random(i)
                        game.drawPile[i], game.drawPile[j] = game.drawPile[j], game.drawPile[i]
                    end
                    
                    -- Draw new hand
                    game.hand = {}
                    for i = 1, 5 do
                        if #game.drawPile > 0 then
                            local value = table.remove(game.drawPile)
                            local card = game:createCard(value, 130 + (i-1) * 65, 500)
                            table.insert(game.hand, card)
                        end
                    end
                end
            end
            return
        end
        
        -- Check if clicking on a card in hand
        for _, card in ipairs(game.hand) do
            if card:containsPoint(x, y) then
                if not card:isDisabled() then
                    card:startDragging()
                    game.draggedCard = card
                end
                card:setSelected(not card:isSelected())
                break
            end
        end
    elseif button == 2 then  -- Right click
        print("Right click detected")
        -- Toggle card selection for discarding
        if game.canDiscard then  -- Only allow selection if can still discard
            print("Can discard is true")
            for _, card in ipairs(game.hand) do
                if card:containsPoint(x, y) then
                    card:setSelected(not card:isSelected())
                    -- Enable discard button if any cards are selected
                    game.discardButton.enabled = false
                    for _, c in ipairs(game.hand) do
                        if c:isSelected() then
                            game.discardButton.enabled = true
                            break
                        end
                    end
                    break
                end
            end
        else
            print("Cannot discard - already discarded this turn")
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
                table.insert(game.discardPile, game.draggedCard.value)
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

function Card:draw()
    -- Draw card sprite
    love.graphics.setColor(1, 1, 1)
    local sprite = game.cardSprites[self.sprite]
    if sprite then
        local spriteWidth, spriteHeight = sprite:getDimensions()
        
        -- Update card dimensions to match sprite scaled up by 2
        self.width = spriteWidth * 2
        self.height = spriteHeight * 2
        
        -- Draw background
        if self.hovered then
            love.graphics.setColor(0.4, 0.4, 0.4)
        else
            love.graphics.setColor(0.3, 0.3, 0.3)
        end
        love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
        
        -- Draw border
        if self.selected then
            love.graphics.setColor(1, 0.8, 0)  -- Gold border for selected cards
        elseif self.disabled then
            love.graphics.setColor(0.5, 0.5, 0.5)  -- Gray border for disabled cards
        else
            love.graphics.setColor(0.8, 0.8, 0.8)  -- White border for normal cards
        end
        love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
        
        -- Draw sprite scaled up by 2
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(sprite, self.x, self.y, 0, 2, 2)
    end
end
