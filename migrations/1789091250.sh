echo "Activate the Kestrel theme for existing T3 Code installs"

kestrel-pkg-present t3code-bin || exit 0
kestrel-install-ai-t3-code
