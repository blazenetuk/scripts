#!/usr/bin/python3

import os
import subprocess
from datetime import datetime, timedelta
from jinja2 import Template

# Configurable Options
LOG_FILE = "/var/log/sysstatus_report.log"  # Log file for output and errors
OUTPUT_HTML = "/var/log/sys_status_report.html"  # Output file for the HTML report
INTERVAL_HOURS = 3  # Configurable interval (e.g., 3 hours)
LAST_RUN_FILE = "/var/log/sysstatus_last_run"  # File to track the last run time
COMMANDS = {
    'failed_services': 'systemctl --type=service --state=failed',
    'corrupted_packages': 'debsums -ac',
    'journal_critical': 'journalctl -p 0 --no-pager -n 10',
    'journal_alert': 'journalctl -p 1 --no-pager -n 10',
    'journal_emergency': 'journalctl -p 2 --no-pager -n 10',
    'netstat_tcp': 'netstat -at',
    'netstat_udp': 'netstat -au',
    'top_cpu_processes': 'ps auxf | sort -nr -k 3 | head -10',
    'top_mem_processes': 'ps auxf | sort -nr -k 4 | head -10',
    'no_owner_files': 'find / -xdev \( -nouser -o -nogroup \) -print',
    'setuid_setgid_files': 'find / -xdev -type f \( -perm -4000 -o -perm -2000 \) -print',
    'world_writable_files': 'find / -xdev -type f -perm -o+w -print',
    'disk_usage': 'df -h',
    'iostat': 'iostat -x 1 5',
    'uptime': 'uptime',
    'network_stats': 'ip -s link'
}

# HTML Template for the report
HTML_TEMPLATE = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>System Status Report</title>
    <style>
        body {
            font-family: 'Arial', sans-serif;
            background-color: #f4f7f9;
            color: #333;
            margin: 0;
            padding: 0;
        }
        h1 {
            background-color: #3a6ea5;
            color: #fff;
            text-align: center;
            padding: 20px 0;
            margin: 0;
        }
        h2 {
            color: #3a6ea5;
            border-bottom: 2px solid #3a6ea5;
            padding-bottom: 5px;
        }
        .container {
            max-width: 800px;
            margin: 20px auto;
            padding: 20px;
            background-color: #fff;
            box-shadow: 0 0 15px rgba(0, 0, 0, 0.1);
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 20px;
        }
        table, th, td {
            border: 1px solid #ddd;
        }
        th {
            background-color: #3a6ea5;
            color: #fff;
            padding: 10px;
        }
        td {
            padding: 10px;
            text-align: left;
        }
        tr:nth-child(even) {
            background-color: #f2f7fa;
        }
        tr:hover {
            background-color: #eaf2f9;
        }
        .no-data {
            text-align: center;
            padding: 10px;
            color: #666;
            background-color: #f4f7f9;
        }
        .footer {
            text-align: center;
            padding: 10px;
            font-size: 0.9em;
            color: #999;
        }
    </style>
</head>
<body>
    <h1>System Status Report for {{ hostname }}</h1>
    <div class="container">
        {% if failed_services %}
        <h2>Failed Services</h2>
        <table>
            <tr><th>Service Name</th><th>Status</th></tr>
            {% for service in failed_services %}
            <tr><td>{{ service.name }}</td><td>{{ service.status }}</td></tr>
            {% endfor %}
        </table>
        {% else %}
        <p class="no-data">No failed services found.</p>
        {% endif %}

        {% if corrupted_packages %}
        <h2>Corrupted Packages</h2>
        <table>
            <tr><th>Package</th></tr>
            {% for package in corrupted_packages %}
            <tr><td>{{ package }}</td></tr>
            {% endfor %}
        </table>
        {% else %}
        <p class="no-data">No corrupted packages found.</p>
        {% endif %}

        {% if top_cpu_processes %}
        <h2>Top 10 CPU-Intensive Processes</h2>
        <table>
            <tr><th>PID</th><th>User</th><th>CPU %</th><th>Command</th></tr>
            {% for proc in top_cpu_processes %}
            <tr><td>{{ proc.pid }}</td><td>{{ proc.user }}</td><td>{{ proc.cpu }}</td><td>{{ proc.command }}</td></tr>
            {% endfor %}
        </table>
        {% else %}
        <p class="no-data">No CPU-intensive processes found.</p>
        {% endif %}

        {% if top_mem_processes %}
        <h2>Top 10 Memory-Intensive Processes</h2>
        <table>
            <tr><th>PID</th><th>User</th><th>Memory %</th><th>Command</th></tr>
            {% for proc in top_mem_processes %}
            <tr><td>{{ proc.pid }}</td><td>{{ proc.user }}</td><td>{{ proc.memory }}</td><td>{{ proc.command }}</td></tr>
            {% endfor %}
        </table>
        {% else %}
        <p class="no-data">No memory-intensive processes found.</p>
        {% endif %}

        {% if no_owner_files %}
        <h2>Files with No Owner or Group</h2>
        <table>
            <tr><th>File Path</th></tr>
            {% for file in no_owner_files %}
            <tr><td>{{ file }}</td></tr>
            {% endfor %}
        </table>
        {% else %}
        <p class="no-data">No files with missing ownership found.</p>
        {% endif %}

        {% if setuid_setgid_files %}
        <h2>SetUID and SetGID Files</h2>
        <table>
            <tr><th>File Path</th></tr>
            {% for file in setuid_setgid_files %}
            <tr><td>{{ file }}</td></tr>
            {% endfor %}
        </table>
        {% else %}
        <p class="no-data">No SetUID or SetGID files found.</p>
        {% endif %}

        {% if world_writable_files %}
        <h2>World-Writable Files</h2>
        <table>
            <tr><th>File Path</th></tr>
            {% for file in world_writable_files %}
            <tr><td>{{ file }}</td></tr>
            {% endfor %}
        </table>
        {% else %}
        <p class="no-data">No world-writable files found.</p>
        {% endif %}

        {% if disk_usage %}
        <h2>Disk Usage</h2>
        <pre>{{ disk_usage }}</pre>
        {% else %}
        <p class="no-data">No disk usage information available.</p>
        {% endif %}

        {% if iostat %}
        <h2>I/O Statistics</h2>
        <pre>{{ iostat }}</pre>
        {% else %}
        <p class="no-data">No I/O statistics available.</p>
        {% endif %}

        {% if uptime %}
        <h2>System Uptime and Load</h2>
        <pre>{{ uptime }}</pre>
        {% else %}
        <p class="no-data">No uptime information available.</p>
        {% endif %}

        {% if network_stats %}
        <h2>Network Interface Statistics</h2>
        <pre>{{ network_stats }}</pre>
        {% else %}
        <p class="no-data">No network statistics available.</p>
        {% endif %}

    </div>

    <div class="footer">
        Report generated on {{ current_time }}
    </div>
