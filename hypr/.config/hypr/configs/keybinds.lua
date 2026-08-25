---@module 'hl'

local mainMod = "SUPER"
local scriptsDir = os.getenv("HOME") .. "/.config/hypr/scripts"
-- local ipc = "qs -c noctalia-shell ipc call"
local ipc = "noctalia msg "

-- 0. COMMONS
-- -- Applications --
hl.bind(mainMod .. " + " .. "B", hl.dsp.exec_cmd("xdg-open https://"), { description = "Open Browser" })
hl.bind(mainMod .. " + " .. "T", hl.dsp.exec_cmd("kitty"), { description = "Open Terminal" })
hl.bind(mainMod .. " + SHIFT + T", hl.dsp.exec_cmd("bash " .. scriptsDir .. "/dropdown_term.sh"),
    { description = "Open Dropdown Terminal" })
hl.bind(mainMod .. " + " .. "E", hl.dsp.exec_cmd("nautilus"), { description = "Open File Manager" })
hl.bind("xf86Calculator", hl.dsp.exec_cmd("flatpak run org.gnome.Calculator"), { description = "Open Calculator" })

-- -- System UI & Launchers --
hl.bind(mainMod .. " + " .. "S", hl.dsp.exec_cmd(ipc .. "panel-toggle launcher"), { description = "Open App Launcher" })
hl.bind(mainMod .. " + " .. "Escape", hl.dsp.exec_cmd(ipc .. "panel-toggle control-center"),
    { description = "Open Control Center" })
hl.bind(mainMod .. " + " .. "Comma", hl.dsp.exec_cmd(ipc .. "settings-toggle"), { description = "Open Settings" })
-- hl.bind(mainMod .. " + " .. "F1", hl.dsp.exec_cmd(ipc .. "panel-toggle kenn/keybind-cheatsheet:cheatsheet"),
--     { description = "Open Keybinds Cheatsheet" })
hl.bind(mainMod .. " + " .. "W", hl.dsp.exec_cmd(ipc .. "panel-toggle wallpaper"), { description = "Change Wallpaper" })

-- -- Tools & Accessibility --
hl.bind(mainMod .. " + " .. "V", hl.dsp.exec_cmd(ipc .. "panel-toggle clipboard"), { description = "Open Clipboard" })
hl.bind(mainMod .. " + " .. "X", hl.dsp.exec_cmd(ipc .. "panel-toggle noctalia/notes:panel"),
    { description = "Open Scratchpad" })
hl.bind(mainMod .. " + " .. "Slash", hl.dsp.exec_cmd(ipc .. "panel-toggle alexander/mimir:chat"),
    { description = "Open AI Assistant" })
-- hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "Slash",
--     hl.dsp.exec_cmd("qs -c noctalia-shell ipc call plugin:assistant-panel clear"), { description = "Clear AI Assistant Chat" })
-- hl.bind(mainMod .. " + CTRL + mouse_down", hl.dsp.exec_cmd("bash " .. scriptsDir .. "/zoom.sh in"), { description = "Zoom In" })
-- hl.bind(mainMod .. " + CTRL + mouse_up", hl.dsp.exec_cmd("bash " .. scriptsDir .. "/zoom.sh out"), { description = "Zoom Out" })

-- -- Power & Hardware --
hl.bind("xf86Sleep", hl.dsp.exec_cmd("systemctl suspend"), { locked = true, description = "Sleep" })
hl.bind("xf86Rfkill", hl.dsp.exec_cmd(scriptsDir .. "/airplane_mode.sh"),
    { locked = true, description = "Airplane Mode" })
-- bindld = , Airplane, Airplane Mode, exec, $scriptsDir/airplane_mode.sh #"Airplane Mode"

-- 1. MEDIA
-- -- Audio --
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(ipc .. "volume-up"), { locked = true, description = "Volume Up" })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(ipc .. "volume-down"), { locked = true, description = "Volume Down" })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd(ipc .. "volume-mute"), { locked = true, description = "Volume Toggle" })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd(ipc .. "volume-mute-input"), { locked = true, description = "Mic Toggle" })

