#!/bin/sh -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

run() {
    ./create_raw_table.sh
    ./create_cases_table.sh
}

(cd $DIR && run)

echo "Done."
