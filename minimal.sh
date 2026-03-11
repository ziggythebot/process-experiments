#!/bin/bash
# Pure ASCII animation - no ffmpeg, no dependencies
# Just bash, printf, and sleep

clear
for i in {1..45}; do
  clear
  echo ""
  echo ""
  echo "  BUILD"
  [ $((i % 4)) -eq 0 ] && echo "  →" || echo "   "
  [ $((i % 4)) -eq 1 ] && echo "  DEPLOY" || echo ""
  [ $((i % 4)) -eq 1 ] && echo "  →" || echo "   "
  [ $((i % 4)) -eq 2 ] && echo "  ITERATE" || echo ""
  [ $((i % 4)) -eq 2 ] && echo "  →" || echo "   "
  [ $((i % 4)) -eq 3 ] && echo "  FOREVER" || echo ""
  echo ""
  echo "  $i/45"
  sleep 1
done
