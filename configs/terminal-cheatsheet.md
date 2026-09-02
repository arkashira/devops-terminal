# devops-terminal Cheat Sheet

## ⚡ Quick wins
| ปุ่ม/คำสั่ง | ทำอะไร |
|---|---|
| `Tab` | **fzf-tab dropdown** — เลือกด้วยลูกศร+พิมกรอง ทุกคำสั่ง (kubectl/aws/helm/cd/git) ทุก terminal รวม tmux — กด `/` เจาะโฟลเดอร์ต่อ, มี preview ตอน cd |
| `Esc Esc` | เติม/ถอด `sudo` หน้าคำสั่ง (บรรทัดว่าง = หยิบคำสั่งก่อนหน้ามาใส่ sudo ให้) |
| `Ctrl+Z` | สลับเข้า/ออกโปรแกรมที่พักไว้ — กดใน vim/k9s เพื่อพัก กดอีกทีกลับ |
| พิมคำสั่งผิด | zsh ถาม `correct 'kubctl' to 'kubectl'? [ynae]` — y=แก้ให้ |
| `→` หรือ `Ctrl+E` / `Alt+F` | รับ ghost text ทั้งหมด / ทีละคำ |
| `reload` (หรือ `rl`) | โหลด config ใหม่แบบปลอดภัย — **อย่าใช้ `source ~/.zshrc`** จะทำ ZLE พัง |
| พิม `~` หรือ path เฉยๆ | cd ไปเลย ไม่ต้องพิม cd (autocd) |
| `keys` | เปิด cheat sheet นี้ |

## 🤖 AI (ต้องมี kiro-cli + login)
| ปุ่ม/คำสั่ง | ทำอะไร |
|---|---|
| `Alt+T` | พิมภาษาคนบนบรรทัด → AI แปลงเป็นคำสั่งจริง (มีเมนูก่อนรัน) |
| `ask <คำถาม>` | ถาม AI ตอบในจอ (read-only ไม่แตะไฟล์/ไม่รันคำสั่ง) |
| `whyfail` | คำสั่งเมื่อกี้พัง → AI อธิบายสาเหตุ+วิธีแก้ |
| `kiro-cli chat` | AI agent เต็มตัวใน terminal |

## 👻 Ghostty
| ปุ่ม | ทำอะไร |
|---|---|
| `Cmd+\`` (จากแอปไหนก็ได้) | Quick Terminal หล่นจากขอบบน กดซ้ำเก็บ |
| `Cmd+↑` / `Cmd+↓` | กระโดดระหว่าง prompt (แบบ blocks ของ Warp) |
| `Cmd+Shift+J` | เท scrollback ทั้งหมดลงไฟล์แล้วเปิดดู |
| `Shift+Enter` | ขึ้นบรรทัดใหม่ไม่ส่งคำสั่ง (ใช้กับ AI chat) |
| `Cmd+D` / `Cmd+Shift+D` | split ขวา / ล่าง |
| `Cmd+Alt+ลูกศร` / `Cmd+Shift+Enter` | ย้าย split / zoom |
| `Cmd+K` | เคลียร์จอ · `Cmd+Shift+,` reload config |

## 🔍 fzf / ค้นหา
| ปุ่ม | ทำอะไร |
|---|---|
| `Ctrl+R` | ค้น history (atuin UI — กรองตาม dir/exit code ได้) |
| `Ctrl+T` | ค้นไฟล์ + preview (bat) แล้ววางลงบรรทัด |
| `Alt+C` | เลือก dir แล้ว cd ไปเลย |
| `**` แล้ว `Tab` | fuzzy completion เช่น `vim **<Tab>` |
| `Ctrl+G` | navi — คลังคำสั่ง devops (aws/k8s/tf/trivy) |
| `z <คำ>` / `zi` | กระโดดไป dir ที่ไปบ่อย / เลือกผ่าน fzf |

## ☸️ Kubernetes / AWS
| คำสั่ง | ทำอะไร |
|---|---|
| `saws` | สลับ AWS profile (dropdown) |
| `kubectx` / `kubens` | สลับ cluster / namespace (dropdown) |
| `fkl` / `fke` / `fkd` / `fkpf` | เลือก pod → log / shell / describe / port-forward |
| `stern <pattern> -n <ns>` | tail log หลาย pod พร้อมกัน |
| `k` | kubectl แบบมีสี |
| `watch kubectl get pods` | viddy — ไฮไลท์ diff อัตโนมัติ |
| cd เข้าโฟลเดอร์ที่ map ไว้ | AWS_PROFILE สลับเอง (ตั้งใน AWS_DIR_PROFILES) |

