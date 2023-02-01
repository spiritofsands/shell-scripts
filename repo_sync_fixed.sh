#!/bin/bash

assert_repo_dir() {
    if [[ ! -d .repo ]]; then
        echo "Should be run in the repo root"
        exit 0
    fi
}

run_repo_sync() {
    repo sync -j1 --fail-fast 2>&1
    return "${PIPESTATUS[0]}"  # return repo error code
}

print() {
    echo
    echo "-----------------------"
    echo "$1"
    echo "-----------------------"
    echo
}

get_paths_to_remove() {
    local repo_sync_output
    repo_sync_output="$1"

    while IFS= read -r line; do
        local path
        path="$line"

        not_found_regex='.* in .* not found$'
        uncommited_regex='error: .*: contains uncommitted changes$'
        if [[ $line =~ $not_found_regex ]]; then
            path="${path##* in }"
            path="${path%% not found}"
            echo "$path"
        elif [[ $line =~ $uncommited_regex ]]; then
            path="${path##error: }"
            path="${path%%: contains uncommitted changes}"
            echo "$path"
        fi
    done < <(echo "$repo_sync_output" | grep "error: .* not found")
}

rm_dirs() {
    local paths
    paths="$1"

    while IFS= read -r path; do
        echo "Seems that $path should be removed"
        local full_paths
        full_paths="$(find .repo -wholename ".*$path.git")"

        while IFS= read -r full_path; do
            echo "Removing $full_path"
            rm -rf "$full_path"
        done <<< "$full_paths"
    done <<< "$paths"
}

has_local_changes() {
    local repo_sync_output
    repo_sync_output="$1"

    grep -q "Your local changes to the following files would be overwritten by checkout" <<< "$repo_sync_output"
}

reset_all_repos_to_master() {
    local confirm
    read -rp "Git reset all repos to master? (Y/N): " confirm
    if [[ "$confirm" == 'Y' || "$confirm" == 'y' ]]; then
        repo forall -vc "git reset --hard"
    else
        echo "Done"
        exit 0
    fi
}

main_loop() {
    repo_sync_status=1
    while [[ "$repo_sync_status" -ne 0 ]]; do
        print "Running repo sync"
        repo_sync_output="$(run_repo_sync)"
        repo_sync_status="$?"
        echo "$repo_sync_output"

        print "Removing failed repos, if any"
        paths_to_remove="$(get_paths_to_remove "$repo_sync_output")"
        if [[ -n "$paths_to_remove" ]]; then
            rm_dirs "$paths_to_remove"
            continue
        else
            echo "OK"
        fi

        print "Checking for local changes, if any"
        if [[ "$repo_sync_status" -ne 0 ]]; then
            if has_local_changes "$repo_sync_output"; then
                reset_all_repos_to_master
            fi
        else
            echo "OK"
        fi
    done
}

assert_repo_dir
main_loop
print "Success"
