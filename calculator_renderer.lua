local CalculatorRenderer = {}
CalculatorRenderer.__index = CalculatorRenderer

function CalculatorRenderer.new(calculator)
    local self = setmetatable({}, CalculatorRenderer)
    self.calculator = calculator
    return self
end

function CalculatorRenderer:draw()
    if self.calculator.rewardState.active then
        self:drawRewardScreen()
        return
    end
    
    self:drawCalculator()
end

function CalculatorRenderer:drawCalculator()
    -- Draw calculator background
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", self.calculator.x, self.calculator.y, self.calculator.width, self.calculator.height)
    
    -- Draw calculator border
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.rectangle("line", self.calculator.x, self.calculator.y, self.calculator.width, self.calculator.height)
    
    -- Draw display background
    love.graphics.setColor(0.1, 0.1, 0.1)
    love.graphics.rectangle("fill", self.calculator.x + 10, self.calculator.y + 10, self.calculator.width - 20, 60)
    
    -- Draw display border
    love.graphics.setColor(0.4, 0.4, 0.4)
    love.graphics.rectangle("line", self.calculator.x + 10, self.calculator.y + 10, self.calculator.width - 20, 60)
    
    -- Draw display text
    self:drawDisplay()
    
    -- Draw level and target
    self:drawLevelInfo()
    
    -- Draw buttons
    self:drawButtons()
end

function CalculatorRenderer:drawDisplay()
    love.graphics.setColor(0, 1, 0)
    if self.calculator.animationState.active then
        self:drawAnimationDisplay()
    else
        self:drawGameStateDisplay()
    end
end

function CalculatorRenderer:drawAnimationDisplay()
    if self.calculator.animationState.currentStep < self.calculator.animationState.totalSteps then
        -- Draw counting animation
        local currentValue = math.floor(self.calculator.animationState.result * 
            (self.calculator.animationState.currentStep / self.calculator.animationState.totalSteps))
        love.graphics.printf(currentValue, self.calculator.x + 20, self.calculator.y + 30, 
            self.calculator.width - 40, "right")
    else
        -- Draw result message
        if self.calculator.animationState.targetReached then
            love.graphics.setColor(0, 1, 0)
            love.graphics.printf("Target Reached!", self.calculator.x + 20, self.calculator.y + 20, 
                self.calculator.width - 40, "center")
        else
            love.graphics.setColor(1, 0, 0)
            love.graphics.printf("Try Again!", self.calculator.x + 20, self.calculator.y + 30, 
                self.calculator.width - 40, "center")
        end
    end
end

function CalculatorRenderer:drawGameStateDisplay()
    if self.calculator.gameState == "gameOver" then
        self:drawGameOverDisplay()
    elseif self.calculator.gameState == "levelComplete" then
        self:drawLevelCompleteDisplay()
    else
        love.graphics.printf(self.calculator.display, self.calculator.x + 20, self.calculator.y + 30, 
            self.calculator.width - 40, "right")
    end
end

function CalculatorRenderer:drawGameOverDisplay()
    love.graphics.setColor(1, 0, 0)
    love.graphics.printf("GAME OVER", self.calculator.x + 20, self.calculator.y + 20, 
        self.calculator.width - 40, "center")
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.printf("Result: " .. self.calculator.animationState.result, 
        self.calculator.x + 20, self.calculator.y + 40, self.calculator.width - 40, "center")
    love.graphics.printf("Press R to Restart", self.calculator.x + 20, self.calculator.y + 60, 
        self.calculator.width - 40, "center")
end

function CalculatorRenderer:drawLevelCompleteDisplay()
    love.graphics.setColor(0, 1, 0)
    love.graphics.printf("LEVEL " .. self.calculator.level .. " COMPLETE!", 
        self.calculator.x + 20, self.calculator.y + 20, self.calculator.width - 40, "center")
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.printf("Result: " .. self.calculator.animationState.result, 
        self.calculator.x + 20, self.calculator.y + 40, self.calculator.width - 40, "center")
    love.graphics.printf("Press SPACE to Continue", self.calculator.x + 20, self.calculator.y + 60, 
        self.calculator.width - 40, "center")
end

function CalculatorRenderer:drawLevelInfo()
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.printf("Level " .. self.calculator.level, 
        self.calculator.x + self.calculator.width + 20, self.calculator.y + 20, 100, "left")
    love.graphics.printf("Target: " .. self.calculator.target, 
        self.calculator.x + self.calculator.width + 20, self.calculator.y + 40, 100, "left")
end

function CalculatorRenderer:drawButtons()
    for _, button in ipairs(self.calculator.buttons) do
        -- Draw button shadow
        love.graphics.setColor(0, 0, 0, 0.3)
        love.graphics.rectangle("fill", button.x + 2, button.y + 2, button.width, button.height)
        
        -- Draw button background
        love.graphics.setColor(0.3, 0.3, 0.3)
        love.graphics.rectangle("fill", button.x, button.y, button.width, button.height)
        
        -- Draw button border
        love.graphics.setColor(0.6, 0.6, 0.6)
        love.graphics.rectangle("line", button.x, button.y, button.width, button.height)
        
        -- Draw button text
        love.graphics.setColor(0.8, 0.8, 0.8)
        love.graphics.printf(button.value, button.x, button.y + button.height/2 - 10, button.width, "center")
    end
end

function CalculatorRenderer:drawRewardScreen()
    -- Draw full screen background
    love.graphics.setColor(0.1, 0.1, 0.1)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    -- Draw title
    love.graphics.setColor(0, 1, 0)
    love.graphics.printf("LEVEL " .. self.calculator.level .. " COMPLETE!", 
        0, 50, love.graphics.getWidth(), "center")
    
    -- Draw result
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.printf("Result: " .. self.calculator.animationState.result, 
        0, 100, love.graphics.getWidth(), "center")
    
    -- Draw reward cards
    self:drawRewardCards()
    
    -- Draw instruction
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.printf("Click a card to select your reward", 
        0, 400, love.graphics.getWidth(), "center")
end

function CalculatorRenderer:drawRewardCards()
    local cardWidth = 120
    local cardHeight = 180
    local spacing = 40
    local startX = (love.graphics.getWidth() - (cardWidth * 3 + spacing * 2)) / 2
    
    for i, card in ipairs(self.calculator.rewardState.cards) do
        local x = startX + (i-1) * (cardWidth + spacing)
        local y = 200
        
        -- Draw card shadow
        love.graphics.setColor(0, 0, 0, 0.3)
        love.graphics.rectangle("fill", x + 4, y + 4, cardWidth, cardHeight)
        
        -- Draw card background
        if card == self.calculator.rewardState.selectedCard then
            love.graphics.setColor(0.3, 0.8, 0.3)
        else
            love.graphics.setColor(0.2, 0.2, 0.2)
        end
        love.graphics.rectangle("fill", x, y, cardWidth, cardHeight)
        
        -- Draw card border
        love.graphics.setColor(0.8, 0.8, 0.8)
        love.graphics.rectangle("line", x, y, cardWidth, cardHeight)
        
        -- Draw card value
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(card.value, x, y + 20, cardWidth, "center")
        
        -- Draw card type (smaller and more compact)
        local cardType = (card.value:match("%d") or card.value == "rand") and "NUM" or "OP"
        love.graphics.setColor(0.8, 0.8, 0.8)
        love.graphics.printf(cardType, x, y + 50, cardWidth, "center")
        
        -- Draw card name
        love.graphics.setColor(0.8, 0.8, 0.8)
        love.graphics.printf(card.name, x, y + 90, cardWidth, "center")
    end
end

return CalculatorRenderer 