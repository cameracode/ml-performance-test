#!/bin/bash

SITE="https://www.magicleap.com"
OUTFILE="report_apache_benchmark.html"

# File doesn't exist, create
touch $OUTFILE

echo "Magic Leap Website Performance Test utilizing Apache Benchmark"
echo "Performance Test on: $SITE"

# Run 1000 iterations of the Apache Benchmark against $SITE
ab -n 1000 -c 10 $SITE > $OUTFILE 