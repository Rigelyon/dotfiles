---@module 'hl'

-- Variables & Directories
local home = os.getenv("HOME") or ""
local configsDir = home .. "/.config/hypr/configs/"
local themesDir = home .. "/.config/hypr/themes/"
local noctaliaDir = home .. "/.config/hypr/noctalia/"

-- Load Sub-Configurations
dofile(configsDir .. "env_variables.lua")
dofile(configsDir .. "default_apps.lua")
pcall(dofile, configsDir .. "env_variables.local.lua")
dofile(configsDir .. "startup_apps.lua")
dofile(configsDir .. "keybinds.lua")
dofile(configsDir .. "monitor_settings.lua")
dofile(configsDir .. "window_rules.lua")
dofile(configsDir .. "system_settings.lua")
dofile(configsDir .. "workspace_settings.lua")
dofile(configsDir .. "animations.lua")
dofile(themesDir .. "catppuccin_mocha.lua")
dofile(configsDir .. "decorations.lua")
pcall(dofile, noctaliaDir .. "noctalia-colors.lua")

-- Autostart
hl.on("hyprland.start", function()
    hl.exec_cmd(home .. "/.config/hypr/scripts/first_boot.sh")
end)

-- For Noctalia Color templates
require("noctalia").apply_theme()
