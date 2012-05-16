config=".cshell"
incl=".incl"
func=".func"
main=".main"

cat $config | grep "//incl" > $incl 2> /dev/null
cat $config | grep "//func" > $func 2> /dev/null
cat $config | grep "//main" > $main 2> /dev/null

type="(void|bool|char|int)"
vardecl() { echo "$1" | egrep "^$type[ a-zA-Z0-9-]+" | grep "="; }
fundecl() { echo "$1" | egrep "^$type[ a-zA-Z0-9-]+" | grep "("; }

cnt=0
lvl=0
start="main() {"
out=$main
end="}"

progout=.output
outskip=0

# interpreter loop
while [ 1 = 1 ]
do

if [ $lvl == 0 ]
then
    echo -n "> "
else
    for i in `seq 1 $lvl`;
    do
        echo -n ". "
    done
fi

read input

if [ "`echo $input | grep ^#include`" != "" ]
then
    out=$incl
    echo "Include directive"
else
    #todo ignore "{"
    if [ "`echo $input | grep {`" != "" ]
    then
        let lvl=lvl+1
    fi
    if [ "`echo $input | grep }`" != "" ]
    then
        let lvl=lvl-1
    fi

    if [ "`vardecl \"$input\"`" != "" ]
    then
        echo "Variable declaration"
    fi

    if [ "`fundecl \"$input\"`" != "" ]
    then
        echo "Function declaration"
        out=$func
    fi
fi

let cnt=cnt+1
echo ${input/'printf("'/'printf("\n'} >> $out

if [ $lvl == 0 ]
then
    #todo format code
    echo > .code.c
    cat $incl >> .code.c
    cat $func >> .code.c
    echo "$start" >> .code.c
    cat $main >> .code.c
    echo "$end" >> .code.c

    gcc .code.c -o .out
    if [ $? == 0 ]
    then
        ./.out &> $progout
        let take=`cat $progout | wc -l`-outskip
        if [ $take -lt 1 ]
        then
            take=0
        fi
        tail -n $take $progout
        let outskip=`cat $progout | wc -l`
    else
        echo .code.c

        for i in `seq 1 $cnt`;
        do
            sed -i "`cat $out | wc -l` d" $out
        done
    fi

    out=$main
    cnt=0
    lvl=0
    echo
fi
done
