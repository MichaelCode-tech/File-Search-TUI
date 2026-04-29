# File Search TUI — README

## Overview
A single-file Bash TUI to search for files and directories.  
Authors: MichaelCode-tech & sheild_yech

Features
- Search by name (wildcard) or regular expression.
- Case-insensitive or case-sensitive matching.
- Limit to files, directories, or both.
- Set starting path and max depth.
- Interactive results: open, copy path, print, or delete.
- No external TUI dependencies — uses bash, find, and common CLI tools.

## Requirements
- bash (GNU bash recommended)
- find, sed, awk (standard on Unix-like systems)
- Optional: xdg-open / open (to open files), wl-copy / xclip / pbcopy (to copy to clipboard)

## Installation
-  git clone https://github.com/MichaelCode-tech/File-Search-TUI.git
-  cd 'File-Search-TUI'
-  chmod +x search.sh
3. Run:
   - ./search-tui.sh

## Usage (quick)
1. Start the script:
   - ./search-tui.sh
2. Menu options:
   - 1) Set start path
   - 2) Set name pattern (wildcard or regex)
   - 3) Toggle regex mode
   - 4) Toggle case-insensitive
   - 5) Set type filter (a/f/d)
   - 6) Set max depth
   - 7) Run search
   - 8) Quit

## Pattern examples
- Wildcard (regex OFF):
  - *.sh  — matches files ending with .sh
  - *.txt — matches .txt files
- Regex (regex ON; find's -regex matches the whole path):
  - .*\.sh$    — matches paths ending with .sh
  - .*/notes/.* — matches any path containing a notes directory

Important: When regex mode is ON, the pattern must match the full path; prefix with .* and suffix with $ as needed.

## Example: Find all shell scripts
- Using wildcard (recommended):
  1. Toggle regex OFF (option 3).
  2. Set pattern to: *.sh (option 2).
  3. Optionally set type filter to f (option 5).
  4. Run search (option 7).
- Using regex:
  1. Toggle regex ON.
  2. Set pattern to: .*\.sh$
  3. Run search.

## Interactive results actions
When results are shown you can:
- Enter a result number to print its path.
- o — open a chosen result (uses xdg-open or open).
- c — copy a chosen result path to clipboard (uses wl-copy / xclip / pbcopy).
- p — print a chosen result path to stdout.
- d — delete a chosen result (asks confirmation).
- s — start a new search
- q — quit

## Configuration options
- start_path: initial directory to search (default: .)
- pattern: search pattern (wildcard or regex)
- use_regex: 0 = wildcard, 1 = regex
- case_insensitive: 1 = case-insensitive, 0 = case-sensitive
- type_filter: a = all, f = files only, d = directories only
- maxdepth: integer or empty for unlimited

## Safety notes
- Deleting via the TUI uses rm -rf — confirm before deleting.
- Clipboard and opener functions require the respective tools to be installed.

## Troubleshooting
- No results found: check start path, pattern, regex mode, and maxdepth.
- Wildcard being expanded by shell: Enter patterns at the script prompt literally (the script reads the string; do not quote unless your shell would expand before the script runs).
- Clipboard not working: install wl-clipboard/xclip (Linux) or pbcopy (macOS).
- Open not working: install xdg-utils (xdg-open) or use macOS open.

## Customization
- Edit the script to change defaults (start_path, case sensitivity).
- Add more result actions (e.g., move, rename) by extending the show_results() function.

## License
it's open source
## Changelog (high level)
- 2026-04-29 — Initial release: interactive search, wildcard & regex support, basic actions.

## Contact / Credits
Authors: MichaelCode-tech & sheild_yech

---
