local Assets = {}

-- Card colors and styles
Assets.colors = {
    number = {
        background = {0.7, 0.8, 1.0, 1.0},  -- Light blue
        border = {0.3, 0.4, 0.6, 1.0},      -- Darker blue
        text = {0.2, 0.2, 0.2, 1.0}         -- Dark gray
    },
    operator = {
        background = {1.0, 0.8, 0.8, 1.0},  -- Light red
        border = {0.6, 0.3, 0.3, 1.0},      -- Darker red
        text = {0.2, 0.2, 0.2, 1.0}         -- Dark gray
    },
    disabled = {
        background = {0.5, 0.5, 0.5, 1.0},  -- Gray
        border = {0.3, 0.3, 0.3, 1.0},      -- Darker gray
        text = {0.7, 0.7, 0.7, 1.0}         -- Light gray
    }
}

-- Card dimensions
Assets.card = {
    width = 60,
    height = 90,
    cornerRadius = 5,
    borderWidth = 2
}

function Assets.load()
    -- No need to load anything since we're using built-in graphics
    return true
end

return Assets 