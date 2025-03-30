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


    local activeModifiers = self.game:getActiveModifiers()
    
    -- Draw "Exam Day" label
    if GAME.state.level % 5 == 0 then
        love.graphics.setColor(1, 0.8, 0)  -- Gold color for exam day
        love.graphics.printf("Exam Day:", 32, 128 - 56, 316, "left")
    end
    
    -- Draw each modifier
    for _, modifier in ipairs(activeModifiers) do
        love.graphics.setColor(1, 0, 0.3)
        love.graphics.printf(modifier.name, 32, 128 - 32, 316, "left")
    end


    -- Draw target number (not affected by rotation)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Reach: " .. GAME.state.targetNumber, 
                        32, 128, 316, "left")
    
    -- Draw level (not affected by rotation)
    love.graphics.printf("Days:", 
                       32, 128 + 48, 316, "left")
    -- draw level as stripes with every fifth being diagonal
    local diagonal_overlap = 4
    for i = 1, GAME.state.level do
        if i % 5 == 0 then
            love.graphics.line(32 + (i-1) * 12 - 48 - diagonal_overlap, 128 + 80, 32 + (i-2) * 12 + diagonal_overlap, 128 + 80 + 16)
        else
            love.graphics.rectangle("fill", 32 + (i-1) * 12, 128 + 80, 2, 16)
        end
    end

    -- Draw modifier tooltips if hovering
    if next(self.game.modifiers) then
        local activeModifiers = self.game:getActiveModifiers()
        local y = 128 - 56
        local x = 32
        
        -- Check if mouse is over modifier area
        local mx, my = love.mouse.getPosition()
        if my >= y and my <= y + 32 then
            for _, modifier in ipairs(activeModifiers) do
                local modifierWidth = love.graphics.getFont():getWidth(modifier.name)
                if mx >= x and mx <= x + modifierWidth then
                    -- Draw tooltip
                    love.graphics.setColor(0, 0, 0, 0.8)
                    local padding = 16
                    local tooltipWidth = love.graphics.getFont():getWidth(modifier.description) + padding * 2
                    local tooltipHeight = love.graphics.getFont():getHeight() + padding * 2
                    
                    local tooltipX = x
                    local tooltipY = y + 25
                    
                    -- Adjust position if tooltip would go off screen
                    if tooltipX + tooltipWidth > love.graphics.getWidth() then
                        tooltipX = love.graphics.getWidth() - tooltipWidth
                    end
                    
                    love.graphics.rectangle("fill", tooltipX, tooltipY, tooltipWidth, tooltipHeight)
                    love.graphics.setColor(1, 1, 1)
                    love.graphics.print(modifier.description, tooltipX + padding, tooltipY + padding)
                    break
                end
                x = x + 120
            end
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
    if GAME.state.gameState == "playing" then
        local result = 0
        -- If display is empty, only allow numbers
        if self.display == "" then
            result = value
        else
            -- Calculate and show intermediary result
            result = self:calculateResult(value)
            self.currentOperation = nil
        end

        self.currentValue = result

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

function Calculator:getResult()
    -- Calculate final result from display
    local result = 0
    local currentNumber = ""
    local currentOperator = nil
    
    result = self.currentValue

    return result
 
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
    local currentOperator = self.currentOperation

    if currentOperator == nil then
        return self.currentValue
    end
    
    result = currentOperator(self.currentValue, value)
    
    return result
end

function Calculator:reset()
    self.display = ""
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