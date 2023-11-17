# findwraper
a shell wraper for find with short options, type much less words

-q output find command, some redundancy is necessary, capitalization means '-not', @ means '-and', % means '-or', & means 'not case sensitive' for ipath iname iregex, -x to run commands divided by \n, short option meaning check the naming in script and zsh completion file _f.sh.
```
% f.sh -n '*rc' -q 
find . -iregex '.*' -and \( -name '*rc' \) 
% f.sh -r '.*(jpe?g|png)' -q
find . -iregex '.*' -regextype egrep -and \( -regex './.*(jpe?g|png)' \)
% f.sh -n 'ba*@*rc' -q
find . -iregex '.*' -and \( -name 'ba*' -and -name '*rc' \)
% f.sh -d 1-2 -q
find . -mindepth 1 -maxdepth 2 -iregex '.*'
% f.sh -N 'ba*%*rc' -q
find . -iregex '.*' -not \( -name 'ba*' -or -name '*rc' \)
% f.sh -n 'ba*' -I 'disk' -q
find . -path './disk' -prune -o -iregex '.*' -and \( -name 'ba*' \)
% f.sh -k d -q
find . -iregex '.*' -and \( -type 'd' \)
% f.sh -x '-e cat {} \n -e file {} ' -q
find . -iregex '.*' -exec cat {} \; -exec file {} \;
```
