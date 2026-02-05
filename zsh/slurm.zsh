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
