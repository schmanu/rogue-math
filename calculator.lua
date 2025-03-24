local Calculator = {}
Calculator.__index = Calculator

function Calculator.new(x, y, game)
    print("Creating calculator" ..#game.cardLibrary.cardIds)
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
    self.level = 1
    self.gameMode = nil
    self.targetNumber = 0
    self.animationState = {
        active = false,
        currentStep = 0,
        totalSteps = 60,
        result = 0,
        targetReached = false
    }
    self.rewardState = {
        active = false,
        cards = {},
        selectedCard = nil
    }
    self.rewardCards = {
        game.cardLibrary.cardIds.op_div,
        game.cardLibrary.cardIds.op_mul,
        game.cardLibrary.cardIds.num_random,
        game.cardLibrary.cardIds.op_sub,
        game.cardLibrary.cardIds.mod_double,
        game.cardLibrary.cardIds.mod_reverse,
        game.cardLibrary.cardIds.op_exp,
    }
    
    -- Initialize button dimensions
    self.buttonSize = 40
    self.buttonSpacing = 8
    self.buttons = {}
    
    -- Initialize buttons
    self:initializeButtons()
    
    -- Initialize first level without incrementing level number
    self:initializeLevel()
    
    return self
end


function Calculator:update(dt)
    -- Update buttons
    for _, button in ipairs(self.buttons) do
        button:update(dt)
    end
    
    -- Update reward cards if active
    if self.rewardState.active then
        for _, card in ipairs(self.rewardState.cards) do
            card:update(dt)
        end
    end
    
    -- Update animation state
    self:updateAnimation()
end

function Calculator:draw()
    -- Draw calculator background
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    
    -- Draw calculator border
    love.graphics.setColor(0.4, 0.4, 0.4)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    
    -- Draw display
    love.graphics.setColor(0.1, 0.1, 0.1)
    love.graphics.rectangle("fill", self.x + 10, self.y + 10, self.width - 20, 60)
    
    -- Draw display text
    love.graphics.setColor(0, 1, 0)
    love.graphics.printf(self.display == "" and "0" or self.display, 
                        self.x + 20, self.y + 20, self.width - 40, "right")
    
    -- Draw target number and game mode
    love.graphics.setColor(1, 1, 1)
    local modeText = self.gameMode == "hit_target" and "Hit exactly:" or "Reach at least:"
    love.graphics.printf(modeText .. " " .. self.targetNumber, 
                        self.x + 10, self.y + 80, self.width - 20, "center")
    
    -- Draw level and score
    love.graphics.printf("Level: " .. self.level, 
                        self.x + 10, self.y + 100, self.width - 20, "center")
    
    -- Draw buttons
    self:drawButtons()
    
    -- Draw reward cards if active
    if self.rewardState.active then
        self:drawRewardCards()
    end
end

function Calculator:generateRewardCards()
    print("Generating reward cards" .. #self.rewardCards)
    local available = {}
    for _, card in ipairs(self.rewardCards) do
        table.insert(available, card)
    end
    
    -- Shuffle available cards
    for i = #available, 2, -1 do
        local j = math.random(i)
        available[i], available[j] = available[j], available[i]
    end
    
    -- Take first 3 cards
    self.rewardState.cards = {}
    local cardWidth = 120
    local cardHeight = 180
    local spacing = 40
    local startX = (love.graphics.getWidth() - (cardWidth * 3 + spacing * 2)) / 2
    
    for i = 1, 3 do
        local cardId = available[i]
        local card = self.game.cardLibrary:createCard(cardId, startX + (i-1) * (cardWidth + spacing), 200)
        table.insert(self.rewardState.cards, card)
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
    if self.gameMode == "hit_target" then
        targetReached = result == self.targetNumber
    else  -- reach_target mode
        targetReached = result >= self.targetNumber
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
        self:startRewardState()
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
                self:startRewardState()
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

function Calculator:startNextLevel()
    -- Increment level and initialize new level
    self.level = self.level + 1
    self:initializeLevel()
end

function Calculator:reset()
    self.display = ""
    self.currentValue = 0
    self.currentOperation = nil
    self.operatorMode = nil
    self.expectedInputType = "number"
    self.gameState = "playing"
    self.level = 1
    self.gameMode = nil
    self.targetNumber = 0
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
    if not self.rewardState.active then return false end
    
    local cardWidth = 120
    local cardHeight = 180
    local spacing = 40
    local startX = (love.graphics.getWidth() - (cardWidth * 3 + spacing * 2)) / 2
    
    for i, card in ipairs(self.rewardState.cards) do
        local cardX = startX + (i-1) * (cardWidth + spacing)
        local cardY = 200
        
        if x >= cardX and x <= cardX + cardWidth and
           y >= cardY and y <= cardY + cardHeight then
            self.rewardState.selectedCard = card
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

function Calculator:calculateTargetNumber()
    if self.gameMode == "hit_target" then
        -- Mode 1: Random number between 1 and level * 10
        return math.random(2, self.level * 7)
    elseif self.gameMode == "reach_target" then
        -- Mode 2: Fibonacci number
        local fib = 5
        local prev = 3
        for i = 2, self.level do
            local temp = fib
            fib = fib + prev
            prev = temp
        end
        return fib
    end
end

function Calculator:startRewardState()
    self.rewardState.active = true
    self:generateRewardCards()
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

function Calculator:drawButtons()
    -- Implementation of drawButtons function
end

function Calculator:drawRewardCards()
    -- Implementation of drawRewardCards function
    for _, card in ipairs(self.rewardState.cards) do
        card:draw()
    end
end

function Calculator:initializeLevel()
    -- Randomly select game mode
    self.gameMode = math.random() < 0.5 and "hit_target" or "reach_target"
    
    -- Calculate target number based on game mode
    self.targetNumber = self:calculateTargetNumber()
    
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