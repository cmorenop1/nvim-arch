#!/usr/bin/env bash

MAX_HP=3600
BAR_WIDTH=30
SAVE_FILE="$HOME/.local/share/healthbar.txt"

load_hp() {
  if [[ -f "$SAVE_FILE" ]]; then
    local val
    val=$(cat "$SAVE_FILE")
    if [[ "$val" =~ ^[0-9]+$ ]] && (( val <= MAX_HP )); then
      echo "$val"
    else
      echo "$MAX_HP"
    fi
  else
    echo "$MAX_HP"
  fi
}

save_hp() {
  mkdir -p "$(dirname "$SAVE_FILE")"
  echo "$1" > "$SAVE_FILE"
}

render() {
  local hp=$1
  local filled=$(( hp * BAR_WIDTH / MAX_HP ))
  local empty=$(( BAR_WIDTH - filled ))
  local pct=$(( hp * 100 / MAX_HP ))

  local bar="["
  for (( i=0; i<filled; i++ )); do bar+="|"; done
  for (( i=0; i<empty;  i++ )); do bar+=" "; done
  bar+="]"

  local color reset="\033[0m"
  if   (( pct > 50 )); then color="\033[32m"   # green
  elif (( pct > 25 )); then color="\033[33m"   # yellow
  elif (( pct > 10 )); then color="\033[91m"   # orange
  else                      color="\033[31m"   # red
  fi

  local status
  if   (( pct > 75 )); then status="healthy"
  elif (( pct > 50 )); then status="good"
  elif (( pct > 25 )); then status="caution!"
  elif (( pct > 10 )); then status="low!!"
  elif (( hp  >  0 )); then status="CRITICAL"
  else                      status="DEAD"
  fi

  printf "\033[H\033[J"
  printf "  ${color}%s${reset}\n"   "$bar"
  printf "  ${color}%4d/%d${reset}\n" "$hp" "$MAX_HP"
}

cleanup() {
  tput cnorm
  stty "$OLD_STTY"
  printf "\033[H\033[J"
  save_hp "$hp"
  exit 0
}

hp=$(load_hp)

tput civis
OLD_STTY=$(stty -g)
stty -echo -icanon min 0 time 0
trap cleanup INT TERM EXIT
last_tick=$SECONDS

while true; do
  render "$hp"
  key=""
  IFS= read -r -s -n1 -t 1 key || true
  case "$key" in
    q|Q) cleanup ;;
    r|R) hp=$MAX_HP; save_hp "$hp" ;;
  esac

  if (( SECONDS - last_tick >= 1 )); then
    (( hp > 0 )) && (( hp-- ))
    save_hp "$hp"
    last_tick=$SECONDS
  fi
done
