-- Window and layer rules for the HeliOS Quickshell surfaces. The
-- shell-wide bar / menu / popouts are layer-shell.

-- Keep the bar instant: no layer-shell fade/slide animation.
hl.layer_rule({ match = { namespace = "helios-bar" }, no_anim = true, animation = "none" })

-- Launcher, image selector, emojis, clipboard overlays, the OSD, reminders, the
-- Wi-Fi QR code and keyboard-driven panels should pop without compositor layer
-- animations. Overlays open as soon as their scale is ready, without a
-- compositor fade or slide. Panels keep their own QML opacity transition
-- for normal open/close, and skip it for panel handoff.
hl.layer_rule({ match = { namespace = "^(helios-menu|helios-image-selector|helios-emojis|helios-clipboard|helios-keyboard-panel|helios-osd|helios-reminders|helios-network-qr)$" }, no_anim = true, animation = "none" })

-- A boot intro hands the desktop between OWE's video layer and the shell's
-- background layer. The media fades itself, so a compositor fade on either
-- layer only dips the screen toward the empty desktop during the handoff.
hl.layer_rule({ match = { namespace = "^(helios-background|owe-background)$" }, no_anim = true, animation = "none" })

-- Dev gallery is the main shell workbench; open it maximized like
-- SUPER+ALT+F so component previews have the whole workspace.
o.window({ class = "^org.quickshell$", title = "^HeliOS shell – dev gallery$" }, { maximize = true })
