#!/bin/bash

if (( "$1" % 3 == 0 )); then
  echo ' #[bg=colour236] |#[bg=default]'
else
  echo ' '
fi
