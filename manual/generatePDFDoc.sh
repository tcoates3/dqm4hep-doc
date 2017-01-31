#!/bin/sh

# Latex/pdf doc is generated with pandoc, see http://pandoc.org/MANUAL.html for more info
for file in install devguide deploy userguide
  do
    pandoc ${file}.md -f markdown -t latex --smart --toc --normalize --number-sections -o ${file}.pdf ${file}.yaml
done
