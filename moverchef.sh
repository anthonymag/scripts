#!/bin/bash
IFS=$'\n\t'

SEASON_NUMBER="11"
PLAYLIST_PATH="/mnt/media/ytdlm/subscriptions/playlists/masterchef-br-${SEASON_NUMBER}/"
FILE_PATH="/home/ant/mcbr-${SEASON_NUMBER}-files"
MEDIA_PATH="/mnt/media/tvshows/MasterChef (BR) (2014) [tvdbid-285626]/Season ${SEASON_NUMBER}"
PROCESSED_FILE_PATH="${PLAYLIST_PATH}/processed"

episodes="$(ls ${PLAYLIST_PATH}*.mp4 | awk '{print $2}' | uniq)"

rm -rf "${FILE_PATH}"
mkdir -p "${FILE_PATH}" "${PROCESSED_FILE_PATH}"

for ep in $episodes; do
  parts="$(ls ${PLAYLIST_PATH}EPISÓDIO\ ${ep}*.mp4)"

#  echo "${ep} has these parts: ${parts}"

  for part in $parts; do
      echo "file '$part'" >> ${FILE_PATH}/episode_${ep}
  done


done

for episode_file in "$(ls ${FILE_PATH}/episode*)"; do
  # this is a bit of a bold assumption that nothing else in the path has an underscore!
  episode_number="$(echo $episode_file | cut -d'_' -f2)"

  ffmpeg -f concat -safe 0 -i "${episode_file}" -c copy "${MEDIA_PATH}/MasterChef (BR) (2014) - S${SEASON_NUMBER}E${episode_number}.mp4"

  [ -f "${MEDIA_PATH}/${episode_file}.mp4" ] && mv "${PLAYLIST_PATH}EPISÓDIO ${episode_number}*.mp4" "${PROCESSED_FILE_PATH}/"

  echo "*** DONE PROCESSING ${episode_file} ***"
done

