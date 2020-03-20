#!/bin/sh -e

DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"

run() {
    ./create_raw_table.sh
    ./create_cases_table.sh
    ./create_slopes_table.sh
    ./create_projections_table.sh
}

(cd $DIR && run)

echo "Done."
