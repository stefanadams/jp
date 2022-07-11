#!/usr/bin/env bash

[ -n "$JP_VERBOSE" ] && JP_VERBOSE="-V"
jp () {
  [ -n "$SKIP" ] && { echo -e "\033[33mskip ($SKIP)\033[0m: Test #- at L$BASH_LINENO"; return 0; }
  ${0%/*}/../jp -M "Test #$((tests+1)) at L$BASH_LINENO" $JP_VERBOSE "$@" < $jp_test
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

json1=${0%/*}/json1.json

# this is bash, everything returns a string
# might be one or more values, or might be a JSON string

jp_test=$json1

jp /artifactory/0/user -T '\d+'
jp /artifactory/0/hash -T '{"\w":\d}'
jp /artifactory/0/array -T '\["\w","\w","\w"\]'
jp -A /artifactory/0/array -T '\w\t\w\t\w'
jp -p /artifactory/0/user -T '/\t\d+'
SKIP="-i /pointer not implemented" jp -i /Artifactory/0/user -T '\d+'
jp -r /artifactory -T '\[.*\]'
jp -i -r /Artifactory -T '\[.*\]'
jp -r '/arti\w+' -T '\[.*\]'
jp -r '/artifactory/\d+' -T '\{.*\}\n\{.*\}\n\{.*\}'
jp -r '/artifactory/[02]' -T '\{.*\}\n\{.*\}'
jp -r '/artifactory/\d+' /user /password -T '\d+\t\w+\n\d+\t\w+\n\d+\t\w+'
SKIP="-i /pointer not implemented" jp -i -r '/artifactory/\d+' /User /Password -T '\d+\t\w+\n\d+\t\w+\n\d+\t\w+'
jp -p -r '/artifactory/\d+' /user /password -T '/artifactory/\d+\t\d+\t\w+\n/artifactory/\d+\t\d+\t\w+\n/artifactory/\d+\t\d+\t\w+'
jp -n -1 -A -d : -E '$_->grep(sub{$_->jp("/URL") =~ "redacted" && $_->jp("/isdefault")})' -r '/Artifactory/\d' /user /password /array -T ''
jp -n -1 -A -d : -E '$_->grep(sub{$_->jp("/url") =~ "redacted" && $_->jp("/isDefault")})' -r '/artifactory/\d' /user /password /array -T '\d+:\w+:\w:\w:\w'
jp -n -1 -A -d : -i -E '$_->grep(sub{$_->jp("/URL") =~ "redacted" && $_->jp("/isdefault")})' -r '/Artifactory/\d' /user /password /array -T '\d+:\w+:\w:\w:\w'
jp -n -1 -A -E '$_->grep(sub{$_->jp("/url") =~ "redacted" && $_->jp("/isDefault")})' -r '/artifactory/\d' /user /password /array -T '\d+\t\w+\t\w\t\w\t\w'
jp -A -E '$_->grep(sub{$_->jp("/url") =~ "redacted" && $_->jp("/isDefault")})' -r '/artifactory/\d' /user /password /array -T '\d+\t\w+\t\w\t\w\t\w\n\d+\t\w+\t\w\t\w\t\w'
jp -n -1 -E '$_->grep(sub{$_->jp("/url") =~ "redacted" && $_->jp("/isDefault")})' -r '/artifactory/\d' /user /password /array -T '\d+\t\w+\t\["\w","\w","\w"\]'
jp -n 0 -E '$_->tap(sub{out $_->size})' -r '/artifactory/\d+' /user /password -T 3
jp -n 0 -E '$_->tap(sub{out $_->size})->tap(sub{out $_->size})' -r '/artifactory/\d+' /user /password -T '3\n3\n'
jp -n 0 -E '$_->tap(sub{out $_->size})->tap(sub{out $_->size})' -r '/artifactory/\d+' /user /password -T $'3\n3\n'

done_testing