-- -- Brightness --
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(ipc .. "brightness-up"), { locked = true, description = "Brightness Up" })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(ipc .. "brightness-down"),
    { locked = true, description = "Brightness Down" })

-- -- Playback Controls --
hl.bind("xf86AudioPlay", hl.dsp.exec_cmd(ipc .. "media toggle"), { locked = true, description = "Play" })
-- hl.bind("xf86AudioPause", hl.dsp.exec_cmd(ipc .. "media pause"), { locked = true, description = "Pause" })
hl.bind("xf86AudioStop", hl.dsp.exec_cmd(ipc .. "media stop"), { locked = true, description = "Stop" })
hl.bind("xf86AudioNext", hl.dsp.exec_cmd(ipc .. "media next"), { locked = true, description = "Next Track" })
hl.bind("xf86AudioPrev", hl.dsp.exec_cmd(ipc .. "media previous"), { locked = true, description = "Previous Track" })

-- -- Unused --
-- bindld = , xf86AudioPlayPause, Play/pause, exec, $scriptsDir/mediactl.sh --pause

-- 0. SCREEN TOOLKIT
-- -- Capture --
hl.bind("Print", hl.dsp.exec_cmd(scriptsDir .. "/screenshot.sh -m fullscreen"), { description = "Screenshot" })
hl.bind(mainMod .. " + " .. "Print", hl.dsp.exec_cmd(scriptsDir .. "/screenshot.sh -m area"),
    { description = "Screenshot Area" })
hl.bind("SHIFT" .. " + " .. "Print", hl.dsp.exec_cmd(ipc .. "plugin noctalia/screen_recorder:service all toggle"),
    { description = "Record Screen" })
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "Print", hl.dsp.exec_cmd(scriptsDir .. "/record.sh -M area -a -m"),
    { description = "Record Area" })
-- hl.bind("SHIFT" .. " + " .. "Print", hl.dsp.exec_cmd(scriptsDir .. "/record.sh -M fullscreen -a -m"),
--     { description = "Record Screen" })
-- hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "Print", hl.dsp.exec_cmd(scriptsDir .. "/record.sh -M area -a -m"),
--     { description = "Record Area" })

-- -- Tools --
hl.bind(mainMod .. " + " .. "Insert", hl.dsp.exec_cmd(scriptsDir .. "/ocr_scan.sh"), { description = "OCR Scan" })
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "Insert", hl.dsp.exec_cmd(scriptsDir .. "/qr_scan.sh"),
    { description = "QR Scan" })
hl.bind(mainMod .. " + " .. "D", hl.dsp.exec_cmd("pkill -USR1 -f 'wayscriber --daemon'"),
    { description = "Toggle Annotation" })

-- 0. WINDOW MANAGEMENT
-- -- State & Lifecycle --
hl.bind(mainMod .. " + " .. "Q", hl.dsp.window.close(), { description = "Close Active Window" })
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "Q", hl.dsp.window.kill(), { description = "Force Close Active Window" })
hl.bind(mainMod .. " + " .. "P", hl.dsp.window.float(), { description = "Float Window" })
hl.bind(mainMod .. " + " .. "P", hl.dsp.window.pin(), { description = "Pin Window" })
hl.bind(mainMod .. " + " .. "F", hl.dsp.window.fullscreen(), { description = "Fullscreen Window" })
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "F", hl.dsp.window.fullscreen({ mode = "maximized" }),
    { description = "Maximize Window" })
hl.bind(mainMod .. " + space", hl.dsp.window.float(), { description = "Float Current Window" })
-- hl.bind(mainMod .. " + ALT + space", hl.dsp.exec_cmd("bash " .. scriptsDir .. "/toggle_allfloat.sh"), { description = "Float All Windows" })
hl.bind(mainMod .. " + " .. "mouse:274", hl.dsp.exec_cmd("bash " .. scriptsDir .. "/hypr_minimize.sh toggle"),
    { description = "Toggle Minimize Tray" })
hl.bind(mainMod .. " + " .. "CTRL" .. " + " .. "mouse:274",
    hl.dsp.exec_cmd("bash " .. scriptsDir .. "/hypr_minimize.sh push"), { description = "Minimize Window" })
