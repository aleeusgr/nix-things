#!/bin/sh

#!/usr/bin/env bash
# create_dj_usb.sh
# Create a USB-ready directory with MP3 audio from the current directory.
#
# Usage:
#   TARGET=/media/usb ./create_dj_usb.sh            # use env var TARGET
#   ./create_dj_usb.sh /media/usb                   # or pass target as arg
#   ./create_dj_usb.sh --convert --recursive /media/usb
#
# Requirements:
#   - coreutils (mkdir, cp, find, df, awk, du)
#   - (optional) ffmpeg if you use --convert to transcode non-mp3 files

set -euo pipefail

print_usage() {
  cat <<EOF
Usage: $0 [options] [TARGET]
Copy MP3 files from the current directory into TARGET/<current-dir-name>.

Options:
  -h, --help         Show this message
  -c, --convert      Convert non-MP3 audio files to MP3 (requires ffmpeg)
  -r, --recursive    Search for audio files recursively (default: non-recursive)
      --preserve     Preserve directory structure relative to current dir (default: flatten)
  -n, --dry-run      Show what would be done without copying/converting
  -f, --force        Overwrite files at destination without prompting
  -v, --verbose      Verbose output

TARGET may also be specified via environment variables TARGET, DEST or LOCATION.
If no target is given or found, the script exits.

Examples:
  TARGET=/media/usb ./create_dj_usb.sh --recursive --convert
  ./create_dj_usb.sh /mnt/usb --preserve
EOF
}

# Defaults
CONVERT=false
RECURSIVE=false
PRESERVE=false
DRYRUN=false
FORCE=false
VERBOSE=false

# Parse opts
ARGS=()
while (( "$#" )); do
  case "$1" in
    -h|--help) print_usage; exit 0;;
    -c|--convert) CONVERT=true; shift;;
    -r|--recursive) RECURSIVE=true; shift;;
    --preserve) PRESERVE=true; shift;;
    -n|--dry-run) DRYRUN=true; shift;;
    -f|--force) FORCE=true; shift;;
    -v|--verbose) VERBOSE=true; shift;;
    --) shift; while (( "$#" )); do ARGS+=("$1"); shift; done;;
    -*) echo "Unknown option: $1" >&2; print_usage; exit 2;;
    *) ARGS+=("$1"); shift;;
  esac
done

# Determine target
if [ "${#ARGS[@]}" -ge 1 ]; then
  TARGET_DIR_ARG="${ARGS[0]}"
else
  TARGET_DIR_ARG="${TARGET:-${DEST:-${LOCATION:-}}}"
fi

if [ -z "$TARGET_DIR_ARG" ]; then
  echo "Error: target location not provided. Set TARGET/DEST/LOCATION env or pass as argument." >&2
  print_usage
  exit 2
fi

# Normalize target path
TARGET_DIR_ARG="${TARGET_DIR_ARG%/}"   # remove trailing slash if any

if [ ! -d "$TARGET_DIR_ARG" ]; then
  echo "Error: target path '$TARGET_DIR_ARG' does not exist or is not a directory." >&2
  exit 3
fi

SRC_DIR="$(pwd)"
SRC_BASENAME="$(basename "$SRC_DIR")"
DEST_ROOT="$TARGET_DIR_ARG/$SRC_BASENAME"

# Build find pattern
# Recognize common audio formats for optional conversion
MP3_PATTERN="-iname '*.mp3'"
OTHER_AUDIO="-iname '*.wav' -o -iname '*.flac' -o -iname '*.m4a' -o -iname '*.aac' -o -iname '*.ogg' -o -iname '*.wma'"

if [ "$RECURSIVE" = true ]; then
  FIND_PRUNE=""
else
  # non-recursive: limit find depth to 1
  FIND_PRUNE="-maxdepth 1"
fi

# List files to process
if [ "$CONVERT" = true ]; then
  # include mp3 and other audio formats
  FIND_EXPR="\( $MP3_PATTERN -o $OTHER_AUDIO \)"
else
  # only mp3
  FIND_EXPR="\( $MP3_PATTERN \)"
fi

# Build array of files (preserving whitespace)
mapfile -t FILES < <(eval "find . $FIND_PRUNE -type f $FIND_EXPR -print0 | xargs -0 -n1 printf '%s\n' | sed 's|^\./||'")

if [ "${#FILES[@]}" -eq 0 ]; then
  echo "No files found to copy." >&2
  exit 0
fi

# Estimate total size
TOTAL_BYTES=0
for f in "${FILES[@]}"; do
  if [ -e "$f" ]; then
    # du -b may not be portable on all systems; fall back to stat or wc
    if stat --version >/dev/null 2>&1; then
      size=$(stat -c%s "$f")
    else
      size=$(wc -c <"$f")
    fi
    TOTAL_BYTES=$((TOTAL_BYTES + size))
  fi
