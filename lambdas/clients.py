# ============================================================
# SCRIPT: Clients Lambda Handler
# AUTHOR: Jola
# DATE:   2026-05-19
#
# DESCRIPTION:
#   Obsługuje operacje CRUD na klientach psychologa
#   w tabeli DynamoDB.
#
# ASSUMPTIONS:
#   - Każdy klient należy do jednego psychologa (psychologistId z JWT)
#   - Klucz główny: PK=CLIENT#{clientId}, SK=PROFILE
#   - Lista klientów tymczasowo przez scan + filtr (docelowo GSI)
#
# INPUTS:  event["body"]                       — dane klienta (create)
#          event["pathParameters"]["clientId"] — ID klienta (get)
#
# OUTPUTS: HTTP response z kodem statusu i danymi JSON
# ============================================================

import os
import uuid
import boto3
from utils import response, parse_body, get_psychologist_id
from boto3.dynamodb.conditions import Attr

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(os.environ["DYNAMODB_TABLE"])

def create(event, context):
    # POST /clients — tworzy nowego klienta i zwraca jego ID
    try:
        body = parse_body(event)

        required_fields = ["firstName", "lastName", "pesel", "birthDate"]
        missing = [f for f in required_fields if not body.get(f)]
        if missing:
            return response(400, {"error": f"Missing required fields: {', '.join(missing)}"})

        client_id = str(uuid.uuid4())

        table.put_item(Item={
            "PK": f"CLIENT#{client_id}",
            "SK": "PROFILE",
            "psychologistId": get_psychologist_id(event),
            "clientId": client_id,
            "firstName": body["firstName"],
            "lastName": body["lastName"],
            "pesel": body["pesel"],
            "birthDate": body["birthDate"],
        })

        return response(201, {"id": client_id})
    except Exception as e:
        return response(500, {"error": str(e)})
    

def get(event, context):
    # GET /clients/{clientId} — pobiera klienta po ID; 404 jeśli nie istnieje
    try:
        client_id = event["pathParameters"]["clientId"]

        result = table.get_item(Key={
            "PK": f"CLIENT#{client_id}",
            "SK": "PROFILE",
        })

        item = result.get("Item")
        if not item:
            return response(404, {"error": "Client not found"})

        return response(200, item)
    except Exception as e:
        return response(500, {"error": str(e)})
    

def list(event, context):
    # GET /clients — zwraca wszystkich klientów psychologa; tymczasowo scan z filtrem (docelowo GSI)
    try:
        psychologist_id = get_psychologist_id(event)

        result = table.scan(
            FilterExpression=Attr("psychologistId").eq(psychologist_id)
        )

        return response(200, {"clients": result.get("Items", [])})
    except Exception as e:
        return response(500, {"error": str(e)})
