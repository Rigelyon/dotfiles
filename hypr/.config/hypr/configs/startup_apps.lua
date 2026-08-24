---@module 'hl'

local scriptsDir = (os.getenv("HOME") or "") .. "/.config/hypr/scripts"

local wallpapersDir = (os.getenv("HOME") or "") .. "/Pictures/Wallpapers"

-- Autostart
hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("/usr/libexec/xdg-desktop-portal --replace &")
    -- hl.exec_cmd("qs -c noctalia-shell")
    hl.exec_cmd("noctalia")
    hl.exec_cmd("wayscriber --daemon")
    hl.exec_cmd("hyprctl dispatch workspace 1")
    hl.exec_cmd("hyprctl dispatch workspace 2")
    hl.exec_cmd("hyprctl dispatch workspace 3")
    hl.exec_cmd("hyprctl dispatch workspace 4")
    hl.exec_cmd("hyprctl dispatch workspace 2")
    hl.exec_cmd("gtk-launch vesktop")
    hl.exec_cmd("gtk-launch com.abdownloadmanager")
end)