hl.bind(mainMod .. " + " .. "CTRL + ALT" .. " + " .. "mouse:274",
    hl.dsp.exec_cmd("bash " .. scriptsDir .. "/hypr_minimize.sh push --all"), { description = "Minimize All Windows" })
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "mouse:274",
    hl.dsp.exec_cmd("bash " .. scriptsDir .. "/hypr_minimize.sh pop"), { description = "Restore Minimized Window" })
hl.bind(mainMod .. " + " .. "SHIFT + ALT" .. " + " .. "mouse:274",
    hl.dsp.exec_cmd("bash " .. scriptsDir .. "/hypr_minimize.sh pop --all"),
    { description = "Restore All Minimized Windows" })

hl.bind(mainMod .. " + " .. "M", hl.dsp.exec_cmd("bash " .. scriptsDir .. "/hypr_minimize.sh push"),
    { description = "Minimize Window (Keyboard)" })
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "M", hl.dsp.exec_cmd("bash " .. scriptsDir .. "/hypr_minimize.sh pop"),
    { description = "Restore Minimized Window (Keyboard)" })

-- -- Focus & Navigation --
hl.bind(mainMod .. " + " .. "Tab", hl.dsp.exec_cmd(ipc .. "window-switcher"), { description = "Switch Window" })
hl.bind("ALT" .. " + " .. "Tab", hl.dsp.window.cycle_next(), { description = "Cycle Next Window" })
hl.bind("ALT" .. " + " .. "Tab", hl.dsp.window.bring_to_top(), { description = "Bring Active Window" })
hl.bind(mainMod .. " + " .. "Left", hl.dsp.focus({ direction = "left" }), { description = "Focus Left" })
hl.bind(mainMod .. " + " .. "Right", hl.dsp.focus({ direction = "right" }), { description = "Focus Right" })
hl.bind(mainMod .. " + " .. "Up", hl.dsp.focus({ direction = "up" }), { description = "Focus Up" })
hl.bind(mainMod .. " + " .. "Down", hl.dsp.focus({ direction = "down" }), { description = "Focus Down" })

-- -- Move --
hl.bind(mainMod .. " + " .. "CTRL" .. " + " .. "Left", hl.dsp.window.move({ direction = "left" }),
    { description = "Move Window Left" })
hl.bind(mainMod .. " + " .. "CTRL" .. " + " .. "Right", hl.dsp.window.move({ direction = "right" }),
    { description = "Move Window Right" })
hl.bind(mainMod .. " + " .. "CTRL" .. " + " .. "Up", hl.dsp.window.move({ direction = "up" }),
    { description = "Move Window Up" })
hl.bind(mainMod .. " + " .. "CTRL" .. " + " .. "Down", hl.dsp.window.move({ direction = "down" }),
    { description = "Move Window Down" })

-- -- Swap --
hl.bind(mainMod .. " + " .. "ALT" .. " + " .. "Left", hl.dsp.window.swap({ direction = "left" }),
    { description = "Swap Window Left" })
hl.bind(mainMod .. " + " .. "ALT" .. " + " .. "Right", hl.dsp.window.swap({ direction = "right" }),
    { description = "Swap Window Right" })
hl.bind(mainMod .. " + " .. "ALT" .. " + " .. "Up", hl.dsp.window.swap({ direction = "up" }),
    { description = "Swap Window Up" })
hl.bind(mainMod .. " + " .. "ALT" .. " + " .. "Down", hl.dsp.window.swap({ direction = "down" }),
    { description = "Swap Window Down" })

-- -- Resize --
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "Left", hl.dsp.window.resize({ x = -50, y = 0 }),
    { repeating = true, description = "Resize Window Left" })
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "Right", hl.dsp.window.resize({ x = 50, y = 0 }),
    { repeating = true, description = "Resize Window Right" })
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "Up", hl.dsp.window.resize({ x = 0, y = -50 }),
    { repeating = true, description = "Resize Window Up" })
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "Down", hl.dsp.window.resize({ x = 0, y = 50 }),
    { repeating = true, description = "Resize Window Down" })

