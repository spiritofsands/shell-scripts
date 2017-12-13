#!/bin/bash

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
# Add cron job at 2:05 AM + RAND_MINUTES
#
#   which sets rtcwake to wake up computer at 2 AM
#   which uploads screencasts to googledrive
#


#
# =============================================================================
#


#
# Global variables init
#

find_executable() {
  if command -v "$1" &> /dev/null; then
    echo "$1"
  else
    if [[ -x "$script_dir/distrib/$1" ]]; then
      echo "$script_dir/distrib/$1"
    else
      echo -n ''
    fi
  fi
}

init_variables() {
  ffmpeg_lockfile="$save_path/.ffmpeg.lock"
  screencaster_lockfile="$save_path/.screencaster.lock"
  yad_lockfile="$save_path/.yad.lock"
  upload_status_file="$save_path/.upload_status"
  cron_job_path='/etc/cron.d/screencaster-upload'
  script_path="$(readlink -f "$0")"
  script_dir="$(dirname "$script_path")"
  heartbeat_interval='5s'
  max_failures_count=5
  ffmpeg_exec=''
  skicka_exec=''
  rtcwake_exec=''
  yad_exec=''
  skicka_exec="$(find_executable 'skicka')"
  ffmpeg_exec="$(find_executable 'ffmpeg')"
  rtcwake_exec="$(find_executable 'rtcwake')"
  yad_exec="$(find_executable 'yad')"
}

init_variables

#
# Recording
#

on_exit() {
  echo "Finalizing screencast ($$)"
  trap - SIGINT SIGTERM
  stop_recording_and_finalize
}

sanity_check() {
  local failed=0

  # Check options
  if [[ ! ( -d "$save_path" && -x "$save_path" ) ]]; then
    echo "Can't access $save_path"
    failed=1
  fi

  if [[ "$fps" -lt 0 ]]; then
    echo "Framerate should be > 0"
    failed=1

  fi

  # Check executables
  if [[ -z "$skicka_exec" ]]; then
    echo "No skicka executable. Place it to $PWD/distrib or install systemwide."
    failed=1
  fi

  if [[ -z "$ffmpeg_exec" ]]; then
    echo "No ffmpeg executable. Place it to $PWD/distrib or install systemwide:"
    echo 'sudo apt install ffmpeg'
    failed=1
  fi

  if [[ -z "$rtcwake_exec" ]]; then
    echo "No rtcwake executable. Place it to $PWD/distrib or install systemwide:"
    echo 'sudo apt install util-linux'
    failed=1
  fi

  if [[ -z "$yad_exec" ]]; then
    echo "No yad executable. Place it to $PWD/distrib or install systemwide:"
    echo 'sudo apt install yad'
    failed=1
  fi

  if [[ "$failed" -eq 1 ]]; then
    echo 'Exiting...'
  fi

  # Check if not running
  if any_component_is_running; then
    echo "Screencaster is already running"
    exit 1
  fi

  # Check googledrive
  if ! googledrive_is_initialized; then
    init_googledrive
  fi
}

any_component_is_running() {
  if [[ -f "$screencaster_lockfile" ]]; then
    if pid_exists "$(cat "$screencaster_lockfile")"; then
      return 0
    else
      echo "Removing corrupted lockfile: $screencaster_lockfile"
      rm "$screencaster_lockfile"
    fi
  fi

  if [[ -f "$ffmpeg_lockfile" ]]; then
    if pid_exists "$(cat "$ffmpeg_lockfile")"; then
      return 0
    else
      echo "Removing corrupted lockfile: $ffmpeg_lockfile"
      rm "$ffmpeg_lockfile"
    fi
  fi

  if [[ -f "$yad_lockfile" ]]; then
    if pid_exists "$(cat "$yad_lockfile")"; then
      return 0
    else
      echo "Removing corrupted lockfile: $yad_lockfile"
      rm "$yad_lockfile"
    fi
  fi

  return 1
}

get_screen_resolution() {
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

  echo $$ > "$screencaster_lockfile"

  screen_resolution="$(get_screen_resolution)"
  ffmpeg_cmd="$ffmpeg_exec -loglevel quiet -f x11grab -framerate $fps -video_size $screen_resolution -i $DISPLAY -vcodec libx264 -preset ultrafast $save_path/$(get_screencast_filename)"

  $ffmpeg_cmd &
  ffmpeg_pid=$!

  echo "$ffmpeg_pid" > "$ffmpeg_lockfile"
}

stop_recording_and_finalize() {
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

  if [[ -f "$ffmpeg_lockfile" ]]; then
    rm "$ffmpeg_lockfile"
  fi

  if kill_yad; then
    stopped_something=1
  fi

  if [[ $stopped_something -eq 1 ]]; then
    echo 'Stopping recording'
  else
    echo 'Nothing to stop'
  fi

  rm_all_lockfiles
}

rm_all_lockfiles() {
  echo 'Removing lockfiles'
  if [[ -f "$ffmpeg_lockfile" ]]; then
    rm "$ffmpeg_lockfile"
  fi

  if [[ -f "$screencaster_lockfile" ]]; then
    rm "$screencaster_lockfile"
  fi

  if [[ -f "$yad_lockfile" ]]; then
    rm "$yad_lockfile"
  fi
}

pid_exists() {
  ps -p "$1" > /dev/null
}

