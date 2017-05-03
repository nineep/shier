#!/bin/bash
#record system problem in database

#determine mysql location & put into variable
MYSQL=`which mysql`"Problem_Trek -u cbres"

#create record id & Report_Date
ID_NUMBER=`date +%y%m%d%H%M`
REPORT_DATE=`date +%Y%m%d`

#acquire information to put into table
echo -e "Briefly describe the problem & its symptoms: \c"
read ANSWER
PROB_SYMPTOMS=$ANSWER
#set fixed date & problem solution to null for now
FIXED_DATE=0
PROB_SOLUTIONS=""

#insert acquired information into table
echo "problem recorded as follows:"
$MYSQL <<EOF
INSERT INTO problem_logger VALUES (
    $ID_NUMBER,
    $REPORT_DATE,
    $FIXED_DATE,
    "$PROB_SYMPTOMS",
    "$PROB_SOLUTIONS");
SELECT * FROM problem_logger WHERE id_number=$ID_NUMBER\G
EOF
