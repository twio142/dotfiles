#!/bin/sh

# symlink to /usr/local/bin/start-rime-ls

export DYLD_LIBRARY_PATH=/opt/homebrew/lib
exec /usr/local/bin/rime_ls --listen 127.0.0.1:9257