-- -- Mouse & System --
hl.bind(mainMod .. " + " .. "mouse:272", hl.dsp.window.drag(), { mouse = true, description = "Move Window" })
hl.bind(mainMod .. " + " .. "mouse:273", hl.dsp.window.resize(), { mouse = true, description = "Resize Window" })
hl.bind("CTRL + ALT" .. " + " .. "Delete", hl.dsp.exit(), { description = "Exit Hyprland" })

-- 0. WORKSPACE MANAGEMENT
-- -- Navigation --
-- hl.bind(mainMod .. " + " .. "TAB", hl.dsp.exec_cmd("qs ipc -c overview call overview toggle"), { description = "Toggle Workspace Overview" })
hl.bind(mainMod .. " + " .. "mouse_down", hl.dsp.focus({ workspace = "e+1" }), { description = "Next Workspace" })
hl.bind(mainMod .. " + " .. "mouse_up", hl.dsp.focus({ workspace = "e-1" }), { description = "Previous Workspace" })

-- -- Unused --
-- bindd = $mainMod, TAB, Next Workspace, workspace, m+1
-- bindd = $mainMod SHIFT, Tab, Previous Workspace, workspace, m-1

-- -- Special Workspace --
hl.bind(mainMod .. " + " .. "code:90", hl.dsp.workspace.toggle_special("num_0"),
    { description = "Toggle Special Workspace 0" })
hl.bind(mainMod .. " + " .. "code:87", hl.dsp.workspace.toggle_special("num_1"),
    { description = "Toggle Special Workspace 1" })
hl.bind(mainMod .. " + " .. "code:88", hl.dsp.workspace.toggle_special("num_2"),
    { description = "Toggle Special Workspace 2" })
hl.bind(mainMod .. " + " .. "code:89", hl.dsp.workspace.toggle_special("num_3"),
    { description = "Toggle Special Workspace 3" })
hl.bind(mainMod .. " + " .. "code:83", hl.dsp.workspace.toggle_special("num_4"),
    { description = "Toggle Special Workspace 4" })
hl.bind(mainMod .. " + " .. "code:84", hl.dsp.workspace.toggle_special("num_5"),
    { description = "Toggle Special Workspace 5" })
hl.bind(mainMod .. " + " .. "code:85", hl.dsp.workspace.toggle_special("num_6"),
    { description = "Toggle Special Workspace 6" })
hl.bind(mainMod .. " + " .. "code:79", hl.dsp.workspace.toggle_special("num_7"),
    { description = "Toggle Special Workspace 7" })
hl.bind(mainMod .. " + " .. "code:80", hl.dsp.workspace.toggle_special("num_8"),
    { description = "Toggle Special Workspace 8" })
hl.bind(mainMod .. " + " .. "code:81", hl.dsp.workspace.toggle_special("num_9"),
    { description = "Toggle Special Workspace 9" })

hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "code:90", hl.dsp.window.move({ workspace = "special:num_0" }),
    { description = "Move Window to Special Workspace 0" })
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "code:87", hl.dsp.window.move({ workspace = "special:num_1" }),
    { description = "Move Window to Special Workspace 1" })
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "code:88", hl.dsp.window.move({ workspace = "special:num_2" }),
    { description = "Move Window to Special Workspace 2" })
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "code:89", hl.dsp.window.move({ workspace = "special:num_3" }),
    { description = "Move Window to Special Workspace 3" })
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "code:83", hl.dsp.window.move({ workspace = "special:num_4" }),
    { description = "Move Window to Special Workspace 4" })
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "code:84", hl.dsp.window.move({ workspace = "special:num_5" }),
    { description = "Move Window to Special Workspace 5" })
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "code:85", hl.dsp.window.move({ workspace = "special:num_6" }),
    { description = "Move Window to Special Workspace 6" })
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "code:79", hl.dsp.window.move({ workspace = "special:num_7" }),
    { description = "Move Window to Special Workspace 7" })
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "code:80", hl.dsp.window.move({ workspace = "special:num_8" }),
    { description = "Move Window to Special Workspace 8" })
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "code:81", hl.dsp.window.move({ workspace = "special:num_9" }),
    { description = "Move Window to Special Workspace 9" })

