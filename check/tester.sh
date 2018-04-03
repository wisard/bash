#!/bin/bash

#
# This script will print a nice test result report
# Easy to add/remove test cases and hosts for execution
#

Init()
{

 group1_selinux="on"
 group1_userid="1000"
 group1_remoute_user=wisard
 DEBUG=false
 VM_LIST="\
 localhost
 remote\
 "
 for i in `ls -1 | grep '[a-zA-Z0-9].tst$'`; do
    echo "sourcing $i"
    source "${i}" || exit 1
 done

}

Usage()
{
echo "Usage: ${0} <options>

Options:
 -v   VM to verify ( group1=VM group1, group2=VM group2, ...)
 -d   Enable debug mode
 -h   Pring this help
"

exit ${1:-0} 

}

Result()
{

if [[ "x${1}" == "x0" ]]; then
  printf "\033[1;32m OK \033[0m \n"
elif [[ "x${1}" == "x1" ]]; then
  printf "\033[31m NOT OK \033[0m \n"
else
  printf "\033[00;33m NOT DEFINED \033[00m\n"
fi

}

group1_verify()
{

for node in ${VM_LIST[*]}; do

    printf "\n\nChecking node $node:\n"
    printf "$header" "TEST" "OK VALUE" "CURRENT VALUE" "STATUS"

    REMOTE="ssh ${SSH_ARGS} $group1_remoute_user@$node"

    # Declare associated array to associate good results with particular tests
    # since good result may vary based on a target group

    declare -A TEST
    TEST=( \
    ["test_selinux"]="${group1_selinux}" \
    ["test_userid"]="${group1_userid}"\
    )

    for test in ${!TEST[@]}; do
        #TODO: to add error message if test doesn't exist
        ${test//_[0-9]/} ${TEST[$test]} 
        status=$( Result $? )
        printf "$format" "${test}" "${OKVALUE}" "${CURRENT:=ERROR}" "[ ${status} ]"
    done

done

}

group2_verify()
{

printf "To be added"

}

main()
{

[ "$#" -lt 1 ] && Usage 1;

Init || exit 1

# Report format
header="\n %1s %20s %10s %10s\n"
format=" %1s %20s %10s %10s\n"

while [ "$#" -ne 0 ]; do

	case "${1}" in
# TODO: Add validation for second argument
	  -g|--group) [[ "${2}" == "group1" ]] && TESTIT=group1_verify;
                   [[ "${2}" == "group2" ]] && TESTIT=group2_verify;
                   shift 2 ;;
	  -d|--debug) DEBUG=true; shift ;;
	  -h|--help) Usage ; exit 0 ;;
	   *) echo "Unknown option ${1}" && Usage ; exit 1 ;;
	esac

done

if ${DEBUG} ; then 
   printf "[debug] ${all_checks[*]}\n"
fi

$TESTIT 

exit $?
}

main "$@"


