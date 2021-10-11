#!/bin/bash
watch "ps --sort -rss -eo pid,pmem,rss,vsz,comm | head -16 && df -ha | grep -E 't[[:alpha:]]{2}fs'"