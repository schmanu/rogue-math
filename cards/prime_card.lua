local Card = require("cards/card")
local PrimeCard = setmetatable({}, {__index = Card})
PrimeCard.__index = PrimeCard

function PrimeCard.new(id, x, y)
    local self = setmetatable(Card.new(id, x, y, "mod_prime", "modifier"), PrimeCard)
    self.type = "modifier"  -- New type for special cards
    return self
end

function PrimeCard:play(calculator)
    if not self.disabled then
        -- Get the current display value
        local currentValue = calculator.display
        if currentValue ~= "" then
            local num = tonumber(currentValue)
            if num then
                -- Helper function to check if a number is prime
                local function isPrime(n)
                    if n < 2 then return false end
                    for i = 2, math.sqrt(n) do
                        if n % i == 0 then return false end
                    end
                    return true
                end

                -- Find next prime number
                local nextNum = num + 1
                while not isPrime(nextNum) do
                    nextNum = nextNum + 1
                end
                calculator:clear()
                calculator:addInput(tostring(nextNum))
                return true
            end
        end
    end
    return false
end

return PrimeCard