local Calculator = {}
Calculator.__index = Calculator

function Calculator.new(x, y, game)
    local self = setmetatable({}, Calculator)
    self.game = game  -- Store reference to game object
    self.x = x
    self.y = y
    self.width = 300
    self.height = 400
    self.display = ""
    self.currentValue = 0
    self.currentOperation = nil
    self.operatorMode = nil
    self.expectedInputType = "number"
    self.gameState = "playing"
    self.animationState = {
        active = false,
        currentStep = 0,
        totalSteps = 60,
        result = 0,
        targetReached = false
    }
    
    -- Initialize button dimensions
    self.buttonSize = 40
    self.buttonSpacing = 8
    self.buttons = {}
    
    -- Initialize buttons
    self:initializeButtons()
    
    return self
end

function Calculator:update(dt)
    -- Update buttons
    for _, button in ipairs(self.buttons) do
        button:update(dt)
    end
    
    -- Update animation state
    self:updateAnimation()
end

function Calculator:draw()
    -- Draw display text
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf(self.display == "" and "0" or self.display, 
                        420, 96, 180, "right")
    
    -- Draw target number and game mode
    love.graphics.setColor(1, 1, 1)
    local modeText = self.game.gameMode == "hit_target" and "Hit:" or "Reach:"
    love.graphics.printf(modeText .. " " .. self.game.targetNumber, 
                        32, 128, 316, "left")
    
    -- Draw level
    love.graphics.printf("Level: " .. self.game.level, 
                       32, 128 + 48, 316, "left")
    
    -- Draw reward cards if active
    if self.game.rewardState.active then
        self.game:drawRewardCards()
    end
end

