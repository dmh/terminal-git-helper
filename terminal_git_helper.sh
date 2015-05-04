# Add Color to the Terminal
export CLICOLOR=1

# Unicode icons for terminal
git_repo_icon='git'
has_untracked_files_icon='✚'
has_adds_icon='⧉'
deletions_icon='✕'
cached_deletions_icon='✖'
modifications_icon='♺ '
cached_modifications_icon='☰'
ready_to_commit_icon='⏏'
has_conflicts_icon='⨂'
has_diverged_icon='⬇⬆'
up_symbol='⬆'
down_symbol='⬇'
synchronized_with_remote_icon='⥁'
has_stashes_icon='★'


# color
d_black='\033[38;5;234m'
black='\033[38;5;235m'
red='\033[38;5;124m'
green='\033[38;5;86m'
yellow='\033[38;5;220m'
blue='\033[38;5;32m'
orange='\033[38;5;208m'
purple='\033[38;5;98m'
white='\033[38;5;255m'
grey='\033[38;5;248m'
d_grey='\033[38;5;235m'

# background
bg_black='\033[48;5;236m'
bg_d_black='\033[48;5;234m'
bg_grey='\033[48;5;237m'

reset_color='\e[0m'


# Append all values and build prompt
function append {
    local var1=$1
    local icon=$2
    local color=$3
    local bgr=$4
    local var5=${5:-true}
    local var6=${6:-true}
    local space1=" "
    local space2=" "
    if [[ $var1 == false ]]; then color=$black ; fi
    if [[ $var5 == false ]]; then space1="" ; fi
    if [[ $var6 == false ]]; then space2="" ; fi
    echo -en "${color}${bgr}${space1}${icon}${space2}"
}

# Git branch full info
parse_git_branch () {
  git status | head -1
}

# Main git info parse function
function git_info {
    local current_hash=$(git rev-parse HEAD 2> /dev/null)
    if [[ -n $current_hash ]]; then local is_a_git_repo=true; fi

    if [[ $is_a_git_repo == true ]]; then
        local current_branch=$(git rev-parse --abbrev-ref HEAD 2> /dev/null)
        if [[ $current_branch == 'HEAD' ]]; then local detached=true; fi

        local number_of_logs="$(git log --pretty=oneline -n1 2> /dev/null | wc -l)"
        if [[ $number_of_logs -eq 0 ]]; then
            local just_init=true
        else
            local upstream=$(git rev-parse --symbolic-full-name --abbrev-ref @{upstream} 2> /dev/null)
            if [[ -n "${upstream}" && "${upstream}" != "@{upstream}" ]]; then local has_upstream=true; fi

            local git_status="$(git status --porcelain 2> /dev/null)"

            if [[ $git_status =~ ($'\n'|^).M ]]; then local has_modifications=true; fi
            if [[ $git_status =~ ($'\n'|^)M ]]; then local has_modifications_cached=true; fi
            if [[ $git_status =~ ($'\n'|^)UU ]]; then local has_conflicts=true; fi
            if [[ $git_status =~ ($'\n'|^)A ]]; then local has_adds=true; fi
            if [[ $git_status =~ ($'\n'|^).D ]]; then local has_deletions=true; fi
            if [[ $git_status =~ ($'\n'|^)D ]]; then local has_deletions_cached=true; fi
            if [[ $git_status =~ ($'\n'|^)[MAD] && ! $git_status =~ ($'\n'|^).[MAD\?] ]]; then local ready_to_commit=true; fi

            local number_of_untracked_files=$(\grep -c "^??" <<< "${git_status}")
            if [[ $number_of_untracked_files -gt 0 ]]; then local has_untracked_files=true; fi

            local tag_at_current_commit=$(git describe --exact-match --tags $current_hash 2> /dev/null)
            if [[ -n $tag_at_current_commit ]]; then local is_on_a_tag=true; fi

            if [[ $has_upstream == true ]]; then
                local commits_diff="$(git log --pretty=oneline --topo-order --left-right ${current_hash}...${upstream} 2> /dev/null)"
                local commits_ahead=$(\grep -c "^<" <<< "$commits_diff")
                local commits_behind=$(\grep -c "^>" <<< "$commits_diff")
            fi

            if [[ $commits_ahead -gt 0 && $commits_behind -gt 0 ]]; then local has_diverged=true; fi
            if [[ $has_diverged == false && $commits_ahead -gt 0 ]]; then local should_push=true; fi

            local number_of_stashes="$(git stash list -n1 2> /dev/null | wc -l)"
            if [[ $number_of_stashes -gt 0 ]]; then local has_stashes=true; fi
        fi
    fi

    echo "$(custom_git_info  ${current_hash:-""} ${is_a_git_repo:-false} ${current_branch:-""} ${detached:-false} ${just_init:-false} ${has_upstream:-false} ${has_modifications:-false} ${has_modifications_cached:-false} ${has_adds:-false} ${has_deletions:-false} ${has_deletions_cached:-false} ${has_untracked_files:-false} ${ready_to_commit:-false} ${tag_at_current_commit:-""} ${is_on_a_tag:-false} ${has_upstream:-false} ${commits_ahead:-false} ${commits_behind:-false} ${has_diverged:-false} ${should_push:-false} ${will_rebase:-false} ${has_stashes:-false} ${has_conflicts:-false} ${git_branch_rebase:-""})"
}