</body>
</html>
"""

def run_command(command):
    """Run a shell command and return the output."""
    result = subprocess.run(command, shell=True, capture_output=True, text=True)
    return result.stdout.strip()

def check_last_run():
    """Check if the script has run within the last INTERVAL_HOURS."""
    if os.path.exists(LAST_RUN_FILE):
        with open(LAST_RUN_FILE, 'r') as f:
            last_run = f.read().strip()
        last_run_time = datetime.strptime(last_run, '%Y-%m-%d %H:%M:%S')
        if datetime.now() - last_run_time < timedelta(hours=INTERVAL_HOURS):
            return False
    return True

def update_last_run():
    """Update the timestamp of the last run."""
    with open(LAST_RUN_FILE, 'w') as f:
        f.write(datetime.now().strftime('%Y-%m-%d %H:%M:%S'))

def generate_html_report(failed_services, corrupted_packages, top_cpu_processes, top_mem_processes, no_owner_files, setuid_setgid_files, world_writable_files, disk_usage, iostat, uptime, network_stats):
    hostname = run_command("hostname")
    current_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    template = Template(HTML_TEMPLATE)
    html_content = template.render(
        hostname=hostname,
        current_time=current_time,
        failed_services=failed_services,
        corrupted_packages=corrupted_packages,
        top_cpu_processes=top_cpu_processes,
        top_mem_processes=top_mem_processes,
        no_owner_files=no_owner_files,
        setuid_setgid_files=setuid_setgid_files,
        world_writable_files=world_writable_files,
        disk_usage=disk_usage,
        iostat=iostat,
        uptime=uptime,
        network_stats=network_stats
    )
    with open(OUTPUT_HTML, 'w') as f:
        f.write(html_content)

def main():
    # Check if the script should run (every INTERVAL_HOURS)
    if not check_last_run():
        print("Skipping execution; it's not time yet.")
        return

    # Fetch system data
    failed_services = run_command(COMMANDS['failed_services'])
    corrupted_packages = run_command(COMMANDS['corrupted_packages'])
    top_cpu_processes = run_command(COMMANDS['top_cpu_processes'])
    top_mem_processes = run_command(COMMANDS['top_mem_processes'])
    no_owner_files = run_command(COMMANDS['no_owner_files'])
    setuid_setgid_files = run_command(COMMANDS['setuid_setgid_files'])
    world_writable_files = run_command(COMMANDS['world_writable_files'])
    disk_usage = run_command(COMMANDS['disk_usage'])
    iostat = run_command(COMMANDS['iostat'])
    uptime = run_command(COMMANDS['uptime'])
    network_stats = run_command(COMMANDS['network_stats'])

    # Generate report
    generate_html_report(failed_services, corrupted_packages, top_cpu_processes, top_mem_processes, no_owner_files, setuid_setgid_files, world_writable_files, disk_usage, iostat, uptime, network_stats)

    # Update last run time
    update_last_run()

    print(f"Report generated: {OUTPUT_HTML}")

if __name__ == "__main__":
    main()
