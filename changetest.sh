#!/usr/bin/env bash

FILE="/opt/test/test.txt"

sed -i '/^changevalue=/ s/=.*/=0/' "$FILE"
