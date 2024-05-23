#!/bin/bash

# Check if a directory is given as an argument, else use the current directory
DIR=${1:-.}

# Get the total, used, and available space of the mount point in kilobytes
MOUNT_POINT_INFO=$(df -k "$DIR" | tail -n 1)

TOTAL_SPACE=$(echo "$MOUNT_POINT_INFO" | awk '{print $2}')  # in KB
USED_SPACE=$(echo "$MOUNT_POINT_INFO" | awk '{print $3}')   # in KB
AVAILABLE_SPACE=$(echo "$MOUNT_POINT_INFO" | awk '{print $4}')  # in KB

# Function to calculate percentage
function calc_percentage {
  echo "scale=2; $1 * 100 / $TOTAL_SPACE" | bc
}

# Get the size of the specified directory in kilobytes
DIR_SIZE=$(du -sk "$DIR" | cut -f1)

# Calculate percentages
DIR_PERCENTAGE=$(calc_percentage $DIR_SIZE)
USED_PERCENTAGE=$(calc_percentage $USED_SPACE)
AVAILABLE_PERCENTAGE=$(calc_percentage $AVAILABLE_SPACE)

# Print the information, converting KB to Bytes for numfmt
echo "Total Disk Space: $(numfmt --to=iec-i --suffix=B $(($TOTAL_SPACE * 1024))) 100%"
echo "Used Space on Mount: $(numfmt --to=iec-i --suffix=B $(($USED_SPACE * 1024))) ($USED_PERCENTAGE %)"
echo "Available Space on Mount: $(numfmt --to=iec-i --suffix=B $(($AVAILABLE_SPACE * 1024))) ($AVAILABLE_PERCENTAGE %)"
echo "Size of '$DIR': $(numfmt --to=iec-i --suffix=B $(($DIR_SIZE * 1024))) ($DIR_PERCENTAGE %)"

# Optionally, list the subdirectories with their sizes and percentages, including hidden ones
echo "Subdirectories of '$DIR':"
(du -sk "$DIR"/* "$DIR"/.[!.]* | sort -nr) 2>/dev/null | while read SIZE FOLDER
do
  SIZE_BYTES=$(($SIZE * 1024))  # Convert KB to Bytes
  PERCENTAGE=$(calc_percentage $SIZE)
  echo "$(numfmt --to=iec-i --suffix=B $SIZE_BYTES) ($PERCENTAGE %) - $(basename "$FOLDER")"
done
