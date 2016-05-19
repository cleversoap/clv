#--------------------------------------------------------------------[ COMMAND ]

function clv-env () {

    # Get the command
    cmd=$1

    case $cmd in
        "init")
            for e in $CLV_ENVS; do
                clv-env-init $e
            done
            for p in $CLV_ENVS_INIT_PLUGINS; do
                eval "$(${=p} -)"
            done
        ;;

        "update")
            for e in $CLV_ENVS; do
                clv-env-update $e
            done
        ;;

        *)
            echo "Usage: clv env (init|update)"
            exit 1
        ;;
    esac

}
autoload clv-env

#-----------------------------------------------------------------------{ init }

# Initialise all the environments
function clv-env-init () {

    # Can only init if the environment exists
    if clv-env-exists $1; then

        # Store a reference to the environment's root, some of them require
        # this and it is useful to store for referencing directories later
        local env_root="${HOME}/.${1}"

        # Some environments require this variable be set and it is useful
        # for referring to externally.
        # eg. pyenv -> PYENV_ROOT -> $HOME/.pyenv
        export ${1:u}_ROOT="${env_root}"

        # Put the environment on the path
        export PATH="${env_root}/bin:${PATH}"

        # Init the environment
        eval "$(${=1} init -)"

    fi

}
autoload clv-env-init

#---------------------------------------------------------------------{ update }

# Updates all environments and plugins
function clv-env-update () {
    if clv-env-exists $1; then
        local env_root="$HOME/.${1}"

        # Update the main environment
        echo "$fg_bold[green]>> $env_root$reset_color"
        clv scm update $env_root

        # Update the plugins
        if [ ! `find $env_root/plugins -prune -empty -type d` ]; then
            for p in $env_root/plugins/*; do
                echo "$fg[green]+ $p$reset_color"
                clv scm update $p
            done
        fi
    fi
}
autoload clv-env-update

#----------------------------------------------------------------------[ UTILS ]

function clv-env-exists() {
    if [[ -d $HOME/.$1 ]]; then
        return 0
    else
        return 1
    fi
}
