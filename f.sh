#!/bin/bash
### find的wraper
### 把find的基本全部功能映射为简短的命令
### 能用-a -o的地方都能简化成@%的可嵌套的写法
### 可以只给出执行语句，不执行
### 语法错误时给出出错的段落，中止执行
### -exec可多条语句
### 在路径上能使用shell匹配到的，在内部抑制shell扩展
### 有类似find命令补全
### Usage: f.sh [PATHs] [-LDzal0Xq] [-dIPpkKsSoOgGuUmMtTjJyYerRnNfWF] <ARGs> [-x] <-e|ed|a|ad> <COMMAND>
set -f
printHelp()
{
awk -F'### ' '/^###/ { print $2 }' "$0"
}
if [[ $1 == "-h" ]]; then
   printHelp
   exit 0
fi
showself()
{
if [ -n "$1" ];then
printf '%s' "-$1"
fi
}
showdepths()
{
if [ -n "$1" ];then
mindepth=$(echo "$1"|hck -d'-' -f1)
maxdepth=$(echo "$1"|hck -d'-' -f2)
fi
if [ -n "$mindepth" ];then
printf '%s' "-mindepth $mindepth "
fi
if [ -n "$maxdepth" ];then
printf '%s' "-maxdepth $maxdepth "
fi
}
prune()
{
if [ -n "$1" ];then
paths=($1)
for i in ${!paths[@]}
do
if [ -z "$2" ];then
printf '%s' "-path './${paths[$i]}' -prune -o "
else
printf '%s' "-path '${paths[$i]}' -prune -o "
fi
done
fi
}
showdaystart()
{
if [ "$1" = daystart ] && [ -n "$2" -o -n "$3" -o -n "$4" -o -n "$5" ];then
printf '%s' "-$1"
fi
}
showregextype()
{
if [ -n "$3" -o -n "$4" -o -n "$5" -o -n "$6" ];then
printf '%s' "-$1 ${2:-egrep}"
fi
}
show()
{
case $1 in
path ) arg=path ;mode=path ;;
type ) arg=type ;;
size ) arg=size ;;
perm ) arg=perm ;;
group ) arg=group ;;
user ) arg=user  ;;
cmin ) arg=cmin ;;
ctime ) arg=ctime ;;
cnewer ) arg=cnewer ;;
newerct ) arg=newerct ;;
regex ) arg=regex ;mode=regex ;;
name ) arg=name  ;;
esac
shift
if [ "$1" = no -a $# = 2 ] ;then
pre=$(echo "-not \(")
after=$(echo "\)")
shift
else
pre=$(echo "-and \(")
after=$(echo "\)")
fi
if [ -n "$1" ];then
if [ -z "$pathe" -a "$mode" = path ];then
pathfix='./'
elif [ -z "$pathe" -a "$mode" = regex ];then 
pathfix='\.\/'
else
pathfix=''
fi
body=$(echo "$1" |sed -re "s/\(([^@%()]+\|[^@%()]+)\)/,,,\1===/g;s#(&?)([^@%() ]+)# -\1$arg '${pathfix}\2'#g;s#-&$arg#-i$arg#g" -e 's/@/ -and /g;s/%/ -or /g;s/[()]/ \\&/g;s/,,,/(/g;s/===/)/g')
echo "$pre" "$body" "$after"
fi
}
showprint1()
{
if [ -n "$2" ];then
printf '%s' "-$1 '$2'"
fi
}
showprint2()
{
if [ -n "$2" ];then
file=$(echo "$2"|hck -f1)
format=$(echo "$2"|hck -f2)
printf '%s' "-$1 '$file' '$format'"
fi
}
showrun()
{
if [ -n "$1" ];then
echo -e "$1" |while read line
do
echo -n "$line" |sed 's/^-e/-exec/;s/^-execd /-execdir /;s/^-o/-ok/;s/^-okd /-okdir /'|sed 's/$/ \\; /;s/+ \\;/+/'
done
fi
}
for i in "$@"
do
case $i in
-* ) break ;;
* ) pathe="$pathe '$i'" ; shift
esac
done
while getopts "LDd:I:p:P:zk:K:s:S:o:O:g:G:u:U:am:M:t:T:j:J:y:Y:e:r:R:n:N:f:W:F:0lqx:X" opt
do 
case "$opt" in
L ) L="L" ;;
D ) depth="depth" ;;
d ) depths="$OPTARG" ;;
I ) prune="$OPTARG" ;;
p ) path="$OPTARG" ;;
P ) Path="$OPTARG" ;;
z ) empty="empty" ;;
k ) type="$OPTARG" ;;
K ) Type="$OPTARG" ;;
s ) size="$OPTARG" ;;
S ) Size="$OPTARG" ;;
o ) perm="$OPTARG" ;;
O ) Perm="$OPTARG" ;;
g ) group="$OPTARG" ;;
G ) Group="$OPTARG" ;;
u ) user="$OPTARG" ;;
U ) User="$OPTARG" ;;
a ) daystart="daystart" ;;
m ) cmin="$OPTARG" ;;
M ) Cmin="$OPTARG" ;;
t ) ctime="$OPTARG" ;;
T ) Ctime="$OPTARG" ;;
j ) cnewer="$OPTARG" ;;
J ) Cnewer="$OPTARG" ;;
y ) newerct="$OPTARG" ;;
Y ) Newerct="$OPTARG" ;;
e ) regextype="$OPTARG" ;;
r ) regex="$OPTARG" ;;
R ) Regex="$OPTARG" ;;
n ) name="$OPTARG" ;;
N ) Name="$OPTARG" ;;
f ) printf="$OPTARG" ;;
W ) fprint="$OPTARG" ;;
F ) fprintf="$OPTARG" ;;
0 ) print0="print0" ;;
l ) ls="ls" ;;
q ) showcommand="true" ;;
x ) run="$OPTARG" ;;
X ) delete="delete" ;;
? ) exit 1
esac
done
shift $(( $OPTIND - 1 ))
for i in "$path" "$type" "$Type" "$size" "$size" "$cnewer" "$Cnewer" "$cmin" "$Cmin" "$ctime" "$Ctime" "$newerct" "$Newerct" "$perm" "$Perm" "$group" "$Group" "$user" "$User" "$regex" "$Regex" "$name" "$Name"
do
if [ -n "$i" ];then
  str=$(echo "$i"|sed -r 's/\(([^@%()]+\|[^@%()]+)\)/_\1=/g;s/[^@%() ]+/,,,&/g;s/ //g')
  if [[ "$str" =~ \([@%] ]];then
  echo "! $i; ( should not followed by @%!"
  showcommand=true
  fi
  if [[ "$str" =~ ,,,[^@%]+,,, ]];then
  echo "! $i; fields head need to be @% !"
  showcommand=true
  fi
  if [[ "$str" =~ ,,,.*[@%]{2,}.*,,, ]];then
  echo "! $i; fields have too many @%!"
  showcommand=true
  fi
fi
done
if [ -n "$run" ];then
while read line
  do
  if [[ ! "$line" =~ ^-[eo]d?' ' ]] ;then
    echo "! $line; must start with -e -ed -o -od"
    showcommand=true
  fi
  if [[ ! "$line" =~ \{\} ]] ;then
    echo "! $line; must contain {}"
    showcommand=true
  fi
  if [[ "$line" =~ \+ ]] && [[ ! "$line" =~ \{\}' '+\+$ ]] ;then
    echo "! $line; must write like ... {} +$"
    showcommand=true
  fi
  done < <(echo -e "$run")
fi
COMMAND=$(echo "find $(showself "$L") ${pathe:-.} $(showself "$depth") $(showdepths "$depths") $(prune "$prune" "$pathe") -iregex '.*' $(show path "$path") $(show path no "$Path") $(showself "$empty") $(show type "$type") $(show type no "$Type") $(show size "$size") $(show size no "$Size") $(show perm "$perm") $(show perm no "$Perm") $(show group "$group") $(show group no "$Group") $(show user "$user") $(show user no "$User") $(showdaystart "$daystart" "$cmin" "$Cmin" "$ctime" "$Ctime") $(show cmin "$cmin") $(show cmin no "$Cmin") $(show ctime "$ctime") $(show ctime no "$Ctime") $(show cnewer "$cnewer") $(show cnewer no "$Cnewer") $(show newerct "$newerct") $(show newerct no "$Newerct") $(showregextype regextype "$regextype" "$iregex" "$regex" "$Iregex" "$Regex") $(show regex "$regex") $(show regex no "$Regex") $(show name "$name") $(show name no "$Name") $(showself "$ls") $(showprint1 printf "$printf") $(showprint1 fprint "$fprint") $(showprint2 fprintf "$fprintf") $(showself "$print0") $(showself "$delete") $(showrun "$run")"|tr -s ' ')
if [ "$showcommand" = true ];then
echo "$COMMAND"
else
eval "$COMMAND"
fi