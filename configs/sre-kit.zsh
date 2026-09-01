# ============================================================
# SRE First-Aid Kit — คำสั่งเดียวต่ออาการ (ของที่ SRE ใหม่ต้องมี)
# ============================================================

# restarts [ns] — pod ไหน restart บ่อยสุด (ไม่ใส่ ns = ทั้งคลัสเตอร์)
restarts() { kubectl get pods ${1:+-n} ${1:--A} --sort-by='.status.containerStatuses[0].restartCount' 2>/dev/null | tail -15 }

# notready — node + pod ที่ไม่พร้อมทั้งคลัสเตอร์
notready() {
  echo "═══ nodes ═══"; kubectl get nodes 2>/dev/null | awk 'NR==1 || $2!="Ready"'
  echo "═══ pods ═══"; kubectl get pods -A --field-selector=status.phase!=Running,status.phase!=Succeeded 2>/dev/null | head -20
}

# pending [ns] — pod ค้าง Pending พร้อมเหตุผล
pending() {
  kubectl get pods ${1:+-n} ${1:--A} --field-selector=status.phase=Pending -o wide 2>/dev/null
  echo "\n💡 ดูเหตุผล: kubectl describe pod <pod> -n <ns> | tail -10 (มักเป็น resources ไม่พอ / nodeSelector / PVC)"
}

# topmem / topcpu [ns] — ใครกิน memory/cpu สุด
topmem() { kubectl top pods ${1:+-n} ${1:--A} --sort-by=memory 2>/dev/null | head -15 }
topcpu() { kubectl top pods ${1:+-n} ${1:--A} --sort-by=cpu 2>/dev/null | head -15 }

# rollback <deploy> [ns] — ถอยกลับ version ก่อนหน้า + รอจนเสร็จ
rollback() {
  [[ -z $1 ]] && { echo "ใช้: rollback <deployment> [namespace]"; return 1 }
  kubectl rollout undo deploy/$1 ${2:+-n $2} && kubectl rollout status deploy/$1 ${2:+-n $2}
}

# imgof <deploy> [ns] — ตอนนี้ deploy นี้รัน image อะไร
imgof() {
  [[ -z $1 ]] && { echo "ใช้: imgof <deployment> [namespace]"; return 1 }
  kubectl get deploy $1 ${2:+-n $2} -o jsonpath='{range .spec.template.spec.containers[*]}{.name}{"	"}{.image}{"\n"}{end}' 2>/dev/null
}

# fks [ns] — เลือก secret จาก dropdown → decode ให้เลย
fks() {
  local s=$(kubectl get secrets ${1:+-n $1} --no-headers 2>/dev/null | fzf --prompt='secret > ' | awk '{print $1}')
  [[ -n $s ]] && kubectl view-secret "$s" -a ${1:+-n $1}
}