hl.bind(mainMod .. " + CTRL + code:90", hl.dsp.window.move({ workspace = "special:num_0", follow = false }),
    { description = "Move Window Silently to Special Workspace 0" })
hl.bind(mainMod .. " + CTRL + code:87", hl.dsp.window.move({ workspace = "special:num_1", follow = false }),
    { description = "Move Window Silently to Special Workspace 1" })
hl.bind(mainMod .. " + CTRL + code:88", hl.dsp.window.move({ workspace = "special:num_2", follow = false }),
    { description = "Move Window Silently to Special Workspace 2" })
hl.bind(mainMod .. " + CTRL + code:89", hl.dsp.window.move({ workspace = "special:num_3", follow = false }),
    { description = "Move Window Silently to Special Workspace 3" })
hl.bind(mainMod .. " + CTRL + code:83", hl.dsp.window.move({ workspace = "special:num_4", follow = false }),
    { description = "Move Window Silently to Special Workspace 4" })
hl.bind(mainMod .. " + CTRL + code:84", hl.dsp.window.move({ workspace = "special:num_5", follow = false }),
    { description = "Move Window Silently to Special Workspace 5" })
hl.bind(mainMod .. " + CTRL + code:85", hl.dsp.window.move({ workspace = "special:num_6", follow = false }),
    { description = "Move Window Silently to Special Workspace 6" })
hl.bind(mainMod .. " + CTRL + code:79", hl.dsp.window.move({ workspace = "special:num_7", follow = false }),
    { description = "Move Window Silently to Special Workspace 7" })
hl.bind(mainMod .. " + CTRL + code:80", hl.dsp.window.move({ workspace = "special:num_8", follow = false }),
    { description = "Move Window Silently to Special Workspace 8" })
hl.bind(mainMod .. " + CTRL + code:81", hl.dsp.window.move({ workspace = "special:num_9", follow = false }),
    { description = "Move Window Silently to Special Workspace 9" })

-- -- Direct Switch (mod + 0-9) --
-- bind = $mainMod, [NUM], workspace, 1 #"Workspace [NUM]"
hl.bind(mainMod .. " + " .. "code:10", hl.dsp.focus({ workspace = 1 }), { description = "Workspace 1" })
hl.bind(mainMod .. " + " .. "code:11", hl.dsp.focus({ workspace = 2 }), { description = "Workspace 2" })
hl.bind(mainMod .. " + " .. "code:12", hl.dsp.focus({ workspace = 3 }), { description = "Workspace 3" })
hl.bind(mainMod .. " + " .. "code:13", hl.dsp.focus({ workspace = 4 }), { description = "Workspace 4" })
hl.bind(mainMod .. " + " .. "code:14", hl.dsp.focus({ workspace = 5 }), { description = "Workspace 5" })
hl.bind(mainMod .. " + " .. "code:15", hl.dsp.focus({ workspace = 6 }), { description = "Workspace 6" })
hl.bind(mainMod .. " + " .. "code:16", hl.dsp.focus({ workspace = 7 }), { description = "Workspace 7" })
hl.bind(mainMod .. " + " .. "code:17", hl.dsp.focus({ workspace = 8 }), { description = "Workspace 8" })
hl.bind(mainMod .. " + " .. "code:18", hl.dsp.focus({ workspace = 9 }), { description = "Workspace 9" })
hl.bind(mainMod .. " + " .. "code:19", hl.dsp.focus({ workspace = 10 }), { description = "Workspace 10" })

-- -- Move to Workspace (mod + SHIFT + 0-9) --
-- bind = $mainMod SHIFT, NUM, movetoworkspace, 1 #"Move Window to Workspace [NUM]"
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "code:10", hl.dsp.window.move({ workspace = 1 }),
    { description = "Move Window to Workspace 1" })
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "code:11", hl.dsp.window.move({ workspace = 2 }),
    { description = "Move Window to Workspace 2" })
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "code:12", hl.dsp.window.move({ workspace = 3 }),
    { description = "Move Window to Workspace 3" })
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "code:13", hl.dsp.window.move({ workspace = 4 }),
    { description = "Move Window to Workspace 4" })
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "code:14", hl.dsp.window.move({ workspace = 5 }),
    { description = "Move Window to Workspace 5" })
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "code:15", hl.dsp.window.move({ workspace = 6 }),
    { description = "Move Window to Workspace 6" })
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "code:16", hl.dsp.window.move({ workspace = 7 }),
    { description = "Move Window to Workspace 7" })
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "code:17", hl.dsp.window.move({ workspace = 8 }),
    { description = "Move Window to Workspace 8" })
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "code:18", hl.dsp.window.move({ workspace = 9 }),
    { description = "Move Window to Workspace 9" })
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "code:19", hl.dsp.window.move({ workspace = 10 }),
    { description = "Move Window to Workspace 10" })

hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "bracketright", hl.dsp.window.move({ workspace = "r+1" }),
    { description = "Move Window to Next Workspace" })
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "bracketleft", hl.dsp.window.move({ workspace = "r-1" }),
    { description = "Move Window to Previous Workspace" })

-- -- Move Silently to Workspace (mod + CTRL + 0-9) --
-- bind = $mainMod CTRL, NUM, movetoworkspacesilent, 1 #"Move Window Silently to Workspace [NUM]"
hl.bind(mainMod .. " + CTRL + code:10", hl.dsp.window.move({ workspace = 1, follow = false }),
    { description = "Move Window Silently to Workspace 1" })
hl.bind(mainMod .. " + CTRL + code:11", hl.dsp.window.move({ workspace = 2, follow = false }),
    { description = "Move Window Silently to Workspace 2" })
hl.bind(mainMod .. " + CTRL + code:12", hl.dsp.window.move({ workspace = 3, follow = false }),
    { description = "Move Window Silently to Workspace 3" })
hl.bind(mainMod .. " + CTRL + code:13", hl.dsp.window.move({ workspace = 4, follow = false }),
    { description = "Move Window Silently to Workspace 4" })
hl.bind(mainMod .. " + CTRL + code:14", hl.dsp.window.move({ workspace = 5, follow = false }),
    { description = "Move Window Silently to Workspace 5" })
hl.bind(mainMod .. " + CTRL + code:15", hl.dsp.window.move({ workspace = 6, follow = false }),
    { description = "Move Window Silently to Workspace 6" })
hl.bind(mainMod .. " + CTRL + code:16", hl.dsp.window.move({ workspace = 7, follow = false }),
    { description = "Move Window Silently to Workspace 7" })
hl.bind(mainMod .. " + CTRL + code:17", hl.dsp.window.move({ workspace = 8, follow = false }),
    { description = "Move Window Silently to Workspace 8" })
hl.bind(mainMod .. " + CTRL + code:18", hl.dsp.window.move({ workspace = 9, follow = false }),
    { description = "Move Window Silently to Workspace 9" })
hl.bind(mainMod .. " + CTRL + code:19", hl.dsp.window.move({ workspace = 10, follow = false }),
    { description = "Move Window Silently to Workspace 10" })

hl.bind(mainMod .. " + CTRL + bracketright",
    hl.dsp.window.move({ workspace = "r+1", follow = false }), { description = "Move Window Silently to Next Workspace" })
hl.bind(mainMod .. " + CTRL + bracketleft",
    hl.dsp.window.move({ workspace = "r-1", follow = false }),
    { description = "Move Window Silently to Previous Workspace" })

-- 0. GENERAL TERMINAL (SHELL)
-- -- Execution Control --
-- bindd = CTRL, C, Interrupt Process, , #"Interrupt/Cancel Process"
-- bindd = CTRL, D, Exit Shell / EOF, , #"Exit Terminal (Logout)"
-- bindd = CTRL, L, Clear Screen, , #"Clear Terminal Screen"
-- bindd = CTRL, Z, Suspend Process, , #"Suspend Process to Background"

-- -- Navigation --
-- bindd = CTRL, A, Move to Start of Line, , #"Go to Start of Line"
-- bindd = CTRL, E, Move to End of Line, , #"Go to End of Line"
-- bindd = ALT, B, Move Backward One Word, , #"Back One Word"
-- bindd = ALT, F, Move Forward One Word, , #"Forward One Word"

