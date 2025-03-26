local Game = {}
Game.__index = Game

function Game.new()
    local self = setmetatable({}, Game)
    self.level = 1
    self.gameMode = nil
    self.targetNumber = 0
    self.rewardState = {
        active = false,
        cards = {},
        selectedCard = nil
    }
    self.rewardCards = {
        "op_div",
        "op_mul",
        "num_random",
        "op_sub",
        "mod_double",
        "mod_reverse",
        "op_exp",
        "mod_prime"
    }
    return self
end

function Game:initializeLevel()
    -- Randomly select game mode
    self.gameMode = math.random() < 0.5 and "hit_target" or "reach_target"
    
    -- Calculate target number based on game mode
    self.targetNumber = self:calculateTargetNumber()
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
    self.rewardState.active = true
    self:generateRewardCards()
end

function Game:generateRewardCards()
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
        local card = self.cardLibrary:createCard(cardId, startX + (i-1) * (cardWidth + spacing), 200)
        table.insert(self.rewardState.cards, card)
    end
end

function Game:drawRewardCards()
    for _, card in ipairs(self.rewardState.cards) do
        card:draw()
    end
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

return Game 