// cursor-trail — แสงเรืองตาม cursor เวลาเลื่อน (GPU ล้วน ไม่กระทบความเร็ว)
// ปิดได้โดยคอมเมนต์บรรทัด custom-shader ใน config
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec4 term = texture(iChannel0, uv);

    // จุดกึ่งกลาง cursor ปัจจุบันและก่อนหน้า (xy = มุมบนซ้ายของ cell, origin ล่างซ้าย)
    vec2 cur  = iCurrentCursor.xy  + iCurrentCursor.zw  * vec2(0.5, -0.5);
    vec2 prev = iPreviousCursor.xy + iPreviousCursor.zw * vec2(0.5, -0.5);

    // ช่วงเวลาหลัง cursor ขยับ (0 → 1 ใน 0.3 วิ)
    float t = clamp((iTime - iTimeCursorChange) / 0.3, 0.0, 1.0);

    // ระยะจาก fragment ถึงเส้นทางที่ cursor วิ่งผ่าน
    vec2 pa = fragCoord.xy - prev;
    vec2 ba = cur - prev;
    float h = clamp(dot(pa, ba) / max(dot(ba, ba), 1.0), 0.0, 1.0);
    float d = length(pa - ba * h);

    // แสงจางลงตามเวลาและระยะ — subtle ไม่แสบตา
    float glow = exp(-d * 0.06) * (1.0 - t) * 0.30;
    vec3 gcol = iCurrentCursorColor.rgb;

    fragColor = vec4(term.rgb + gcol * glow, term.a);
}
