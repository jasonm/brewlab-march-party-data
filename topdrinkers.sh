#!/bin/sh
cat drinks.csv| sed 's/,.*//'|sort|uniq -c|sort -r|grep " \\d\{10\}\$" | tee drinkers.txt
grep "^  1" drinkers.txt | cut -c 6- | xargs -I% sh -c '{ echo ; grep \% drinkers.txt ; grep \% drinks.csv | cut -c 45- | sort; }'