## 🖥 tmux (prefix = Ctrl+b)
| ปุ่ม | ทำอะไร |
|---|---|
| `prefix Tab` | extrakto — หยิบ token จากจอ (pod/IP/hash) ด้วย fzf |
| `prefix i` | AI chat popup (kiro) |
| `prefix k` | k9s popup |
| `prefix t` | scratch terminal popup |
| `prefix S` | sync panes — พิมครั้งเดียวลงทุก pane (มี ⚠ SYNC เตือน) |
| `prefix F` | เมนูจัดการ session/window/pane (fzf) |
| `prefix u` | เปิด URL ที่อยู่บนจอ |
| `prefix \|` / `prefix -` | split แนวตั้ง / แนวนอน |
| `Alt+ลูกศร` | ย้าย pane (ไม่ต้อง prefix) |
| `Shift+←/→` | สลับ window (ไม่ต้อง prefix) |
| `prefix [` แล้ว `v`,`y` | copy mode แบบ vim — เลือกแล้ว copy เข้า clipboard |
| `prefix Ctrl+s` / `Ctrl+r` | save / restore session (autosave ทุก 15 นาที) |
| `prefix I` | ติดตั้ง/อัปเดต plugins · `prefix r` reload config |

## 🧰 Modern CLI
| คำสั่ง | ทำอะไร |
|---|---|
| `rg <คำ>` | grep ยุคใหม่ เร็วกว่า 8 เท่า เคารพ .gitignore |
| `dust` / `duf` / `procs` | du / df / ps ฉบับสวยอ่านง่าย |
| `tldr <cmd>` | ตัวอย่างใช้งานคำสั่งแบบสั้นๆ |
| `lg` | lazygit — git แบบ TUI |
| `y` | yazi file manager — ออกแล้ว cd ตามโฟลเดอร์ที่ browse |
| `kdash` | k8s dashboard เร็วจัด (คู่กับ k9s) |
| `k8sgpt analyze` | AI ไล่หาปัญหาทั้งคลัสเตอร์ (โหมดพื้นฐานไม่ต้องมี API key) |
| `kubectl resource-capacity -u` | requests/limits เทียบการใช้จริง |
| `kubectl tree` / `neat` / `view-secret` / `node-shell` | krew plugins |
| `jwtui <token>` | decode JWT ในจอ |
| `kubectl logs ... \| gonzo` | วิเคราะห์ log สดใน TUI |
| ใน k9s: `Ctrl-L` / `Ctrl-G` | stern logs / เท log เข้า gonzo |
| รันคำสั่ง >30 วิ | แจ้งเตือน macOS เด้งเองตอนเสร็จ |
| prompt ⎈ ขึ้น 🔥 สีแดง | อยู่ context prod — เช็คก่อนยิง! |

## 🌐 Network toolkit (2026-09-01)
| คำสั่ง | ทำอะไร |
|---|---|
| `warroom <ns>` | **เปิดห้องบัญชาการ incident**: k9s + stern + watch pods ใน tmux session เดียว |
| `ailog <pod> <ns>` | เท log ให้ AI หา root cause + วิธีแก้ |
| ใน tmux: `prefix p` | จอลอย 80% กลางจอ (floax) — เปิด/ซ่อนได้ งานค้างอยู่ |
| `oops <ns>` | **สรุปความผิดปกติทั้ง namespace**: pod พัง + events + k8sgpt วิเคราะห์ ในคำสั่งเดียว |
| `knet <ns>` | เปิด netshoot pod ใน cluster — dig/curl/tcpdump/iperf จากมุมมองข้างใน ออกแล้วลบตัวเอง |
| `certcheck <domain>` | เช็ค cert: ออกโดยใคร หมดอายุเมื่อไหร่ |
| `myip` / `ports` | IP local+public / ใครเปิด port ฟังอยู่ |
| `speed` / `flushdns` | เทสเน็ต (built-in macOS) / ล้าง DNS cache |
| `nmap <host>` | สแกน port/service (ใช้กับระบบที่มีสิทธิ์เท่านั้น) |
| `sudo mtr <host>` | traceroute+ping ต่อเนื่อง เห็น packet loss รายจุด |
| `iperf3 -c <host>` | วัด bandwidth จริงระหว่างเครื่อง (`knet` แล้วรัน iperf3 -s ฝั่ง cluster ได้) |
| `ipcalc 10.0.0.0/21` | คำนวณ subnet/CIDR |
| `oha -z 30s <url>` | load test สวยๆ มีกราฟสด |
| `httpstat <url>` | เวลาแต่ละช่วงของ HTTP request (DNS/TCP/TLS/TTFB) |
| `helm diff upgrade ...` | ดู diff ก่อน helm upgrade จริง (สาย GitOps ต้องมี) |
| `k8sgpt analyze --explain -b amazonbedrock` | AI อธิบายปัญหา cluster (ต้องเปิด Bedrock model access ก่อน) |

