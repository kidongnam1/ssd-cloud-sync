export EDITOR=micro

# 탐색기 스타일 폴더 내용 표시 함수
elist() {
  echo -e "\n\e[1;36m📍 현재 폴더: $(pwd | sed "s|$HOME|~|")\e[0m"
  echo -e "\e[0;90m──────────────────────────────────────\e[0m"
  local cnt=0
  while IFS= read -r item; do
    [ -z "$item" ] && continue
    cnt=$((cnt + 1))
    if [ "$cnt" -le 15 ]; then
      if [[ "$item" == */ ]]; then
        echo -e "  📁 \e[1;33m${item%/}\e[0m"
      else
        echo -e "  📄 \e[0;37m${item}\e[0m"
      fi
    fi
  done < <(ls -1p --group-directories-first 2>/dev/null | grep -v '^\~\$')
  if [ "$cnt" -eq 0 ]; then
    echo -e "  \e[0;90m(비어 있는 폴더입니다)\e[0m"
  elif [ "$cnt" -gt 15 ]; then
    echo -e "  \e[0;90m...외 $((cnt - 15))개 항목 더 있음 ('1' 입력 시 전체 탐색기)\e[0m"
  fi
  echo -e "\e[0;90m──────────────────────────────────────\e[0m"
}

# 초기 탐색기 홈 화면 함수
menu() {
  clear
  echo -e "\e[1;36m┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓\e[0m"
  echo -e "\e[1;36m┃\e[0m \e[1;32m📂 남기동 대표님 모바일 탐색기 홈\e[0m  \e[1;36m┃\e[0m"
  echo -e "\e[1;36m┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫\e[0m"
  echo -e "\e[1;36m┃\e[0m  \e[1;33m1\e[0m. 🟦 전체 파일 탐색기 (파란창 mc)\e[1;36m┃\e[0m"
  echo -e "\e[1;36m┃\e[0m  \e[1;33m2\e[0m. 🔄 클라우드 & Git 3초 동기화   \e[1;36m┃\e[0m"
  echo -e "\e[1;36m┃\e[0m  \e[1;33m3\e[0m. 📁 program 폴더 열기           \e[1;36m┃\e[0m"
  echo -e "\e[1;36m┃\e[0m  \e[1;33m4\e[0m. 📁 Program_kdn 폴더 열기       \e[1;36m┃\e[0m"
  echo -e "\e[1;36m┃\e[0m  \e[1;33m5\e[0m. 🤖 AI 에이전트 실행 (go)       \e[1;36m┃\e[0m"
  echo -e "\e[1;36m┃\e[0m  \e[1;33m6\e[0m. 🍴 내 GitHub 포크 목록 보기    \e[1;36m┃\e[0m"
  echo -e "\e[1;36m┃\e[0m  \e[1;33m7\e[0m. 🌿 Git 변경내역 탐색기(lazygit)\e[1;36m┃\e[0m"
  echo -e "\e[1;36m┃\e[0m  \e[1;33m8\e[0m. 🖥️ 서울 PC 원격 접속 (SSH)    \e[1;36m┃\e[0m"
  echo -e "\e[1;36m┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫\e[0m"
  echo -e "\e[1;36m┃\e[0m 💡 \e[1;37mb\e[0m:뒤로  \e[1;37ml\e[0m:목록  \e[1;37m0\e[0m:홈화면 다시보기\e[1;36m┃\e[0m"
  echo -e "\e[1;36m┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛\e[0m"
  echo -e "\e[1;35m📂 [~/program 작업실 실시간 미리보기]\e[0m"
  ls -1p --group-directories-first "$HOME/program" 2>/dev/null | grep -v '^\~\$' | head -n 8 | while IFS= read -r item; do
    if [[ "$item" == */ ]]; then
      echo -e "  📁 \e[1;33m${item%/}\e[0m"
    else
      echo -e "  📄 \e[0;37m${item}\e[0m"
    fi
  done
  echo ""
}

# 숫자 0~7 원터치 실행 단축키 (PC SSD_Master 방식)
alias 0='cd ~ && menu'
alias 1='mc ~/program ~/Program_kdn'
alias 2='msync'
alias 3='cd ~/program && elist'
alias 4='cd ~/Program_kdn && elist'
alias 5='go'
alias 6='gh repo list kidongnam1 --fork --limit 60'
alias 7='lazygit'
  echo -e "\e[1;36m┃\e[0m  \e[1;33m8\e[0m. 🖥️ 서울 PC 원격 접속 (SSH)    \e[1;36m┃\e[0m"

# 기존 알파벳 핫키 및 대소문자 오타 방지 호환 유지
alias p='cd ~/program && elist'
alias P='cd ~/program && elist'
alias k='cd ~/Program_kdn && elist'
alias K='cd ~/Program_kdn && elist'
alias h='cd ~ && elist'
alias b='cd .. && elist'
alias ..='cd .. && elist'
alias e='mc ~/program ~/Program_kdn'
alias E='mc ~/program ~/Program_kdn'
alias mc='mc ~/program ~/Program_kdn'
alias Mc='mc ~/program ~/Program_kdn'
alias m='msync'
alias M='msync'
alias l='elist'
alias ll='ls -lah --color=auto'
alias c='clear'
alias Cd='cd'
alias fk='gh repo list kidongnam1 --fork --limit 60'
alias gs='git status'
alias gl='git log --oneline --graph -n 5'
alias py='python3'

menu
alias 8="ssh '남기동@100.87.8.86'"
alias seoul="ssh '남기동@100.87.8.86'"
