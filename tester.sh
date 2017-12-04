#!/bin/bash

exe="./src/okreadme"           # The application (from command arg)
diff="diff -iad"   # Diff command, or what ever

case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

print_ok() {
    if [ "$color_prompt" = yes ]; then
        printf "\033[32mOK!\033[0m\n"
    else
        printf "OK!\n"
    fi
}
print_fail() {
    if [ "$color_prompt" = yes ]; then
        printf "\033[31mFAILS..\033[0m\n"
    else
        printf "FAILS..\n"
    fi
}
run_test() {
    printf "  - test %s ... " $1

    # Validate infile exists (do the same for out validate file)
    if [ ! -f "$1" ]; then
        print_fail
        printf "    -> file not exists %s\n" $1
        continue;
    fi
    if [ ! -f "$2" ]; then
        print_fail
        printf "    -> file not exists %s\n" $2
        continue;
    fi

    rm -r tests/**/*.test

    printf "  - test %s ... " "$1"

    run_out=${1%%.*}".test"

    # Run application, redirect in file to app, and output to out file
    "./$exe" "$1" > $run_out 2>&1

    e_code=$?

    if [ "$3" = "success" ]; then
        if [ $e_code != 0 ]; then
            print_fail
            printf "    -> result code is %s\n" $e_code
            return
        fi
    else
        if [ $e_code = 0 ]; then
            print_fail
            printf "    -> result code is %s\n" $e_code
            return
        fi
    fi

    # Execute diff
    # echo "$diff $run_out $2"
    $diff $run_out $2

    # Check exit code from previous command (ie diff)
    # We need to add this to a variable else we can't print it
    # as it will be changed by the if [
    # Iff not 0 then the files differ (at least with diff)
    e_code=$?
    if [ $e_code != 0 ]; then
        print_fail
        printf "    -> fail diff %s\n" $e_code
    else
        print_ok
    fi
}

echo "[Run Tests, Success Cases]"
for file in tests/success/*.input; do
    # Padd file_base with suffixes
    file_in="${file%%.*}.input"             # The in file
    file_out="${file%%.*}.output"       # The out file

    run_test $file_in $file_out "success"

done

echo ""
echo "[Run Tests, Error Cases]"
for file in tests/fail/*.input; do
    # Padd file_base with suffixes
    file_in="${file%%.*}.input"             # The in file
    file_out="${file%%.*}.output"       # The out file

    run_test $file_in $file_out "fail"

done

# Clean exit with status 0
exit 0
