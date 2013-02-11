#!/bin/sh

describe "areafix"

. ./testcommon.sh

before () {
	setup_crashmail_env
	setup_tmpfile
}

after () {
	clean_crashmail_env
	clean_tmpfile
}

# Tests that crashmail returns an area list in
# response to a %LIST request.
it_generates_area_list () {
	echo %LIST |
	$__tools__/crashwrite dir spool/inbound \
		fromname "Test User" fromaddr 99:99/88 \
		toname "Areafix" toaddr 99:99/1 \
		subject "TESTPASS" \
		text /dev/stdin

	$__crashmail__ toss | tee $tmpfile
	grep 'AreaFix: Sending list of areas to 99:99/88.0' $tmpfile
	test -f spool/outbound/00630058.out
}

# Test that crashmail links an area in response to a
# link request.
it_subscribes_node () {
	echo TESTAREA |
	$__tools__/crashwrite dir spool/inbound \
		fromname "Test User" fromaddr 99:99/88 \
		toname "Areafix" toaddr 99:99/1 \
		subject "TESTPASS" \
		text /dev/stdin

	$__crashmail__ toss | tee $tmpfile
	grep 'AreaFix: Request from 99:99/88' $tmpfile
	grep 'AreaFix: Attached to TESTAREA' $tmpfile
	test -f spool/outbound/00630058.out
	grep '^EXPORT .* 99:99/88.0' crashmail.prefs
}

