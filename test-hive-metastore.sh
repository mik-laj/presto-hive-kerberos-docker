#!/usr/bin/env bash

set -euo pipefail

./hive.sh -e "CREATE TABLE IF NOT EXISTS employee (
  eid int,
  name String,
  salary String,
  destination String
)
COMMENT 'Employee details'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
STORED AS TEXTFILE;"

cat <<EOF >> test-data.txt
1201  Gopal       45000    Technical manager
1202  Manisha     45000    Proof reader
1203  Masthanvali 40000    Technical writer
1204  Kiran       40000    Hr Admin
1205  Kranthi     30000    Op Admin
EOF

./hive.sh -e "LOAD DATA LOCAL INPATH '$PWD/test-data.txt' OVERWRITE INTO TABLE employee;"

# YARN is not configured to use Kerberos
#./hive.sh -e "SELECT * FROM employee;"
