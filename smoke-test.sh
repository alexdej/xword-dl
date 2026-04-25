#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTDIR=$(mktemp -d)
PASS=()
FAIL=()

echo "Output directory: $OUTDIR"
echo ""

run() {
    local name="$1"
    shift
    echo "=== $name ==="
    local before
    before=$(ls "$OUTDIR")
    if (cd "$OUTDIR" && uv run --project "$SCRIPT_DIR" xword-dl "$@"); then
        PASS+=("$name")
        local after
        after=$(ls "$OUTDIR")
        local new_files
        new_files=$(comm -13 <(echo "$before" | sort) <(echo "$after" | sort))
        if [[ -n "$new_files" ]]; then
            while IFS= read -r f; do
                echo "  -> $OUTDIR/$f"
            done <<< "$new_files"
        fi
    else
        FAIL+=("$name")
    fi
    echo ""
}

run "Atlantic latest"              atl
run "Atlantic by date"             atl -d 12/15/23
run "Billboard latest"             bill
run "Crossword Club latest"        club
run "Crossword Club by date"       club -d 1/3/23
run "Crossword Club by URL"        "https://crosswordclub.com/puzzles/sunday-january-07-2024/"
run "Daily Beast latest"           db
run "Daily Pop latest"             pop
run "Der Standard latest"          std
run "Der Standard by URL"          "https://www.derstandard.at/story/3000000201583/kreuzwortraetsel-h-10580"
run "Guardian Cryptic"             grdc
run "Guardian Everyman"            grde
run "Guardian Prize"               grdp
run "Guardian Quick"               grdq
run "Guardian Quiptic"             grdu
run "Guardian Speedy"              grds
run "Guardian Weekend"             grdw
run "LA Times latest"              lat
run "LA Times by date"             lat -d "2022/12/14"
run "LA Times Mini latest"         latm
run "LA Times Mini by date"        latm -d "july 20, 2025"

if [[ -n "${NYT_S_VALUE:-}" ]]; then
    NYT_SETTINGS='{"NYT-S": "'"$NYT_S_VALUE"'"}'
    run "NYT latest"               nyt --settings "$NYT_SETTINGS"
    run "NYT by date"              nyt --settings "$NYT_SETTINGS" -d "5/17/23"
    run "NYT rebus"                nyt --settings "$NYT_SETTINGS" -d "aug 10, 2023"
    run "NYT rebus special chars"  nyt --settings "$NYT_SETTINGS" -d 7/17/22
    run "NYT blanks and circles"   nyt --settings "$NYT_SETTINGS" -d "12/17/23"
    run "NYT blank clues"          nyt --settings "$NYT_SETTINGS" -d "9/27/18"
else
    echo "=== NYT tests skipped (NYT_S_VALUE not set) ==="
    echo ""
fi

run "New Yorker latest"            tny
run "New Yorker by date"           tny -d "3/31/23"
run "New Yorker by URL"            "https://www.newyorker.com/puzzles-and-games-dept/crossword/2024/01/01"
run "New Yorker themed"            "https://www.newyorker.com/puzzles-and-games-dept/crossword/2024/01/05"
run "New Yorker themed special chars" tny -d 1/12/24
run "New Yorker Mini latest"       tnym
run "New Yorker Mini by date"      tnym -d "5/16/25"
run "New Yorker Mini by URL"       "https://www.newyorker.com/puzzles-and-games-dept/mini-crossword/2025/05/16"
run "Newsday latest"               nd
run "Newsday by date"              nd -d "dec. 12, 2023"
run "Observer Everyman latest"     ever
run "Observer Everyman by URL"     "https://observer.co.uk/puzzles/everyman/article/everyman-no-4109"
run "Observer Speedy latest"       spdy
run "Observer Speedy by URL"       "https://observer.co.uk/puzzles/speedy/article/speedy-no-1563"
run "Puzzmo latest"                pzm
run "Puzzmo Big latest"            pzmb
run "Puzzmo by date"               pzm -d "2024-08-02"
run "Puzzmo Big by date"           pzmb -d "2025-04-21"
run "Simply Daily Puzzles"         sdp
run "Simply Daily Puzzles Cryptic" sdpc
run "Simply Daily Puzzles Quick"   sdpq
run "Universal latest"             uni
run "Universal by date"            uni -d "october 6, 2023"
run "USA Today latest"             usa
run "USA Today by date"            usa -d "january 7, 2024"
run "Vox"                          vox
run "Vulture"                      vult
run "Vulture by URL"               "https://www.vulture.com/article/daily-crossword-puzzle-june-19-2025.html"
run "Vulture by date"              vult -d "may 21, 2025"
run "The Walrus"                   wal
run "Washington Post latest"       wp
run "Washington Post by date"      wp -d "6/22/25"

echo "=============================="
echo "PASSED (${#PASS[@]}): ${PASS[*]}"
echo "FAILED (${#FAIL[@]}): ${FAIL[*]}"
echo "=============================="

[[ ${#FAIL[@]} -eq 0 ]]
