local Calculator = {}
Calculator.__index = Calculator

function Calculator.new(x, y)
    local self = setmetatable({}, Calculator)
    self.x = x
    self.y = y
    self.width = 300
    self.height = 400
    self.display = ""
    self.target = 8
    self.level = 1
    self.gameState = "playing"  -- "playing", "success", "failure"
    self.buttonSize = 40
    self.expectedInputType = "number"  -- "number" or "operator"
    self.buttons = {}
    self.animationState = {
        active = false,
        currentStep = 0,
        totalSteps = 30,
        result = 0,
        targetReached = false,
    }
    self.rewardState = {
        active = false,
        cards = {},
        selectedCard = nil
    }
    
    -- Available reward cards
    self.rewardCards = {
        {value = "÷", name = "Division"},
        {value = "x", name = "Multiplication"},
        {value = "rand", name = "Random"},
        {value = "x2", name = "Double"},
    }
    
    -- Initialize buttons
    self:initializeButtons()
    
    -- Start first level
    self:startNextLevel()
    
    return self
end

function Calculator:init(game)
    self.game = game  -- Store reference to game object
    self.x = 100
    self.y = 100
    self.width = 300
    self.height = 400
    self.display = ""
    self.target = 8
    self.level = 1
    self.gameState = "playing"
    self.animationState = {
        active = false,
        currentStep = 0,
        totalSteps = 30,
        result = 0,
        targetReached = false,
    }
    
    -- Reward system
    self.rewardState = {
        active = false,
        cards = {},
        selectedCard = nil
    }
    
    -- Button dimensions and spacing
    self.buttonSize = 40
    self.buttonSpacing = 8
    self.buttons = {}
    
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
            hovered = false
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
            hovered = false
        })
    end
    
    -- Add clear and equals buttons
    table.insert(self.buttons, {
        value = "C",
        x = self.x + 20,
        y = self.y + 150 + 4 * (self.buttonSize + self.buttonSpacing),
        width = self.buttonSize,
        height = self.buttonSize,
        hovered = false
    })
    
    table.insert(self.buttons, {
        value = "=",
        x = self.x + 20 + self.buttonSize + self.buttonSpacing,
        y = self.y + 150 + 4 * (self.buttonSize + self.buttonSpacing),
        width = self.buttonSize,
        height = self.buttonSize,
        hovered = false
    })
    
    -- Create renderer
    local CalculatorRenderer = require("calculator_renderer")
    self.renderer = CalculatorRenderer.new(self)
    
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
    
    -- Draw display
    love.graphics.setColor(0.1, 0.1, 0.1)
    love.graphics.rectangle("fill", self.x + 10, self.y + 10, self.width - 20, 60)
    love.graphics.setColor(0.2, 0.8, 0.2)  -- Terminal green color
    love.graphics.printf(self.display, self.x + 20, self.y + 20, self.width - 40, "right")
    
    -- Draw target (moved outside display)
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.printf("Target: " .. self.target, self.x + 20, self.y + 80, self.width - 40, "left")
    
    -- Draw level (moved outside display)
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.printf("Level " .. self.level, self.x + 20, self.y + 100, self.width - 40, "left")
    
    -- Draw expected input type (moved outside display)
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.printf("Expecting: " .. self.expectedInputType, self.x + 20, self.y + 120, self.width - 40, "left")
    
    -- Draw end of round text
    if self.gameState == "levelComplete" then
        love.graphics.setColor(0.2, 0.8, 0.2)  -- Green for success
        love.graphics.printf("Level Complete! Score: " .. self.animationState.result, 
            self.x + 20, self.y + 140, self.width - 40, "center")
    elseif self.gameState == "gameOver" then
        love.graphics.setColor(0.8, 0.2, 0.2)  -- Red for failure
        love.graphics.printf("Game Over! Final Score: " .. self.animationState.result, 
            self.x + 20, self.y + 140, self.width - 40, "center")
    end
    
    -- Draw buttons
    for _, button in ipairs(self.buttons) do
        button:draw()
    end
    
    -- Draw reward cards if active
    if self.rewardState.active then
        for _, card in ipairs(self.rewardState.cards) do
            card:draw()
        end
    end
end

function Calculator:generateRewardCards()
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
        local card = available[i]
        table.insert(self.rewardState.cards, {
            value = card.value,
            name = card.name,
            x = startX + (i-1) * (cardWidth + spacing),
            y = 200,
            width = cardWidth,
            height = cardHeight,
            draw = function(self)
                -- Draw card background
                love.graphics.setColor(0.3, 0.3, 0.3)
                love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
                
                -- Draw card border
                love.graphics.setColor(0.8, 0.8, 0.8)
                love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
                
                -- Draw card value
                love.graphics.setColor(1, 1, 1)
                love.graphics.printf(self.value, self.x, self.y + 20, self.width, "center")
                
                -- Draw card name
                love.graphics.setColor(0.8, 0.8, 0.8)
                love.graphics.printf(self.name, self.x, self.y + 60, self.width, "center")
            end,
            update = function(self, dt)
                -- No update needed for now
            end
        })
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
            self.currentOperator = nil
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
    if self.gameState == "playing" then
        local currentNumber = "0"
        
        for i = 1, #self.display do
            local char = self.display:sub(i,i)
            if char:match("%d") then
                currentNumber = currentNumber .. char
            end
        end
        local result = tonumber(currentNumber)

        print("End of turn: " .. result)

        self.animationState = {
            active = true,
            currentStep = 0,
            totalSteps = 30,
            result = result,
            targetReached = result >= self.target,
        }
        self:setExpectedInputType("number")
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
                self.level = self.level + 1
                self.target = self.target * 2
                self.gameState = "levelComplete"
                self:generateRewardCards()
                self.rewardState.active = true
            else
                self.gameState = "gameOver"
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
    self.gameState = "playing"
    self.display = ""
end

function Calculator:reset()
    self.display = ""
    self.target = 8
    self.level = 1
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


function Calculator:initializeButtons()
    -- Button dimensions and spacing
    self.buttonSpacing = 8
    
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

return Calculator 