done

# Get free space on target filesystem (portable)
# Use `df -k` and parse the Available column (in 1K blocks). Works with GNU, BusyBox, macOS.
avail_kb=$(df -k "$TARGET_DIR_ARG" 2>/dev/null | awk 'NR>1 {print $4; exit}')
if [ -z "$avail_kb" ]; then
  echo "Warning: could not determine free space on target filesystem; continuing without space check." >&2
  avail_bytes=0
else
  avail_bytes=$((avail_kb * 1024))
fi

if [ "$VERBOSE" = true ]; then
  echo "Files to process: ${#FILES[@]}"
  echo "Total size: $TOTAL_BYTES bytes"
  if [ "$avail_bytes" -gt 0 ]; then
    echo "Available on target: $avail_bytes bytes"
  else
    echo "Available on target: unknown"
  fi
fi

if [ "$avail_bytes" -gt 0 ] && [ "$avail_bytes" -lt "$TOTAL_BYTES" ]; then
  echo "Warning: free space on target ($avail_bytes bytes) is less than total files size ($TOTAL_BYTES bytes)." >&2
  echo "Proceeding may fail due to lack of space."
fi

# Prepare destination
if [ "$DRYRUN" = false ]; then
  mkdir -p "$DEST_ROOT"
fi

# Copy/convert files
echo "Starting ${DRYRUN:+(dry-run) }operation: copying to '$DEST_ROOT' ..."
for src in "${FILES[@]}"; do
  # destination path
  if [ "$PRESERVE" = true ]; then
    dest_path="$DEST_ROOT/$(dirname "$src")"
    dest_name="$(basename "$src")"
  else
    dest_path="$DEST_ROOT"
    # flattening: use basename only; if duplicate names exist, add numeric suffix
    base="$(basename "$src")"
    dest_name="$base"
    if [ -e "$dest_path/$dest_name" ] && [ "$FORCE" = false ] && [ "$DRYRUN" = false ]; then
      # create unique name
      i=1
      ext="${base##*.}"
      name_noext="${base%.*}"
      while [ -e "$dest_path/${name_noext}_$i.$ext" ]; do
        i=$((i+1))
      done
      dest_name="${name_noext}_$i.$ext"
    fi
  fi

  mkdir -p "$dest_path"

  src_lower="$(printf '%s' "$src" | awk '{print tolower($0)}')"
  is_mp3=false
  case "$src_lower" in
    *.mp3) is_mp3=true;;
    *) is_mp3=false;;
  esac

  dest_file="$dest_path/${dest_name%.*}.mp3"  # if converting, ensure .mp3 extension

  if [ "$is_mp3" = true ] && [ "$CONVERT" != true ]; then
    # plain copy the mp3
    dest_file="$dest_path/$dest_name"
    if [ "$DRYRUN" = true ]; then
      echo "[COPY] '$src' -> '$dest_file'"
    else
      if [ -e "$dest_file" ] && [ "$FORCE" = false ]; then
        echo "Skipping existing file '$dest_file' (use --force to overwrite)" >&2
        continue
      fi
      if [ "$VERBOSE" = true ]; then echo "[COPY] '$src' -> '$dest_file'"; fi
      cp -p -- "$src" "$dest_file"
    fi
  else
    # conversion path (either convert explicitly requested, or converting a non-mp3)
    if [ "$CONVERT" != true ]; then
      # shouldn't happen, but guard
      echo "Skipping non-mp3 file '$src' (conversion not enabled)."
      continue
    fi

    if ! command -v ffmpeg >/dev/null 2>&1; then
      echo "Error: ffmpeg required for conversion but not found in PATH." >&2
      exit 4
    fi

    # Build conversion command
    if [ "$DRYRUN" = true ]; then
      echo "[CONVERT] '$src' -> '$dest_file' (ffmpeg)"
    else
      if [ -e "$dest_file" ] && [ "$FORCE" = false ]; then
        echo "Skipping existing file '$dest_file' (use --force to overwrite)" >&2
        continue
      fi
      if [ "$VERBOSE" = true ]; then echo "[CONVERT] '$src' -> '$dest_file'"; fi
      # Use ffmpeg with sane defaults for DJ usage: 44.1kHz, 2 channels, 192k bitrate
      ffmpeg -hide_banner -loglevel error -y -i "$src" -vn -ar 44100 -ac 2 -b:a 192k "$dest_file"
    fi
  fi
done

echo "Done. Files placed in: $DEST_ROOT"
if [ "$DRYRUN" = true ]; then
  echo "(dry-run: no files were actually copied or converted)"
fi
