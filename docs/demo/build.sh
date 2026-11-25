#!/bin/sh
# Re-records docs/demo/demo.gif. Needs Docker and ffmpeg.
#   1. builds an image with this config, Python tooling (pyright, pytest, debugpy) and VHS
#   2. records the sample session in demo.tape to demo.mp4 inside the container
#   3. turns the video into a GIF here (the container is too small to encode it)
set -e
cd "$(dirname "$0")/../.."
docker build -f docs/demo/Dockerfile -t nvim-explorer-vhs .
docker run --rm -v "$PWD/docs/demo:/vhs" nvim-explorer-vhs demo.tape
cd docs/demo
ffmpeg -v error -y -i demo.mp4 -vf "fps=10,scale=960:-1:flags=lanczos,split[a][b];[a]palettegen=max_colors=96:stats_mode=diff[p];[b][p]paletteuse=dither=bayer:bayer_scale=4:diff_mode=rectangle" demo.gif
rm demo.mp4
ls -lh demo.gif
