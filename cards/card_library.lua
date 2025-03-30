local NumberCard = require("cards/number_card")
local OperatorCard = require("cards/operator_card")
local DoubleCard = require("cards/double_card")
local RandomCard = require("cards/random_card")
local ReverseCard = require("cards/reverse_card")
local PrimeCard = require("cards/prime_card")
local Draw3Card = require("cards/draw3_card")
local InverseCard = require("cards/inverse_card")
local PowerOf2Card = require("cards/pow2_card")
local PlusOneCard = require("cards/operator_plus1")
local CardLibrary = {}
CardLibrary.__index = CardLibrary

function CardLibrary.new()
    local self = setmetatable({}, CardLibrary)
    self.cardIds = {
        num_0 = "num_0",
        num_0001 = "num_0001",
        num_1 = "num_1",
        num_2 = "num_2",
        num_3 = "num_3",
        num_4 = "num_4",
        num_5 = "num_5",
        num_6 = "num_6",
        num_7 = "num_7",
        num_8 = "num_8",
        num_9 = "num_9",
        num_100 = "num_100",
        num_random = "num_random",
        num_pow2 = "num_pow2",
        op_add = "op_add",
        op_sub = "op_sub",
        op_mul = "op_mul",
        op_div = "op_div",
        op_exp = "op_exp",
        op_concat = "op_concat",
        op_plus1 = "op_plus1",
        mod_reverse = "mod_reverse",
        mod_double = "mod_double",
        mod_prime = "mod_prime",
        mod_inverse = "mod_inverse",
        sp_draw3 = "sp_draw3",
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
        self.cardIds.op_sub,
    }

    return self
end

function CardLibrary:createCard(cardId, x, y) 
    -- numbers
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
    elseif cardId == self.cardIds.num_0001 then
        return NumberCard.new(cardId, "0.001", x, y)
    elseif cardId == self.cardIds.num_100 then
        return NumberCard.new(cardId, "100", x, y)
    elseif cardId == self.cardIds.num_random then
        return RandomCard.new(cardId, x, y)
    elseif cardId == self.cardIds.num_pow2 then
        return PowerOf2Card.new(cardId, x, y)

    -- operators
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
    elseif cardId == self.cardIds.op_concat then
        return OperatorCard.new(cardId, "⊕", x, y)
    elseif cardId == self.cardIds.op_plus1 then
        return PlusOneCard.new(cardId, x, y)


    -- modifiers
    elseif cardId == self.cardIds.mod_reverse then
        return ReverseCard.new(cardId, x, y)
    elseif cardId == self.cardIds.mod_double then
        return DoubleCard.new(cardId, x, y)
    elseif cardId == self.cardIds.mod_prime then
        return PrimeCard.new(cardId, x, y)
    elseif cardId == self.cardIds.mod_inverse then
        return InverseCard.new(cardId, x, y)

    -- special cards
    elseif cardId == self.cardIds.sp_draw3 then
        return Draw3Card.new(cardId, x, y)
    end
end

return CardLibrary