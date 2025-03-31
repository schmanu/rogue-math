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
    self.grade = 15
    self.projectedGrade = nil
    self.projectedGradeProgress = 0

    self.gradeProjectionAnimation = {
        speed = 6,
        currentScore = 0,
        targetScore = 0,
    }

    self.gradeLabels = {
        "F",
        "E-",
        "E",
        "E+",
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

function Grade:nextRound()
    self.gradeProjectionAnimation.currentScore = 0
end

function Grade:update(dt)
    -- current actual projected grade
    local actualScore = GAME.calculator:getResult()


    -- Update animation target score
    if (actualScore ~= self.gradeProjectionAnimation.targetScore) then    
        self.gradeProjectionAnimation.targetScore = actualScore
    end
    
    -- Animate towards target using smooth easing
    local currentScore = self.gradeProjectionAnimation.currentScore
    local targetScore = self.gradeProjectionAnimation.targetScore
    local progress = dt * self.gradeProjectionAnimation.speed
    
    if math.abs(currentScore - targetScore) > 0.001 then -- Reduced threshold
        -- Use smooth easing function with stronger easing
        progress = 1 - math.cos(progress * math.pi) -- Full pi instead of pi/2 for faster easing
        -- Add extra acceleration
        progress = progress * 1.5
        -- Clamp progress to avoid overshooting
        progress = math.min(progress, 1)
        self.gradeProjectionAnimation.currentScore = currentScore + (targetScore - currentScore) * progress
    else
        self.gradeProjectionAnimation.currentScore = targetScore
    end

    self.projectedGrade = self.grade + GAME.game:calculateGradeDiff(self.gradeProjectionAnimation.currentScore)
    self.projectedGradeProgress = GAME.game:calculateGradeProgress(self.gradeProjectionAnimation.currentScore)
    -- Clamp projected grade between 1 and 16   
    if (self.projectedGrade < 1) then
        self.projectedGrade = 1
    elseif (self.projectedGrade > 16) then
        self.projectedGrade = 16
        self.projectedGradeProgress = 1
    end
end

function Grade:updateGrade(difference)
    print("Updating grade by " .. difference)
    self.grade = self.grade + difference
    if self.grade < 1 then
        self.grade = 1
    elseif self.grade > 16 then
        self.grade = 16
    end
end

function Grade:draw()
    -- Draw current grade
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(Assets.gradeSprite, self.x + 56, self.y, 0)
    love.graphics.setColor(1, 0, 0.301)
    love.graphics.printf(self.gradeLabels[self.grade], self.x + 56 + 48, self.y + 132, 56, "center")
    
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.setColor(1, 0, 0.301)
    love.graphics.printf(self.gradeLabels[self.projectedGrade], self.x, self.y + 224, 43, "right")
    if self.projectedGrade < 16 then
        love.graphics.printf(self.gradeLabels[self.projectedGrade + 1], self.x + 209, self.y + 224, 256, "left")
    end

    -- add a progress bar
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", self.x + 48 - 2, self.y + 226 - 2, 152 + 4, 16 + 4)
    if self.projectedGrade < self.grade then
        love.graphics.setColor(1, 0, 0.301)
        love.graphics.rectangle("fill", self.x + 48, self.y + 226, 152 * self.projectedGradeProgress, 16)
    else
        love.graphics.setColor(0, 0.89, 0.21)
        love.graphics.rectangle("fill", self.x + 48, self.y + 226, 152 * (self.projectedGradeProgress), 16)
    end
    love.graphics.setColor(1, 1, 1)
end

return Grade 