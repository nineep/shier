#!/bin/bash
#finds problem records using keywords

#determine sql location & set variable
MYSQL=`which mysql`"Problem_Trek -u cbres"

#obtain keyword(s)
if [ -n "$1" ]
then
    KEYWORDS=$@   #grab all the params as separate words,same string
else
    echo "what keywords would you like to search for?"
    echo -e "please separate words by a space: \c"
    read ANSWER
    KEYWORDS=$ANSWER
fi

#find problem record
echo
echo "the following was found using keywords: $KEYWORDS"
KEYWORDS=`echo $KEYWORDS | sed 's/ /|/g'`
$MYSQL <<EOF
SELECT * FROM problem_logger WHERE prob_symptoms REGEXP '($KEYWORDS)' OR prob_solutions REGEXP '($KEYWORDS)"\G
EOF