function Calculator:generateRewardCards()
    print("Generating reward cards" .. #self.game.rewardCards)
    local available = {}
    for _, card in ipairs(self.game.rewardCards) do
        table.insert(available, card)
    end
    
    -- Shuffle available cards
    for i = #available, 2, -1 do
        local j = math.random(i)
        available[i], available[j] = available[j], available[i]
    end
    
    -- Take first 3 cards
    self.game.rewardState.cards = {}
    local cardWidth = 120
    local cardHeight = 180
    local spacing = 40
    local startX = (love.graphics.getWidth() - (cardWidth * 3 + spacing * 2)) / 2
    
    for i = 1, 3 do
        local cardId = available[i]
        local card = self.game.cardLibrary:createCard(cardId, startX + (i-1) * (cardWidth + spacing), 200)
        table.insert(self.game.rewardState.cards, card)
    end
end

function Calculator:containsPoint(x, y)
    return x >= self.x and x <= self.x + self.width and
           y >= self.y and y <= self.y + self.height
end

function Calculator:addInput(value)
    if self.gameState == "playing" then
        -- If display is empty, only allow numbers
        if self.display == "" then
            self.display = value
            
        else
            -- Calculate and show intermediary result
            local result = self:calculateResult(tonumber(value))
            self.currentOperation = nil
            self.display = tostring(result)
        end

        self:setExpectedInputType("operator")
    end
end

function Calculator:clear()
    self.display = ""
    self:setExpectedInputType("number")  -- Reset to expect number after clear
end

function Calculator:evaluate()
    if self.display == "" then return end
    
    -- Calculate final result from display
    local result = 0
    local currentNumber = ""
    local currentOperator = nil
    
    result = tonumber(self.display)
    
    -- Check if target is reached based on game mode
    local targetReached = false
    if self.game.gameMode == "hit_target" then
        targetReached = result == self.game.targetNumber
    else  -- reach_target mode
        targetReached = result >= self.game.targetNumber
    end
    
    -- Set up animation state
    self.animationState = {
        active = true,
        currentStep = 0,
        totalSteps = 60,
        result = result,
        targetReached = targetReached
    }
    
    if targetReached then
        -- Level complete
        self.gameState = "levelComplete"
        self.game:startRewardState()
    else
        -- Game over
        self.gameState = "gameOver"
    end
end

function Calculator:setOperatorMode(operation, symbol)
    -- Store the operation function for later use
    self.currentOperation = operation
    -- Add the operator symbol to the display
    if self.display ~= "" then
        self.display = self.display .. symbol
    end

    self:setExpectedInputType("number")
end

function Calculator:calculateResult(value)
    -- Simple evaluation for now
    local result = 0
    local currentNumber = ""
    local currentOperator = self.currentOperation
    
    for i = 1, #self.display do
        local char = self.display:sub(i,i)
        if char:match("%d") then
            currentNumber = currentNumber .. char
        end
    end

    if currentOperator == nil then
        return value
    end
    
    if currentNumber ~= "" then
        result = currentOperator(tonumber(currentNumber), value)
    end
    
    return result
end

function Calculator:updateAnimation()
    if self.animationState.active then
        self.animationState.currentStep = self.animationState.currentStep + 1
        if self.animationState.currentStep >= self.animationState.totalSteps then
            self.animationState.active = false
            if self.animationState.targetReached then
                self.game:startRewardState()
            end
            self.display = ""
        end
    end
end

function Calculator:endTurn()
    if self.gameState == "playing" then
        self:evaluate()
    end
    self.game.canDiscard = true  -- Reset discard ability
end

function Calculator:reset()
    self.display = ""
    self.currentValue = 0
    self.currentOperation = nil
    self.operatorMode = nil
    self.expectedInputType = "number"
    self.gameState = "playing"
    self.animationState.active = false
end

function Calculator:updateHoverState(x, y)
    -- No-op since buttons are visual only
end

function Calculator:handleButtonClick(x, y)
    -- No-op since buttons are visual only
    return false
end

function Calculator:handleRewardClick(x, y)
    if not self.game.rewardState.active then return false end
    
    local cardWidth = 120
    local cardHeight = 180
    local spacing = 40
    local startX = (love.graphics.getWidth() - (cardWidth * 3 + spacing * 2)) / 2
    
    for i, card in ipairs(self.game.rewardState.cards) do
        local cardX = startX + (i-1) * (cardWidth + spacing)
        local cardY = 200
        
        if x >= cardX and x <= cardX + cardWidth and
           y >= cardY and y <= cardY + cardHeight then
            self.game.rewardState.selectedCard = card
            return true
        end
    end
    
    return false
end

function Calculator:setExpectedInputType(type)
    self.expectedInputType = type
end

function Calculator:getExpectedInputType()
    return self.expectedInputType
end

function Calculator:initializeButtons()
    -- Create number buttons (1-9)
    for i = 1, 9 do
        local row = math.ceil(i/3) - 1
        local col = (i-1) % 3
        table.insert(self.buttons, {
            value = tostring(i),
            x = self.x + 20 + col * (self.buttonSize + self.buttonSpacing),
            y = self.y + 150 + row * (self.buttonSize + self.buttonSpacing),
            width = self.buttonSize,
            height = self.buttonSize,
            hovered = false,
            draw = function(self)
                if self.hovered then
                    love.graphics.setColor(0.4, 0.4, 0.4)
                else
                    love.graphics.setColor(0.3, 0.3, 0.3)
                end
                love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
                love.graphics.setColor(1, 1, 1)
                love.graphics.printf(self.value, self.x, self.y + 10, self.width, "center")
            end,
            update = function(self, dt)
                -- No update needed for now
            end
        })
    end
    
    -- Create operator buttons
    local operators = {"+", "-", "×", "÷"}
    for i, op in ipairs(operators) do
        table.insert(self.buttons, {
            value = op,
            x = self.x + 20 + (i-1) * (self.buttonSize + self.buttonSpacing),
            y = self.y + 150 + 3 * (self.buttonSize + self.buttonSpacing),
            width = self.buttonSize,
            height = self.buttonSize,
            hovered = false,
            draw = function(self)
                if self.hovered then
                    love.graphics.setColor(0.4, 0.4, 0.4)
                else
                    love.graphics.setColor(0.3, 0.3, 0.3)
                end
                love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
                love.graphics.setColor(1, 1, 1)
                love.graphics.printf(self.value, self.x, self.y + 10, self.width, "center")
            end,
            update = function(self, dt)
                -- No update needed for now
            end
        })
    end
    
    -- Add clear and equals buttons
    table.insert(self.buttons, {
        value = "C",
        x = self.x + 20,
        y = self.y + 150 + 4 * (self.buttonSize + self.buttonSpacing),
        width = self.buttonSize,
        height = self.buttonSize,
        hovered = false,
        draw = function(self)
            if self.hovered then
                love.graphics.setColor(0.4, 0.4, 0.4)
            else
                love.graphics.setColor(0.3, 0.3, 0.3)
            end
            love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf(self.value, self.x, self.y + 10, self.width, "center")
        end,
        update = function(self, dt)
            -- No update needed for now
        end
    })
    
    table.insert(self.buttons, {
        value = "=",
        x = self.x + 20 + self.buttonSize + self.buttonSpacing,
        y = self.y + 150 + 4 * (self.buttonSize + self.buttonSpacing),
        width = self.buttonSize,
        height = self.buttonSize,
        hovered = false,
        draw = function(self)
            if self.hovered then
                love.graphics.setColor(0.4, 0.4, 0.4)
            else
                love.graphics.setColor(0.3, 0.3, 0.3)
            end
            love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf(self.value, self.x, self.y + 10, self.width, "center")
        end,
        update = function(self, dt)
            -- No update needed for now
        end
    })
end

function Calculator:drawRewardCards()
    -- Implementation of drawRewardCards function
    for _, card in ipairs(self.game.rewardState.cards) do
        print("Drawing reward card " .. card.id)
        card:draw()
    end
end

function Calculator:initializeLevel()
    -- Reset calculator state
    self.display = ""
    self.currentValue = 0
    self.currentOperation = nil
    self.operatorMode = nil
    self.expectedInputType = "number"
    self.gameState = "playing"
    self:setOperatorMode(nil, nil)
end

return Calculator 