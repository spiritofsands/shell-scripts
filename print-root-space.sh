#!/bin/bash

string="$(df -h | grep '/dev/dm-0')"

string="$(echo "$string" | awk '{print $5}')"

string="${string%%%}"

echo "$string"
