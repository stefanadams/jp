#!/usr/bin/env bash

jp () {
  local jp_test=${0%/*}/$jp_test.json
  [ -n "$SKIP" ] && { echo -e "\033[33mskip ($SKIP)\033[0m: Test #- at L$BASH_LINENO"; return 0; }
  if [ -n "$JP_VERBOSE" ]; then
    ${0%/*}/../jp -M "Test #$((tests+1)) at L$BASH_LINENO" -v "$@" < $jp_test
  else
    ${0%/*}/../jp -M "Test #$((tests+1)) at L$BASH_LINENO" "$@" 2>/dev/null < $jp_test
  fi
  ok
}

ok=0 tests=0
ok () {
  err=$?
  ((++tests)) && [ $err -eq 0 ] && ((ok++))
  return $err
}
done_testing () {
  if ((ok==tests)); then
    echo -e "\033[32mPassed $ok/$tests tests\033[0m"
    exit 0
  else
    echo -e "\033[31mPassed $ok/$tests tests\033[0m"
    exit 1
  fi
}

# this is bash, everything returns a string
# might be one or more values, or might be a JSON string

jp_test=json1

# Use a JSON pointer to get a value from the JSON data structure
jp /server/0/password -I REDACTED_APIKEYfalse
jp /server/0/password -R 'REDACTED_\w{6}false'

# Use a JSON pointer to get a value from the JSON data structure, defaults to /
jp -R '.*?"Version":"1".*?'
jp -T '$j->{Version} == 1'

# Use a regex in the pointer to reduce the JSON data structure and return each result, one per line
jp -n 1 -r '/server/\d+' -T '$j->{serverId} eq "redacted"'

# Use a regex in the pointer to reduce the JSON data structure and include the pointer for all records found
jp -n 1 -p -r '/server/\d+' /user /password -R '/server/0\t0038137\tREDACTED_APIKEYfalse'

# Filtering
jp -Aip -n -1 -d: -E '$_->grep(sub{$_->jp("/isdefault")})' -r '/server/\d' /user /password -I /server/1:0038137:REDACTED1_APIKEYtrue

# A syntax error in the -E Perl eval is handled gracefully
jp -V -n 1 -E '$_->tap(sub{out $_->size})->tap(sub{die 123}' -r '/server/\d+' /user /password -I 'syntax error in -E eval'

jp_test=json2

# Don't sort by pointer, sort arbitrarily as specified in the -E Perl eval
jp -V -S -U -p -r '/markers/\d' -E '$_->sort(sub{$a->jp("/location/0", "/position/0") <=> $b->jp("/location/0", "/position/0")})' /location /position \
  -R '/markers/2\t\[.*?\]\n/markers/0\t\[.*?\]\n/markers/3\t\[.*?\]\n/markers/1\t\[.*?\]'

# Ideas for more tests:

# jp /server/0/user -T '\d+'
# jp /server/0/hash -T '{"\w":\d}'
# jp /server/0/array -T '\["\w","\w","\w"\]'
# jp -A /server/0/array -T '\w\t\w\t\w'
# jp -p /server/0/user -T '/\t\d+'
# SKIP="-i /pointer not implemented" jp -i /Server/0/user -T '\d+'
# jp -r /server -T '\[.*\]'
# jp -i -r /Server -T '\[.*\]'
# jp -r '/arti\w+' -T '\[.*\]'
# jp -r '/server/\d+' -T '\{.*\}\n\{.*\}\n\{.*\}'
# jp -r '/server/[02]' -T '\{.*\}\n\{.*\}'
# jp -r '/server/\d+' /user /password -T '\d+\t\w+\n\d+\t\w+\n\d+\t\w+'
# SKIP="-i /pointer not implemented" jp -i -r '/server/\d+' /User /Password -T '\d+\t\w+\n\d+\t\w+\n\d+\t\w+'
# jp -p -r '/server/\d+' /user /password -T '/server/\d+\t\d+\t\w+\n/server/\d+\t\d+\t\w+\n/server/\d+\t\d+\t\w+'
# jp -n -1 -A -d : -E '$_->grep(sub{$_->jp("/URL") =~ "redacted" && $_->jp("/isdefault")})' -r '/Server/\d' /user /password /array -T ''
# jp -n -1 -A -d : -E '$_->grep(sub{$_->jp("/url") =~ "redacted" && $_->jp("/isDefault")})' -r '/server/\d' /user /password /array -T '\d+:\w+:\w:\w:\w'
# jp -n -1 -A -d : -i -E '$_->grep(sub{$_->jp("/URL") =~ "redacted" && $_->jp("/isdefault")})' -r '/Server/\d' /user /password /array -T '\d+:\w+:\w:\w:\w'
# jp -n -1 -A -E '$_->grep(sub{$_->jp("/url") =~ "redacted" && $_->jp("/isDefault")})' -r '/server/\d' /user /password /array -T '\d+\t\w+\t\w\t\w\t\w'
# jp -A -E '$_->grep(sub{$_->jp("/url") =~ "redacted" && $_->jp("/isDefault")})' -r '/server/\d' /user /password /array -T '\d+\t\w+\t\w\t\w\t\w\n\d+\t\w+\t\w\t\w\t\w'
# jp -n -1 -E '$_->grep(sub{$_->jp("/url") =~ "redacted" && $_->jp("/isDefault")})' -r '/server/\d' /user /password /array -T '\d+\t\w+\t\["\w","\w","\w"\]'
# jp -n 0 -E '$_->tap(sub{out $_->size})' -r '/server/\d+' /user /password -T 3
# jp -n 0 -E '$_->tap(sub{out $_->size})->tap(sub{out $_->size})' -r '/server/\d+' /user /password -T '3\n3\n'
# jp -n 0 -E '$_->tap(sub{out $_->size})->tap(sub{out $_->size})' -r '/server/\d+' /user /password -T $'3\n3\n'

done_testing
