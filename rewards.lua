-- imports
local Assets = require("assets")
local ModuleLibrary = require("modules/module_library")
local CardLibrary = require("cards/card_library")

local Rewards = {}
Rewards.__index = Rewards

function Rewards.new()
    local self = setmetatable({}, Rewards)

    self.moduleLibrary = ModuleLibrary.new()
    self.cardLibrary = CardLibrary.new()
    self.rewardState = {
        active = false,
        cards = {},
        modules = {},
        selectedCard = nil,
        rewardType = nil,
    }

    self.rewardCards = {
        "op_div",
        "op_mul",
        "num_random",
        "op_sub",
        "mod_double",
        "mod_reverse",
        "op_exp",
        "mod_prime",
        "sp_draw3"
    }

    self.rewardModules = {
        "infinity",
    }

    return self
end

function Rewards:prepareRewards()
    -- flip a coin to determine if we are using cards or modules
    local coin = math.random(2)
    if coin == 1 then
        self.rewardState.rewardType = "cards"
        self:generateRewardCards()
    else
        self.rewardState.rewardType = "modules"
        self:generateRewardModules()
    end

    self.rewardState.active = true

end

function Rewards:generateRewardCards()
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
        local card = self.cardLibrary:createCard(cardId, startX + (i-1) * (cardWidth + spacing), 264)
        table.insert(self.rewardState.cards, card)
    end
end

function Rewards:generateRewardModules()
    local available = {}
    for _, module in ipairs(self.rewardModules) do
        table.insert(available, module)
    end

    -- Shuffle available modules    
    for i = #available, 2, -1 do
        local j = math.random(i)
        available[i], available[j] = available[j], available[i]
    end 

    -- Take first module
    self.rewardState.modules = {}
    local moduleWidth = 68
    local moduleHeight = 64
    local spacing = 40
    local startX = (love.graphics.getWidth() - (moduleWidth + spacing * 2)) / 2
    
    local moduleId = available[1]
    local module = self.moduleLibrary:createModule(moduleId, startX, 264)
    table.insert(self.rewardState.modules, module)

end

function Rewards:draw()
    love.graphics.setColor(0, 0, 0, 0.9)
    love.graphics.rectangle("fill", 32, 200 - 16, love.graphics.getWidth() - 64, 480)
    love.graphics.setColor(1, 1, 1)
    if self.rewardState.rewardType == "cards" then
        love.graphics.printf("Choose a card", 0, 200, love.graphics.getWidth(), "center")
        for _, card in ipairs(self.rewardState.cards) do
            card:draw()
        end
    elseif self.rewardState.rewardType == "modules" then
        love.graphics.printf("Choose a module", 0, 200, love.graphics.getWidth(), "center")
        for _, module in ipairs(self.rewardState.modules) do
            module:draw()
        end
    end
end


function Rewards:handleRewardClick(x, y)
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

return Rewards