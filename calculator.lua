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

    self.modules = {
        slot1 = nil,
        slot2 = nil,
    }
    
    -- Initialize button dimensions
    self.buttonSize = 40
    self.buttonSpacing = 8

    self.slots = {
        slot1 = {
            x = self.x + 40,
            y = self.y + 48,
        },
        slot2 = {
            x = self.x + 132,
            y = self.y + 120,
        },
    }
    
    return self
end

function Calculator:onCardPlayed()
    -- trigger onCardPlayed on all modules
    if self.modules.slot1 then
        self.modules.slot1:onCardPlayed()
    end
    if self.modules.slot2 then
        self.modules.slot2:onCardPlayed()
    end
end

function Calculator:draw()

    -- Draw calculator sprite
    if self.flipped then
        love.graphics.draw(Assets.calculatorSprites.back, self.x, self.y, 0)
        -- Draw modules
        if self.modules.slot1 then
            self.modules.slot1:draw()
        else
            love.graphics.draw(Assets.calculatorSprites.modules.empty, self.slots.slot1.x, self.slots.slot1.y, 0)
        end

        if self.modules.slot2 then
            self.modules.slot2:draw()
        else
            love.graphics.draw(Assets.calculatorSprites.modules.empty, self.slots.slot2.x, self.slots.slot2.y, 0)
        end
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

function Calculator:installModule(module, x, y)
    -- Check closer to which slot it was dropped
    local module_center_x = module.x + module.width/2
    local module_center_y = module.y + module.height/2

    local slot1_distance = math.sqrt((module_center_x - (self.slots.slot1.x + module.width / 2))^2 + (module_center_y - (self.slots.slot1.y + module.height / 2))^2)
    local slot2_distance = math.sqrt((module_center_x - (self.slots.slot2.x + module.width / 2))^2 + (module_center_y - (self.slots.slot2.y + module.height / 2))^2)
    
    if slot1_distance < slot2_distance then
        print("Installing module in slot 1")
        self.modules.slot1 = module
        module.x = self.slots.slot1.x
        module.y = self.slots.slot1.y
    else
        print("Installing module in slot 2")
        self.modules.slot2 = module
        module.x = self.slots.slot2.x
        module.y = self.slots.slot2.y
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
        local result = 0
        -- If display is empty, only allow numbers
        if self.display == "" then
            result = tonumber(value)
        else
            -- Calculate and show intermediary result
            result = self:calculateResult(tonumber(value))
            self.currentOperation = nil
        end

        -- format display such that it fits (8 characters to fit the next operator)
        local display_length = 8
        local formatted_result =tostring(result)
        if #formatted_result > display_length then
            self.display = string.format("%.4g", result)
        else
            self.display = formatted_result
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
    self.game.gameState = "playing"
    self.currentValue = 0
    self.currentOperation = nil
    self.operatorMode = nil
    self.expectedInputType = "number"
    self.animationState.active = false
end

function Calculator:setExpectedInputType(type)
    self.expectedInputType = type
end

function Calculator:getExpectedInputType()
    return self.expectedInputType
end

function Calculator:initializeLevel()
    -- Reset calculator state
    self.display = ""
    self.currentValue = 0
    self.currentOperation = nil
    self.operatorMode = nil
    self.expectedInputType = "number"
    self:setOperatorMode(nil, nil)
end

return Calculator 