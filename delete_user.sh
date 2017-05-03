#!/bin/bash

#delete_user: automates the 4 steps to remove an account

#define functions
function get_answer {
unset ANSWER
ASK_COUNT=0
while [ -z "$ANSWER" ]
do
    ASK_COUNT=$[ $ASK_COUNT + 1 ]
    case $ASK_COUNT in
    2)
        echo "Please answer the question."
    ;;
    3)
        echo "One last try...please answer the question."
    ;;
    4)
        echo "Since you refuse to answer the question..."
        exit
    ;;
    esac
    echo 

    if [ -n "$LINE2" ]
    then                #print 2 line
        echo $LINE1
        echo -e $LINE2" \c"
    else                #print 1 line
        echo -e $LINE1" \c"
    fi

    #allow 60 seconds to answer before time-out
    read -t 60 ANSWER
done

#do a little variable clean-up
unset LINE1
unset LINE2
}

function process_answer {
case $ANSWER in
    y|Y|YES|yes)
    ;;
    *)
        echo $EXIT_LINE1
        echo $EXIT_LINE2
        exit
    ;;
esac

unset EXIT_LINE1
unset EXIT_LINE2
}

#######main script###########
#get name of user account to check
echo "Step #1 - Determine user account name to delete"
echo
LINE1="please enter the username of the user "
LINE2="account you wish to delete from system: "
get_answer
USER_ACCOUNT=$ANSWER

#double check with script user that this is the correct user account
LINE1="is $USER_ACCOUNT the user account "
LINE2="you wish to delete from the system? [y/n]"
get_answer

#call process_answer function:
EXIT_LINE1="because the account. $USER_ACCOUNT. is not "
EXIT_LINE2="the noe you wish to delete. we are leaving the script..."
process_answer

#check that UAER_ACCOUNT is really an account on the system
USER_ACCOUNT_RECORD=$(cat /etc/passwd | grep -w $USER_ACCOUNT)
if [ $? -eq 1 ]
then
    echo "account $user_account not found "
    echo ":leaving the script... "
    exit
fi

echo "I found this record: "
echo $USER_ACCOUNT_RECORD

LINE1="Is this the correct user account? [y/n]"
get_answer

#call process_answer function
EXIT_LINE1="because the account $UAER_ACCOUNT is not "
EXIT_LINE2="the one you wish to delete .we are leaving the script..."
process_answer


#search for any running process that belong to the user account
echo "Step #2: find process on system belong to user account"
echo
echo "$USER_ACCOUNT has the following process running: "
echo
ps -u $USER_ACCOUNT
case $? in
        1)
            echo "there are no process for this account currently running: "
            echo
        ;;
        0)
            unset ANSWER
            LINE1="would you like me to kill the process(es)? [y/n]"
            get_answer
            case $ANSWER in
                y|Y|yes|YES)
                    echo
                    #clean-up temp file upon signals
                    trap "rm $USER_ACCOUNT_Running_Process.rpt" SIGTERM SIGINT SIGQUIT
                    #list user process running
                    ps -u $USER_ACCOUNT > $USER_ACCOUNT_Running_Process.rpt
                    exec < $USER_ACCOUNT_Running_Process.rpt
                    read USER_PROCESS_REC
                    read USER_PROCESS_REC

                    while [ $? -eq 0 ]
                    do
                        #obtain PID
                        USER_PID=$(echo $USER_PROCESS_REC | cut -d "" -f1)
                        kill -9 $USER_PID
                        echo "killed process $USER_PID"
                        read USER_PROCESS_REC
                    done

                    rm $USER_ACCOUNT_Running_Process.rpt
                ;;
                *)
                    echo "will not kill the process(ES)"
                ;;
            esac
        ;;
esac

#create a report of all files owned by user account
echo "Step #3: find files on system belonging to user account"
echo
echo "creating a report of all files owned by $USER_ACCOUNT. "
echo
echo "it is recommended that you backup/archive these files. "
echo "and then do one of two things: "
echo " 1) delete the files"
echo " 2) change the files' ownership to a current user account. "
echo
echo "please wait. this may take a while..."

REPORT_DATE=`date +%y%m%d`
REPORT_FILE=$USER_ACCOUNT"_Files_"$REPORT_DATE".rpt"
find / -user $USER_ACCOUNT > $REPORT_FILE 2>/dev/null
echo
echo "report is complete. "
echo "name of report:  $REPORT_FILE"
echo "location of report: `pwd`"
echo

#remove user account
echo "Step #4: remove user account"
echo
LINE1="do you wish to remove $USER_ACCOUNT's account from system> [y/n]"
get_answer

#call process_answer function
EXIT_LINE1="since you do not wish to remove the user account."
EXIT_LINE2="$USER_ACCOUNT at this time. exiting the script..."
process_answer

userdel $USER_ACCOUNT
echo
echo "user account $USER_ACCOUNT has been removed"
echo

