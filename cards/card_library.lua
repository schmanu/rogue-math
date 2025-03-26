local NumberCard = require("cards/number_card")
local OperatorCard = require("cards/operator_card")
local DoubleCard = require("cards/double_card")
local RandomCard = require("cards/random_card")
local ReverseCard = require("cards/reverse_card")
local PrimeCard = require("cards/prime_card")

local CardLibrary = {}
CardLibrary.__index = CardLibrary

function CardLibrary.new()
    local self = setmetatable({}, CardLibrary)
    self.cardIds = {
        num_0 = "num_0",
        num_1 = "num_1",
        num_2 = "num_2",
        num_3 = "num_3",
        num_4 = "num_4",
        num_5 = "num_5",
        num_6 = "num_6",
        num_7 = "num_7",
        num_8 = "num_8",
        num_9 = "num_9",
        num_random = "num_random",
        op_add = "op_add",
        op_sub = "op_sub",
        op_mul = "op_mul",
        op_div = "op_div",
        op_exp = "op_exp",
        mod_reverse = "mod_reverse",
        mod_double = "mod_double",
        mod_prime = "mod_prime",
    }
    self.initialCardIds = {
        self.cardIds.num_0, 
        self.cardIds.num_1, 
        self.cardIds.num_2, 
        self.cardIds.num_3, 
        self.cardIds.num_4, 
        self.cardIds.num_5, 
        self.cardIds.num_6, 
        self.cardIds.num_7, 
        self.cardIds.num_8, 
        self.cardIds.num_9, 
        self.cardIds.op_add, 
        self.cardIds.op_add,
        self.cardIds.mod_prime,
    }

    return self
end

function CardLibrary:createCard(cardId, x, y) 
    if cardId == self.cardIds.num_0 then
        return NumberCard.new(cardId, "0", x, y)
    elseif cardId == self.cardIds.num_1 then
        return NumberCard.new(cardId, "1", x, y)
    elseif cardId == self.cardIds.num_2 then
        return NumberCard.new(cardId, "2", x, y)
    elseif cardId == self.cardIds.num_3 then
        return NumberCard.new(cardId, "3", x, y)
    elseif cardId == self.cardIds.num_4 then
        return NumberCard.new(cardId, "4", x, y)
    elseif cardId == self.cardIds.num_5 then
        return NumberCard.new(cardId, "5", x, y)
    elseif cardId == self.cardIds.num_6 then
        return NumberCard.new(cardId, "6", x, y)
    elseif cardId == self.cardIds.num_7 then
        return NumberCard.new(cardId, "7", x, y)
    elseif cardId == self.cardIds.num_8 then
        return NumberCard.new(cardId, "8", x, y)
    elseif cardId == self.cardIds.num_9 then
        return NumberCard.new(cardId, "9", x, y)
    elseif cardId == self.cardIds.num_random then
        return RandomCard.new(cardId, x, y)
    elseif cardId == self.cardIds.op_add then
        return OperatorCard.new(cardId, "+", x, y)
    elseif cardId == self.cardIds.op_sub then
        return OperatorCard.new(cardId, "-", x, y)
    elseif cardId == self.cardIds.op_mul then
        return OperatorCard.new(cardId, "x", x, y)
    elseif cardId == self.cardIds.op_div then
        return OperatorCard.new(cardId, "/", x, y)
    elseif cardId == self.cardIds.op_exp then
        return OperatorCard.new(cardId, "^", x, y)
    elseif cardId == self.cardIds.mod_reverse then
        return ReverseCard.new(cardId, x, y)
    elseif cardId == self.cardIds.mod_double then
        return DoubleCard.new(cardId, x, y)
    elseif cardId == self.cardIds.mod_prime then
        return PrimeCard.new(cardId, x, y)
    end
end

return CardLibrary