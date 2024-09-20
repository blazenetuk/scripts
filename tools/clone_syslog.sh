#!/usr/bin/bash

# Description -
#
# This script is designed to automate
# copying a system file to a user directory
# defined below, it will update the
# file permissons to the defined user and group

# Settings -

# File name to be copied
SOURCE_NAME="auth.log"

# The system file/log name to be copied
# Please include the full path (directory) 
SOURCE_FILE="/var/log/auth.log"

# Destination
# This should be the directory
# you want to copy the file to
#  The home directory of the target user
DEST_DIR="/home/<normal username>/"

# The username and group of <normal username>
# This will change the file permissons
# for the user in their home directory
USER="<normal username>"
GROUP="<normal username>"

# Advise we are coping the file
# - Please comment this out if running
#   from crontab
echo "Copying $SOURCE_FILE to $DEST_DIR..."

# Copy the file to the destination directory
cp "$SOURCE_FILE" "$DEST_DIR"

# Change ownership of the copied file
DEST_FILE="$DEST_DIR/$SOURCE_NAME"

# Confirm the action
# - Please comment this out if running
#   from crontab with '#'
echo "Changing ownership of $DEST_FILE to $USER:$GROUP..."

# update the file permissons
chown "$USER:$GROUP" "$DEST_FILE"

# Confirm what we have done
# - Please comment this out if running
#   from crontab with '#'
echo "File copied and ownership changed successfully."

# END