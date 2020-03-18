#!/bin/sh -e

DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)../"

run() {
    ./tables/create_raw_table.sh
    ./tables/create_cases_table.sh
}

(cd $DIR && run)

echo "Done."
