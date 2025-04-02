local Grade = require("grade")
local Rewards = require("rewards")
local Tabs = require("tabs")
local Modifiers = require("modifiers")

local Game = {}
Game.__index = Game

function Game.new()
    local self = setmetatable({}, Game)
    self.grade = Grade.new(732, 64)
    self.rewards = Rewards.new()
    self.tabs = Tabs.new(992, 128)
    self.modifiers = {}
    return self
end

function Game:initializeLevel()
    -- Clear previous modifiers
    self.modifiers = {}
    
    -- Check if this is a boss level (every 5th level)
    if GAME.state.level % 5 == 0 then
        -- Select a random modifier
        local modifierKeys = {
            "HitTheNumber",
            "DividableBy",
            "NoDiscards",
            "DecreasedHand",
            "BigNumbers",
            "Wasteful",
            "SignedNumbers"
        }
        local randomModifier = modifierKeys[math.random(#modifierKeys)]
        local modifier = Modifiers[randomModifier].new()

        -- Store the modifier instance
        self.modifiers[modifier.name] = modifier
    end
    
    -- Calculate target number
    GAME.state.targetNumber = self:calculateTargetNumber()
    
    GAME.state.gameState = "playing" -- playing, levelComplete, gameOver
    self.grade:nextRound()
end

function Game:calculateTargetNumber()
    local weekFactor = 2
    local week = math.floor((GAME.state.level - 1) / 5) + 1
    local baseNumber = (10 ^ ((1 + week) / 2)) * weekFactor ^ (week - 1)

    local dayFactor = 1.3

    return math.ceil(baseNumber * ((dayFactor ^ ((GAME.state.level - 1) % 5 + 1))))
end

function Game:calculateGradeDiff(argResult)
    local result = argResult or GAME.calculator:getResult()
    -- Check if target is reached based on game mode
    local targetReached = false
    local health_diff = 0
    targetReached = result >= GAME.state.targetNumber
    if targetReached then
        -- reaching exactly the target gives 1 health
        if result == GAME.state.targetNumber then
                health_diff = 1
        else
            -- for every time the target was overshot, add 1 health
            health_diff = math.floor((result / GAME.state.targetNumber)) - 1
        end


    else
        -- lose lives based on how much percent was reached
        health_diff = math.floor((1 - (result / GAME.state.targetNumber)) * -16)
    end
    return health_diff
end

function Game:calculateGradeProgress(argResult)
    local result = argResult or GAME.calculator:getResult()
    local gradeStepSize = GAME.state.targetNumber / 16
    local currentGrade = math.floor((result / GAME.state.targetNumber) * 16)
    local grade_diff = math.floor((1 - (result / GAME.state.targetNumber)) * -16)

    if self.modifiers["HitTheNumber"] then
        grade_diff = grade_diff * -1
    end

    if (grade_diff < 0) then
        local predictedGrade = GAME.game.grade.grade + grade_diff
        local stepsRequired = 1
        if predictedGrade < 1 then
            stepsRequired = 2 - predictedGrade
            currentGrade = 0
        end

        local previousGradePoints = currentGrade * gradeStepSize
        local progress = (result - previousGradePoints) / (gradeStepSize * stepsRequired)
        return progress
    else
        local overshotBy = result - GAME.state.targetNumber
        local stepSize = GAME.state.targetNumber

        local increase = math.floor(overshotBy / stepSize)
        if GAME.game.grade.grade + increase > 16 then
            return 1
        else
            return (overshotBy % stepSize) / stepSize
        end
    end
end

function Game:onTurnEnd()
    if not GAME.state.gameState == "playing" then return end
    
    -- apply health diff
    local health_diff = self:calculateGradeDiff()
    self.grade:updateGrade(health_diff)

    -- apply potential modifiers
    self:evaluateResult(GAME.calculator:getResult())


    
    if self.grade.grade > 1 then
        -- Level complete
        GAME.state.gameState = "levelComplete"
        GAME.game:startRewardState()
    else
        -- Game over
        GAME.state.gameState = "gameOver"
    end
end

function Game:evaluateResult(result)
    -- Apply all active modifiers
    for _, modifier in pairs(self.modifiers) do
        modifier:evaluate(result)
    end
end

function Game:getActiveModifiers()
    local activeModifiers = {}
    for _, modifier in pairs(self.modifiers) do
        table.insert(activeModifiers, {
            name = modifier.name,
            description = modifier:getDescription(self)
        })
    end
    return activeModifiers
end

function Game:startNextLevel()
    -- Increment level and initialize new level
    GAME.state.level = GAME.state.level + 1
    GAME.state.handSize = 5
    GAME.state.discards = 1
    self:initializeLevel()
end

function Game:startRewardState()
    self.rewards:prepareRewards()
end

function Game:handleRewardClick(x, y)
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

function Game:update(dt)
    self.grade:update(dt)
end

function Game:reset()
    GAME.state.level = 0
    self.targetNumber = 0
    self.rewardState.active = false
    self.rewardState.cards = {}
    self.rewardState.selectedCard = nil
    GAME.state.gameState = "playing"
end

function Game:draw()
    self.grade:draw()

    if GAME.state.gameState == "levelComplete" then
        self.rewards:draw()
    end

    self.tabs:draw()
end

return Game 