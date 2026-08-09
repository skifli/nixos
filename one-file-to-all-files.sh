awk '/^===== .* =====$/ {close(f); f=$2; next} f {print > f}' output.txt
