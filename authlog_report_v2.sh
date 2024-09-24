#!/usr/bin/bash

# Configuration

# Path to Auth Log
LOG_FILE="/path/to/your/auth.log"

# The Path and File name to use to output the HTML report
OUTPUT_HTML="/path/to/output.html"

# Command to execute once the report has been generated
# Example to email the command:
#  COMMAND="mail -a "Content-type: text/html"  -s 'Auth Log Report ($hostname) - $date' youremail@example.com < $OUTPUT_HTML"
COMMAND="your-command-here"

# Get the current date and time
CURRENT_DATE=$(date +"%b %d %H:%M:%S")

# Get the date and time 3 hours ago
PAST_DATE=$(date --date="3 hours ago" +"%b %d %H:%M:%S")

# Filter the log file entries for the past date above
LOG_ENTRIES=$(awk -v past_date="$PAST_DATE" -v current_date="$CURRENT_DATE" '
{
    log_time = sprintf("%s %s %s", $1, $2, $3);
    if (log_time >= past_date && log_time <= current_date) {
        print $0;
    }
}' "$LOG_FILE" | grep -E "Accepted|Failed password|session opened")

# Check if there are any log entries found
if [[ -z "$LOG_ENTRIES" ]]; then
    echo "No connection attempts found in the configured time frame."
    exit 0  # Exit the script if no entries are found
fi

# If we have log entries, proceed with generating the HTML report
# Start the HTML file with basic structure and styles
cat <<EOF > "$OUTPUT_HTML"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Auth Log Report</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f8f8f8;
            color: #333;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin: 20px 0;
        }
        table, th, td {
            border: 1px solid #ddd;
        }
        th, td {
            padding: 10px;
            text-align: left;
        }
        th {
            background-color: #b30000;
            color: white;
        }
        tr:nth-child(even) {
            background-color: #f2f2f2;
        }
        tr:hover {
            background-color: #f5c6c6;
        }
        caption {
            font-size: 1.5em;
            margin-bottom: 10px;
            color: #b30000;
        }
    </style>
</head>
<body>
    <h1>Authentication Log Report (Past 3 Hours)</h1>
    <table>
        <caption>Connection Attempts</caption>
        <tr>
            <th>Timestamp</th>
            <th>Username</th>
            <th>IP Address</th>
        </tr>
EOF

# Process the log entries
echo "$LOG_ENTRIES" | while read -r line; do
    # Extract timestamp
    timestamp=$(echo "$line" | awk '{print $1, $2, $3}')
    
    # Extract username, handling "invalid user" and "user" cases
    username=$(echo "$line" | grep -oP "for (invalid user |user )\K\w+" || echo "N/A")

    # Extract IP address
    ip=$(echo "$line" | grep -oP "(\d{1,3}\.){3}\d{1,3}")

    # If the IP is blank, skip this entry
    # otherwise we just have duplicates and blank entries
    if [[ -z "$ip" ]]; then
        continue
    fi

    # Append the details as a table row to the HTML file
    echo "        <tr>" >> "$OUTPUT_HTML"
    echo "            <td>$timestamp</td>" >> "$OUTPUT_HTML"
    echo "            <td>$username</td>" >> "$OUTPUT_HTML"
    echo "            <td>$ip</td>" >> "$OUTPUT_HTML"
    echo "        </tr>" >> "$OUTPUT_HTML"
done

# Close the HTML structure
cat <<EOF >> "$OUTPUT_HTML"
    </table>
</body>
</html>
EOF

# Print success message
echo "HTML report generated: $OUTPUT_HTML"

# Execute the specified command after generating report
$COMMAND
