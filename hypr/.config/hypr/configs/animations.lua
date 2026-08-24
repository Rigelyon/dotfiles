---@module 'hl'

hl.config({
    animations = {
        enabled = true,
    },
})

-- Define Bezier Curve
hl.curve("quart", {
    type = "bezier",
    points = { { 0.25, 1 }, { 0.5, 1 } },
})

-- Define Animations
hl.animation({ leaf = "windows", enabled = true, speed = 4, bezier = "quart", style = "slide" })
hl.animation({ leaf = "border", enabled = true, speed = 4, bezier = "quart" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 4, bezier = "quart" })
hl.animation({ leaf = "fade", enabled = true, speed = 4, bezier = "quart" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 3, bezier = "quart" })
hl.animation({ leaf = "specialWorkspaceIn", enabled = true, speed = 3, bezier = "quart", style = "slide bottom" })
hl.animation({ leaf = "specialWorkspaceOut", enabled = true, speed = 3, bezier = "quart", style = "slide top" })
