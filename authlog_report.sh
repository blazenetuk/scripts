#!/usr/bin/bash

# Settings/Variable
LOG_FILE="/home/<some user>/auth.log"   # Path/Directory to your log file 'authlog' file
OUTPUT_HTML="/home/<some user>/authlog.html"  # Path/Directory and File name for the html report

# Get the current date and time
CURRENT_DATE=$(date +"%b %d %H:%M:%S")

# Get the date and time 3 hours ago
PAST_DATE=$(date --date="3 hours ago" +"%b %d %H:%M:%S")

# Defines the name of the server
MY_NAME=$(hostname)

# Start the HTML file with basic structure and styles
# Style color is RED
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
    <h1>Authentication Report for $MY_NAME</h1>
    <table>
        <caption>Connection Attempts</caption>
        <tr>
            <th>Timestamp</th>
            <th>Username</th>
            <th>IP Address</th>
        </tr>
EOF

# Process the log file to extract entries from the past 3 hours
awk -v past_date="$PAST_DATE" -v current_date="$CURRENT_DATE" '
{
    log_time = sprintf("%s %s %s", $1, $2, $3);
    if (log_time >= past_date && log_time <= current_date) {
        print $0;
    }
}' "$LOG_FILE" | grep -E "Accepted|Failed password|session opened" | while read -r line; do
    # Extract timestamp
    timestamp=$(echo "$line" | awk '{print $1, $2, $3}')

    # Extract username correctly (handles both "invalid user" and normal cases)
    # or applies 'N/A' if unknown or not found
    username=$(echo "$line" | grep -oP "for (invalid user |user )\K\w+" || echo "N/A")

    # Extract IP address
    ip=$(echo "$line" | grep -oP "(\d{1,3}\.){3}\d{1,3}")

    # If the IP is blank, skip this entry
    # prevents a lot of false entries
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

# Close the HTML output
cat <<EOF >> "$OUTPUT_HTML"
    </table>
</body>
</html>
EOF

# Print success message
# -- if running from crontab
#    Please comment this out by putting
#    '#' before the word 'echo'
echo "HTML report generated: $OUTPUT_HTML"