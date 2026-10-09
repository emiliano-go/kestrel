# Chromium ships in the base packages, so it never goes through
# kestrel-install-browser, and fresh installs mark every migration as already
# applied. Without this, the bundled extensions load but have no native
# messaging host to talk to.
kestrel-install-chromium-copy-url
kestrel-install-chromium-ytdlp
