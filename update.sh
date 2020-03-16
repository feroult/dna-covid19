#!/bin/sh -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

$DIR/create_raw_table.sh && $DIR/create_cases_table.sh