function custom_git_info {
    local current_hash=${1}
    local is_a_git_repo=${2}
    local current_branch=${3}
    local detached=${4}
    local just_init=${5}
    local has_upstream=${6}
    local has_modifications=${7}
    local has_modifications_cached=${8}
    local has_adds=${9}
    local has_deletions=${10}
    local has_deletions_cached=${11}
    local has_untracked_files=${12}
    local ready_to_commit=${13}
    local tag_at_current_commit=${14}
    local is_on_a_tag=${15}
    local has_upstream=${16}
    local commits_ahead=${17}
    local commits_behind=${18}
    local has_diverged=${19}
    local should_push=${20}
    local will_rebase=${21}
    local has_stashes=${22}
    local has_conflicts=${23}
    local git_branch_rebase=${24}




    prompt+=$(append $is_a_git_repo $git_repo_icon "${orange}" "${bg_grey}")
    prompt+=$(append $has_stashes $has_stashes_icon "${orange}" "${bg_grey}" false false)
    prompt+=$(append $has_conflicts $has_conflicts_icon "${red}" "${bg_grey}")
    prompt+=$(append $has_untracked_files $has_untracked_files_icon "${blue}" "${bg_black}")
    prompt+=$(append $has_deletions $deletions_icon "${green}" "${bg_grey}" true false)
    prompt+=$(append $has_modifications $modifications_icon "${green}" "${bg_grey}")
    prompt+=$(append $has_adds $has_adds_icon "${yellow}" "${bg_black}")
    prompt+=$(append $has_deletions_cached $cached_deletions_icon "${yellow}" "${bg_black}" false false)
    prompt+=$(append $has_modifications_cached $cached_modifications_icon "${yellow}" "${bg_black}")
    prompt+=$(append $ready_to_commit $ready_to_commit_icon "${white}" "${bg_grey}")
        if [[ $detached == true ]]; then



            prompt+=$(append $detached "$(parse_git_branch)" "${red}" "${bg_d_black}")


        else
            if [[ $has_upstream == false ]]; then
                if [[ $is_a_git_repo == true ]]; then
                    prompt+=$(append $is_a_git_repo "${current_branch}" "${blue}" "${bg_d_black}" )
                fi
            else
                if [[ $has_diverged == true ]]; then
                    prompt+=$(append $is_a_git_repo "${current_branch}" "${blue}" "${bg_d_black}" true false)
                    prompt+=$(append $is_a_git_repo "-${commits_behind} ${has_diverged_icon} +${commits_ahead}" "${red}" "${bg_d_black}")
                    prompt+=$(append $is_a_git_repo "${upstream}" "${grey}" "${bg_d_black}" false true)
                else
                    if [[ $commits_behind -gt 0 ]]; then
                        prompt+=$(append $is_a_git_repo "${current_branch}" "${blue}" "${bg_d_black}" true false)
                        prompt+=$(append $is_a_git_repo "-${commits_behind} ${down_symbol} -- " "${yellow}" "${bg_d_black}")
                        prompt+=$(append $is_a_git_repo "${upstream}" "${grey}" "${bg_d_black}" false true)
                    fi
                    if [[ $commits_ahead -gt 0 ]]; then
                        prompt+=$(append $is_a_git_repo "${current_branch}" "${blue}" "${bg_d_black}" true false)
                        prompt+=$(append $is_a_git_repo " -- ${up_symbol} +${commits_ahead}"  "${yellow}" "${bg_d_black}")
                        prompt+=$(append $is_a_git_repo "${upstream}" "${grey}" "${bg_d_black}" "${reset}" false true)
                    fi
                    if [[ $commits_ahead == 0 && $commits_behind == 0 ]]; then
                        prompt+=$(append $is_a_git_repo "${current_branch}" "${blue}" "${bg_d_black}" true false)
                        prompt+=$(append $is_a_git_repo " -- ${synchronized_with_remote_icon} -- " "${yellow}" "${bg_d_black}")
                        prompt+=$(append $is_a_git_repo "${upstream}" "${grey}" "${bg_d_black}" false true)
                    fi
                fi
            fi
        fi
        prompt+=$(append ${is_on_a_tag} " ${tag_at_current_commit}" "${yellow}" "${bg_d_black}" false true)
    echo ${prompt}
}


export PS1="\n\[$yellow\]▎ \[$green\]\w\[$reset_color\]\n\[$yellow\]▎ \[$d_black\]\[$bg_grey\]\$(git_info)\[$reset_color\]\n\[$yellow\]▎ \[$reset_color\]\[$d_grey\]\u\[$reset_color\]\[$purple\]»\[$reset_color\]\[$d_grey\](\t)\[$reset_color\]\[$d_grey\] ▜  \[$reset_color\]"

