echo "Activate the HeliOS theme for existing T3 Code installs"

helios-pkg-present t3code-bin || exit 0
helios-install-ai-t3-code
