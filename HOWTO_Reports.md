# ALERT - Auth Log and Event Reporting Tool

This Branch provides the following -

### :basecampy: Auth Log Report
<!-- SPACE -->

<!-- SPACE -->
A script to generate a HTML report of the current server auth requests for the past 3 hours
Provides a regular report for the each 3 hours of the `auth.log` on the server to audit server
connection attempts and logins.
Can be run via the crontab to produce the html report
:star: a script snipplet is available to provide an admin with a copy of the `auth.log` from the
log file directory
<!-- SPACE -->
<br></br>
<!-- SPACE -->
### :basecampy: System Status Report
<!-- SPACE -->

<!-- SPACE -->
A script to generate a HTML report of the server stats for the administrator or operators
The html report generates includes the following information and can be run via the crontab
<!-- SPACE -->

<!-- SPACE -->
:star: Current Open Ports
:star: Current Connections
:star: System Log Entries from the past 2 hours
:star: System Critical Entry's (Priority 2)
:star: System Alert Entry's (Priority 1)
:star: System Emergency Entry's (Priority 0)
<!-- SPACE -->
<br></br>
### How To 

To Use the Scripts

1. Upload them to the required server

2. Check you are happy with the settings by opening the script in an editor
   for example; `$ nano authlog_report.sh`

3. Make the script executable with chmod `chmod u+x`
   for example; `$ chmod u+x authlog_report.sh`

> [!CAUTION]
> We do not encourage you to use this from a system directory or set it up for the 'root' user on your system
> Please ensure you consult the correct documents for operating system

4. Test the script by by running it
   for example; `$ ./authlog_report.sh`
  
6. Ensure the report has been generated and address any errors/software not installed as required.
   You will receive the following message (if not commented out)

> HTML report generated: authlog.html



### Configuration

**authlog_report.sh**

Path/Directory to your log file 'authlog' file

> LOG_FILE=

Path/Directory and File name for the html report

> OUTPUT_HTML=

**sysstatus_report.sh**

Log file to analyze
This should be the same layout/format as the system
file 'authlog.log'

> LOG_FILE=

The filename to use for the html report

> OUTPUT_HTML=


### Requirements


This is a list of the programs that are current ran by each script to generate the report.

**authlog_report.sh**

- date
  <sub> - Display date and time in the given FORMAT. </sub>
- hostname
  <sub> - Hostname is the program that is used to either set or display the
       current host, domain or node name of the system.  These names are
       used by many of the networking programs to identify the machine.
       The domain name is also used by NIS/YP. </sub>
- awk
<sub>  - The awk utility shall execute programs written in the awk
       programming language, which is specialized for textual data
       manipulation. An awk program is a sequence of patterns and
       corresponding actions. When input is read that matches a pattern,
       the action associated with that pattern is carried out.</sub>
- grep
<sub>  - grep searches for PATTERNS in each FILE.  PATTERNS is one or more
       patterns separated by newline characters, and grep prints each
       line that matches a pattern.  Typically PATTERNS should be quoted
       when grep is used in a shell command.</sub>
- cat
<sub>  - concatenate files and print on the standard output.</sub>

**sysstatus_report.sh**

- date
  <sub> - Display date and time in the given FORMAT. </sub>
- hostname
  <sub> - Hostname is the program that is used to either set or display the
       current host, domain or node name of the system.  These names are
       used by many of the networking programs to identify the machine.
       The domain name is also used by NIS/YP. </sub>
- netstat
  <sub> - Netstat prints information about the Linux networking subsystem.
       The type of information printed is controlled by the first
       argument</sub>
- tail
  <sub> - Print the last 10 lines of each FILE to standard output.  With
       more than one FILE, precede each with a header giving the file
       name. With no FILE, or when FILE is -, read standard input.</sub>
- grep
  <sub> - grep searches for PATTERNS in each FILE.  PATTERNS is one or more
       patterns separated by newline characters, and grep prints each
       line that matches a pattern.  Typically PATTERNS should be quoted
       when grep is used in a shell command.</sub>
- awk
  <sub> - The awk utility shall execute programs written in the awk
       programming language, which is specialized for textual data
       manipulation. An awk program is a sequence of patterns and
       corresponding actions. When input is read that matches a pattern,
       the action associated with that pattern is carried out. </sub>
- journalctl
  <sub> - journalctl is used to print the log entries stored in the journal
       by systemd-journald.service(8) and
       systemd-journal-remote.service(8).
       If called without parameters, it will show the contents of the
       journal accessible to the calling user, starting with the oldest
       entry collected.</sub>

