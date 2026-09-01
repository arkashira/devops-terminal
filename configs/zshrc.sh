# ============================================================
# devops-terminal — zsh enhancements for SRE/DevOps/Platform engineers
# https://github.com/arkashira/devops-terminal
# Loaded from ~/.zshrc — ทุกส่วนมี guard ถ้าเครื่องไม่มี tool นั้นจะข้ามเอง
# ============================================================

# หา homebrew prefix แบบ dynamic (Apple Silicon = /opt/homebrew, Intel = /usr/local)
if [[ -n "$HOMEBREW_PREFIX" ]]; then BREW_PREFIX="$HOMEBREW_PREFIX"
elif [[ -d /opt/homebrew ]]; then BREW_PREFIX=/opt/homebrew
else BREW_PREFIX=/usr/local; fi

# ---------- nvm lazy-load (ถ้ามี nvm) ----------
if [[ -d "$HOME/.nvm" ]]; then
  export NVM_DIR="$HOME/.nvm"
  _nvm_bins=("$NVM_DIR"/versions/node/*/bin(/Nn))
  [[ ${#_nvm_bins[@]} -gt 0 ]] && export PATH="${_nvm_bins[-1]}:$PATH"
  unset _nvm_bins
  nvm() { unfunction nvm; [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"; nvm "$@" }
fi

# ---------- AWS profile switching ----------
# saws — เลือก AWS profile จาก dropdown (fzf)
saws() {
  local profile profiles
  profiles=$(grep -hE '^\[' "$HOME/.aws/config" "$HOME/.aws/credentials" 2>/dev/null \
    | sed -E 's/^\[profile //; s/^\[//; s/\]$//' | sort -u)
  if [[ -z "$profiles" ]]; then
    echo "saws: no AWS profiles found in ~/.aws/config or ~/.aws/credentials" >&2
    return 1
  fi
  if command -v fzf >/dev/null 2>&1; then
    profile=$(echo "$profiles" | fzf --height=~40% --reverse \
      --prompt='AWS profile > ' --header="current: ${AWS_PROFILE:-none}")
  else
    echo "Select AWS profile (current: ${AWS_PROFILE:-none}):"
    select profile in ${(f)profiles}; do break; done
  fi
  [[ -z "$profile" ]] && return
  export AWS_PROFILE="$profile" AWS_DEFAULT_PROFILE="$profile"
  echo "Switched to AWS Profile: $profile"
}

# พิมชื่อ profile ตรงๆ เพื่อสลับได้เลย (เช่น พิม `myprofile`)
for profile in $(grep -hE '^\[' "$HOME/.aws/config" "$HOME/.aws/credentials" 2>/dev/null \
    | sed -E 's/^\[profile //; s/^\[//; s/\]$//' | sort -u); do
  alias "$profile"="export AWS_PROFILE=\"$profile\" AWS_DEFAULT_PROFILE=\"$profile\" && echo \"Switched to AWS Profile: $profile\""
done
unset profile
alias awsclear='unset AWS_PROFILE AWS_DEFAULT_PROFILE && echo "Cleared AWS Profile environment variables."'

# ---------- auto AWS profile ตามโฟลเดอร์ ----------
# ใส่ mapping ของคุณเอง: "path" profile  (ไม่ต้องวางไฟล์อะไรในโปรเจกต์)
typeset -gA AWS_DIR_PROFILES=(
  # "$HOME/work/project-a" profile-a
  # "$HOME/work/project-b" profile-b
)
typeset -g _AWS_DIR_PREV="" _AWS_DIR_ACTIVE=""
_aws_profile_by_dir() {
  local dir want=""
  for dir in ${(k)AWS_DIR_PROFILES}; do
    [[ "$PWD/" == "$dir/"* ]] && { want=$AWS_DIR_PROFILES[$dir]; break; }
  done
  if [[ -n "$want" ]]; then
    if [[ "$_AWS_DIR_ACTIVE" != "$want" ]]; then
      [[ -z "$_AWS_DIR_ACTIVE" ]] && _AWS_DIR_PREV="$AWS_PROFILE"
      _AWS_DIR_ACTIVE="$want"
      export AWS_PROFILE="$want" AWS_DEFAULT_PROFILE="$want"
    fi
  elif [[ -n "$_AWS_DIR_ACTIVE" ]]; then
    _AWS_DIR_ACTIVE=""
    if [[ -n "$_AWS_DIR_PREV" ]]; then
      export AWS_PROFILE="$_AWS_DIR_PREV" AWS_DEFAULT_PROFILE="$_AWS_DIR_PREV"
    else
      unset AWS_PROFILE AWS_DEFAULT_PROFILE
    fi
  fi
}
autoload -U add-zsh-hook
add-zsh-hook chpwd _aws_profile_by_dir
_aws_profile_by_dir

# ---------- fzf full integration ----------
if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
  export FZF_DEFAULT_OPTS="--height=~60% --layout=reverse --border=rounded --info=inline \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
--color=selected-bg:#45475a,border:#6c7086"
  export BAT_THEME="Catppuccin Mocha"
  export FZF_TMUX_OPTS='-p 80%,60%'
  if command -v fd >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
    _fzf_compgen_path() { fd --hidden --follow --exclude .git . "$1" }
    _fzf_compgen_dir() { fd --type d --hidden --follow --exclude .git . "$1" }
  fi
  command -v bat >/dev/null 2>&1 && \
    export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:200 {}'"
  export FZF_ALT_C_OPTS="--preview 'ls -la {} | head -50'"
fi

# ---------- prompt / นำทาง / history ----------
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"
command -v zoxide  >/dev/null 2>&1 && eval "$(zoxide init zsh)"
command -v atuin   >/dev/null 2>&1 && eval "$(atuin init zsh --disable-up-arrow)"
command -v direnv  >/dev/null 2>&1 && eval "$(direnv hook zsh)"
command -v navi    >/dev/null 2>&1 && eval "$(navi widget zsh)"

# ---------- modern CLI aliases ----------
if command -v eza >/dev/null 2>&1; then
  alias ls='eza --icons=auto'
  alias ll='eza -la --icons=auto --git'
  alias la='eza -a --icons=auto'
  alias lt='eza --tree --level=2 --icons=auto'
fi
command -v viddy >/dev/null 2>&1 && alias watch='viddy'
# krew — kubectl plugins
[[ -d "$HOME/.krew/bin" ]] && export PATH="$HOME/.krew/bin:$PATH"
# lazygit
command -v lazygit >/dev/null 2>&1 && alias lg='lazygit'
# yazi — ออกแล้ว cd ตาม dir ที่เปิดค้าง
if command -v yazi >/dev/null 2>&1; then
  y() { local tmp="$(mktemp)"; yazi --cwd-file="$tmp" "$@"; local d="$(cat "$tmp")"; rm -f "$tmp"; [[ -n $d && $d != $PWD ]] && cd "$d" }
fi
# granted — สลับ AWS SSO role (ต้อง source เลยเป็น alias)
command -v granted >/dev/null 2>&1 && alias assume='. assume'
# ntfy — nt <คำสั่ง> = รันเสร็จแจ้งเข้ามือถือ ผ่าน ntfy.sh
# วิธีใช้: ลงแอป ntfy บนมือถือ → subscribe topic ลับของคุณ → ตั้งค่าแล้ว uncomment:
# export NTFY_TOPIC="my-secret-topic"
if command -v ntfy >/dev/null 2>&1; then
  nt() {
    local start=$SECONDS; "$@"; local code=$?
    local dur=$((SECONDS-start))
    local icon="✅"; [[ $code -ne 0 ]] && icon="❌"
    [[ -n "$NTFY_TOPIC" ]] && command ntfy publish "$NTFY_TOPIC" "$icon $* (${dur}s, exit $code)" >/dev/null 2>&1
    return $code
  }
fi
if command -v kubecolor >/dev/null 2>&1; then
  alias kubectl='kubecolor'
  alias k='kubecolor'
fi
alias keys='glow -p ~/.devops-terminal/configs/terminal-cheatsheet.md'

# ---------- k8s fzf helpers ----------
_fzf_pick_pod() {
  command kubectl get pods --all-namespaces --no-headers 2>/dev/null \
    | fzf --height=~60% --reverse --prompt='pod > ' --header='NAMESPACE  POD' \
    | awk '{print $1, $2}'
}
fkl()  { local p=($(_fzf_pick_pod)); [[ -n "$p" ]] && command kubectl logs -f -n $p[1] $p[2] }
fke()  { local p=($(_fzf_pick_pod)); [[ -n "$p" ]] && command kubectl exec -it -n $p[1] $p[2] -- sh -c 'command -v bash >/dev/null && exec bash || exec sh' }
fkd()  { local p=($(_fzf_pick_pod)); [[ -n "$p" ]] && command kubectl describe pod -n $p[1] $p[2] | bat -l yaml }
fkpf() { local p=($(_fzf_pick_pod)); [[ -z "$p" ]] && return; local ports; read "ports?local:remote (e.g. 8080:80): "; command kubectl port-forward -n $p[1] $p[2] $ports }

# ---------- AI helpers (ต้องมี kiro-cli + login แล้ว) ----------
if command -v kiro-cli >/dev/null 2>&1; then
  # fix-kiro — ใช้เมื่อ dropdown กดเลือกไม่ได้ (มักเป็นหลังแอป self-update ทำสิทธิ์ macOS ค้าง)
  fix-kiro() {
    killall kiro_cli_desktop 2>/dev/null
    open "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
    echo "1) Accessibility: เลือก Kiro CLI → กด − ลบ → กด + เพิ่มใหม่จาก /Applications/Kiro CLI.app"
    echo "2) Input Monitoring (เมนูซ้าย): ทำแบบเดียวกัน"
    echo "3) เสร็จทั้งสองแล้วกด Enter ตรงนี้"
    read -r
    open -a "Kiro CLI"
    echo "✅ เปิดแท็บ terminal ใหม่แล้วลองพิม cd ดู"
  }
  # ask <คำถาม> — ถาม AI ตอบในจอ (read-only)
  ask() { kiro-cli chat --no-interactive --trust-tools= "$*" }
  # whyfail — ให้ AI อธิบายว่าคำสั่งล่าสุดพังเพราะอะไร
  whyfail() {
    local code=$?
    local last=$(fc -ln -2 -2 2>/dev/null)
    ask "This zsh command failed (exit code $code) on macOS: ${last} — explain the likely cause and fix, concisely"
  }
  # Alt+T — แปลงข้อความบนบรรทัดเป็นคำสั่งจริงด้วย AI
  _kiro_translate_widget() {
    [[ -z $BUFFER ]] && return
    BUFFER="kiro-cli translate ${(q)BUFFER}"
    zle accept-line
  }
  zle -N _kiro_translate_widget
  bindkey '^[t' _kiro_translate_widget
  # fixdrop — dropdown ของ Kiro หาย/ค้าง พิมคำเดียวจบ แล้วเปิดแท็บใหม่
  alias fixdrop='killall kiro_cli_desktop 2>/dev/null; sleep 2; open -ga "Kiro CLI"; echo "restarted — open a new tab"'
fi

# warroom [ns] — ห้องบัญชาการ incident: k9s + stern + watch pods ในคำสั่งเดียว
warroom() {
  local ns=${1:-default} s="war-${1:-default}"
  if tmux has-session -t "$s" 2>/dev/null; then
    [[ -n $TMUX ]] && tmux switch-client -t "$s" || tmux attach -t "$s"; return
  fi
  tmux new-session -d -s "$s" -n cockpit "k9s -n $ns"
  tmux split-window -h -t "$s:cockpit" "stern . -n $ns --tail 20"
  tmux split-window -v -t "$s:cockpit.2" "viddy -n 5 kubectl get pods -n $ns"
  tmux select-pane -t "$s:cockpit.1"
  [[ -n $TMUX ]] && tmux switch-client -t "$s" || tmux attach -t "$s"
}

# ailog <pod-pattern> [ns] — ดึง log ส่งให้ AI หา root cause (ต้องมี kiro-cli + stern)
if command -v kiro-cli >/dev/null 2>&1 && command -v stern >/dev/null 2>&1; then
  ailog() {
    local pattern=$1 ns=${2:-default}
    [[ -z $pattern ]] && { echo "usage: ailog <pod-pattern> [namespace]"; return 1 }
    local logs=$(stern "$pattern" -n "$ns" --no-follow --tail 60 2>/dev/null | tail -c 12000)
    [[ -z $logs ]] && { echo "no logs for '$pattern' in ns '$ns'"; return 1 }
    ask "Analyze these pod logs ('$pattern', ns $ns) — find errors/root cause and suggest a fix, concisely:
$logs"
  }
fi

# ---------- network toolkit ----------
myip() {
  echo "local : $(ipconfig getifaddr en0 2>/dev/null || echo -)"
  echo "public: $(curl -s --max-time 5 ifconfig.me || echo -)"
}
ports() { lsof -nP -iTCP -sTCP:LISTEN }
certcheck() {
  echo | openssl s_client -servername "$1" -connect "${1}:${2:-443}" 2>/dev/null \
    | openssl x509 -noout -subject -issuer -dates
}
alias speed='networkQuality -v'
alias flushdns='sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder && echo "DNS cache flushed"'
# knet [ns] — netshoot pod สำหรับ debug network จากในคลัสเตอร์ (ออกแล้วลบตัวเอง)
knet() { kubectl run knet-$$ --rm -it --image=nicolaka/netshoot --restart=Never ${1:+-n "$1"} -- bash }
# oops [ns] — pod พัง + events + AI วิเคราะห์ ในคำสั่งเดียว
oops() {
  local ns=${1:-default}
  echo "═══ pods ไม่ปกติ (ns: $ns) ═══"
  kubectl get pods -n "$ns" --no-headers 2>/dev/null | command grep -vE "Running|Completed" || echo "  (ไม่มี — เขียวหมด)"
  echo "═══ events ล่าสุด ═══"
  kubectl get events -n "$ns" --sort-by=.lastTimestamp 2>/dev/null | tail -12
  if command -v k8sgpt >/dev/null 2>&1; then
    echo "═══ k8sgpt วิเคราะห์ ═══"
    k8sgpt analyze --namespace "$ns" 2>/dev/null | head -30
  fi
}

# ---------- termdoctor / termup / termsync — ระบบดูแลตัวเอง ----------
[[ -f "$HOME/.zsh/term-maintenance.zsh" ]] && source "$HOME/.zsh/term-maintenance.zsh"
# SRE First-Aid Kit
[[ -f "$HOME/.zsh/sre-kit.zsh" ]] && source "$HOME/.zsh/sre-kit.zsh"

# ---------- workflow accelerators ----------
# zsh-abbr — พิม kgp เคาะ space → kubectl get pods (ดูทั้งหมด: abbr list)
[[ -f "$HOME/.zsh/zsh-abbr/zsh-abbr.zsh" ]] && source "$HOME/.zsh/zsh-abbr/zsh-abbr.zsh"
# forgit — git แบบ fzf: ga/glo/gd/gcb/grh/gss
[[ -f "$BREW_PREFIX/share/forgit/forgit.plugin.zsh" ]] && source "$BREW_PREFIX/share/forgit/forgit.plugin.zsh"
# dyff — kubectl diff แบบเข้าใจ YAML
command -v dyff >/dev/null 2>&1 && export KUBECTL_EXTERNAL_DIFF="dyff between --omit-header --set-exit-code"
# lab-up / lab-down — คลัสเตอร์ k8s จำลองในเครื่อง (k3d) ไว้ซ้อม CKA/ทดสอบ manifest ปลอดภัย 100%
# (ต้องเปิด Docker ก่อน) เสร็จแล้ว kubectx เลือก k3d-lab / กลับ cluster จริงด้วย kubectx
lab-up()   { k3d cluster create lab --agents 1 && kubectl cluster-info }
lab-down() { k3d cluster delete lab }
# gdd — diff แบบเข้าใจโครงสร้างโค้ด (difftastic — เห็นการย้าย function ไม่ใช่แค่บรรทัดเปลี่ยน)
alias gdd='GIT_EXTERNAL_DIFF=difft git diff'
# git absorb — stage การแก้ (git add -p) แล้วรัน `git absorb --and-rebase` = สร้าง fixup เข้า commit ที่ถูกต้องเองอัตโนมัติ

killport() { lsof -ti tcp:$1 | xargs kill -9 2>/dev/null && echo "killed port $1" || echo "nothing on port $1" }
alias serve='python3 -m http.server 8000'
command -v atuin >/dev/null 2>&1 && alias topcmds='atuin stats'
if command -v ntfy >/dev/null 2>&1; then
  [[ -f "$HOME/.config/.ntfy-topic" ]] || openssl rand -hex 4 > "$HOME/.config/.ntfy-topic"
  np() { ntfy publish "term-$(cat ~/.config/.ntfy-topic)" "${1:-done ✅}" >/dev/null && echo "📱 sent" }
  alias nptopic='echo "term-$(cat ~/.config/.ntfy-topic)"'
fi

# ⚡ pal — Command Palette (แบบ Warp): Ctrl+Space หรือพิม pal → เลือกท่าไม้ตาย → วางลงบรรทัดพร้อมเติมค่า
pal() {
  local sel=$(command cat <<'PALEOF' | fzf --height=~75% --reverse --prompt='⚡ ' --header='Command Palette — Enter = วางลงบรรทัด' --delimiter='\|' --with-nth=1,2
warroom          |🚨 ห้องบัญชาการ incident: k9s+stern+watch pods
oops             |🔍 สรุปความผิดปกติใน namespace + AI
ailog            |🤖 เท log ให้ AI หา root cause
ask ''           |💬 ถาม AI
whyfail          |🩹 AI อธิบายคำสั่งที่เพิ่งพัง
k8sgpt analyze   |🧠 AI สแกนทั้งคลัสเตอร์
saws             |☁️ สลับ AWS profile
kubectx          |☸️ สลับ cluster
kubens           |📦 สลับ namespace
fkl              |📜 เลือก pod → tail log
fke              |🐚 เลือก pod → เข้า shell
fkpf             |🔌 เลือก pod → port-forward
knet             |🕸 netshoot pod: debug network ในคลัสเตอร์
stern . -n       |📡 tail log ทั้ง namespace
kubectl resource-capacity -u |📊 capacity ทั้งคลัสเตอร์
kor all -n       |🧹 หา resource กำพร้า
certcheck        |🔐 เช็ค cert หมดอายุ
myip             |🌐 IP เรา (local+public)
killport         |💀 ฆ่า process ที่จอง port
lastout          |📋 copy output คำสั่งล่าสุด
lg               |🌿 lazygit
glo              |🕘 git log แบบ fzf (forgit)
warroom amaze-api|⚔️ war room ของ amaze-api เลย
termdoctor       |🩺 ตรวจสุขภาพ terminal
termup           |⬆️ อัปเดตทุกอย่าง+ซ่อม patch
termsync         |🔁 sync config ขึ้น repo
keys             |📖 cheat sheet ทั้งหมด
roadmap          |🗺 แผนฝึก SRE 90 วัน
PALEOF
  )
  [[ -n $sel ]] && print -z -- "$(echo "${sel%%|*}" | sed 's/ *$//') "
}
_pal_widget() { zle push-input; BUFFER="pal"; zle accept-line }
zle -N _pal_widget
bindkey '^ ' _pal_widget

# ---------- QoL widgets ----------
# Esc Esc = เติม/ถอด sudo หน้าคำสั่ง
_toggle_sudo() {
  [[ -z $BUFFER ]] && LBUFFER="$(fc -ln -1)"
  if [[ $BUFFER == sudo\ * ]]; then LBUFFER="${LBUFFER#sudo }"
  else LBUFFER="sudo $LBUFFER"; fi
}
zle -N _toggle_sudo
bindkey '\e\e' _toggle_sudo

# Ctrl+Z = สลับเข้า/ออกโปรแกรมที่ suspend ไว้
_fancy_ctrl_z() {
  if [[ -z $BUFFER && -n $(jobs) ]]; then BUFFER='fg'; zle accept-line
  else zle push-input; fi
}
zle -N _fancy_ctrl_z
bindkey '^Z' _fancy_ctrl_z

# แจ้งเตือน macOS เองเมื่อคำสั่งที่รันเกิน 30 วิ เสร็จ (terraform apply, build ฯลฯ)
zmodload zsh/datetime 2>/dev/null
typeset -g _lc_start= _lc_cmd=
_lc_preexec() { _lc_start=$EPOCHSECONDS; _lc_cmd=$1 }
_lc_precmd() {
  local code=$?
  [[ -z $_lc_start ]] && return
  local dur=$(( EPOCHSECONDS - _lc_start )); _lc_start=
  (( dur < 30 )) && return
  [[ $_lc_cmd == (vim|nvim|vi|less|man|k9s|tmux|ssh|fzf|lazygit|lazydocker|btop|htop|watch|viddy|yazi|kiro-cli|claude|stern|sesh|atuin)* ]] && return
  local msg="${_lc_cmd//[\"\\\`]/} — $((dur/60))m$((dur%60))s (exit $code)"
  osascript -e "display notification \"${msg[1,80]}\" with title \"✅ งานเสร็จ\" sound name \"Glass\"" &>/dev/null &!
}
add-zsh-hook preexec _lc_preexec
add-zsh-hook precmd _lc_precmd

# y — เปิด yazi แล้ว cd ตามโฟลเดอร์ที่ browse ค้างไว้ตอนออก
if command -v yazi >/dev/null 2>&1; then
  y() {
    local tmp="$(mktemp -t yazi-cwd.XXXXXX)" cwd
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(command cat -- "$tmp")" && [[ -n "$cwd" && "$cwd" != "$PWD" ]]; then
      builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
  }
fi
command -v lazygit >/dev/null 2>&1 && alias lg='lazygit'

# ---------- autocorrect ----------
setopt correct
CORRECT_IGNORE='[._]*'

# ---------- fzf-tab: Tab = dropdown เลือกด้วยลูกศร (ทุกคำสั่ง ทุก terminal รวม tmux) ----------
fpath=("$HOME/.zsh/completions" "$BREW_PREFIX/share/zsh/site-functions" $fpath)
autoload -Uz compinit
for _d in "$HOME"/.zcompdump(N.mh+24); do compinit; break; done
compinit -C
unset _d
autoload -Uz bashcompinit && bashcompinit
command -v aws_completer >/dev/null 2>&1 && complete -C aws_completer aws
command -v terraform >/dev/null 2>&1 && complete -o nospace -C terraform terraform
# carapace — completion ให้อีก 1,000+ คำสั่งที่ยังไม่มีใครทำ (เสริม fzf-tab)
if command -v carapace >/dev/null 2>&1; then
  export CARAPACE_BRIDGES='zsh,bash'
  source <(carapace _carapace zsh)
fi

if [[ -f "$HOME/.zsh/fzf-tab/fzf-tab.plugin.zsh" ]]; then
  source "$HOME/.zsh/fzf-tab/fzf-tab.plugin.zsh"
  zstyle ':completion:*' menu no
  zstyle ':completion:*:descriptions' format '[%d]'
  zstyle ':fzf-tab:*' fzf-flags --height=~60%
  # กด / เจาะเข้าโฟลเดอร์ชั้นถัดไปต่อเลย
  zstyle ':fzf-tab:*' continuous-trigger '/'
  zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --icons=auto --color=always $realpath 2>/dev/null'
  zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-preview 'ps -p $word -o pid,pcpu,pmem,etime,command 2>/dev/null'
  zstyle ':fzf-tab:complete:git-(checkout|switch|merge|rebase):*' fzf-preview 'git log --oneline --color=always -15 $word 2>/dev/null'
  zstyle ':fzf-tab:complete:(export|unset|printenv):*' fzf-preview 'printenv $word 2>/dev/null'
  zstyle ':fzf-tab:complete:brew-(install|info|uninstall|upgrade):*' fzf-preview 'brew info $word 2>/dev/null | head -20'
  # ใน tmux เด้งเป็น popup กลางจอ
  [[ -n $TMUX ]] && zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
fi

# ---------- history เทพ ----------
HISTSIZE=50000
SAVEHIST=50000
setopt hist_ignore_all_dups hist_reduce_blanks inc_append_history extended_history

# Ctrl+X Ctrl+E — เอาคำสั่งที่พิมค้างไปแก้ต่อใน editor
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line

# ---------- suggestions + syntax highlighting (ต้องอยู่ท้ายสุด) ----------
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
[[ -f "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && \
  source "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
[[ -f "$HOME/.zsh/themes/catppuccin_mocha-zsh-syntax-highlighting.zsh" ]] && \
  source "$HOME/.zsh/themes/catppuccin_mocha-zsh-syntax-highlighting.zsh"
[[ -f "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] && \
  source "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# fastfetch ต้อนรับ (เฉพาะหน้าต่างแรกใน Ghostty นอก tmux)
[[ $TERM_PROGRAM == ghostty && -z $TMUX && $SHLVL -eq 1 ]] && command -v fastfetch >/dev/null 2>&1 && fastfetch
