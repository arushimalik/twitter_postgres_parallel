#!/bin/bash

files=$(find data -name "*.zip")

echo '================================================================================'
echo 'load denormalized'
echo '================================================================================'
time for file in $files; do
    echo
    unzip -p "$file" | sed 's/\\u0000//g' | \
    psql "postgresql://postgres:pass@localhost:5435" \
    -c "COPY tweets_jsonb (data) FROM STDIN CSV QUOTE E'\x01' DELIMITER E'\x    02';"
done

echo '================================================================================'
echo 'load pg_normalized'
echo '================================================================================'
time for file in $files; do
    echo
    python3 load_tweets.py \
    --db "postgresql://postgres:pass@localhost:5431" \
    --inputs "$file"
done

echo '================================================================================'
echo 'load pg_normalized_batch'
echo '================================================================================'
time for file in $files; do
    python3 -u load_tweets_batch.py --db=postgresql://postgres:pass@localhost:5436/ --inputs $file
done
