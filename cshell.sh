echo "" > .buffer
echo "" > .includes
echo "" > .funcs # todo :)

cnt=0
lvl=0
start="main() {"
end="}"
kind="code"

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

if [ "`echo $input | grep ^#include`" == "" ]
then
    if [ "`echo $input | grep {`" != "" ]
    then
        kind="block"
        let lvl=lvl+1
    fi
    echo "$input" >> .buffer
    let cnt=cnt+1


    if [ "`echo $input | grep }`" != "" ]
    then
        let lvl=lvl-1
        if [ "$lvl" == "0" ]
        then
            kind="code"
        fi
    fi
else
    kind="include"
    echo "$input" >> .includes
fi

if [ "$kind" != "block" ]
then
    cat .includes > .code.c
    echo "$start" >> .code.c
    cat .buffer >> .code.c
    echo "$end" >> .code.c

    gcc .code.c -o .out
    if [ "$?" == "0" ]
    then
        ./.out
    else
        echo .code.c
        if [ "$kind" == "include" ]
        then
            f=".includes"
        else
            f=".buffer"
        fi

        for i in `seq 1 $cnt`;
        do
            sed -i "`cat .buffer | wc -l` d" $f
        done
        kind="code"
    fi

    cnt=0
    lvl=0
    cat .buffer | grep -v ^puts | grep -v ^printf > .buffer2
    cat .buffer2 > .buffer
    echo
fi
done
