#!/bin/bash

# Path to audiobookshelf database
DB_PATH="/home/tychomat/audiobookshelf/config/absdatabase.sqlite"
BASE_DIR="/mnt/data1"  # The base directory to prepend to the path

# Run SQLite query to get all finished episodes
sqlite3 "$DB_PATH" "SELECT podcastEpisodes.id, mediaProgresses.mediaItemId, mediaProgresses.isFinished, podcastEpisodes.audiofile FROM podcastEpisodes, mediaProgresses WHERE podcastEpisodes.id=mediaProgresses.mediaItemId AND mediaProgresses.isFinished = 1;" | while read -r query_result; do
    # Extract the "path" field from the JSON-like audiofile field
    path=$(echo "$query_result" | grep -o '"path":"[^"]*"' | sed 's/"path":"\([^"]*\)"/\1/')

    # Check if the path was extracted
    if [[ -n "$path" ]]; then
        # Prepend the base directory to the extracted path
        full_path="$BASE_DIR$path"

        # Fix the case for the 'Podcasts' directory (lowercase to uppercase)
        full_path=$(echo "$full_path" | sed 's|/podcasts|/Podcasts|')

        # Check if the file exists and delete it (or print for dry run)
        if [[ -f "$full_path" ]]; then
            #echo "Deleting $full_path..."
            trash "$full_path"
        else
            echo "File not found: $full_path"
        fi
    else
        echo "No valid path found for item: $id"
    fi

done
