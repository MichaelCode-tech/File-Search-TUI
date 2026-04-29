#!/usr/bin/env bash
# search-tui.sh
# Author: MichaelCode-tech & sheild_tech
# License: MIT
# Date: 2026-04-29

set -euo pipefail
IFS=$'\n\t'

# Defaults
start_path="."
pattern="*"
use_regex=0
case_insensitive=1
type_filter="a" # a=all, f=file, d=dir
maxdepth=""
TMP="$(mktemp -t search_tui.XXXXXX)"
trap 'rm -f "$TMP"' EXIT

clear_screen(){ printf "\033c"; }

draw_header(){
  clear_screen
  echo "=== File Search TUI — MichaelCode-tech & sheild_yech ==="
  echo "Start path: $start_path    Pattern: $pattern    Type: $type_filter    Regex:$use_regex    Case-insensitive:$case_insensitive    Maxdepth:${maxdepth:-none}"
  echo "------------------------------------------------------"
}

prompt(){
  local msg="$1"
  read -rp "$msg" REPLY
  echo "$REPLY"
}

build_find_cmd(){
  local path="$1"
  local pat="$2"
  local -a parts=(find -- "$path")
  if [[ -n "$maxdepth" ]]; then parts+=( -maxdepth "$maxdepth"); fi
  case "$type_filter" in
    f) parts+=( -type f ) ;;
    d) parts+=( -type d ) ;;
  esac
  if (( use_regex )); then
    parts+=( -regextype posix-extended )
    if (( case_insensitive )); then
      parts+=( -iregex )
    else
      parts+=( -regex )
    fi
    parts+=( ".*/$pat" )
  else
    if (( case_insensitive )); then
      parts+=( -iname )
    else
      parts+=( -name )
    fi
    parts+=( "$pat" )
  fi
  # print as command string
  printf '%q ' "${parts[@]}"
}

run_search(){
  local cmd
  cmd="$(build_find_cmd "$start_path" "$pattern")"
  # shellcheck disable=SC2086
  eval "$cmd" > "$TMP" 2>/dev/null || true
  if [[ ! -s "$TMP" ]]; then
    echo "No results."
    read -rp "Press ENTER to continue..."
    return 1
  fi
  show_results
  return 0
}

show_results(){
  local lines count sel idx
  mapfile -t lines < "$TMP"
  count=${#lines[@]}
  while :; do
    draw_header
    echo "Results ($count): (use arrows + Enter to choose index, or type number)"
    for i in "${!lines[@]}"; do
      printf "%3d) %s\n" $((i+1)) "${lines[i]}"
    done
    echo "------------------------------------------------------"
    echo "Options: [o]pen [c]opy [p]rint [d]elete [s]elect new search [q]uit"
    read -rp "Select number or option: " sel
    case "$sel" in
      q) exit 0 ;;
      s) return 0 ;;
      o)
        read -rp "Enter result number to open: " idx
        idx=$((idx-1))
        if [[ -n "${lines[idx]:-}" ]]; then
          if command -v xdg-open >/dev/null 2>&1; then xdg-open "${lines[idx]}" >/dev/null 2>&1 &
          elif command -v open >/dev/null 2>&1; then open "${lines[idx]}" >/dev/null 2>&1 &
          else echo "No desktop opener found."; fi
        fi
        read -rp "Press ENTER..."
        ;;
      c)
        read -rp "Enter result number to copy path to clipboard (requires wl-copy/xclip/osx pbcopy): " idx
        idx=$((idx-1))
        if [[ -n "${lines[idx]:-}" ]]; then
          if command -v wl-copy >/dev/null 2>&1; then printf '%s' "${lines[idx]}" | wl-copy
          elif command -v xclip >/dev/null 2>&1; then printf '%s' "${lines[idx]}" | xclip -selection clipboard
          elif command -v pbcopy >/dev/null 2>&1; then printf '%s' "${lines[idx]}" | pbcopy
          else echo "No clipboard tool found."; fi
        fi
        read -rp "Press ENTER..."
        ;;
      p)
        read -rp "Enter result number to print: " idx
        idx=$((idx-1))
        if [[ -n "${lines[idx]:-}" ]]; then printf '%s\n' "${lines[idx]}"; fi
        read -rp "Press ENTER..."
        ;;
      d)
        read -rp "Enter result number to delete (will ask confirmation): " idx
        idx=$((idx-1))
        if [[ -n "${lines[idx]:-}" ]]; then
          read -rp "Confirm delete ${lines[idx]}? (y/N): " conf
          if [[ "$conf" =~ ^[Yy]$ ]]; then rm -rf -- "${lines[idx]}" && echo "Deleted."; else echo "Cancelled."; fi
        fi
        read -rp "Press ENTER..."
        ;;
      ''|*[!0-9]*)
        echo "Unknown option."
        read -rp "Press ENTER..."
        ;;
      *)
        idx=$((sel-1))
        if [[ -n "${lines[idx]:-}" ]]; then
          printf '\n%s\n\n' "${lines[idx]}"
          read -rp "Press ENTER..."
        else
          echo "Index out of range."
          read -rp "Press ENTER..."
        fi
        ;;
    esac
  done
}

main_loop(){
  while :; do
    draw_header
    echo "Menu:"
    echo " 1) Set start path (current: $start_path)"
    echo " 2) Set name pattern (wildcard or regex)"
    echo " 3) Toggle regex mode (currently: $use_regex)"
    echo " 4) Toggle case-insensitive (currently: $case_insensitive)"
    echo " 5) Set type filter (a=all,f=file,d=dir) (current: $type_filter)"
    echo " 6) Set max depth (empty = unlimited)"
    echo " 7) Run search"
    echo " 8) Quit"
    echo "------------------------------------------------------"
    read -rp "Choice: " choice
    case "$choice" in
      1) v=$(prompt "Start path: (default .) "); start_path="${v:-.}" ;;
      2) v=$(prompt "Pattern (wildcards like *.txt or regex when regex mode ON): "); pattern="${v:-*}" ;;
      3) use_regex=$((1-use_regex)) ;;
      4) case_insensitive=$((1-case_insensitive)) ;;
      5)
         v=$(prompt "Type (a/f/d): ")
         case "$v" in a|f|d) type_filter="$v" ;; *) echo "Invalid, keeping." ; sleep 1 ;; esac
         ;;
      6) v=$(prompt "Max depth (number or empty): "); maxdepth="$v" ;;
      7) run_search ;;
      8) exit 0 ;;
      *) echo "Invalid choice."; sleep 1 ;;
    esac
  done
}

# Entry
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main_loop
fi
