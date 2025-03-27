local Assets = require("assets")

local Grade = {}
Grade.__index = Grade

function Grade.new(x, y)
    local self = setmetatable({}, Grade)
    self.x = x
    self.y = y
    self.width = 128
    self.height = 192

    -- Grades go from A+ to F, starting from A
    -- F, D-, D, D+, C-, C, C+, B-, B, B+, A-, A, A+
    self.grade = 12

    self.gradeLabels= {
        "F",
        "D-",
        "D",
        "D+",
        "C-",
        "C",
        "C+",
        "B-",
        "B",
        "B+",
        "A-",
        "A",
        "A+",
    }
    return self
end

function Grade:update(difference)
    self.grade = self.grade + difference
    if self.grade < 1 then
        self.grade = 1
    elseif self.grade > 13 then
        self.grade = 13
    end
end
function Grade:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(Assets.gradeSprite, self.x, self.y, 0)
    love.graphics.setColor(1, 0, 0.301)
    love.graphics.printf(self.gradeLabels[self.grade], self.x + 48, self.y + 132, 56, "center")
    love.graphics.setColor(1, 1, 1)
end

return Grade 