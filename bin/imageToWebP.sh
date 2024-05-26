#!/bin/bash
#################################################################
#              This Script Brought to you by                    #
#                        theBluWIz                              #
#                   Happy Transcoding!                          #
#################################################################

# Function to display usage information
show_usage() {
  cat <<EOF
Usage: ImageToWebP <source> <target> [quality] [compression]

Arguments:
  <source>           Path to source image or video file(s) or directory.
  <target>           Path to save the converted file(s).
  [quality]          Optional. Quality for the output image (0-100).
  [compression]      Optional. Compression level (0-6).

Examples:
  Basic Conversion:
    ImageToWebP input.jpg output.webp

  Custom Quality and Compression:
    ImageToWebP input.png output.webp 75 4

  Video Conversion:
    ImageToWebP input.mp4 output.webp 80 3
EOF
}

# Check if no arguments were passed or if the first argument is --help
if [ "$#" -eq 0 ] || [ "$1" == "--help" ]; then
  show_usage
  exit 0
fi

# Function to convert a single image file
convert_image() {
  local src_file=$1
  local tgt_file=$2
  local quality=$3
  local compression=$4

  echo "Converting $src_file to $tgt_file"

  ffmpeg -i "$src_file" -qscale:v "$quality" -compression_level "$compression" "$tgt_file"
}

# Function to convert a single video file
convert_video() {
  local src_file=$1
  local tgt_file=$2
  local quality=$3
  local compression=$4

  echo "Converting $src_file to $tgt_file with quality $quality and compression $compression"

  ffmpeg -i "$src_file" -vf "fps=10,scale=320:-1:flags=lanczos" -lossless 0 -qscale:v "$quality" -compression_level "$compression" -loop 0 -preset default "$tgt_file"
}

# Function to process a batch of image files
process_image_batch() {
  local file=$1
  local source_dir=$2
  local target_dir=$3
  local quality=$4
  local compression=$5

  local relative_path="${file#$source_dir/}"
  local target_file="$target_dir/${relative_path%.*}.webp"
  mkdir -p "$(dirname "$target_file")"
  convert_image "$file" "$target_file" "$quality" "$compression"
}

# Function to process a batch of video files
process_video_batch() {
  local file=$1
  local source_dir=$2
  local target_dir=$3
  local quality=$4
  local compression=$5

  local relative_path="${file#$source_dir/}"
  local target_file="$target_dir/${relative_path%.*}.webp"
  mkdir -p "$(dirname "$target_file")"
  convert_video "$file" "$target_file" "$quality" "$compression"
}

# Function to process files in a directory
process_files() {
  local source_dir=$1
  local target_dir=$2
  local quality=$3
  local compression=$4

  export -f convert_image
  export -f process_image_batch
  export -f convert_video
  export -f process_video_batch

  # Process image files
  find "$source_dir" -type f \( -iname \*.jpg -o -iname \*.jpeg -o -iname \*.png -o -iname \*.gif -o -iname \*.bmp -o -iname \*.tiff \) -print0 | xargs -0 -n 1 -P 4 -I {} bash -c 'process_image_batch "$@"' _ {} "$source_dir" "$target_dir" "$quality" "$compression"

  # Process video files
  find "$source_dir" -type f \( -iname \*.avi -o -iname \*.mp4 -o -iname \*.mov -o -iname \*.mkv -o -iname \*.flv -o -iname \*.wmv -o -iname \*.webm -o -iname \*.mpeg -o -iname \*.mpg -o -iname \*.3gp -o -iname \*.ogg -o -iname \*.ogv \) -print0 | xargs -0 -n 1 -P 4 -I {} bash -c 'process_video_batch "$@"' _ {} "$source_dir" "$target_dir" "$quality" "$compression"
}

# Function to determine if a file is a video
is_video_file() {
  local file=$1
  local result=$(ffprobe -v error -show_entries format=format_name -of default=noprint_wrappers=1:nokey=1 "$file")
  local video_formats="avi mp4 mov mkv flv wmv webm mpeg mpg 3gp ogg ogv"
  [[ $video_formats =~ (^|[[:space:]])$result($|[[:space:]]) ]]
}

# Check for minimum arguments
if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <Source File or Directory> <Target File or Directory> [Quality (0-100)] [Compression Level (0-6)]"
  exit 1
fi

# Assign arguments to variables
SOURCE=$1
TARGET=$2
QUALITY=${3:-75}  # Default to 75 if not specified
COMPRESSION=${4:-4}  # Default to 4 if not specified

# Debugging output
echo "Source: $SOURCE"
echo "Target: $TARGET"
echo "Quality: $QUALITY"
echo "Compression: $COMPRESSION"

# Check if source is a directory
if [ -d "$SOURCE" ]; then
  echo "Source is a directory. Processing all image and video files."
  # Create target directory
  mkdir -p "$TARGET"
  # Process files
  process_files "$SOURCE" "$TARGET" "$QUALITY" "$COMPRESSION"
else
  echo "Source is a single file. Processing the file."
  # If source is not a directory, check if it's a video file
  if is_video_file "$SOURCE"; then
    target_file="$TARGET.webp"
    convert_video "$SOURCE" "$target_file" "$QUALITY" "$COMPRESSION"
  else
    base_name=$(basename "$SOURCE")
    target_file="$TARGET.webp"
    convert_image "$SOURCE" "$target_file" "$QUALITY" "$COMPRESSION"
  fi
fi
