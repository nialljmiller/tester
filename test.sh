#!/bin/bash

START_DATE="2022-01-01"
END_DATE="2025-01-01"

# Initialize repo if needed
[ ! -d .git ] && git init

# Random commit messages (optional)
MESSAGES=("Fix typo" "Update readme" "Refactor code" "Add test" "Cleanup" "Improve doc" "Update function" "Bugfix" "Adjust spacing" "Remove unused code")

# Convert dates to seconds since epoch
start_sec=$(date -d "$START_DATE" +%s)
end_sec=$(date -d "$END_DATE" +%s)

# Total number of days
total_days=$(( (end_sec - start_sec) / 86400 ))

for ((d=0; d<=total_days; d++)); do
    # Date string
    current_day=$(date -d "$START_DATE +$d days" +%Y-%m-%d)

    # Ramp factor from 0 (start) to 1 (end)
    ramp=$(awk -v day=$d -v total=$total_days 'BEGIN{print day/total}')

    # Max commits per day = 4, scaled by ramp up to 2024, with base noise
    base=$(shuf -i 0-1 -n 1)
    max_commits=$(awk -v base=$base -v r=$ramp 'BEGIN{srand(); print int((r * 4 + base) + rand() * 1.5)}')

    for ((c=0; c<max_commits; c++)); do
        # Random hour/minute/second
        h=$(shuf -i 8-22 -n 1)
        m=$(shuf -i 0-59 -n 1)
        s=$(shuf -i 0-59 -n 1)
        commit_time="${current_day}T$(printf "%02d:%02d:%02d" $h $m $s)"

        export GIT_AUTHOR_DATE="$commit_time"
        export GIT_COMMITTER_DATE="$commit_time"

        message="${MESSAGES[$RANDOM % ${#MESSAGES[@]}]}"
        git commit --allow-empty -m "$message"
    done
done

# Push if remote is set
git push

