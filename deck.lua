local CardLibrary = require("cards/card_library")

local Deck = {}
Deck.__index = Deck

function Deck.new()
    local self = setmetatable({}, Deck)
    self.autoPlayStack = {}
    self.drawPile = {}
    self.discardPile = {}
    self.hand = {}
    self.drawPilePosition = {
        x = 12,
        y = 710,
        width = 128,
        height = 90,
    }
    self.cardLibrary = CardLibrary.new()
    self.lastCardPlayedTime = 0
    self.autoPlaySpeed = 0.5 -- every .5 seconds a crad is played from the stack
    return self
end

function Deck:reset()
    self.drawPile = {}
    self.discardPile = {}
    self.hand = {}

    -- Create initial cards
    for i = 1, #self.cardLibrary.initialCardIds do
        local cardId = self.cardLibrary.initialCardIds[i]
        table.insert(self.drawPile, GAME:createCard(cardId, self.drawPilePosition.x, self.drawPilePosition.y - 200)) -- Position will be set by updateHandPosition
    end

    self:shuffleDrawPile()
    self:drawCards(GAME.state.handSize)
end

function Deck:getCardCount()
    return #self.drawPile + #self.discardPile + #self.hand
end

function Deck:addToDrawPile(card)
    table.insert(self.drawPile, card)
end

function Deck:drawCards(numCards)
    for i = 1, numCards do
        if #self.drawPile > 0 then
            local nextCard = table.remove(self.drawPile)
            table.insert(self.hand, nextCard)
        end
    end
end

function Deck:discardCards(numCards)
    print("Draw pile before discarding: " .. #self.drawPile)
    for i = 1, numCards do
        if #self.drawPile > 0 then
            local nextCard = table.remove(self.drawPile)
            print("Discarding card " .. nextCard.id)
            table.insert(self.discardPile, nextCard)
        end
    end
    print("Draw pile before discarding: " .. #self.drawPile)
end    

function Deck:discardCard(card)
    -- only temporary cards get discarded
    if (not card:isTemporary()) then
        table.insert(self.discardPile, card)
    end

    -- remove card from hand
    for i, handCard in ipairs(self.hand) do
        if handCard == card then
            table.remove(self.hand, i)
            break
        end
    end

    -- remove card from draw pile
    for i, drawPileCard in ipairs(self.drawPile) do
        if drawPileCard == card then
            table.remove(self.drawPile, i)
            break
        end
    end
end

function Deck:shuffleDrawPile()
    for i = #self.drawPile, 2, -1 do
        local j = math.random(i)
        self.drawPile[i], self.drawPile[j] = self.drawPile[j], self.drawPile[i]
    end
end

function Deck:discardSelectedCards()
    local selectedCount = 0
    for i = #self.hand, 1, -1 do
        if self.hand[i]:isSelected() then
            -- Add card to discard pile before removing from hand
            if (not self.hand[i]:isTemporary()) then
                table.insert(self.discardPile, self.hand[i])
            end
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
        self:drawCards(selectedCount)
    end
end

function Deck:resetDrawPile()
    -- merged hand and discard pile into draw pile
    for _, card in ipairs(self.hand) do
        if (not card:isTemporary()) then
            table.insert(self.drawPile, card)
        end
        card:setSelected(false)
    end
    for _, card in ipairs(self.discardPile) do
        if (not card:isTemporary()) then
            table.insert(self.drawPile, card)
        end
        card:setSelected(false)
    end
    self.discardPile = {}
    self.hand = {}
end

function Deck:updateHandPosition()
    local centerX = love.graphics.getWidth() / 2 - 100
    local baseY = 500
    local maxWith = 450
    local maxRotation = 10  -- Maximum rotation in degrees
    
    -- Handle single card case
    if #self.hand == 1 then
        self.hand[1].x = centerX
        self.hand[1].y = baseY
        self.hand[1].rotation = 0
        return
    end
    
    -- Calculate hand width and spacing for multiple cards
    local cardSpacing = math.min(100, maxWith / (#self.hand - 1))
    local handWidth = cardSpacing * (#self.hand - 1)


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

function Deck:update(dt)
    self:updateHandPosition()

    -- Get mouse position
    local mx, my = love.mouse.getPosition()
    -- combine all possible shown cards: hand and reward cards
    local allCards = {}
    for _, card in ipairs(self.hand) do
        table.insert(allCards, card)
    end
    if (GAME.game.rewards.rewardState.active) then
        for _, card in ipairs(GAME.game.rewards.rewardState.cards) do
            table.insert(allCards, card)
        end
    end

    -- Update all cards (hand and rewards) in reverse order
    for _, card in ipairs(allCards) do
        card:update(dt)
    end

    -- if lastCardPlayedTime + autoPlaySpeed is less than current time, play a card from the auto play stack
    if self.lastCardPlayedTime + self.autoPlaySpeed < love.timer.getTime() then
        if #self.autoPlayStack > 0 then
            print("Playing card from auto play stack" .. self.autoPlayStack[1].id)
            self.autoPlayStack[1]:setDisabled(false)
            GAME:playCard(table.remove(self.autoPlayStack, 1))
            self.lastCardPlayedTime = love.timer.getTime()
        end
    end

    -- Display the top card of the auto play stack in the middle of ther screen
    if #self.autoPlayStack > 0 then
        self.autoPlayStack[1].x = love.graphics.getWidth() / 2 - 128
        self.autoPlayStack[1].y = love.graphics.getHeight() / 2 - 100
        self.autoPlayStack[1].rotation = 0
        self.autoPlayStack[1]:update(dt)
    end
    
end

function Deck:draw()
    -- Draw pile
    love.graphics.setColor(1, 1, 1)
    local drawPileCount = self.drawPile and #self.drawPile or 0
    local discardPileCount = self.discardPile and #self.discardPile or 0
    local handCount = self.hand and #self.hand or 0
    love.graphics.printf(drawPileCount .. "/" .. discardPileCount + drawPileCount + handCount, self.drawPilePosition.x, self.drawPilePosition.y, self.drawPilePosition.width, "center")

    -- Hand cards
    for i, card in ipairs(self.hand) do
        card:draw()
    end

    -- Auto play stack
    if #self.autoPlayStack > 0 then
        self.autoPlayStack[1]:draw()
    end
end

return Deck