# Persistent per-node ssh-agent, shared by ALL shells (bash and zsh) on a node.
# Sourced from ~/.zshenv and ~/.bashrc — POSIX sh only, no zsh/bash-isms.
#
# The socket lives on node-local /tmp, NOT NFS $HOME: a Unix socket only works
# on the node whose kernel created it. The previous ~/.ssh/agent.sock (NFS)
# setup meant a login on node B couldn't reach node A's agent, deleted the
# socket, and spawned a replacement — killing agent access for node A and
# leaking one agent per login (124 orphans observed on one node).

_agent_dir="/tmp/ssh-agent-${USER:-$(id -un)}"
export SSH_AUTH_SOCK="$_agent_dir/agent.sock"

if [ ! -d "$_agent_dir" ]; then
    mkdir -p -m 700 "$_agent_dir" 2>/dev/null
fi

ssh-add -l >/dev/null 2>&1
if [ $? -eq 2 ]; then
    # exit 2 = no agent listening on the socket (stale or never started)
    rm -f "$SSH_AUTH_SOCK"
    ssh-agent -a "$SSH_AUTH_SOCK" >/dev/null 2>&1
fi

# load the key only if the agent has none yet (exit 1 = running, no identities)
ssh-add -l >/dev/null 2>&1 || ssh-add ~/.ssh/id_rsa >/dev/null 2>&1

unset _agent_dir
