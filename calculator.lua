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
    -- Add rotation state
    self.rotationState = {
        currentRotation = 0,
        targetRotation = 0,
        animating = false,
        duration = 0.5,  -- 1 second animation
        elapsed = 0
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

function Calculator:onCardPlayed(card)
    -- trigger onCardPlayed on all modules
    if self.modules.slot1 then
        self.modules.slot1:onCardPlayed(card)
    end
    if self.modules.slot2 then
        self.modules.slot2:onCardPlayed(card)
    end
end

function Calculator:draw()
    -- Save the current graphics state
    love.graphics.push()
    
    -- Move to calculator center for scaling
    love.graphics.translate(self.x + self.width/2, self.y + self.height/2)
    -- Scale width based on rotation to create flip effect
    local scale = math.abs(math.cos(self.rotationState.currentRotation))
    love.graphics.scale(scale, 1)
    -- Move back
    love.graphics.translate(-(self.x + self.width/2), -(self.y + self.height/2))
    
    -- Draw calculator sprite based on animation progress
    local sprite = self.flipped and Assets.calculatorSprites.back or Assets.calculatorSprites.front
    love.graphics.draw(sprite, self.x, self.y, 0)

    if (self.flipped) then
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
    end

    -- Draw display text
    if (not self.flipped) then
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf(self.display == "" and "0" or self.display, 
                            420, 96, 180, "right")
    end

    
    -- Restore the graphics state
    love.graphics.pop()

    
    -- Draw flip button right of it (not affected by rotation)
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(Assets.calculatorSprites.button_flip, self.x + 256, self.y, 0)


    
    -- Draw target number and game mode (not affected by rotation)
    love.graphics.setColor(1, 1, 1)
    local modeText = self.game.gameMode == "hit_target" and "Hit:" or "Reach:"
    love.graphics.printf(modeText .. " " .. self.game.targetNumber, 
                        32, 128, 316, "left")
    
    -- Draw level (not affected by rotation)
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
        self.modules.slot1 = module
        module.x = self.slots.slot1.x
        module.y = self.slots.slot1.y
    else
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
    -- Start rotation animation
    self.rotationState.animating = true
    self.rotationState.elapsed = 0
    
    -- Toggle between 0 and pi based on current rotation
    if self.flipped then
        self.rotationState.targetRotation = 0
    else
        self.rotationState.targetRotation = math.pi
    end
end

function Calculator:update(dt)
    -- Update rotation animation
    if self.rotationState.animating then
        self.rotationState.elapsed = self.rotationState.elapsed + dt
        local progress = self.rotationState.elapsed / self.rotationState.duration
        
        if progress >= 1 then
            self.rotationState.currentRotation = self.rotationState.targetRotation
            self.rotationState.animating = false

        else
            -- Use smooth easing function
            progress = 1 - math.cos(progress * math.pi / 2)  -- Ease out
            
            -- Interpolate between current and target rotation
            local startRotation = self.rotationState.targetRotation == 0 and math.pi or 0
            self.rotationState.currentRotation = startRotation + (self.rotationState.targetRotation - startRotation) * progress
            
            -- Set flipped state based on which direction we're rotating
            if progress >= 0.5 then
                self.flipped = (self.rotationState.targetRotation == math.pi)
            end
        end
    end
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