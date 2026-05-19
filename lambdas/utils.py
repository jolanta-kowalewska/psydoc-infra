# ============================================================
# SCRIPT: Lambda Utility Helpers
# AUTHOR: Jola
# DATE:   2026-05-19
#
# DESCRIPTION:
#   Wspólne funkcje pomocnicze dla Lambda handlerów:
#   formatowanie HTTP response, parsowanie body, ekstrakcja
#   psychologistId z JWT Cognito.
#
# ASSUMPTIONS:
#   - JWT claims dostępne przez API Gateway authorizer
#   - psychologistId = Cognito "sub" claim
#   - body eventu może być string (z API GW) lub dict
#
# INPUTS:  event — standardowy AWS Lambda event dict
#
# OUTPUTS: dict z statusCode, headers i body jako JSON string
# ============================================================

import json
import os
import boto3

def response(status_code: int, body: dict) -> dict:
    return {
        "statusCode": status_code,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(body, ensure_ascii=False)
    }

def parse_body(event: dict) -> dict:
    body = event.get("body", "{}")
    if isinstance(body, str):
        return json.loads(body)
    return body or {}

def get_psychologist_id(event: dict) -> str:
    return event["requestContext"]["authorizer"]["claims"]["sub"]