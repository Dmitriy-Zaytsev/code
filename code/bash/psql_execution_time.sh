#!/bin/bash
echo "EXPLAIN (ANALYSE) SELECT COUNT(value_avg) FROM trends_uint ORDER BY random() LIMIT 87" | isql "odbc_pgdb" -v -b  | sed -n '/Execution time/p' | cut -f 2 -d ":" | sed -E 's/[ [:alpha:]]| |\|//g'
exit 0
