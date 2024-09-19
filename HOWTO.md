# SURE - System Utilization and Risk Evaluation

This Branch provides the following -

<!-- SPACE -->
## :basecamp: System Audit Report
<!-- SPACE -->

A script to provide a basic audit of the system. Can be run from crontab to provide a daily/weekly report as needed.
Provides a basic snapshot of the server with the following information -

<!-- SPACE -->
:star: Current Users
:star: Running Procs
:star: Top 10 Memory Usage
:star: Top 10 CPU Usage
:star: Open Files
 <!-- SPACE -->
 
  <!-- SPACE -->
## :basecamp: System Security Report
 <!-- SPACE -->

 <!-- SPACE -->
A script to provide a basic security report of the system. Can be run from crontab to provide daily/weekly report as needed.
Provides a basic snapshot of the following information from the server -
<!-- SPACE -->

<!-- SPACE -->
:star: failog report
:star: No Owner Files
:star: Set GID Files
:star: Set UID Files
:star: World Writeable Files
:star: Open Ports
:star: Current Services
<!-- SPACE -->

### How To 

To Use the Scripts

1. Upload them to the required server

2. Check you are happy with the settings by opening the script in an editor
   for example; `$ nano system_audit.sh`

3. Make the script executable with chmod `chmod u+x`
   for example; `$ chmod u+x system_audit.sh`

> [!CAUTION]
> We do not encourage you to use this from a system directory or set it up for the 'root' user on your system
> Please ensure you consult the correct documents for operating system

4. Test the script by by running it
   for example; `$ ./system_audit.sh`
  
6. Ensure the report has been generated and address any errors/software not installed as required.

### Configuration

The script only have one configuration value, which is for the name/output file
of the generated report.

> REPORTNAME=

### Requirements

This is a list of the programs that are current ran by each script to generate the report.

**system_security.sh**

- faillog
  <sub> - faillog displays the contents of the failure log database (/var/log/faillog). It can also
       set the failure counters and limits. When faillog is run without arguments, it only
       displays the faillog records of the users who had a login failure.</sub>
- find
  <sub> - GNU find searches the directory tree rooted at each given starting-point
       by evaluating the given expression from left to right, according
       to the rules of precedence (see section OPERATORS), until the
       outcome is known (the left hand side is false for and operations,
       true for or), at which point find moves on to the next file name.
       If no starting-point is specified, `.' is assumed.</sub>
- awk
<sub>  - The awk utility shall execute programs written in the awk
       programming language, which is specialized for textual data
       manipulation. An awk program is a sequence of patterns and
       corresponding actions. When input is read that matches a pattern,
       the action associated with that pattern is carried out.</sub>
- systemctl
<sub>   - systemctl may be used to introspect and control the state of the
       "systemd" system and service manager. Please refer to systemd(1)
       for an introduction into the basic concepts and functionality
       this tool manages.</sub>
- ss 
<sub>  - ss is used to dump socket statistics. It allows showing
       information similar to netstat.  It can display more TCP and
       state information than other tools.
</sub>

**system_audit.sh**

- w
  <sub> - w displays information about the users currently on the machine,
       and their processes.  The header shows, in this order, the
       current time, how long the system has been running, how many
       users are currently logged on, and the system load averages for
       the past 1, 5, and 15 minutes.</sub>
- ps
  <sub> - ps displays information about a selection of the active
       processes.  If you want a repetitive update of the selection and
       the displayed information, use top instead.</sub>
- lsof
  <sub> - lsof lists on its standard output file information
       about files opened by processes for the following UNIX dialects</sub>
