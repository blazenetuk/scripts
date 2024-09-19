# Overview

This is a collection of bash/shell scripts to assist in linux server administration
designed to be run by a Unix shell, a command-line interpreter to assist in
automating, management and reporting tasks.

# Prerequisites
<br></br>
**Bash (the Bourne Again SHell) - version 5.1+**

**Linux/Unix System**

> [!IMPORTANT]
> Other versions of bash are not tested/support, for testing you can utilise [Shell Check](https://www.shellcheck.net/)
> 
> The scripts have not been designed to work with non-unix/linux systems

**The scripts are very basic and easy to use/customise**

<br></br>
## **SURE - System Utilization and Risk Evaluation**
<br></br>
<!-- SPACE -->
### :basecamp: System Audit Report
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
 <br></br>
  <!-- SPACE -->
### :basecamp: System Security Report
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


<br></br>
## **ALERT - Auth Log and Event Reporting Tool**
<br></br>
<!-- SPACE -->
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
