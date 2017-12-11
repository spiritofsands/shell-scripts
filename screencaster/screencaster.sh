#~/bin/bash

#
# Configuration
#

save_path="$HOME/screencasts"
fps=1


#
# Workflow
#

#
# Init googledrive
#
# Add anacron job that runs every day
#
#   which sets rtcwake to wake up computer at 2 AM
#
# Add cron job at 2:05 AM + RAND_MINUTES
#
#   which uploads screencasts to googledrive
#
# Add anacron job  |OR|  task 'on wake'
#
#   which starts recording
#
# Add cron job at 8 pm  |OR|  task 'on suspend'
#
#   which stops recording
#


#
# Recording
#

ffmpeg_lockfile="$save_path/.ffmpeg.lock"
screencaster_lockfile="$save_path/.screencaster.lock"
heartbeat_interval='5s'
max_failures_count=5
ffmpeg_exec=''
skicka_exec=''
rtcwake_exec=''

on_exit() {
  echo 'Exiting'
  trap - SIGINT SIGTERM
  cleanup
  # Send SIGTERM to child/sub processes
  kill -- -$$
}

find_executable() {
  if command -v "$1" &> /dev/null; then
    echo "$1"
  else
    if [[ -x "$PWD/$1" ]]; then
      echo "$PWD/$1"
    else
      echo -n ''
    fi
  fi
}

sanity_check() {
  # Check options
  if [[ ! ( -d "$save_path" && -x "$save_path" ) ]]; then
    echo "Can't access $save_path"
    exit 1
  fi

  if [[ "$fps" -lt 0 ]]; then
    echo "Framerate should be > 0"
    exit 1
  fi

  skicka_exec="$(find_executable 'skicka')"
  if [[ -z "$skicka_exec" ]]; then
    echo "No skicka executable. Install it systemwide or place to a current dir"
  fi

  ffmpeg_exec="$(find_executable 'ffmpeg')"
  if [[ -z "$ffmpeg_exec" ]]; then
    echo "No ffmpeg executable. Install it systemwide or place to a current dir"
  fi

  rtcwake_exec="$(find_executable 'rtcwake')"
  if [[ -z "$rtcwake_exec" ]]; then
    echo "No rtcwake executable. Install it systemwide or place to a current dir"
  fi

  if ! googledrive_is_initialized; then
    init_googledrive
  fi
}

get_resolution() {
  local str
  str="$(xdpyinfo | grep dimensions)"
  str="${str##*\    }"
  echo "${str%% *}"
}

get_screencast_filename() {
  echo "$(whoami)_screencast_$(date +"%m_%d_%Y_%H_%M_%S").mp4"
}

start_recording() {
  local screen_resolution
  local ffmpeg_cmd
  local ffmpeg_pid

  cleanup

  echo $$ > "$screencaster_lockfile"

  screen_resolution="$(get_resolution)"
  ffmpeg_cmd="$ffmpeg_exec  -loglevel quiet -f x11grab -framerate $fps -video_size $screen_resolution -i $DISPLAY -vcodec libx264 -preset ultrafast $save_path/$(get_screencast_filename)"

  $ffmpeg_cmd &
  ffmpeg_pid=$!

  echo "$ffmpeg_pid" > "$ffmpeg_lockfile"
}

stop_recording() {
  local stopped_something
  local screencaster_pid
  local ffmpeg_pid

  stopped_something=0

  if [[ -f "$screencaster_lockfile" ]]; then
    screencaster_pid="$(cat "$screencaster_lockfile")"
    kill "$screencaster_pid"
    stopped_something=1
  fi

  if [[ -f "$ffmpeg_lockfile" ]]; then
    ffmpeg_pid="$(cat "$ffmpeg_lockfile")"
    kill -2 "$ffmpeg_pid"
    stopped_something=1
  fi

  cleanup
  if [[ $stopped_something -eq 1 ]]; then
    echo 'Stopped recording'
  else
    echo 'Nothing to stop'
  fi
}

cleanup() {
  if [[ -f "$ffmpeg_lockfile" ]]; then
    rm "$ffmpeg_lockfile"
  fi

  if [[ -f "$screencaster_lockfile" ]]; then
    rm "$screencaster_lockfile"
  fi
}

is_recording() {
  local ffmpeg_pid

  if [[ ! -f "$ffmpeg_lockfile" ]]; then
    return 1
  else
    ffmpeg_pid="$(cat "$ffmpeg_lockfile")"

    if ! ps -p "$ffmpeg_pid" > /dev/null; then
      return 1
    else
      return 0
    fi
  fi
}

heartbeat() {
  local failures_count=0
  while true; do
    if ! is_recording; then
      echo 'Not recordig, starting'
      ((failures_count++))
      if [[ $failures_count -ge $max_failures_count ]]; then
        echo "Failed to start recording $failures_count  times. Exiting"
        exit 1
      fi

      start_recording
    fi
    sleep "$heartbeat_interval"
  done
}

#
# Synchronization
#

googledrive_dirname=''

googledrive_is_initialized() {
  if [[ -f ~/.skicka.config &&-f ~/.skicka.tokencache.json ]]; then
    return 0
  else
    return 1
  fi
}

init_googledrive() {
  echo 'Initializing googledrive'
  $skicka_exec init -quiet
  echo 'Allow access to googledrive at your browser now'
  $skicka_exec ls &> /dev/null

  if googledrive_is_initialized; then
    echo 'Initialized'
  else
    echo 'Failed to initialize'
  fi
}

get_googledrive_dirname() {
  googledrive_dirname="$($skicka_exec ls | grep -E ' .*/' | head -n1)"
}

upload_to_googledrive() {
  get_googledrive_dirname
  if [[ -z "$googledrive_dirname" ]]; then
    echo 'Failed to connect to googledrive'
    return 1
  fi

  echo "Uploading to $googledrive_dirname/screencasts"
  $skicka_exec upload "$save_path" "$googledrive_dirname/screencasts"
}


#
# Scheduling
#

schedule_wakeup() {
  local day_of_a_week
  day_of_a_week="$(date '+%u')"

  # mon - thu
  if [[ $day_of_a_week -lt 5 ]]; then
    local days_to_monday=1
  else
    local days_to_monday=$((7 - day_of_a_week + 1))
  fi

  $rtcwake_exec -m no --date "$(date '+%F' -d "+$days_to_monday days") 02:00"
}

disable_schedules() {
  $rtcwake_exec -m disable
}

#
# Main
#

trap on_exit SIGINT SIGTERM

sanity_check

case $1 in
  start)
    heartbeat
    ;;
  stop)
    stop_recording
    ;;
  upload)
    upload_to_googledrive
    ;;
  *)
    echo 'Allowed options are: start | stop | upload'
    ;;
esac
