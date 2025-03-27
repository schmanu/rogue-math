local Assets = require("assets")

local Calculator = {}
Calculator.__index = Calculator

function Calculator.new(x, y, game)
    local self = setmetatable({}, Calculator)
    self.game = game  -- Store reference to game object
    self.x = x
    self.y = y
    self.width = 240
    self.height = 296
    self.display = ""
    self.currentValue = 0
    self.currentOperation = nil
    self.operatorMode = nil
    self.flipped = false
    self.expectedInputType = "number"
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
end

function Calculator:draw()

    -- Draw calculator sprite
    if self.flipped then
        love.graphics.draw(Assets.calculatorSprites.back, self.x, self.y, 0)
        -- Draw modules
        love.graphics.draw(Assets.calculatorSprites.modules.empty, self.x + 40, self.y + 48, 0)
        love.graphics.draw(Assets.calculatorSprites.modules.empty, self.x + 132, self.y + 120, 0)

    else
        love.graphics.draw(Assets.calculatorSprites.front, self.x, self.y, 0)
    end
    -- Draw flip button right of it
    love.graphics.draw(Assets.calculatorSprites.button_flip, self.x + 256, self.y, 0)

    -- Draw display text
    if (not self.flipped) then
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf(self.display == "" and "0" or self.display, 
                            420, 96, 180, "right")
    end
    
    -- Draw target number and game mode
    love.graphics.setColor(1, 1, 1)
    local modeText = self.game.gameMode == "hit_target" and "Hit:" or "Reach:"
    love.graphics.printf(modeText .. " " .. self.game.targetNumber, 
                        32, 128, 316, "left")
    
    -- Draw level
    love.graphics.printf("Days:", 
                       32, 128 + 48, 316, "left")
    -- draw level as stripes with every fifth being diagonal
    local diagonal_overlap = 4
    for i = 1, self.game.level do
        if i % 5 == 0 then
            love.graphics.line(32 + (i-1) * 12 - 48 - diagonal_overlap, 128 + 80, 32 + (i-2) * 12 + diagonal_overlap, 128 + 80 + 16)
        else
            love.graphics.rectangle("fill", 32 + (i-1) * 12, 128 + 80, 2, 16)
        end
    end
end

function Calculator:containsPoint(x, y)
    return x >= self.x and x <= self.x + self.width and
           y >= self.y and y <= self.y + self.height
end

function Calculator:flipButtonContainsPoint(x, y)
    return x >= self.x + 256 and x <= self.x + 256 + 64 and
           y >= self.y and y <= self.y + 64
end

function Calculator:flip()
    self.flipped = not self.flipped
end

function Calculator:addInput(value)
    if self.game.gameState == "playing" then
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
    local health_diff = 0
    if self.game.gameMode == "hit_target" then
        targetReached = result == self.game.targetNumber
        health_diff = -1 * math.abs(result - self.game.targetNumber)
        -- hitting exactly the target gives 1 health
        if health_diff == 0 then
            health_diff = 1
        end
    else  -- reach_target mode
        targetReached = result >= self.game.targetNumber
        if targetReached then
            -- reaching exactly the target gives 1 health
            if result == self.game.targetNumber then
                health_diff = 1
            else
            -- when overshooting one health per times overshot
                health_diff = math.floor(result / self.game.targetNumber) - 1
            end
        else
            -- lose lives based on how much percent was reached
            health_diff = math.floor((1 - (result / self.game.targetNumber)) * -13)
        end
    end

    -- apply health diff
    self.game.grade:update(health_diff)
    
    -- Set up animation state
    self.animationState = {
        active = true,
        currentStep = 0,
        totalSteps = 60,
        result = result,
        targetReached = targetReached
    }
    
    if self.game.grade.grade > 1 then
        -- Level complete
        self.game.gameState = "levelComplete"
        self.game:startRewardState()
    else
        -- Game over
        self.game.gameState = "gameOver"
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

function Calculator:endTurn()
    if self.game.gameState == "playing" then
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
    self.game.gameState = "playing"
    self.animationState.active = false
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

function Calculator:initializeLevel()
    -- Reset calculator state
    self.display = ""
    self.currentValue = 0
    self.currentOperation = nil
    self.operatorMode = nil
    self.expectedInputType = "number"
    self.game.gameState = "playing"
    self:setOperatorMode(nil, nil)
end

return Calculator 