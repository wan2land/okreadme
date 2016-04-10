
src="README.ok.md"

if [ ! -z "$1" ]; then
    src=$1
fi

if [ ! -f $src ]; then
    echo "File $src does not exist!"
    exit 1
fi

IFS=''

Trim() {
    echo $1 | sed 's/^ *//;s/ *$//'
}
GetCommand() {
    echo `Trim $1` | awk '{split($0,a," "); print a[1]}'
}
GetArguments() {
    repl=`GetCommand $1`
    echo `Trim $1` | sed 's/ *'$repl' *//'
}

CommandInsert() {
    if [ ! -f $1 ]; then
        echo "File $1 does not exists!"
        exit 1
    fi
    echo '```'
    while read line; do
        echo $line
    done < $1
    echo $line
    echo '```'
}

CommandPrint() {
    echo $1
}

# read line from src
while read line; do
    if [ "${line:0:2}" == "%%" ]; then

        # get command
        command=`GetCommand ${line:2}`
        args=`GetArguments ${line:2}`

        # for debugging
        # echo "command : ($command)"
        # echo "arguments : ($args)"

        if [ "$command" == "insert" ]; then
            CommandInsert $args
        elif [ "$command" == "print" ]; then
            CommandPrint $args
        else
            echo "Command $command is not supported!"
            exit 1
        fi
    else
        echo $line
    fi
done < $src
