#!/bin/bash
rauc status

df -ha | grep rw
df -ha | grep ro
df -ha | grep external
df -ha | grep internal