#!/usr/bin/bash

# File name to use for the
# audit report
REPORTNAME="sysaudit.log"

# Check if the file already
# exists, if so delete it
if [ -f $REPORTNAME ]; then
 rm "$REPORTNAME"
fi

# Generate the report
echo "================= SYSTEM AUDIT" | tee $REPORTNAME
echo "  " | tee -a $REPORTNAME
echo "- Current Users: " | tee -a $REPORTNAME
w -f | tee -a $REPORTNAME
echo "  " | tee -a $REPORTNAME
echo "- Running Proc: " | tee -a $REPORTNAME
echo "	" | tee -a $REPORTNAME
ps -eo euser,ruser,suser,fuser,f,comm,label | tee -a $REPORTNAME
echo "	" | tee -a $REPORTNAME
echo "- TOP 10 Memory Usage: " | tee -a $REPORTNAME
echo "	" | tee -a $REPORTNAME
ps -auxf | sort -nr -k 4 | head -10 | tee -a $REPORTNAME
echo "	" | tee -a $REPORTNAME
echo "- TOP 10 CPU Usage: " | tee -a $REPORTNAME
echo "	" | tee -a $REPORTNAME
ps -auxf | sort -nr -k 3 | head -10 | tee -a $REPORTNAME
echo "	" | tee -a $REPORTNAME
echo "- OPEN Files (Sockets ..etc): " | tee -a $REPORTNAME
echo "	" | tee -a $REPORTNAME
lsof | tee -a $REPORTNAME
echo "	" | tee -a $REPORTNAME
echo "================= END OF SYSTEM AUDIT" | tee -a $REPORTNAME

# END