is_recording() {
  local ffmpeg_pid

  if [[ ! -f "$ffmpeg_lockfile" ]]; then
    return 1
  else
    ffmpeg_pid="$(cat "$ffmpeg_lockfile")"

    if ! pid_exists "$ffmpeg_pid"; then
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
      echo 'Starting recording'

      ((failures_count++))
      if [[ $failures_count -ge $max_failures_count ]]; then
        echo "Failed to start recording $failures_count  times. Exiting"
        exit 1
      fi

      place_recording_icon
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
  [[ -f ~/.skicka.config && -f ~/.skicka.tokencache.json ]]
}

init_googledrive() {
  echo 'Initializing googledrive'
  "$skicka_exec" init -quiet
  echo 'Allow access to googledrive at your browser now'
  "$skicka_exec" ls &> /dev/null

  if googledrive_is_initialized; then
    echo 'Initialized'
  else
    echo 'Failed to initialize'
  fi
}

get_googledrive_dirname() {
  googledrive_dirname="$("$skicka_exec" ls | grep -E ' .*/' | head -n1)"
}

upload_to_googledrive() {
  get_googledrive_dirname
  if [[ -z "$googledrive_dirname" ]]; then
    echo 'Failed to connect to googledrive'
    return 1
  fi

  echo "Uploading to $googledrive_dirname$(basename "$save_path")"
  echo
  if "$skicka_exec" upload "$save_path" "$googledrive_dirname$(basename "$save_path")"; then
    echo "Last upload was at: $(date +"%m.%d.%Y %H:%M:%S")"
  else
    echo "Last upload failed"
  fi > "$upload_status_file"
}



#
# Interface
#

recording_icon='/usr/share/icons/Humanity/actions/24/media-record.svg'

kill_yad() {
  local yad_pid
  if [[ ! -f "$yad_lockfile" ]]; then
    return 1
  fi

  yad_pid="$(cat "$yad_lockfile")"

  if pid_exists "$yad_pid"; then
    echo "Switching notification"
    kill "$yad_pid"
    return 0
  else
    return 1
    echo "Not switching notification"
  fi
}

place_recording_icon() {
  local yad_pid

  kill_yad
  "$yad_exec" --notification --image="$recording_icon" --text "Recording" --no-middle --command='' --menu="Stop and quit!$0 stop" &>/dev/null &
  yad_pid=$!

  echo $yad_pid > "$yad_lockfile"
}



#
# Scheduling
#

check_permissions() {
  [[ "$(whoami)" == 'root' ]]
}

is_wakeup_scheduled() {
  # Is not turned off
  ! "$rtcwake_exec" -m show | grep -q 'alarm: off'
}

schedule_wakeup() {
  local day_of_a_week
  day_of_a_week="$(date '+%u')"

  # mon - thu
  if [[ $day_of_a_week -lt 5 ]]; then
    local days_to_monday=1
  else
    local days_to_monday=$((7 - day_of_a_week + 1))
  fi

  "$rtcwake_exec" -m no --date "$(date '+%F' -d "+$days_to_monday days") 02:00"
}

disable_wakeup() {
  if ! check_permissions; then
    echo 'Can not disable wakeup: no permissions'
    return 1
  fi

  "$rtcwake_exec" -m disable &>/dev/null
}

is_cron_task_added() {

  [[ -f "$cron_job_path" ]]
}

add_cron_task() {
  echo 'Adding a cron task'

  rand_minute="$((RANDOM % 60 + 1))"
  cat << EOF > "$cron_job_path"
SHELL=/bin/bash
PATH=$PATH
$rand_minute 2 * * 1-5 if [ -x "/etc/cron.daily/$script_path" ]; then /etc/cron.daily/$script_path") start >/dev/null; fi
EOF

}

uninstall() {
  if ! check_permissions; then
    echo 'Can not uninstall: no permissions'
    return 1
  fi

  echo 'Uninstalling...'

  local files_to_delete=(
    $cron_job_path
  )

  for f in "${files_to_delete[@]}"; do
    rm "$f" &> /dev/null
  done

  echo 'Disabling wakeup'
  disable_wakeup

  echo 'Stopping all services'
  stop_recording_and_finalize

  echo 'Done'
}

schedule_upload() {
  if ! check_permissions; then
    echo 'Can not schedule upload: no permissions'
    return 1
  fi

  if ! is_cron_task_added; then
    add_cron_task
  fi

  if ! is_wakeup_scheduled; then
    schedule_wakeup
  fi

  su "$(logname)" -s /bin/bash -c "$script_path upload"
}

status() {
  if ! check_permissions; then
    echo 'Run as superuser to see scheduled jobs status'
  else
    if is_cron_task_added; then
      echo "Cron task was added"
    fi
    if is_wakeup_scheduled; then
      echo "Wakeup was scheduled"
    fi
  fi

  if [[ -f "$upload_status_file" ]]; then
    cat "$upload_status_file"
  fi

  if is_recording; then
    echo "Recording"
  else
    echo "Not recording"
  fi
}

#
# Main
#

case $1 in
  schedule-upload)
    schedule_upload
    ;;
  start)
    sanity_check
    trap on_exit SIGINT SIGTERM
    heartbeat
    ;;
  stop)
    stop_recording_and_finalize
    ;;
  upload)
    sanity_check
    upload_to_googledrive
    ;;
  status)
    status
    ;;
  uninstall)
    uninstall
    ;;
  *)
    echo 'Allowed options are: schedule-upload | start | stop | upload | status | uninstall'
    ;;
esac