# fssm — เลือก EC2 จาก dropdown → เข้าเครื่องผ่าน SSM (ไม่ต้องมี SSH key/bastion)
fssm() {
  local sel=$(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" \
    --query "Reservations[].Instances[].[InstanceId,Tags[?Key=='Name']|[0].Value,PrivateIpAddress]" \
    --output text 2>/dev/null | fzf --prompt='EC2 > ' --header='InstanceId  Name  PrivateIP')
  [[ -n $sel ]] && aws ssm start-session --target "$(echo $sel | awk '{print $1}')"
}

# preflight [file/dir] — ด่านตรวจ 2 ชั้นก่อน apply: schema ถูกไหม + จะเปลี่ยนอะไรจริง
preflight() {
  local t=${1:-.}
  echo "🔎 [1/2] kubeconform — ตรวจ schema..."
  kubeconform -summary -ignore-missing-schemas "$t" || { echo "❌ schema พัง — หยุดก่อน"; return 1 }
  echo "🧪 [2/2] diff กับของจริงบนคลัสเตอร์ (dyff)..."
  kubectl diff -f "$t" 2>/dev/null | head -100
  echo "✅ preflight ผ่าน — ถ้า diff ตรงใจ: kubectl apply -f $t"
}

# tour — ไกด์นำเที่ยวของเล่นทั้งหมด (สำหรับคนเพิ่งติดตั้ง)
tour() {
  command -v gum >/dev/null 2>&1 || { keys; return }
  local c
  while true; do
    c=$(gum choose --header "⚡ devops-terminal tour — เลือกหมวด (Esc = ออก)" \
      "1. พิมเร็ว: Tab / abbr / palette" "2. AI ช่วยงาน" "3. k8s first-aid" \
      "4. war room & incident" "5. network kit" "6. ความสวย" "7. ดูแลตัวเอง" "ออก") || break
    case $c in
      1.*) gum format -- "- **Tab** = dropdown ทุกคำสั่ง (พิม \`cd co\` แล้ว Tab, กด / เจาะต่อ)" \
        "- **kgp**+space = kubectl get pods (ดูหมด: \`abbr list\`)" \
        "- **Ctrl+Space** = command palette รวมท่าไม้ตาย" \
        "- **Ctrl+R** ค้น history, **z** กระโดด dir, **→** รับ ghost text" ;;
      2.*) gum format -- "- \`ask คำถาม\` ถาม AI • \`whyfail\` วิเคราะห์คำสั่งพัง" \
        "- \`ailog <pod> <ns>\` เท log หา root cause • \`oops <ns>\` สรุปทั้ง namespace" \
        "- \`k8sgpt analyze\` สแกนคลัสเตอร์ • \`Alt+T\` แปลงภาษาคนเป็นคำสั่ง" ;;
      3.*) gum format -- "- \`restarts\` ใคร restart บ่อย • \`notready\` อะไรไม่พร้อม • \`pending\` ค้างเพราะอะไร" \
        "- \`topmem\`/\`topcpu\` ใครกินสุด • \`rollback <deploy> <ns>\` ถอยด่วน" \
        "- \`imgof <deploy>\` รัน image อะไร • \`fks\` decode secret • \`preflight\` ตรวจก่อน apply" ;;
      4.*) gum format -- "- \`warroom <ns>\` = k9s + stern + watch ในจอเดียว" \
        "- ใน k9s: Ctrl-L stern, Ctrl-G gonzo • tmux: prefix+S sync, prefix+p จอลอย" \
        "- tmux bar มี pill สุขภาพคลัสเตอร์ (เขียว/แดง+จำนวน pod พัง)" ;;
      5.*) gum format -- "- \`knet\` netshoot ใน cluster • \`certcheck\` cert หมดอายุ • \`myip\` \`ports\` \`killport\`" \
        "- nmap / mtr / iperf3 / gping / trippy / doggo / oha / httpstat / ipcalc" ;;
      6.*) gum format -- "- Ghostty: Cmd+\` quick terminal, Cmd+↑↓ กระโดด prompt, cursor ระเบิดแสง" \
        "- transient prompt = scrollback สะอาด • fastfetch เปิดตัว • ธีม Catppuccin ทั้งระบบ" ;;
      7.*) gum format -- "- \`termdoctor\` ตรวจสุขภาพ • \`termup\` อัปเดต+ซ่อม patch เอง" \
        "- \`termsync\` sync ขึ้น repo (มีด่านกันข้อมูลหลุด) • \`keys\` cheat sheet เต็ม" ;;
      *) break ;;
    esac
    echo; read -k1 "?กดปุ่มใดๆ เพื่อกลับเมนู..."
  done
}

# fargo — เลือก ArgoCD app จาก dropdown → status/diff/sync/history (ต้อง argocd login ก่อน)
fargo() {
  command -v argocd >/dev/null 2>&1 || { echo "ไม่มี argocd CLI"; return 1 }
  local app=$(argocd app list -o name 2>/dev/null | fzf --prompt='argo app > ')
  [[ -z $app ]] && return
  local act=$(printf "status\ndiff\nsync\nhistory\nlogs" | fzf --prompt="$app → " --height=~30%)
  case $act in
    status)  argocd app get "$app" ;;
    diff)    argocd app diff "$app" ;;
    sync)    gum confirm "⚠️ sync $app จริงไหม?" && argocd app sync "$app" ;;
    history) argocd app history "$app" ;;
    logs)    argocd app logs "$app" --tail 100 ;;
  esac
}

# chaos-pod [ns] — ฆ่า pod สุ่ม 1 ตัวไว้ซ้อมกู้ incident — ล็อคให้ใช้ได้เฉพาะ lab (k3d) เท่านั้น
chaos-pod() {
  local ctx=$(kubectl config current-context 2>/dev/null)
  [[ $ctx != k3d-* ]] && { echo "🛑 ใช้ได้เฉพาะ context k3d-* (lab-up ก่อน) — ตอนนี้อยู่ '$ctx' ไม่ยอมยิงของจริงเด็ดขาด"; return 1 }
  local ns=${1:-default}
  local pod=$(kubectl get pods -n "$ns" --no-headers 2>/dev/null | awk 'BEGIN{srand()} {a[NR]=$1} END{if(NR)print a[int(rand()*NR)+1]}')
  [[ -z $pod ]] && { echo "ไม่มี pod ใน ns $ns"; return 1 }
  echo "💥 ฆ่า: $pod (ns: $ns) — จับเวลาหาสาเหตุ+กู้เลย! (ใบ้: restarts, oops, kubectl describe)"
  kubectl delete pod "$pod" -n "$ns" --wait=false
}
