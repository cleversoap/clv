#--------------------------------------------------------------------[ COMMAND ]

function clv-scm () {

    cmd=$1
    shift

    case $cmd in
        "type")
            clv-scm-type $@
            ;;
        "update")
            clv-scm-update $@
            ;;
        *)
            echo "Usage: clv scm (type|update) [dir]"
            exit 1
            ;;
    esac

}

#-----------------------------------------------------------------------{ type }

# NB: Has a weakness where only the parent repository type will be detected
# So a mercurial repository inside of a git one will be detected as git
# I've only encountered this with pyenv and cpython repo but it does happen
function clv-scm-type () {
    dir=${1:-$PWD}

    if [[ -d $dir ]]; then

        # git
        if type git > /dev/null; then
            if [[ $(cd $dir && git rev-parse --is-inside-work-tree 2> /dev/null) = 'true' ]]; then
                echo git
                return 0
            fi
        fi

        # mercurial
        if type hg > /dev/null; then
            hg --cwd $dir root &> /dev/null
            if [[ $? -eq 0 ]]; then
                echo 'mercurial'
                return 0
            fi
        fi

        # subversion
        if type svn > /dev/null; then
            svn info $dir &> /dev/null
            if [[ $? -eq 0 ]]; then
                echo 'subversion'
                return 0
            fi
        fi

        # Unknown or not a directory
        return 1

    else
        echo "No such directory $dir"
        return 1
    fi

}
autoload clv-scm-type

#---------------------------------------------------------------------{ update }

function clv-scm-update () {
    dir=${1:-$PWD}
    case $(clv-scm-type $1) in
        "git")
            (cd $dir && git pull)
            ;;
        "mercurial")
            (cd $dir && hg pull && hg update)
            ;;
        "subversion")
            (cd $dir && svn update)
            ;;
        *)
            echo "Cannot find scm repository"
            return 1
            ;;
    esac

}
autoload clv-scm-update
