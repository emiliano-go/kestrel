# Set default XCompose that is triggered with CapsLock
tee ~/.XCompose >/dev/null <<EOF
# Run kestrel-restart-xcompose to apply changes

# Include fast emoji access
include "/usr/share/kestrel/default/xcompose"

# Identification
<Multi_key> <space> <n> : "$KESTREL_USER_NAME"
<Multi_key> <space> <e> : "$KESTREL_USER_EMAIL"
EOF
