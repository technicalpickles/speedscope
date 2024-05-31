#!/bin/bash

set -x

helpString="Usage: speedscope [filepath]

If invoked with no arguments, will open a local copy of speedscope in your default browser.
Once open, you can browse for a profile to import.

If - is used as the filepath, will read from stdin instead.

cat /path/to/profile | speedscope - 
"

function getProfileBuffer() {
    if [ "$1" == "-" ]; then
        cat -
    else
        cat $1
    fi
}

urlToOpen="file://$(realpath "$(dirname $0)/../dist/release/index.html")"

filePrefix="speedscope-$(date +%s)-$$"
tempdir=$(mktemp -d)

jsPath="$tempdir/$filePrefix.js"
echo "Creating temp file $jsPath"
jsSource="speedscope.loadFileFromBase64(\"$1\", \"$(getProfileBuffer $1 | base64 -w 0)\")"
echo "$jsSource" > "$jsPath"
urlToOpen="$urlToOpen#localProfilePath=$jsPath"

htmlPath="$tempdir/$filePrefix.html"
echo "Creating temp file $htmlPath"
cat <<EOF > "$htmlPath"
<script>window.location="${urlToOpen}"</script>
EOF

function openBrowser() {
  if command -v xdg-open > /dev/null; then
    xdg-open $1
  elif command -v open > /dev/null; then
    open $1
  else
    echo "Could not open $1 in a browser. Please open it manually."
  fi
}

urlToOpen="file://${htmlPath}"
echo "Opening $urlToOpen in your default browser"
openBrowser $urlToOpen
