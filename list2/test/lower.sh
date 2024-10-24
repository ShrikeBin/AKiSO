#!/bin/bash

for file in *; do
	if [ -f "$file" ]; then
		lower_file=$(echo "$file" | tr '[:upper:]' '[:lower:]')
		
		if [ "$file" != "$lower_file" ]; then			
			mv "$file" "$lower_file"
		fi
	fi
done
