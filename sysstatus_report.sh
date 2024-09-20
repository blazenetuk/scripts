#!/usr/bin/bash

# Log file to analyze (replace with actual path if needed)
LOG_FILE="/home/<some user>/auth.log"

# The filename to use for the html report
OUTPUT_HTML="report.html"

# Get today's date in the format of the log system log file
TODAYS_DATE=$(date +"%b %d")

# Get the current time
CURRENT_TIME=$(date +"%H:%M")

# Get the time two hours ago
TWO_HOURS_AGO=$(date -d '2 hours ago' +"%H:%M")

# delete the old file as we will update
if [ -f $OUTPUT_HTML ]; then
 rm $OUTPUT_HTML
fi

# Updated HTML Code for better email format
# The Color Scheme is currently BLUE

# Create or overwrite the HTML report file
echo "<html>" > $OUTPUT_HTML
echo "<head><title>System Report $(hostname)</title></head>" >> $OUTPUT_HTML

# Add inline CSS for email-friendly formatting
echo "<body style='font-family: Arial, sans-serif; background-color: #f4f4f9; color: #333;'>" >> $OUTPUT_HTML
echo "<h1 style='color: #0044cc;'>System Report</h1>" >> $OUTPUT_HTML

# Netstat TCP Connections
echo "<h2 style='color: #0044cc;'>Netstat TCP Connections (-at)</h2>" >> $OUTPUT_HTML
echo "<table border='1' cellpadding='5' cellspacing='0' style='width: 100%; border-collapse: collapse;'>" >> $OUTPUT_HTML
echo "<tr style='background-color: #0044cc; color: white;'><th>Proto</th><th>Local Address</th><th>Foreign Address</th><th>State</th></tr>" >> $OUTPUT_HTML
netstat -at | tail -n +3 | while read proto local_addr foreign_addr state; do
    echo "<tr><td style='border: 1px solid #ddd;'>$proto</td><td style='border: 1px solid #ddd;'>$local_addr</td><td style='border: 1px solid #ddd;'>$foreign_addr</td><td style='border: 1px solid #ddd;'>$state</td></tr>" >> $OUTPUT_HTML
done
echo "</table>" >> $OUTPUT_HTML

# Netstat UDP Connections
echo "<h2 style='color: #0044cc;'>Netstat UDP Connections (-au)</h2>" >> $OUTPUT_HTML
echo "<table border='1' cellpadding='5' cellspacing='0' style='width: 100%; border-collapse: collapse;'>" >> $OUTPUT_HTML
echo "<tr style='background-color: #0044cc; color: white;'><th>Proto</th><th>Local Address</th><th>Foreign Address</th></tr>" >> $OUTPUT_HTML
netstat -au | tail -n +3 | while read proto local_addr foreign_addr; do
    echo "<tr><td style='border: 1px solid #ddd;'>$proto</td><td style='border: 1px solid #ddd;'>$local_addr</td><td style='border: 1px solid #ddd;'>$foreign_addr</td></tr>" >> $OUTPUT_HTML
done
echo "</table>" >> $OUTPUT_HTML

# Table of log entries by today's date only
echo "<h2 style='color: #0044cc;'>Log Entries (Past 2 hours)</h2>" >> $OUTPUT_HTML
echo "<table border='1' cellpadding='5' cellspacing='0' style='width: 100%; border-collapse: collapse;'>" >> $OUTPUT_HTML
echo "<tr style='background-color: #0044cc; color: white;'><th>Date</th><th>Message</th></tr>" >> $OUTPUT_HTML

# Filter logs by today's date and the last two hours
grep "$TODAYS_DATE" $LOG_FILE | awk -v current_time="$CURRENT_TIME" -v two_hours_ago="$TWO_HOURS_AGO" '
{
    # Extract the time (hour:minute) from the log line (4th field)
    log_time = substr($3, 1, 5)

    # Check if the log time is between two_hours_ago and current_time
    if (log_time >= two_hours_ago && log_time <= current_time) {
        # Print log entry with date and message (cut off the first 5 fields for the message)
        print "<tr><td style=\"border: 1px solid #ddd;\">" $1, $2, $3 "</td><td style=\"border: 1px solid #ddd;\">" substr($0, index($0,$6)) "</td></tr>"
    }
}' >> $OUTPUT_HTML

echo "</table>" >> $OUTPUT_HTML

# Function to add journalctl output, check if "-- No entries --" is returned
add_journalctl_section() {
    PRIORITY=$1
    TITLE=$2

    echo "<h2 style='color: #0044cc;'>Journalctl Output (Priority $PRIORITY - $TITLE)</h2>" >> $OUTPUT_HTML
    echo "<table border='1' cellpadding='5' cellspacing='0' style='width: 100%; border-collapse: collapse;'>" >> $OUTPUT_HTML
    echo "<tr style='background-color: #0044cc; color: white;'><th>Date</th><th>Time</th><th>Message</th></tr>" >> $OUTPUT_HTML

    # Capture the journalctl output
    JOURNAL_OUTPUT=$(journalctl -p $PRIORITY -n 5 --no-pager)

    if [[ "$JOURNAL_OUTPUT" == *"-- No entries --"* ]]; then
        echo "<tr><td colspan='3' style='text-align: center;'>No current issues logged</td></tr>" >> $OUTPUT_HTML
    else
        echo "$JOURNAL_OUTPUT" | while read date time message; do
            echo "<tr><td style='border: 1px solid #ddd;'>$date</td><td style='border: 1px solid #ddd;'>$time</td><td style='border: 1px solid #ddd;'>$message</td></tr>" >> $OUTPUT_HTML
        done
    fi

    echo "</table>" >> $OUTPUT_HTML
}

# Add sections for different journal priorities
add_journalctl_section 2 "Critical"
add_journalctl_section 1 "Alert"
add_journalctl_section 0 "Emergency"

# Close HTML tags
echo "</body></html>" >> $OUTPUT_HTML

# we are going to be running from crontab so don't confirm report generated
# Print completion message
# if you are running this from a crontab, you should
# comment this out with '#'
echo "Report generated: $OUTPUT_HTML"
