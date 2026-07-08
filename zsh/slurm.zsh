# 'slurmviz': Interactive TUI dashboard for Slurm GPU cluster status
# Install: pip install textual
alias slurmviz='python3 ~/slurmviz/slurmviz.py'
alias slurmviz-demo='python3 ~/slurmviz/slurmviz.py --demo'

# 'sq': Show ONLY my jobs with clean formatting
# Columns: ID, Partition, JobName, User, State, Time, Nodes, Reason/Nodelist
alias sq='squeue -u $USER -o "%.10i %.9P %.20j %.8u %.2t %.10M %.4D %R"'

# 'sqall': See what everyone else is doing (Cluster Load)
alias sqall='squeue -o "%.10i %.9P %.20j %.8u %.2t %.10M %.4D %R" | less'

# 'sj': Inspect a specific job (usage: sj 12345)
alias sj='scontrol show job'

# 'scancel-all': The "Panic Button" - Cancel ALL your running jobs
alias scancel-all='scancel -u $USER'

# 'nodes': A clean summary of partition health
# Shows: Partition | Node Count | State (Allocated/Idle/Other/Total) | Node List
alias nodes='sinfo -o "%20P %5D %14F %N"'

# 'free-nodes': explicitly show me idle nodes where I can run stuff now
alias free-nodes='sinfo --state=idle'

# Usage: 'interact' or 'interact 4' (for 4 hours)
# Request: 1 Node, 4 CPUs, 8GB RAM (Adjust these defaults to your cluster's limits)
interact() {
  local time=${1:-01:00:00} # Default 1 hour if no argument
  # If the user typed just "4", treat it as 4 hours
  if [[ "$time" =~ ^[0-9]+$ ]]; then time="${time}:00:00"; fi

  echo "🚀 Requesting interactive shell for $time..."
  srun --pty --nodes=1 --ntasks=1 --cpus-per-task=4 --mem=8G --time=$time /bin/zsh
}

# 'wsq': Watch my Queue (refreshes every 2 seconds)
wsq() {
  watch -n 2 -c "squeue -u $USER -o \"%.10i %.9P %.20j %.8u %.2t %.10M %.4D %R\""
}

# 'wnodes': Watch Cluster Status
wnodes() {
  watch -n 5 -c "sinfo -o \"%20P %5D %14F %N\""
}

# GPU cluster status dashboard
gpustats() {
    local total_nodes=0 idle=0 mix=0 alloc=0 down=0
    local idle_list=""
    while IFS=' ' read -r node state; do
        ((total_nodes++))
        case "$state" in
            idle)      ((idle++)); idle_list+="$node " ;;
            mixed)     ((mix++)) ;;
            allocated) ((alloc++)) ;;
            down*|drain*) ((down++)) ;;
        esac
    done < <(sinfo -N -o "%N %T" --noheader 2>/dev/null)

    local total_gpus=$(sinfo -N -o "%G" --noheader 2>/dev/null | grep -oP '\d+' | awk '{s+=$1}END{print s}')
    local down_gpus=$(sinfo -N -o "%T %G" --noheader 2>/dev/null | grep 'down\|drain' | grep -oP 'gpu:\K\d+' | awk '{s+=$1}END{print s+0}')
    local used_gpus=$(squeue -o "%b" --noheader 2>/dev/null | grep -oP 'gpu:\K\d+' | awk '{s+=$1}END{print s+0}')
    local free_gpus=$((total_gpus - down_gpus - used_gpus))
    local usable=$((total_gpus - down_gpus))
    local pct=0
    (( usable > 0 )) && pct=$((free_gpus * 100 / usable))

    local bar_len=30
    local filled=$((pct * bar_len / 100))
    local empty=$((bar_len - filled))
    local bar=""
    for ((i=0; i<filled; i++)); do bar+="█"; done
    for ((i=0; i<empty; i++)); do bar+="░"; done

    local D=$'\e[90m' R=$'\e[0m' B=$'\e[1m' GR=$'\e[32m' YL=$'\e[33m' RD=$'\e[31m' MG=$'\e[35m' CY=$'\e[36m'
    local BC
    (( pct >= 50 )) && BC=$GR || { (( pct >= 20 )) && BC=$YL || BC=$RD; }

    echo ""
    echo "${D}┌──────────────────────────────────────────────┐${R}"
    echo "${D}│${R}  ${B}${CY}⬡ GPU CLUSTER STATUS${R}                         ${D}│${R}"
    echo "${D}├──────────────────────────────────────────────┤${R}"
    printf "${D}│${R}  ${B}Nodes${R}  ${GR}●${R} idle ${B}%-3s${R} ${YL}●${R} mix ${B}%-3s${R} ${MG}●${R} full ${B}%-3s${R}  ${D}│${R}\n" "$idle" "$mix" "$alloc"
    printf "${D}│${R}         ${RD}●${R} down ${B}%-3s${R} ${D}total %-3s${R}          ${D}│${R}\n" "$down" "$total_nodes"
    echo "${D}├──────────────────────────────────────────────┤${R}"
    printf "${D}│${R}  ${B}GPUs${R}   ${B}%-4s${R}total  ${B}%-4s${R}used  ${B}${GR}%-4s${R}free     ${D}│${R}\n" "$total_gpus" "$used_gpus" "$free_gpus"
    printf "${D}│${R}  ${B}Free${R}   ${BC}${bar}${R} ${B}%3d%%${R}    ${D}│${R}\n" "$pct"
    if [[ -n "$idle_list" ]]; then
        echo "${D}├──────────────────────────────────────────────┤${R}"
        echo "${D}│${R}  ${B}Idle${R}   ${GR}${idle_list}${R}"
        echo "${D}│${R}         ${D}^ ready for full-node jobs${R}              ${D}│${R}"
    fi
    echo "${D}└──────────────────────────────────────────────┘${R}"
    echo ""
}

