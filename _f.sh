#compdef f.sh

local curcontext="$curcontext" state_descr variant default ret=1
local -a state line args alts disp smatch

#~ _pick_variant -r variant gnu=GNU $OSTYPE -version

_arguments -C \
  '*:directory:_files -/' \
  '*-L[follow symlinks]' \
  '*-D[-depth : reverse to files first then their parent directory]' \
  '*-d[-mindepth to -maxdepth : minimum to maximum search depth]' \
  '*-I[-prune : skipped directory]: :_files -/' \
  '(*-p *-P)'{-p,-P}'[-path : path pattern to search]: :_files -/' \
  '*-z[-empty : empty files and directories]' \
  '(*-k *-K)'{-k,-K}'[-type : file type]:file type:((b\:block\ special\ file c\:character\ special\ file d\:directory p\:named\ pipe f\:normal\ file l\:symbolic\ link s\:socket))' \
  '(*-s *-S)'{-s,-S}'[-size]:size type:(b k M G + -)' \
  '(*-o *-O)'{-o,-O}'[-perm]: :_file_modes' \
  '(*-g *-G)'{-g,-G}'[-group]:group:_groups' \
  '(*-u *-U)'{-u,-U}'[-user]:user:_users' \
  '*-a[-daystart]' \
  '(*-m *-M)'{-m,-M}'[-cmin : inode change time (minutes)]: :_dates -f m' \
  '(*-t *-T)'{-t,-T}'[-ctime : inode change time (days)]: :->times' \
  '(*-j *-J)'{-j,-J}'[-cnewer : file to compare (modification time)]: :_files' \
  '(*-y *-Y)'{-y,-Y}'[-newerct : compare modification time than YYYY-MM-DD HH:MM]: :_dates' \
  '*-e[-regextype]:regexp syntax:(help findutils-default awk egrep ed emacs gnu-awk grep posix-awk posix-basic posix-egrep posix-extended posix-minimal-basic sed)' \
  '(*-r *-R)'{-r,-R}'[-regex : regular expression to search]' \
  '(*-n *-N)'{-n,-N}'[-iname : name pattern (case insensitive)]' \
  '*-f[-printf : show output with format]:output format' \
  '*-W[-fprint : output file]:output file:_files' \
  '*-F[-fprintf : output file with format]:output file:_files:output format' \
  '*-0[-print0]' \
  '*-l[-ls]' \
  '*-q[show find commands]' \
  '*-x[run]:execute command:((-e\:exec -o\:ok -ed\:execdir -od\:okdir))' \
  '*-X[-delete]' \
&& ret=0

case $state in
times )
  if ! compset -P '[+-]' || [[ -prefix '[0-9]' ]]; then
    compstate[list]+=' packed'
    if zstyle -t ":completion:${curcontext}:senses" verbose; then
      zstyle -s ":completion:${curcontext}:senses" list-separator sep || sep=--
      default=" [default exactly]"
      disp=( "+ $sep before (older files)" "- $sep since (newer files)" )
      smatch=( - + )
    else
      disp=( before exactly since )
      smatch=( + '' - )
    fi
    alts=( "senses:sense${default}:compadd -V times -S '' -d disp -a smatch" )
  fi
  alts+=( "times:${state_descr}:_dates -f d" )
  _alternative $alts && ret=0 ;;
esac

return ret
