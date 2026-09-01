# ============================================================
# devops-terminal maintenance — termdoctor / termup / termsync
# ============================================================
zmodload zsh/datetime 2>/dev/null

_dt_repo() {
  local R="${DEVOPS_TERMINAL_DIR:-$HOME/develop/devops-terminal}"
  [[ -d $R/.git ]] || R="$HOME/.devops-terminal"
  [[ -d $R ]] && echo "$R"
}

# termdoctor — ตรวจสุขภาพ terminal ทั้งระบบใน 5 วินาที
termdoctor() {
  echo "🩺 terminal health check"
  local s=$EPOCHREALTIME
  zsh -ic exit >/dev/null 2>&1
  printf "  ⏱  shell startup: %.2fs %s\n" $(( EPOCHREALTIME - s )) "$( (( EPOCHREALTIME - s < 0.5 )) && echo ✅ || echo '⚠️ ช้าผิดปกติ')"
  pgrep -xq kiro_cli_desktop && echo "  ✅ Kiro app รันอยู่" || echo "  ❌ Kiro app ไม่รัน → พิม fixdrop"
  command grep -q '@=@' ~/.tmux/plugins/tmux-resurrect/scripts/save.sh 2>/dev/null \
    && echo "  ✅ resurrect patch (tmux 3.7) อยู่ครบ" || echo "  ❌ resurrect patch หาย → พิม termup จะซ่อมให้"
  local plugins=$(command ls ~/.tmux/plugins 2>/dev/null | wc -l | tr -d ' ')
  echo "  ✅ tmux plugins: $plugins ตัว"
  command ls ~/Library/Fonts 2>/dev/null | command grep -q JetBrainsMonoNerdFont && echo "  ✅ Nerd Font" || echo "  ❌ Nerd Font หาย"
  local miss="" t
  for t in fzf starship zoxide atuin eza bat kubectl k9s stern; do
    command -v "$t" >/dev/null || miss="$miss $t"
  done
  [[ -z $miss ]] && echo "  ✅ core tools ครบ" || echo "  ❌ หาย:$miss"
  local out=$(brew outdated --quiet 2>/dev/null | wc -l | tr -d ' ')
  echo "  📦 brew มีของรออัปเดต: $out ตัว (พิม termup เพื่ออัปเดต)"
  local R=$(_dt_repo)
  [[ -n $R ]] && { local dirty=$(git -C "$R" status --short 2>/dev/null | wc -l | tr -d ' '); echo "  📁 repo: แก้ค้าง $dirty ไฟล์ (termsync เพื่อ sync+push)"; }
}

# termup — อัปเดตทั้งระบบแบบปลอดภัย: brew + tmux plugins + re-patch resurrect อัตโนมัติ
termup() {
  echo "🔄 brew update..."
  brew update >/dev/null 2>&1
  local out=$(brew outdated --quiet | wc -l | tr -d ' ')
  if (( out > 0 )); then
    echo "📦 อัปเดต $out ตัว..."
    brew upgrade
  else
    echo "📦 brew ล่าสุดแล้ว"
  fi
  echo "🔄 tmux plugins..."
  ~/.tmux/plugins/tpm/bin/update_plugins all >/dev/null 2>&1
  # re-apply resurrect patch ถ้าโดน update ทับ
  local SAVE=~/.tmux/plugins/tmux-resurrect/scripts/save.sh R=$(_dt_repo)
  if [[ -f $SAVE && -n $R ]] && ! command grep -q '@=@' "$SAVE"; then
    git -C ~/.tmux/plugins/tmux-resurrect apply "$R/patches/resurrect-tmux37.patch" 2>/dev/null \
      && echo "🩹 re-patch resurrect (tmux 3.7) ให้แล้ว" \
      || echo "⚠️ patch resurrect ไม่เข้า — เช็ค upstream ว่าแก้แล้วหรือยัง"
  fi
  tldr --update >/dev/null 2>&1
  echo "✅ termup เสร็จ — รัน termdoctor เช็คซ้ำได้"
}

# termsync — sync config เครื่อง → repo (มีด่านสแกนข้อมูลบริษัทก่อน push)
termsync() {
  local R=$(_dt_repo)
  [[ -z $R ]] && { echo "ไม่เจอ repo devops-terminal"; return 1 }
  cp ~/.tmux.conf "$R/configs/tmux.conf" 2>/dev/null
  cp ~/.config/starship.toml "$R/configs/starship.toml" 2>/dev/null
  cp ~/.config/ghostty/config "$R/configs/ghostty-config" 2>/dev/null
  cp ~/.config/fastfetch/config.jsonc "$R/configs/fastfetch.jsonc" 2>/dev/null
  cp "$HOME/Library/Application Support/k9s/plugins.yaml" "$R/configs/k9s-plugins.yaml" 2>/dev/null
  # 🛡 ด่าน 1: gitleaks สแกน secret จริงจัง (ถ้ามี)
  if command -v gitleaks >/dev/null 2>&1; then
    if ! gitleaks detect --no-git -s "$R" --no-banner >/dev/null 2>&1; then
      echo "🚨 gitleaks เจอ secret ใน repo — ยกเลิกการ push:"
      gitleaks detect --no-git -s "$R" --no-banner 2>&1 | tail -8
      return 1
    fi
  fi
  # 🛡 ด่าน 2: ห้ามข้อมูลบริษัท/ความลับหลุดขึ้น public repo
  local leaks=$(git -C "$R" diff --cached --diff-filter=ACM 2>/dev/null; git -C "$R" diff 2>/dev/null | command grep -iE "471157221567|498952158610|amaze|ascend|amzn|tbit|AKIA[A-Z0-9]{16}|-----BEGIN" | head -5)
  if [[ -n $leaks ]]; then
    echo "🚨 เจอข้อมูลที่อาจเป็นของบริษัท/ความลับใน diff — ยกเลิกการ push:"
    echo "$leaks"
    echo "แก้ไฟล์ให้ generic ก่อนแล้วค่อย termsync ใหม่"
    return 1
  fi
  git -C "$R" status --short | head -15
  local n=$(git -C "$R" status --short | wc -l | tr -d ' ')
  (( n == 0 )) && { echo "✅ ไม่มีอะไรเปลี่ยน — repo ตรงกับเครื่องแล้ว"; return 0 }
  local a; read "a?commit + push $n ไฟล์? [y/N] "
  [[ $a == y* ]] && git -C "$R" add -A && git -C "$R" commit -m "termsync: $(date +%Y-%m-%d)" && git -C "$R" push && echo "✅ pushed"
}
