# Set default XCompose that is triggered with CapsLock
tee ~/.XCompose >/dev/null <<EOF
# Run helios-restart-xcompose to apply changes

# Include fast emoji access
include "/usr/share/helios/default/xcompose"

# Identification
<Multi_key> <space> <n> : "$HELIOS_USER_NAME"
<Multi_key> <space> <e> : "$HELIOS_USER_EMAIL"
EOF
