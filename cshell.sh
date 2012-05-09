echo "" > .buffer
echo "" > .includes
start="main() {"
end="}"

while [ 1 = 1 ]
do
read input
if [ "`echo $input | grep ^#include`" == "" ]
then
    echo "$input" >> .buffer
else
    echo "$input" >> .includes
fi


cat .includes > .code.c
echo "$start" >> .code.c
cat .buffer >> .code.c
echo "$end" >> .code.c

gcc .code.c -o .codeout
if [ "$?" == "0" ]
then
    ./.codeout
else
    echo .code.c
    sed -i "`cat .buffer | wc -l` d" .buffer
fi

cat .buffer | grep -v ^puts | grep -v ^printf > .buffer2
cat .buffer2 > .buffer

done
