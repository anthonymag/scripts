#!/bin/bash
IFS=$'\n\t'

SEASON_NUMBER="11"
#SEASON_NUMBER="99" # for testing
#PLAYLIST_PATH="/mnt/media/ytdlm/subscriptions/playlists/masterchef-br-${SEASON_NUMBER}/"
PLAYLIST_PATH="/mnt/media/ytdlm/users/anthony/subscriptions/playlists/masterchef-br-${SEASON_NUMBER}/"
FILE_PATH="/home/ant/mcbr-${SEASON_NUMBER}-files"
MEDIA_PATH="/mnt/media/tvshows/MasterChef (BR) (2014) [tvdbid-285626]/Season ${SEASON_NUMBER}"
PROCESSED_FILE_PATH="${PLAYLIST_PATH}processed"

notify_discord() {
  [ -n ${DISCORD_WEBHOOK} ] && curl -i -H "Accept: application/json" -H "Content-Type:application/json" -X POST --data "{\"content\": \"$1\"}" ${DISCORD_WEBHOOK}
}

if ls "$PLAYLIST_PATH"/*.mp4 1> /dev/null 2>&1; then
    echo "Found files to process"
    notify_discord "Found MasterChef files to process"
else
    echo "Nothing to do"
    notify_discord "No MasterChef files found to process"
    exit 0
fi

episodes="$(ls ${PLAYLIST_PATH}*.mp4 | awk '{print $2}' | uniq)"

rm -rf "${FILE_PATH}"
mkdir -p "${FILE_PATH}" "${PROCESSED_FILE_PATH}"
mkdir -p "${MEDIA_PATH}"

for ep in $episodes; do
  parts="$(ls ${PLAYLIST_PATH}EPISÓDIO\ ${ep}*.mp4)"

#  echo "${ep} has these parts: ${parts}"

  for part in $parts; do
      echo "file '$part'" >> ${FILE_PATH}/episode_${ep}
  done


done

unset IFS

for episode_file in ${FILE_PATH}/episode*; do
  base_file="$(basename $episode_file)"
  echo "*** Processing ${base_file} ***"

  episode_number="$(echo $base_file | cut -d'_' -f2)"
  concat_episode_file_name="${MEDIA_PATH}/MasterChef (BR) (2014) - S${SEASON_NUMBER}E${episode_number} - TBA [HDTV-1080p][Opus 2.0][VP9].mp4"

  ffmpeg -f concat -safe 0 -i "${episode_file}" -c copy "${concat_episode_file_name}"
  notify_discord "Processed ${base_file} as ${concat_episode_file_name}"

  if [ -f "${concat_episode_file_name}" ]; then
    echo "Moving ${base_file} parts to processed directory"
    mv ${PLAYLIST_PATH}EPISÓDIO\ ${episode_number}*.mp4 ${PROCESSED_FILE_PATH}/
  fi

  echo "*** DONE PROCESSING ${base_file} ***"
done

notify_discord "MoverChef job finished"

