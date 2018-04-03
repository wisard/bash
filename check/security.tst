test_userid()
{

CURRENT=""
OKVALUE="${1}"

CURRENT=$( $REMOTE id -u wisard 2>/dev/null )

if [[ "x${CURRENT}" != "x${OKVALUE}" ]]; then
        return 1
else
        return 0
fi

}

test_selinux()
{
CURRENT=""
OKVALUE=${1}

CURRENT=$( $REMOTE sestatus 2>/dev/null| sed -n 's/SELinux status: *\(.*\)$/\1/p' )

if ! [[ "$CURRENT" =~ (disabled|enabled) ]]; then
   CURRENT=$( $REMOTE sestatus 2>/dev/null| sed -n 's/Current mode: *\(.*\)$/\1/p')
fi
[[ "$CURRENT" =~ (disabled|permissive) ]] && CURRENT=off
[[ "$CURRENT" =~ (enabled|enforcing) ]] && CURRENT=on

if [[ "x${CURRENT}" != "x${OKVALUE} " ]]; then
        return 1
else
        return 0
fi

}

