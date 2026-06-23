#!/usr/bin/env bash

FILE="/opt/test/test.txt"

if grep -q '^changevalue=1$' "$FILE"; then
    sed -i 's/^changevalue=1$/changevalue=0/' "$FILE"
    echo "Значение изменено"
else
    echo "Строка changevalue=1 не найдена"
fi
