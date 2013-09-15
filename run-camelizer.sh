#!/bin/bash 

set -e

die () {
  echo "Usage: $0 root_directory_to_camelize"
  echo >&2 "$@"
  exit 1
}

[ "$#" -eq 1 ] || die "1 argument required, $# provided"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
grep -lr --include='*.java' '[a-z]_[a-z]*(' $1 | xargs $DIR/camelize_from_stdin.rb
