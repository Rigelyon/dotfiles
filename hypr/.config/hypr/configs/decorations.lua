---@module 'hl'

hl.config({
    general = {
        border_size = 2,
        gaps_in = 4,
        gaps_out = 8,
        col = {
            active_border = "rgb(cba6f7)",
            inactive_border = "rgb(313244)",
        },
    },
})

hl.config({
    decoration = {
        rounding = 12,
        rounding_power = 2,
        active_opacity = 0.98,
        inactive_opacity = 0.88,
        fullscreen_opacity = 1.0,
        dim_inactive = true,
        dim_strength = 0.1,
        dim_special = 0.8,
        shadow = {
            enabled = true,
            range = 15,
            render_power = 3,
            color = "rgba(1a1a1aee)",
        },
        blur = {
            enabled = true,
            size = 6,
            passes = 3,
            vibrancy = 0.1696,
            new_optimizations = true,
            xray = false,
            ignore_opacity = true,
            special = true,
            popups = true,
        },
    },
})
