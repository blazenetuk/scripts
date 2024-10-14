#!/usr/bin/env python3

import os
import subprocess
from datetime import datetime
import logging
import fcntl
from jinja2 import Template

# Configurable Options
LOG_FILE = "/var/log/sysstatus_report.log"  # Log file for output and errors
OUTPUT_HTML = "/var/log/sys_status_report.html"  # Output file for the HTML report
LOCK_FILE = "/var/lock/sysstatus_report.lock"  # Lock file to prevent concurrent execution
MAIL_CONFIG = {
    'enabled': True,  # Enable/disable email sending
    'recipient': 'reports@myserver.com',  # Recipient email address
    'subject': 'System Status Report',  # Email subject
    'mail_command': '/usr/bin/mail -a "Content-type: text/html" -s "{subject}" {recipient} < {html_file}'  # Command to send mail
}

# Commands to gather system data
COMMANDS = {
    'failed_services': 'systemctl --type=service --state=failed',
    'package_updates': 'apt list --upgradeable 2>/dev/null',
    'top_cpu_processes': 'ps auxf | sort -nr -k 3 | head -10',
    'top_mem_processes': 'ps auxf | sort -nr -k 4 | head -10',
    'no_owner_files': 'find / -xdev \( -nouser -o -nogroup \) -print',
    'setuid_setgid_files': 'find / -xdev -type f \( -perm -4000 -o -perm -2000 \) -print',
    'world_writable_files': 'find / -xdev -type f -perm -o+w -print',
    'disk_usage': 'df -h',
    'iostat': 'iostat -x 1 5',
    'uptime': 'uptime',
    'network_stats_tcp': 'netstat -at',
    'network_stats_udp': 'netstat -au',
    'memory_usage': 'free -h',
    'load_average': 'uptime | awk \'{print "Load average: " $10 " " $11 " " $12}\'',
    'auth_log': 'grep "Failed password" /var/log/auth.log',  # Check for failed logins
    'journal_crit': 'journalctl -p 0 -n 15 --no-pager',  # Priority 0 (Emergency)
    'journal_alert': 'journalctl -p 1 -n 15 --no-pager',  # Priority 1 (Alert)
    'journal_crit': 'journalctl -p 2 -n 15 --no-pager',  # Priority 2 (Critical)
    'journal_error': 'journalctl -p 3 -n 15 --no-pager',  # Priority 3 (Error)
    'journal_warning': 'journalctl -p 4 -n 15 --no-pager',  # Priority 4 (Warning)
}

# HTML Template for the report
HTML_TEMPLATE = """
<!DOCTYPE html>
<html>
<head>
    <title>System Status Report</title>
    <style>
        body { font-family: Arial, sans-serif; }
        table { width: 100%; border-collapse: collapse; margin-bottom: 20px; }
        table, th, td { border: 1px solid #000; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
        h1, h2 { font-family: Arial, sans-serif; }
    </style>
</head>
<body>
    <h1>System Status Report for {{ hostname }}</h1>
    <p>Report generated on {{ current_time }}</p>

    {% for section_title, section_data in sections.items() %}
    <h2>{{ section_title }}</h2>
    <table>
        <tr><td><pre>{{ section_data }}</pre></td></tr>
    </table>
    {% endfor %}
</body>
</html>
"""

def setup_logging():
    logging.basicConfig(
        filename=LOG_FILE,
        level=logging.INFO,
        format='%(asctime)s %(levelname)s:%(message)s',
        datefmt='%Y-%m-%d %H:%M:%S'
    )
    console = logging.StreamHandler()
    console.setLevel(logging.ERROR)
    formatter = logging.Formatter('%(asctime)s %(levelname)s:%(message)s')
    console.setFormatter(formatter)
    logging.getLogger('').addHandler(console)

def run_command(command):
    """Run a shell command and return the output."""
    try:
        result = subprocess.run(command, shell=True, capture_output=True, text=True, timeout=300)
        if result.returncode != 0:
            logging.error(f"Command failed: {command}\nError: {result.stderr.strip()}")
            return f"Error: {result.stderr.strip()}"
        return result.stdout.strip()
    except subprocess.TimeoutExpired:
        logging.error(f"Command timed out: {command}")
        return "Error: Command timed out."

def gather_system_data():
    """Gather system data and return it as a dictionary."""
    data = {}
    data['hostname'] = run_command("hostname")
    data['current_time'] = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    sections = {}
    for section_name, command in COMMANDS.items():
        sections[section_name.replace("_", " ").title()] = run_command(command)

    return {
        'hostname': data['hostname'],
        'current_time': data['current_time'],
        'sections': sections
    }

def generate_html_report(data):
    """Generate the HTML report using Jinja2."""
    template = Template(HTML_TEMPLATE)
    html_content = template.render(data)

    try:
        with open(OUTPUT_HTML, 'w') as f:
            f.write(html_content)
        logging.info(f"Report generated: {OUTPUT_HTML}")
    except Exception as e:
        logging.error(f"Failed to write HTML report: {e}")

def mail_report():
    """Mail the generated HTML report."""
    if MAIL_CONFIG['enabled']:
        mail_command = MAIL_CONFIG['mail_command'].format(
            subject=MAIL_CONFIG['subject'],
            recipient=MAIL_CONFIG['recipient'],
            html_file=OUTPUT_HTML
        )
        try:
            result = subprocess.run(mail_command, shell=True, capture_output=True, text=True)
            if result.returncode != 0:
                logging.error(f"Mail command failed: {result.stderr.strip()}")
            else:
                logging.info(f"Mail sent to {MAIL_CONFIG['recipient']}")
        except Exception as e:
            logging.error(f"Failed to send email: {e}")

def acquire_lock(lock_file):
    """Acquire a file lock to prevent concurrent executions."""
    try:
        lock_fd = open(lock_file, 'w')
        try:
            fcntl.flock(lock_fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
            return lock_fd
        except IOError:
            logging.error("Another instance of the script is running.")
            sys.exit(1)
    except IOError as e:
        logging.error(f"Error opening lock file: {e}")
        sys.exit(1)

def release_lock(lock_fd):
    """Release the lock and close the file descriptor."""
    try:
        fcntl.flock(lock_fd, fcntl.LOCK_UN)
        lock_fd.close()
    except IOError as e:
        logging.error(f"Error releasing lock: {e}")

def main():
    setup_logging()

    # Acquire lock to prevent concurrent runs
    lock_fd = acquire_lock(LOCK_FILE)

    try:
        # Gather system data
        data = gather_system_data()

        # Generate HTML report
        generate_html_report(data)

        # Mail the report
        mail_report()

    finally:
        release_lock(lock_fd)

if __name__ == "__main__":
    main()
