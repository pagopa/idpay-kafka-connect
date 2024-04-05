#!/bin/bash

ENV_PIPELINE_FILE=.devops/deploy-pipelines.yml
env=$(cat "$ENV_PIPELINE_FILE" | grep -i 'environment:' | cut -d' ' -f2)

if [[$env == 'DEV']]; then
   for connector in $(curl -s -X GET https://dev01.idpay.internal.dev.cstar.pagopa.it/idpaykafkaconnect/connectors | grep -Eo '[^]",\[]+'); do
     curl -s -X GET https://dev01.idpay.internal.dev.cstar.pagopa.it/idpaykafkaconnect/connectors/$connector/status | grep FAILED | wc -l;
   done | grep -Ez '^(0[[:space:]])+$'
fi