#  User PATH 
typeset -U path PATH
path=("$HOME/mhm/scripts" $path)
export PATH

#  Startup 
# Commands to execute on startup (before the prompt is shown)
# Check if the interactive shell option is set
if [[ $- == *i* ]]; then
    # This is a good place to load graphic/ascii art, display system information, etc.
    if command -v pokego >/dev/null; then
        pokego --no-title -r 1,3,6
    elif command -v pokemon-colorscripts >/dev/null; then
        pokemon-colorscripts --no-title -r 1,3,6
    elif command -v fastfetch >/dev/null; then
        if do_render "image"; then
            fastfetch
        fi
    fi
fi

#   Overrides 
# HYDE_ZSH_NO_PLUGINS=1 # Set to 1 to disable loading of oh-my-zsh plugins, useful if you want to use your zsh plugins system 
# unset HYDE_ZSH_PROMPT # Uncomment to unset/disable loading of prompts from HyDE and let you load your own prompts
# HYDE_ZSH_COMPINIT_CHECK=1 # Set 24 (hours) per compinit security check // lessens startup time
# HYDE_ZSH_OMZ_DEFER=1 # Set to 1 to defer loading of oh-my-zsh plugins ONLY if prompt is already loaded

if [[ ${HYDE_ZSH_NO_PLUGINS} != "1" ]]; then
    #  OMZ Plugins 
    # manually add your oh-my-zsh plugins here
    plugins=(
        "sudo"
    )
fi

alias c='clear && printf "\e[3J"'

#  Auto-update omp on launch 
omp() {
    if [[ -n "$OMPCODE" || -n "$AGENT" || -n "$OMP_NO_AUTO_UPDATE" ]]; then
        command omp "$@"
        return $?
    fi
    case "$1" in
        update|config|completions|plugin|agents|bench|cleanse|auth-broker|auth-gateway|browser-relay|commit|compress|dry-balance|gallery|gc|git|grep|grievances|if-bench|images|install|join|models|ps|read|render|say|search|setup|share|shell|ssh|stats|tiny-models|token|ttsr|usage|worktree|-h|--help|-v|--version|-p|--print)
            command omp "$@"
            return $?
            ;;
    esac
    command omp update || true
    command omp "$@"
}
