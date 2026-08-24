---@module 'hl'

local primary = "rgb(cba6f7)"
local surface = "rgb(1e1e2e)"
local secondary = "rgb(fab387)"
local error = "rgb(f38ba8)"
local tertiary = "rgb(94e2d5)"

local surface_lowest = "rgb(212232)"

hl.config({
    general = {
        col = {
            active_border = "rgb(cba6f7)",
            inactive_border = "rgb(1e1e2e)",
        },
    },
})

hl.config({
    group = {
        groupbar = {
            col = {
                active = "rgb(fab387)",
                inactive = "rgb(1e1e2e)",
                locked_active = "rgb(f38ba8)",
                locked_inactive = "rgb(1e1e2e)",
            },
        },
        col = {
            border_active = "rgb(fab387)",
            border_inactive = "rgb(1e1e2e)",
            border_locked_active = "rgb(f38ba8)",
            border_locked_inactive = "rgb(1e1e2e)",
        },
    },
})
