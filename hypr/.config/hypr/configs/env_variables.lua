---@module 'hl'

-- Environment Variables that needs to be set according to Hyprland Wiki for NVIDIA GPU

-- https://wiki.hypr.land/Nvidia/

hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("NVD_BACKEND", "direct")
hl.env("GSK_RENDERER", "ngl")

--## Toolkit Backend Variables ###

hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("CLUTTER_BACKEND", "wayland")

--Run SDL2 applications on Wayland.
--Remove or set to x11 if games that provide older versions of SDL cause compatibility issues
--env = SDL_VIDEODRIVER,wayland

--## XDG Specifications ###

hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")

--## QT Variables ###

hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")

--## hyprland-qt-support ###

hl.env("QT_QUICK_CONTROLS_STYLE", "org.hyprland.style")

--## xwayland apps scale fix (useful if you are use monitor scaling) ###

-- Set same value if you use scaling in Monitors.conf
-- 1 is 100% 1.5 is 150%
-- see https://wiki.hyprland.org/Configuring/XWayland/

hl.env("GDK_SCALE", "1")
hl.env("QT_SCALE_FACTOR", "1")

--## firefox ###

hl.env("MOZ_ENABLE_WAYLAND", "1")
