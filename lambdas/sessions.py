# ============================================================
# SCRIPT: Sessions Lambda Handler
# AUTHOR: Jola
# DATE:   2026-05-19
#
# DESCRIPTION:
#   Obsługuje operacje na sesjach terapeutycznych psychologa
#   w tabeli DynamoDB: tworzenie, odczyt, listowanie i podpisywanie.
#
# ASSUMPTIONS:
#   - Sesja przechodzi przez stany: draft -> signed (przejście nieodwracalne)
#   - Klucz główny: PK=SESSION#{sessionId}, SK=META
#   - Lista sesji tymczasowo przez scan + filtr po clientId (docelowo GSI)
#   - Hash podpisu to SHA-256 z treści pola notes (UTF-8)
#   - psychologistId pochodzi z JWT (Cognito Authorizer)
#
# INPUTS:  event["body"]                         — dane sesji (create)
#          event["pathParameters"]["sessionId"]  — ID sesji (get, sign)
#          event["queryStringParameters"]["clientId"] — filtr klienta (list)
#
# OUTPUTS: HTTP response z kodem statusu i danymi JSON
# ============================================================

import os
import uuid
import hashlib
import boto3
from datetime import datetime, timezone
from utils import response, parse_body, get_psychologist_id
from boto3.dynamodb.conditions import Attr

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(os.environ["DYNAMODB_TABLE"])

def create(event, context):
    # POST /sessions — tworzy nową sesję
    try:
        body = parse_body(event)

        required_fields = ["clientId", "sessionType", "date", "notes"]
        missing = [f for f in required_fields if not body.get(f)]
        if missing:
            return response(400, {"error": f"Missing required fields: {', '.join(missing)}"})

        session_id = str(uuid.uuid4())

        table.put_item(Item={
            "PK": f"SESSION#{session_id}",
            "SK": "META",
            "psychologistId": get_psychologist_id(event),
            "clientId": body['clientId'],
            "sessionType": body['sessionType'],
            "date": body['date'],
            "notes" : body['notes'],
            "state" : "draft"            
        })

        return response(201, {"id": session_id})
    
    except Exception as e:
        return response(500, {"error": str(e)})
    


def get(event,context):
    try:
        # GET /session/{sessionId} — pobiera sesje po ID; 404 jeśli nie istnieje
        session_id = event["pathParameters"]["sessionId"]

        result = table.get_item(Key={
            "PK": f"SESSION#{session_id}",
            "SK": "META",
        })

        item = result.get("Item")
        if not item:
            return response(404, {"error": "Session not found"})

        return response(200, item)
    
    except Exception as e:
        return response(500, {"error": str(e)})
    
      
def sign(event, context):
    # POST /sessions/{sessionId}/sign — podpisuje sesję; zmienia stan draft -> signed
    try:
        session_id = event["pathParameters"]["sessionId"]

        result = table.get_item(Key={"PK": f"SESSION#{session_id}", "SK": "META"})
        item = result.get("Item")
        if not item:
            return response(404, {"error": "Session not found"})

        notes = item.get("notes", "")
        signature_hash = hashlib.sha256(notes.encode("utf-8")).hexdigest()

        table.update_item(
            Key={"PK": f"SESSION#{session_id}", "SK": "META"},
            UpdateExpression="SET #state = :signed, signedAt = :ts, signatureHash = :hash, signedBy = :pid",
            ExpressionAttributeNames={"#state": "state"},
            ExpressionAttributeValues={
                ":signed": "signed",
                ":draft": "draft",
                ":ts": datetime.now(timezone.utc).isoformat(),
                ":hash": signature_hash,
                ":pid": get_psychologist_id(event),
            },
            ConditionExpression="#state = :draft",
        )

        return response(200, {"id": session_id, "state": "signed"})

    except dynamodb.meta.client.exceptions.ConditionalCheckFailedException:
        return response(409, {"error": "Session is already signed"})
    except Exception as e:
        return response(500, {"error": str(e)})


def list(event, context):
    # GET /sessions — zwraca wszystkie sesje clienta; query table
    try:
        
        
        client_id = event.get("queryStringParameters", {}).get("clientId")
        if not client_id:
            return response(400, {"error": "Missing required parameter: clientId"})
        
        result = table.scan(
            FilterExpression=Attr("clientId").eq(client_id)
        )

        return response(200, {"sessions": result.get("Items", [])})
    
    except Exception as e:
        return response(500, {"error": str(e)})
