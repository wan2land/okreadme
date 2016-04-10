
src="README.ok.md"
dist="README.md"

if [ ! -z "$1" ]; then
    src=$1
fi

if [ ! -z "$2" ]; then
    src=$2
fi

if [ ! -f $src ]; then
    echo "File $src does not exist!"
    exit 1
fi

# initialize
rm $dist

IFS=''

# read line from src
while read line; do
    if [ "${line:0:2}" == "%%" ]; then
        # get command
        command=`echo ${line:2} | sed 's/^ *//;s/ *$//' | awk '{split($0,a," "); print a[1]}'`
        args=`echo ${line:2} | sed 's/^ *//;s/ *$//' | sed 's/ *'$command' *//'`

        # for debugging
        # echo "command : ($command)"
        # echo "arguments : ($args)"

        if [ "$command" == "insert" ]; then
            if [ ! -f $args ]; then
                echo "File $args does not exists!"
                exit 1
            fi
            echo '```' >> $dist
            while read jline; do
                echo "    "$jline >> $dist
            done < $args
            echo "    "$jline >> $dist
            echo '```' >> $dist
        else
            echo "Command $command is not supported!"
            exit 1
        fi

    else
        echo $line >> $dist
    fi
done < $src