-- -- Editing & Deletion --
-- bindd = CTRL, U, Delete to Start of Line, , #"Delete to Start"
-- bindd = CTRL, K, Delete to End of Line, , #"Delete to End"
-- bindd = CTRL, W, Delete Word Before, , #"Delete Word Before"
-- bindd = ALT, D, Delete Word After, , #"Delete Word After"
-- bindd = CTRL, Y, Paste Deleted Text, , #"Yank (Paste) Deleted Text"

-- -- History --
-- bindd = CTRL, R, Reverse Search History, , #"Search Command History"
-- bindd = CTRL, G, Cancel Search, , #"Exit Search Mode"
-- bindd = CTRL, P, Previous Command, , #"Previous Command (Up)"
-- bindd = CTRL, N, Next Command, , #"Next Command (Down)"

-- 0. KITTY: SCROLLING
-- bind = CTRL SHIFT, Up, , #"Scroll Line Up"
-- bind = CTRL SHIFT, Down, , #"Scroll Line Down"
-- bind = CTRL SHIFT, Page Up, , #"Scroll Page Up"
-- bind = CTRL SHIFT, Page Down, , #"Scroll Page Down"
-- bind = CTRL SHIFT, Home, , #"Scroll to Top"
-- bind = CTRL SHIFT, End, , #"Scroll to Bottom"

-- 0. KITTY: TABS MANAGEMENT
-- bind = CTRL SHIFT, T, , #"New Tab"
-- bind = CTRL SHIFT, Q, , #"Close Tab"
-- bind = CTRL SHIFT, Right, , #"Next Tab"
-- bind = CTRL SHIFT, Left, , #"Previous Tab"
-- bind = CTRL SHIFT, Period, , #"Move Tab Forward"
-- bind = CTRL SHIFT, Comma, , #"Move Tab Backward"
-- bind = CTRL SHIFT ALT, T, , #"Set Tab Title"

-- 0. KITTY: PANE MANAGEMENT
-- bind = CTRL SHIFT, Enter, , #"New Pane"
-- bind = CTRL SHIFT, W, , #"Close Pane"
-- bind = CTRL SHIFT, bracketleft, , #"Next Pane"
-- bind = CTRL SHIFT, bracketright, , #"Previous Pane"
-- bind = CTRL SHIFT, F, , #"Move Pane Forward"
-- bind = CTRL SHIFT, B, , #"Move Pane Backward"
-- bind = CTRL SHIFT, Grave, , #"Move Pane to Top"
-- bind = CTRL SHIFT, NUM, , #"Focus Specific Pane"

-- 0. KITTY: OTHERS
-- -- Clipboard --
-- bindd = CTRL SHIFT, C, Copy to Clipboard, , #"Copy to clipboard"
-- bindd = CTRL SHIFT, V, Paste from Clipboard, , #"Paste from clipboard"
-- bindd = CTRL SHIFT, S, Paste from Selection, , #"Paste from selection"

-- -- Appearance --
-- bindd = CTRL SHIFT, equal, Increase Font Size, , #"Increase font size"
-- bindd = CTRL SHIFT, minus, Decrease Font Size, , #"Decrease font size"
-- bindd = CTRL SHIFT, BackSpace, Restore Font Size, , #"Restore font size"

-- -- Control --
-- bindd = CTRL SHIFT, U, Input Unicode Character, , #"Input unicode character"
-- bindd = CTRL SHIFT, E, Click URL with Keyboard, , #"Click URL with keyboard"
-- bindd = CTRL SHIFT, Delete, Reset Terminal, , #"Reset the terminal"

-- -- Config & Docs --
-- bindd = CTRL SHIFT, F5, Reload kitty.conf, , #"Reload kitty.conf"
-- bindd = CTRL SHIFT, F6, Debug kitty.conf, , #"Debug kitty.conf"
-- bindd = CTRL SHIFT, F2, Edit Kitty Config, , #"Edit kitty config file"
-- bindd = CTRL SHIFT, F1, View Kitty Docs, , #"View kitty docs in browser"
-- bindd = CTRL SHIFT, Escape, Open Kitty Shell, , #"Open a kitty shell"
-- bindd = CTRL SHIFT, O, Pass Selection to Program, , #"Pass selection to program"
