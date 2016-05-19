# Load colours
autoload colors
colors

# Load library
source "${CLV_ROOT}/lib/clv-scm.zsh"
source "${CLV_ROOT}/lib/clv-env.zsh"

# Setup the function call
function clv () {
    cmd=$1
    shift

    case $cmd in
        "env")
            clv-env $@
        ;;

        "scm")
            clv-scm $@
        ;;
    esac
}
autoload clv
