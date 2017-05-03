#!/bin/bash
#update problem record in database

#determine sql location & set variable
MYSQL=`which mysql`"Problem_Trek -u cbres"

#obtain record id
if [ $# -eq 0 ]
then
    #check if any unfinished records exist.
    RECORDS_EXIST=`$MYSQL -Bse 'SELECT id_number FROM problem_logger WHERE fixed_date="0000-00-00" OR prob_solutions=""'`
    if [ "$RECORDS_EXIST" != "" ]
    then
        echo "the following records need updating..."
        $MYSQL <<EOF
        SELECT id_number, report_date, prob_symptoms FROM problem_logger WHERE fixed_date="0000-00-00" OR prob_solutions=""\G
EOF
    fi
    echo
    echo "what is the ID number for the"
    echo -e "problem you want to update?: \c"
    read ANSWER
    ID_NUMBER=$ANSWER
else
    ID_NUMBER=$1
fi

#obtain solution (aka fixed) date
echo
echo -e "was problem solved today? (y/n) \c"
read ANSWER
case $ANSWER in
    y|Y|yes|YES )
        FIXED_DATE=`date +%Y%m%d`
    ;;
    *)
        echo -e "what was the date of resolution? [YYYYMMDD] \c"
        read ANSWER
        FIXED_DATE=$ANSWER
    ;;
esac

#acquire problem solution
echo -e "briefly describe the problem solution: \c"
read ANSWER
PROB_SOLUTION=$ANSWER

#update problem record
echo "problem record updated as follows:"
$MYSQL <<EOF
UPDATE problem_logger SET prob_solutions="$PROB_SOLUTIONS", fixed_date=$FIXED_DATE WHERE id_number=$ID_NUMBER;
SELECT * FROM problem_logger WHERE id_number=$ID_NUMBER\G
EOF
