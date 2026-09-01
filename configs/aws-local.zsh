# ============================================================
# AWS local emulation — ฟรีล้วน (fakecloud / moto / minio / sam)
# ปรัชญา: ซ้อมบนเครื่องให้พังให้หมดก่อน แล้วค่อยไปของจริง
# ============================================================


# ── ซ่อม aws CLI: brew python@3.14 ผูก pyexpat กับ libexpat ของระบบที่ขาด symbol ──
# (ถ้าวันหนึ่ง brew แก้แล้ว ลบ 3 บรรทัดนี้ได้ — เช็คด้วย: command aws --version)
if [[ -d /opt/homebrew/opt/expat/lib ]]; then
  aws() { DYLD_LIBRARY_PATH="/opt/homebrew/opt/expat/lib${DYLD_LIBRARY_PATH:+:$DYLD_LIBRARY_PATH}" command aws "$@" }
fi

export AWS_LOCAL_ENDPOINT="${AWS_LOCAL_ENDPOINT:-http://localhost:4566}"

# awsl <args> — aws cli ที่ยิงเข้า emulator เสมอ (creds ปลอม ไม่แตะ profile จริง)
awsl() {
  AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test AWS_DEFAULT_REGION=ap-southeast-1 \
  AWS_PAGER="" DYLD_LIBRARY_PATH="/opt/homebrew/opt/expat/lib${DYLD_LIBRARY_PATH:+:$DYLD_LIBRARY_PATH}" \
    command aws --endpoint-url "$AWS_LOCAL_ENDPOINT" "$@"
}
alias tfl='AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test terraform'   # terraform ชี้ emulator (ตั้ง endpoints ใน provider)

# cloudup [engine] — สตาร์ท emulator (default: fakecloud; อื่นๆ: moto)
cloudup() {
  local engine=${1:-fakecloud}
  case $engine in
    fakecloud)
      command -v fakecloud >/dev/null || { echo "ไม่มี fakecloud (brew install fakecloud)"; return 1 }
      pgrep -xq fakecloud && { echo "fakecloud รันอยู่แล้ว → $AWS_LOCAL_ENDPOINT"; return 0 }
      nohup fakecloud >/tmp/fakecloud.log 2>&1 &
      sleep 2; echo "☁️  fakecloud ขึ้นแล้ว → $AWS_LOCAL_ENDPOINT (log: /tmp/fakecloud.log)" ;;
    moto)
      command -v moto_server >/dev/null || { echo "ไม่มี moto_server (uv tool install 'moto[server]')"; return 1 }
      pgrep -f moto_server >/dev/null && { echo "moto รันอยู่แล้ว"; return 0 }
      nohup moto_server -p 4566 >/tmp/moto.log 2>&1 &
      sleep 2; echo "☁️  moto ขึ้นแล้ว → $AWS_LOCAL_ENDPOINT (log: /tmp/moto.log)" ;;
    *) echo "ใช้: cloudup [fakecloud|moto]" ;;
  esac
}
clouddown() { pkill -x fakecloud 2>/dev/null; pkill -f moto_server 2>/dev/null; echo "🛑 emulator ปิดแล้ว" }
cloudstat() {
  echo "endpoint: $AWS_LOCAL_ENDPOINT"
  pgrep -xq fakecloud && echo "  ✅ fakecloud รันอยู่" || echo "  – fakecloud ไม่รัน"
  pgrep -f moto_server >/dev/null && echo "  ✅ moto รันอยู่" || echo "  – moto ไม่รัน"
  pgrep -f "minio server" >/dev/null && echo "  ✅ minio รันอยู่ (http://localhost:9000, console :9001)" || echo "  – minio ไม่รัน"
  curl -s --max-time 2 -o /dev/null -w "" "$AWS_LOCAL_ENDPOINT/_fakecloud/health" 2>/dev/null \
    && echo "  ✅ endpoint ตอบสนอง ($AWS_LOCAL_ENDPOINT)" \
    || { nc -z localhost 4566 2>/dev/null && echo "  ✅ port 4566 เปิดอยู่" || echo "  ❌ endpoint ไม่ตอบ"; }
}

# s3up — MinIO เป็น S3 จริงจังในเครื่อง (เก็บของถาวร, มี console เว็บ)
s3up() {
  command -v minio >/dev/null || { echo "ไม่มี minio"; return 1 }
  pgrep -f "minio server" >/dev/null && { echo "minio รันอยู่แล้ว"; return 0 }
  mkdir -p ~/.local/share/minio
  MINIO_ROOT_USER=minioadmin MINIO_ROOT_PASSWORD=minioadmin \
    nohup minio server ~/.local/share/minio --console-address ":9001" >/tmp/minio.log 2>&1 &
  sleep 2; echo "🪣 minio: API http://localhost:9000 | console http://localhost:9001 (minioadmin/minioadmin)"
}
s3down() { pkill -f "minio server" 2>/dev/null; echo "🛑 minio ปิดแล้ว" }

# cloudtest — สร้างของเล่นใน emulator เพื่อพิสูจน์ว่ามันทำงาน
cloudtest() {
  echo "🧪 สร้าง bucket + ใส่ไฟล์ + list ..."
  awsl s3 mb s3://demo-bucket 2>&1 | tail -1
  echo "hello from local aws" | awsl s3 cp - s3://demo-bucket/hello.txt 2>&1 | tail -1
  awsl s3 ls s3://demo-bucket/ 2>&1 | tail -3
  echo "🧪 DynamoDB table ..."
  awsl dynamodb create-table --table-name demo --attribute-definitions AttributeName=id,AttributeType=S \
    --key-schema AttributeName=id,KeyType=HASH --billing-mode PAY_PER_REQUEST >/dev/null 2>&1
  awsl dynamodb list-tables 2>&1 | tail -3
}
