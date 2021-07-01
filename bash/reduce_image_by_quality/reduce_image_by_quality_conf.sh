#!/bin/bash

INPUT_DIR=/c/dev/ws/tmp/in
OUTPUT_DIR=/c/dev/ws/tmp/out
FILELIST_FILE_PATH=/c/dev/ws/tmp/reduce_image_by_quality_targets.txt
MAX_SIZE_KB=300
MAX_SIZE_BYTE=$(( MAX_SIZE_KB * 1024 ))