## 🏎 Accelerators & Dev (2026-09-02)
| คำสั่ง | ทำอะไร |
|---|---|
| `Ctrl+Space` หรือ `pal` | **Command Palette** — เมนูท่าไม้ตายทั้งหมด เลือกแล้ววางลงบรรทัด |
| `kgp`+space | abbr แบบ fish: ระเบิดเป็น `kubectl get pods` (ดูหมด: `abbr list` — kgpa/kl/ke/kaf/krr/tfp/tfa/gst/gcm...) |
| `ga` `glo` `gd` `gcb` `gss` | forgit — git ทุกท่าแบบ fzf (stage/log/diff/branch/stash) |
| `git absorb --and-rebase` | stage แก้ไขแล้วรัน → สร้าง fixup เข้า commit ที่ถูกต้องเองอัตโนมัติ |
| `gdd` | diff แบบเข้าใจโครงสร้างโค้ด (difftastic) |
| `lab-up` / `lab-down` | คลัสเตอร์ k8s จำลองในเครื่อง (k3d) ไว้ซ้อม CKA/เทส manifest |
| `glab` | GitLab CLI — MR/pipeline จาก terminal (`glab auth login --hostname <กิตบริษัท>`) |
| `freeze <file> -o x.png` | แปลงโค้ดเป็นรูปสวยๆ แชร์ได้ |
| `vhs <tape>` | อัด terminal เป็น GIF จากสคริปต์ |
| `jnv <file.json>` | เขียน jq แบบเห็นผลสดๆ |
| `mprocs` / `pueue` | รันหลาย process ใน TUI / คิวงานยาวไม่ตายตามเทอร์มินัล |
| `hurl x.hurl` / `act` | เทส API เป็นไฟล์ (CI ได้) / รัน GitHub Actions ในเครื่อง |
| `cosign` / `awscurl` / `rclone` | verify image / curl แบบ SigV4 / sync ทุก cloud storage |
| `tokei` / `grex` / `hexyl` | นับโค้ด / สร้าง regex จากตัวอย่าง / hex viewer |
| `img <รูป>` / `lastout` | ดูรูปในจอ / copy output คำสั่งล่าสุด (tmux) |
| Enter แล้ว prompt เก่าย่อ | transient prompt — scrollback สะอาด (ปิด: คอมเมนต์ใน zshrc) |

## 🧑‍💻 DevX pack (2026-09-04)
| คำสั่ง | ทำอะไร |
|---|---|
| `mirdev <pod> -- <cmd>` | **mirrord** — รันโค้ดในเครื่องแต่ traffic/env/ไฟล์วิ่งผ่าน pod จริงในคลัสเตอร์ (ไม่ต้อง build+deploy เพื่อ debug) |
| `kftui` | จัดการ port-forward หลายตัวใน TUI — pod ตายมันต่อกลับเอง (แก้จุดอ่อน kubectl port-forward) |
| `fdb [ns]` | เลือก DB pod จาก dropdown → เข้า client ที่ตรงชนิด DB |
| `pgcli` / `mycli` | postgres/mysql client มี autocomplete + syntax highlight (usql สร้างไม่ผ่าน Go 1.27 — upstream bug) |
| Freelens (แอป) | Kubernetes IDE ฟรี (ทายาท OpenLens) — คู่กับ k9s เวลาต้องการ GUI |
| Atuin Desktop (แอป) | runbook ที่ "รันได้" — เขียนเป็นเอกสารแต่กดรันคำสั่งจริงได้ ไว้ทำ incident playbook ของทีม |

