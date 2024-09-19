#!/usr/bin/bash

# File name to use for the
# security report
REPORTNAME="securityreport.log"

# If the file exists delete it 
if [ -f $REPORTNAME ]; then
 rm "$REPORTNAME"
fi

# Generate the report output
echo "================= SYSTEM SECURITY REPORT" | tee $REPORTNAME
echo "  " | tee -a $REPORTNAME
echo "- FAILLOG:" | tee -a $REPORTNAME
faillog -a | tee -a $REPORTNAME
echo "  " | tee -a $REPORTNAME
echo "- CURRENT NO OWNER FILES: " | tee -a $REPORTNAME
find / -xdev \( -nouser -o -nogroup \) -print | tee -a $REPORTNAME
echo " " | tee -a $REPORTNAME
echo "- SECURITY CHECK FOR PASSWORD AND SHADOW:" | tee -a $REPORTNAME
awk -F: '($3 == "0") {print}' /etc/passwd | tee -a $REPORTNAME
awk -F: '($2 == "") {print}' /etc/shadow | tee -a $REPORTNAME
echo " " | tee -a $REPORTNAME
echo "- CURRENT SERVICES STATUS:" | tee -a $REPORTNAME
echo " " | tee -a $REPORTNAME
systemctl list-unit-files --type=service | tee -a $REPORTNAME
echo " " | tee -a $REPORTNAME
echo "- SET GID FILES:" | tee -a $REPORTNAME
find / -perm 2000 | tee -a $REPORTNAME
echo " " | tee -a $REPORTNAME
echo "- SET UID FILES:" | tee -a $REPORTNAME
find / -perm 4000 | tee -a $REPORTNAME
echo "  " | tee -a $REPORTNAME
echo "- WORLD WRITEABLE FILES:" | tee -a $REPORTNAME
find / -xdev -type d \( -perm -0002 -a ! -perm -1000 \) -print | tee -a $REPORTNAME
echo "  " | tee -a $REPORTNAME
echo "- CURRENT OPEN PORTS -" | tee -a $REPORTNAME
echo "	" | tee -a $REPORTNAME
ss -tual | tee -a $REPORTNAME
echo "================= END OF SECURITY REPORT" | tee -a $REPORTNAME

# END