# My jobs dashboard
myjobs() {
    local D=$'\e[90m' R=$'\e[0m' B=$'\e[1m' GR=$'\e[32m' YL=$'\e[33m' RD=$'\e[31m' CY=$'\e[36m' MG=$'\e[35m' WH=$'\e[37m'

    local lines=()
    while IFS=' ' read -r id name state elapsed nodes gres node; do
        local gpu_str="-"
        [[ "$gres" == *gpu:* ]] && gpu_str=$(echo "$gres" | grep -oP 'gpu:\K\d+')
        local sc
        case "$state" in
            R)  sc="${GR}RUN${R}" ;;
            PD) sc="${YL}PND${R}" ;;
            CG) sc="${MG}CMP${R}" ;;
            *)  sc="${RD}${state}${R}" ;;
        esac
        lines+=("${id}|${name}|${sc}|${elapsed}|${gpu_str}|${node}")
    done < <(squeue -u "$USER" -o "%i %j %t %M %D %b %N" --noheader 2>/dev/null)

    local total=${#lines[@]}
    local total_gpus=0
    for l in "${lines[@]}"; do
        local g=$(echo "$l" | cut -d'|' -f5)
        [[ "$g" != "-" ]] && ((total_gpus += g))
    done

    echo ""
    echo "${D}┌─────────────────────────────────────────────────────────────────┐${R}"
    echo "${D}│${R}  ${B}${CY}◈ MY JOBS${R}                                  ${D}jobs:${R}${B}${total}${R}  ${D}gpus:${R}${B}${GR}${total_gpus}${R}  ${D}│${R}"
    echo "${D}├─────────────────────────────────────────────────────────────────┤${R}"
    printf "${D}│${R}  ${D}%-12s %-18s %-5s %-12s %-4s %-14s${R} ${D}│${R}\n" "ID" "NAME" "ST" "TIME" "GPU" "NODE"
    echo "${D}├─────────────────────────────────────────────────────────────────┤${R}"

    if (( total == 0 )); then
        echo "${D}│${R}  ${D}No jobs running${R}                                                ${D}│${R}"
    else
        for l in "${lines[@]}"; do
            IFS='|' read -r id name sc elapsed gpu node <<< "$l"
            [[ ${#name} -gt 18 ]] && name="${name:0:16}.."
            printf "${D}│${R}  ${WH}%-12s${R} ${B}%-18s${R} %-14s ${D}%-12s${R} ${CY}%-4s${R} ${GR}%-14s${R} ${D}│${R}\n" "$id" "$name" "$sc" "$elapsed" "$gpu" "$node"
        done
    fi

    echo "${D}└─────────────────────────────────────────────────────────────────┘${R}"
    echo ""
}

# Per-user GPU usage breakdown
gpu-who() {
    local D=$'\e[90m' R=$'\e[0m' B=$'\e[1m' GR=$'\e[32m' YL=$'\e[33m' RD=$'\e[31m' CY=$'\e[36m' MG=$'\e[35m' WH=$'\e[37m'

    local total_cluster_gpus=$(sinfo -N -o "%T %G" --noheader 2>/dev/null | grep -v 'down\|drain' | grep -oP 'gpu:\K\d+' | awk '{s+=$1}END{print s+0}')

    local -A user_gpus user_jobs
    while read -r user gres; do
        ((user_jobs[$user]++))
        if [[ "$gres" == *gpu:* ]]; then
            local g=$(echo "$gres" | grep -oP 'gpu:\K\d+')
            ((user_gpus[$user] += g))
        fi
    done < <(squeue -o "%u %b" --noheader 2>/dev/null)

    # Sort users by GPU count descending
    local sorted_users=()
    for u in "${(@k)user_gpus}"; do
        sorted_users+=("${user_gpus[$u]}|$u")
    done
    # Add users with 0 gpus but active jobs
    for u in "${(@k)user_jobs}"; do
        [[ -z "${user_gpus[$u]}" ]] && sorted_users+=("0|$u")
    done
    sorted_users=(${(On)sorted_users})

    echo ""
    echo "${D}┌──────────────────────────────────────────────────┐${R}"
    echo "${D}│${R}  ${B}${CY}◉ GPU USAGE BY USER${R}                              ${D}│${R}"
    echo "${D}├──────────────────────────────────────────────────┤${R}"
    printf "${D}│${R}  ${D}%-14s %-6s %-6s %-20s${R} ${D}│${R}\n" "USER" "GPUs" "JOBS" ""
    echo "${D}├──────────────────────────────────────────────────┤${R}"

    for entry in "${sorted_users[@]}"; do
        local gpus=${entry%%|*}
        local user=${entry#*|}
        local jobs=${user_jobs[$user]:-0}
        local pct=0
        (( total_cluster_gpus > 0 )) && pct=$((gpus * 100 / total_cluster_gpus))

        # Mini bar (20 chars wide)
        local bar_len=20
        local filled=$((pct * bar_len / 100))
        local empty=$((bar_len - filled))
        local bar=""
        for ((i=0; i<filled; i++)); do bar+="█"; done
        for ((i=0; i<empty; i++)); do bar+="░"; done

        local uc="${WH}"
        [[ "$user" == "$USER" ]] && uc="${GR}"

        printf "${D}│${R}  ${uc}${B}%-14s${R} ${CY}%-6s${R} ${D}%-6s${R} ${YL}%s${R} ${B}%2d%%${R} ${D}│${R}\n" "$user" "$gpus" "$jobs" "$bar" "$pct"
    done

    echo "${D}└──────────────────────────────────────────────────┘${R}"
    echo ""
}

# Tail slurm job output log
joblog() {
    local D=$'\e[90m' R=$'\e[0m' B=$'\e[1m' GR=$'\e[32m' YL=$'\e[33m' CY=$'\e[36m' RD=$'\e[31m'

    if [[ -z "$1" ]]; then
        # No arg: show fzf picker of user's jobs
        local pick
        pick=$(squeue -u "$USER" -o "%i %j %t %M %N" --noheader 2>/dev/null | fzf --prompt="Select job > " --height=40%)
        [[ -z "$pick" ]] && return 0
        set -- $(echo "$pick" | awk '{print $1}')
    fi

    local job_id="$1"
    local logfile=$(scontrol show job "$job_id" 2>/dev/null | grep -oP 'StdOut=\K\S+')

    if [[ -z "$logfile" ]]; then
        # Try common patterns
        for f in "slurm-${job_id}.out" "$HOME/slurm-${job_id}.out"; do
            [[ -f "$f" ]] && { logfile="$f"; break; }
        done
    fi

    if [[ -z "$logfile" || ! -f "$logfile" ]]; then
        echo ""
        echo "${D}┌────────────────────────────────────────┐${R}"
        echo "${D}│${R}  ${RD}✗${R} No log found for job ${B}${job_id}${R}        ${D}│${R}"
        echo "${D}└────────────────────────────────────────┘${R}"
        echo ""
        return 1
    fi

    local lines=$(wc -l < "$logfile")
    local size=$(du -h "$logfile" | cut -f1)
    local jobname=$(scontrol show job "$job_id" 2>/dev/null | grep -oP 'JobName=\K\S+')
    [[ -z "$jobname" ]] && jobname="(completed)"

    echo ""
    echo "${D}┌────────────────────────────────────────────────────────┐${R}"
    echo "${D}│${R}  ${B}${CY}▶ JOB LOG${R}                                              ${D}│${R}"
    echo "${D}├────────────────────────────────────────────────────────┤${R}"
    printf "${D}│${R}  ${D}Job:${R}  ${B}%-10s${R}  ${D}Name:${R} ${B}%-20s${R}          ${D}│${R}\n" "$job_id" "$jobname"
    printf "${D}│${R}  ${D}File:${R} %-45s  ${D}│${R}\n" "$logfile"
    printf "${D}│${R}  ${D}Size:${R} ${YL}%-8s${R}    ${D}Lines:${R} ${YL}%-10s${R}                 ${D}│${R}\n" "$size" "$lines"
    echo "${D}├────────────────────────────────────────────────────────┤${R}"
    echo "${D}│${R}  ${D}Showing last 30 lines (Ctrl+C to exit tail -f)${R}       ${D}│${R}"
    echo "${D}└────────────────────────────────────────────────────────┘${R}"
    echo ""
    tail -n 30 -f "$logfile"
}

# Quick tensorboard launcher
tb() {
    local D=$'\e[90m' R=$'\e[0m' B=$'\e[1m' GR=$'\e[32m' YL=$'\e[33m' CY=$'\e[36m' RD=$'\e[31m'

    local logdir="${1:-}"
    local port="${2:-6006}"

    if [[ -z "$logdir" ]]; then
        # Auto-detect: search for common TB log dirs
        local candidates=()
        for d in runs tb_logs lightning_logs tensorboard_logs logs/tensorboard; do
            [[ -d "$d" ]] && candidates+=("$d")
        done
        # Also search for tfevents files up to 3 levels deep
        while IFS= read -r f; do
            local dir=$(dirname "$f")
            # Go up to parent if it's a version/run dir
            candidates+=("$dir")
        done < <(find . -maxdepth 4 -name "events.out.tfevents*" -printf '%T@ %p\n' 2>/dev/null | sort -rn | head -5 | awk '{print $2}')

        if (( ${#candidates[@]} == 0 )); then
            echo ""
            echo "${D}┌──────────────────────────────────────────┐${R}"
            echo "${D}│${R}  ${RD}✗${R} No tensorboard logs found             ${D}│${R}"
            echo "${D}│${R}  ${D}Usage: tb <logdir> [port]${R}                ${D}│${R}"
            echo "${D}└──────────────────────────────────────────┘${R}"
            echo ""
            return 1
        fi

        # Deduplicate and pick
        local unique_dirs=($(printf '%s\n' "${candidates[@]}" | sort -u))
        if (( ${#unique_dirs[@]} == 1 )); then
            logdir="${unique_dirs[1]}"
        else
            logdir=$(printf '%s\n' "${unique_dirs[@]}" | fzf --prompt="Select log dir > " --height=40%)
            [[ -z "$logdir" ]] && return 0
        fi
    fi

    # Find a free port starting from the requested one
    while ss -tlnp 2>/dev/null | grep -q ":${port} "; do
        ((port++))
    done

    local abs_logdir=$(realpath "$logdir")
    local num_runs=$(find "$abs_logdir" -name "events.out.tfevents*" 2>/dev/null | wc -l)

    echo ""
    echo "${D}┌──────────────────────────────────────────────────────┐${R}"
    echo "${D}│${R}  ${B}${CY}▸ TENSORBOARD${R}                                        ${D}│${R}"
    echo "${D}├──────────────────────────────────────────────────────┤${R}"
    printf "${D}│${R}  ${D}Logdir:${R} ${B}%-42s${R} ${D}│${R}\n" "$abs_logdir"
    printf "${D}│${R}  ${D}Runs:${R}   ${YL}%-4s${R}    ${D}Port:${R} ${GR}%-6s${R}                     ${D}│${R}\n" "$num_runs" "$port"
    echo "${D}├──────────────────────────────────────────────────────┤${R}"
    echo "${D}│${R}  ${GR}http://localhost:${port}${R}                                ${D}│${R}"
    echo "${D}│${R}  ${D}Press Ctrl+C to stop${R}                                 ${D}│${R}"
    echo "${D}└──────────────────────────────────────────────────────┘${R}"
    echo ""
    tensorboard --logdir="$abs_logdir" --port="$port" --bind_all 2>/dev/null
}
