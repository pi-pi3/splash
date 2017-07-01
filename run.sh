#!/bin/sh
dir=$(echo $0 | sed 's/\/[^\/]*/\//')
mv $dir/init.lua $dir/main.lua
love $dir
mv $dir/main.lua $dir/init.lua
