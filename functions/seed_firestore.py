#!/usr/bin/env python3
"""Seed Firestore with data from bazadanych.json."""
import json
import sys
from datetime import datetime
from google.cloud import firestore

def seed_from_json(json_path: str, collection_prefix: str = ""):
    db = firestore.Client()

    with open(json_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    batch = db.batch()
    count = 0

    if "orders" in data and isinstance(data["orders"], list):
        for item in data["orders"]:
            ref = db.collection(f"{collection_prefix}orders").document(item.get("id", item.get("order_number", str(count))))
            doc_data = item.copy()
            if "timestamp" in doc_data and isinstance(doc_data["timestamp"], str):
                try:
                    doc_data["timestamp"] = datetime.fromisoformat(doc_data["timestamp"])
                except (ValueError, TypeError):
                    doc_data["timestamp"] = firestore.SERVER_TIMESTAMP
            batch.set(ref, doc_data)
            count += 1

    if "menu_items" in data and isinstance(data["menu_items"], list):
        for item in data["menu_items"]:
            ref = db.collection(f"{collection_prefix}menu_items").document(item.get("name", str(count)))
            batch.set(ref, item)
            count += 1

    if "extras" in data and isinstance(data["extras"], list):
        for item in data["extras"]:
            ref = db.collection(f"{collection_prefix}extras").document(item.get("name", str(count)))
            batch.set(ref, item)
            count += 1

    if "settings" in data and isinstance(data["settings"], dict):
        ref = db.collection(f"{collection_prefix}settings").document("app")
        batch.set(ref, data["settings"], merge=True)
        count += 1

    batch.commit()
    print(f"Seeded {count} documents successfully.")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python seed_firestore.py <path_to_bazadanych.json>")
        sys.exit(1)
    seed_from_json(sys.argv[1])