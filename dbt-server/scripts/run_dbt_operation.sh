#!/bin/sh

COMPLETE_PATH=$1
OPERATION=$2

TARGET=prod

DBT_PROJECT_PATH=$(echo $COMPLETE_PATH | cut -d'/' -f
)
DBT_PROFILES_PATH=$(echo $COMPLETE_PATH | cut -d'/' -f 1-7)
PROJECT=$(echo $COMPLETE_PATH | cut -d'/' -f 6)
MODEL=$(echo $COMPLETE_PATH | rev | cut -d'/' -f 1 | rev | cut -d'.' -f 1)
MODEL_PATH=$(echo $COMPLETE_PATH | rev | cut -d'/' -f 2 | rev)


export AIRFLOW_DS=''
export AIRFLOW_TS=''

if [ $OPERATION = 'compile' ]
then

dbt_output=$(dbt compile --target "${TARGET}" --profiles-dir "${DBT_PROFILES_PATH}" --project-dir "${DBT_PROJECT_PATH}" --select "${MODEL}")
compiled_sql=$(cat "${DBT_PROJECT_PATH}"/target/compiled/"${PROJECT}"/models/"${MODEL_PATH}"/"${MODEL}".sql)

query_result=$(dbt run-operation run_limited_set --args "{query: ""${compiled_sql}""}" --profiles-dir "${DBT_PROFILES_PATH}" --project-dir "${DBT_PROJECT_PATH}" --target "${TARGET}" )

jq --raw-output --null-input \
  --arg compiled_sql "$compiled_sql" \
  --arg model "$MODEL" \
  --arg query_result "$query_result" \
  --arg dbt_output "$dbt_output" \
  '{"model": $model, "queryResult": $query_result, "compiledSql": $compiled_sql, "dbtOutput": $dbt_output}'

elif [ $OPERATION = 'run' ]
then
dbt_output=$(dbt run --target "${TARGET}" --profiles-dir "${DBT_PROFILES_PATH}" --project-dir "${DBT_PROJECT_PATH}" --select "${MODEL}")
compiled_sql=$(cat "${DBT_PROJECT_PATH}"/target/compiled/"${PROJECT}"/models/"${MODEL_PATH}"/"${MODEL}".sql)

jq --raw-output --null-input \
  --arg compiled_sql "$compiled_sql" \
  --arg model "$MODEL" \
  --arg dbt_output "$dbt_output" \
  '{"model": $model, "compiledSql": $compiled_sql, "dbtOutput": $dbt_output}'

elif [ $OPERATION = 'seed' ]
then
  echo to seed
  dbt_output=$(dbt seed --target "${TARGET}" --profiles-dir "${DBT_PROFILES_PATH}" --project-dir "${DBT_PROJECT_PATH}")

  jq --raw-output --null-input \
  --arg model "$MODEL" \
  --arg dbt_output "$dbt_output" \
  '{"model": $model, "dbtOutput": $dbt_output}'

fi



