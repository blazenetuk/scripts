# Overview

Script to provide html reporting of a system status.
Provides an offline/regular report to lessen the need to install resource heavy software like webadmin on a server

The main focus of the script is to be secure, simple and focus on using less resources as possible
while still providing a good amount of information for server administration

<i>The scripts were previous written in bash/shell script, this is still available in the inital release of this project.</i>

# Prerequisites

Requires a Linux/Unix System and Python 3, please see the `COMMANDS` section of the script for commands utilising in the reporting.

# Configuration

> LOG_FILE = ""
This should be the directory and file name for the log output and errors

> OUTPUT_HTML = ""
Directory and file name for the HTML output to be generated too

> LAST_RUN_FILE = ""
The directory and lock file name to use for tracking the last run time

> MAIL_CONFIG = ""
>
This is configuration for the mail settings
>
`Enabled`
TRUE would enable to use of mailing the output.
FALSE would disable the option of mailing the outputted HTML file.
>
`recipient`
This should be the email to send the html out/stats file to.
>
`Subject`
This is the subject line of the email/stats email if enabled.
>
`mail_command`
You can set the default mail command here.

> [!IMPORTANT]
> It is not recommend to change the `COMMANDS` section unless you are able to configure the out correctly.
> We do not provide support for customising this section of the script 
