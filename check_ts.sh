#!/data/data/com.termux/files/usr/bin/bash

GWANGYANG_IP="100.69.203.94"
SEOUL_IP="여기에_서울PC_IP_입력" # 나중에 확인되면 추가

echo "=================================================="
echo " 🔍 [Tailscale 실시간 비밀 터널 레이더]"
echo "=================================================="

MY_TS=$(ip addr 2>/dev/null | grep -oE "100\.[0-9]+\.[0-9]+\.[0-9]+" | head -n 1)
if [ -n "$MY_TS" ]; then
    echo " 📱 내 스마트폰 터널 IP : $MY_TS (작동 중)"
else
    echo " ⚠️ 스마트폰 IP 표시 제한됨 (안드로이드 기본 보안 - 정상)"
fi
echo "--------------------------------------------------"

# 광양 PC (100.69.203.94) 핑 테스트
if ping -c 1 -W 2 "$GWANGYANG_IP" > /dev/null 2>&1; then
    echo " 🟢 [광양 PC] ($GWANGYANG_IP) ➔ 현재 온라인! (연결 성공)"
    # SSH 원격 포트(22번) 열림 여부 추가 확인
    if timeout 1 bash -c "</dev/tcp/$GWANGYANG_IP/22" 2>/dev/null; then
        echo "    └─ 🔓 SSH 원격 제어 문(Port 22)도 열려 있습니다!"
    fi
else
    echo " 🔴 [광양 PC] ($GWANGYANG_IP) ➔ 응답 없음 (PC 꺼짐 / 절전모드 / 방화벽)"
fi

# 서울 PC 테스트 (입력된 경우에만)
if [[ "$SEOUL_IP" != *"입력"* ]]; then
    if ping -c 1 -W 2 "$SEOUL_IP" > /dev/null 2>&1; then
        echo " 🟢 [서울 PC] ($SEOUL_IP) ➔ 현재 온라인! (연결 성공)"
    else
        echo " 🔴 [서울 PC] ($SEOUL_IP) ➔ 응답 없음"
    fi
fi
echo "=================================================="
