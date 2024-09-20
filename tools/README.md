# Description

Collection of Scripts to assist in using the ALERT and SURE shell scripts

Please review the 'How To' documents for each script.

## clone_syslog.sh

Provides a simply shell script to clone a system file to a user's home directory.
This will update the file permissons to the user and group as required.

### Settings

The Name of the system log or file to be copied
> SOURCE_NAME=

The full path to the system log or file including directory
> SOURCE_FILE=

The directory of the user to copy the file to, the destination
> DEST_DIR=

The username to change the file permissons to
> USER=

The group to change the file permissons to
> GROUP=

