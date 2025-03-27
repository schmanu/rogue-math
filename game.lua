local Grade = require("grade")
local Rewards = require("rewards")
local Tabs = require("tabs")

local Game = {}
Game.__index = Game

function Game.new()
    local self = setmetatable({}, Game)
    self.level = 1
    self.gameMode = nil
    self.grade = Grade.new(832, 64)
    self.targetNumber = 0
    self.discards = 1
    self.gameState = "playing"
    self.rewards = Rewards.new()
    self.tabs = Tabs.new(992, 480)
    return self
end

function Game:initializeLevel()
    -- Randomly select game mode
    self.gameMode = math.random() < 0.5 and "hit_target" or "reach_target"
    
    -- Calculate target number based on game mode
    self.targetNumber = self:calculateTargetNumber()

    if (self.gameMode == "hit_target") then
        self.discards = 2
    else
        self.discards = 1
    end
end

function Game:startNextLevel()
    -- Increment level and initialize new level
    self.level = self.level + 1
    self:initializeLevel()

end

function Game:calculateTargetNumber()
    if self.gameMode == "hit_target" then
        -- Mode 1: Random number between 1 and level * 8
        return math.random(1, self.level * 8)
    elseif self.gameMode == "reach_target" then
        -- Mode 2: Fibonacci number
        local fib = 5
        local prev = 3
        for i = 1, self.level do
            local temp = fib
            fib = fib + prev
            prev = temp
        end
        return fib
    end
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

function Game:reset()
    self.level = 1
    self.gameMode = nil
    self.targetNumber = 0
    self.rewardState.active = false
    self.rewardState.cards = {}
    self.rewardState.selectedCard = nil
end

function Game:draw()
    self.grade:draw()

    if self.gameState == "levelComplete" then
        self.rewards:draw()
    end

    self.tabs:draw()
end

return Game 