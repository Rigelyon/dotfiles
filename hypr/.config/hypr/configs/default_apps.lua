---@module 'hl'

-- --- NAMING SETUP ---

-- Binary Name
local terminal = "kitty"
local editor = "micro"
local fileManager = "nautilus"

-- Desktop Name
local browserDesktop = "com.brave.Browser.desktop"
local fileManagerDesktop = "org.gnome.Nautilus.desktop"
local editorDesktop = "dev.zed.Zed.desktop"
local imageViewDesktop = "org.gnome.Loupe.desktop"
local videoPlayerDesktop = "org.videolan.VLC.desktop"
local pdfViewerDesktop = "org.gnome.Papers.desktop"
local archiveDesktop = "io.github.peazip.PeaZip.desktop"
local discordDesktop = "vesktop.desktop"
local pcapDesktop = "org.wireshark.Wireshark.desktop"

-- --- ENV VARIABLES SETUP ---
hl.env("TERMINAL", "kitty")
hl.env("EDITOR", "micro")
hl.env("FILEMANAGER", "nautilus")
hl.env("BROWSER", "brave")

-- --- XDG SETUP ---

-- Web & Internet
-- exec-once = xdg-settings set default-web-browser $browserDesktop
-- exec-once = xdg-mime default $browserDesktop x-scheme-handler/http x-scheme-handler/https text/html application/xhtml+xml
-- exec-once = xdg-mime default $discordDesktop x-scheme-handler/discord

-- Files & System
-- exec-once = xdg-mime default $fileManagerDesktop inode/directory application/x-gnome-saved-search
-- exec-once = xdg-mime default $archiveDesktop application/vnd.rar
-- exec-once = xdg-mime default $pcapDesktop application/vnd.tcpdump.pcap

-- Media & Docs
-- exec-once = xdg-mime default $imageViewDesktop image/jpeg image/png
-- exec-once = xdg-mime default $videoPlayerDesktop video/mp4
-- exec-once = xdg-mime default $pdfViewerDesktop application/pdf
-- exec-once = xdg-mime default $editorDesktop application/json
