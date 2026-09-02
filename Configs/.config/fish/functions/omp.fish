# Auto-update omp on launch instead of prompting inside the session
function omp --wraps omp --description 'Oh My Pi with auto-update on launch'
    if test -n "$OMPCODE"; or test -n "$AGENT"; or test -n "$OMP_NO_AUTO_UPDATE"
        command omp $argv
        return $status
    end

    if test (count $argv) -gt 0
        switch $argv[1]
            case update config completions plugin agents bench cleanse auth-broker auth-gateway browser-relay commit compress dry-balance gallery gc git grep grievances if-bench images install join models ps read render say search setup share shell ssh stats tiny-models token ttsr usage worktree -h --help -v --version -p --print
                command omp $argv
                return $status
        end
    end

    command omp update; or true
    command omp $argv
end