## ☁️ AWS emulate ในเครื่อง (ฟรีล้วน — 2026-09-04)
| คำสั่ง | ทำอะไร |
|---|---|
| `cloudup` | สตาร์ท AWS emulator (fakecloud) ที่ localhost:4566 — `cloudup moto` ใช้ moto แทน |
| `awsl <args>` | aws cli ที่ยิงเข้า emulator เสมอ เช่น `awsl s3 ls` (creds ปลอม ไม่แตะ profile จริง) |
| `cloudtest` | สร้าง bucket+ไฟล์+dynamodb table พิสูจน์ว่า emulator ทำงาน |
| `cloudstat` / `clouddown` | ดูสถานะ / ปิด emulator |
| `s3up` / `s3down` | MinIO = S3 จริงจังในเครื่อง (console http://localhost:9001 minioadmin/minioadmin) |
| `sam local start-api` | รัน Lambda + API Gateway ในเครื่อง (AWS SAM CLI — ฟรีทางการ) |
| `tfl` | terraform + creds ปลอม (ต้องตั้ง endpoints ใน provider ให้ชี้ 4566) |
> LocalStack ถูก archive มี.ค. 2026 + ต้อง login แล้ว — ชุดนี้ฟรี 100% ไม่ต้องสมัครอะไร

## 🛡 DevSecOps
| คำสั่ง | ทำอะไร |
|---|---|
| `trivy image <img>` | สแกน vuln ใน image |
| `trivy config .` | สแกน terraform/k8s yaml หา misconfig |
| `trivy fs --scanners secret .` | หา secret หลุดใน repo |
| `terraform-docs markdown table .` | gen เอกสาร module |
| `glow <file.md>` | อ่าน markdown สวยๆ ในจอ |
## 🚀 Pro tools (เพิ่ม 2026-07-23)
| คำสั่ง | ทำอะไร |
|---|---|
| `lg` | lazygit — git TUI ครบจบในจอเดียว (stage/commit/rebase/push) |
| `git diff` | สวยอัตโนมัติด้วย delta — กด `n`/`N` กระโดดข้ามไฟล์ |
| `y` | yazi — file manager มี preview ออกแล้ว cd ตามให้ |
| `btop` / `lazydocker` / `dive <image>` | monitor ระบบ / docker TUI / ส่องชั้น image |
| `kubectl neat -f x.yaml` | ล้าง yaml ให้เหลือแต่เนื้อ |
| `kubectl tree deploy/<name>` | ดู ownership ของ resource เป็นต้นไม้ |
| `kubectl node-shell <node>` | เข้า shell ของ node ตรงๆ |
| `kubent` | สแกน deprecated API ก่อนอัปเกรด cluster |
| `popeye` | ตรวจสุขภาพ cluster + ให้เกรด |
| `argocd` / `kustomize` | CLI คู่สาย gitops |
| `lnav <dir>` | เปิด log หลายไฟล์ merge ตามเวลา + query ด้วย SQL |
| `fx` / `jless` | ส่อง JSON แบบโต้ตอบ / แบบ pager |
| `xh get api.example.com/x` | curl โฉมใหม่ syntax ภาษาคน |
| `trippy <host>` / `gping <h1> <h2>` / `doggo <domain>` | traceroute+ping TUI / ping เป็นกราฟ / DNS สวยๆ |
| `hyperfine 'cmd1' 'cmd2'` | benchmark เทียบคำสั่ง |
| `watchexec -e tf 'terraform validate'` | รันซ้ำอัตโนมัติเมื่อไฟล์เปลี่ยน |
| `sops -e secrets.yaml` | เข้ารหัส secret เก็บใน git (คู่กับ age) |
| `assume` | granted — สลับ AWS SSO role หลาย account, token อยู่ใน keychain |
| `steampipe query "select name, region from aws_s3_bucket"` | query AWS ด้วย SQL |
| `aws ssm start-session --target <instance-id>` | เข้า EC2 โดยไม่ต้องมี SSH/bastion |
| `mise use terraform@1.9` / `just` | pin เวอร์ชัน tool ต่อโปรเจกต์ / task runner |
| `eksctl get cluster` / `infracost breakdown --path .` | จัดการ EKS / ประเมินค่าใช้จ่าย terraform |
