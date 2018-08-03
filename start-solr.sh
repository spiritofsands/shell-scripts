#!/bin/bash

cd ~/work/main-website/sources/
/home/kos/.rbenv/shims/rails sunspot:solr:start
cd - > /dev/null
