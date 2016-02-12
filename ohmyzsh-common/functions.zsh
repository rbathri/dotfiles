function zsh_stats() {
  history | awk '{print $2}' | sort | uniq -c | sort -rn | head
}

function extract() {
    unset REMOVE_ARCHIVE

    if test "$1" = "-r"; then
        REMOVE=1
        shift
    fi
    if [[ -f $1 ]]; then
        case $1 in
          *.tar.bz2) tar xjf $1;;
          *.tar.gz) tar xzf $1;;
          *.tar.xz) tar xJf $1;;
          *.tar.lzma) tar --lzma -xf $1;;
          *.bz2) bunzip $1;;
          *.rar) unrar x $1;;
          *.gz) gunzip $1;;
          *.tar) tar xf $1;;
          *.tbz2) tar xjf $1;;
          *.tgz) tar xzf $1;;
          *.zip) unzip $1;;
          *.Z) uncompress $1;;
          *.7z) 7z x $1;;
          *) echo "'$1' cannot be extracted via >extract<";;
        esac

        if [[ $REMOVE_ARCHIVE -eq 1 ]]; then
            echo removing "$1";
            /bin/rm "$1";
        fi

    else
        echo "'$1' is not a valid file"
    fi
}

function kill-ssh() {
    process=$(ps aux | grep ssh | grep "$1" | grep -v grep | head -n1)
    if [[ -n "$process" ]]; then
        echo -n "Kill" $process "? (Y/n) "
        read opt
        if [[ "$(echo $opt | tr "[A-Z]" "[a-z]")" == "n" ]]; then
        else
            sudo kill -INT `echo $process | awk '{print $2}'`
        fi
    fi
}
compdef _ssh kill-ssh=ssh

# generate links for files from a directory shared over apache
function robots() {
    local base_url=$1
    test -z "$(echo $base_url | grep '^http')" && base_url="http://$1"
    test -z "$(echo $base_url | grep '/$')" && base_url="$base_url/"
    curl -s $base_url | sed 's/&amp;/\&/g' | grep '<td .*<a href="' | grep -v 'alt="\[\(PARENT\)\?DIR\]"' | sed 's/^.*href="/'"$(echo $base_url | sed 's/\//\\\//g')"'/g' | sed 's/">.*$//g'
}

# generate links for files shared over python's SimpleHTTPServer
function pyrobots() {
    local base_url=$1
    test -z "$(echo $base_url | grep '^http')" && base_url="http://$1"
    test -z "$(echo $base_url | grep '/$')" && base_url="$base_url/"
    curl -s $base_url | grep '^<li>' | sed 's/^.*href="/'"$(echo $base_url | sed 's/\//\\\//g')"'/g' | sed 's/">.*$//g' | grep -v '/$'
}

# remove nth line from a file
function rmn() {
    local temp="/tmp/temp.$RANDOM"
    sed "${2}d" $1 > $temp
    mv $temp $1
}
