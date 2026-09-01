#!/bin/bash
# แถบสุขภาพ cluster บน tmux bar — cache 60 วิ ไม่ spam API (ซ่อนตัวเมื่อต่อ cluster ไม่ได้)
C=/tmp/.k8s-health-cache
command -v kubectl >/dev/null || exit 0
if [[ ! -f $C || $(( $(date +%s) - $(stat -f %m "$C" 2>/dev/null || echo 0) )) -gt 60 ]]; then
  out=$(kubectl get pods -A --no-headers 2>/dev/null)
  if [[ -z $out ]]; then echo "" > "$C"; else echo "$out" | grep -cvE "Running|Completed" > "$C"; fi
fi
n=$(cat "$C" 2>/dev/null)
[[ -z $n ]] && exit 0
if (( n > 0 )); then printf '#[fg=#11111b,bg=#f38ba8]󰀦 %s#[bg=default] ' "$n"; else printf '#[fg=#11111b,bg=#a6e3a1]󰄬#[bg=default] ' ; fi
