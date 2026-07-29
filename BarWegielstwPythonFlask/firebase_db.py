import os, json, random, uuid
from datetime import datetime
from pathlib import Path

FIREBASE_AVAILABLE = False
FIRESTORE_CLIENT = None
_db_cache = None
_db_mtime = 0
BASE_DIR = Path(__file__).resolve().parent
DATABASE_FILE = BASE_DIR / 'bazadanych.json'

def init_firebase():
    global FIREBASE_AVAILABLE, FIRESTORE_CLIENT
    try:
        import firebase_admin
        from firebase_admin import credentials, firestore

        key_path = os.environ.get('FIREBASE_SERVICE_ACCOUNT',
                                   str(BASE_DIR / 'firebase-service-account.json'))
        if not os.path.isfile(key_path):
            return

        cred = credentials.Certificate(key_path)
        firebase_admin.initialize_app(cred)
        FIRESTORE_CLIENT = firestore.client()
        FIREBASE_AVAILABLE = True
    except Exception:
        FIREBASE_AVAILABLE = False


def generate_order_number():
    return str(random.randint(101, 999))


def _normalize_order(o):
    if 'order_number' not in o: o['order_number'] = generate_order_number()
    if 'status' not in o: o['status'] = 'Zamówione'
    if 'timestamp' not in o: o['timestamp'] = datetime.now().isoformat()
    if 'customer_name' not in o: o['customer_name'] = 'Gość'
    if 'notes' not in o: o['notes'] = ''
    if 'reason' not in o: o['reason'] = ''
    return o


# ----- Firestore functions -----

def _fs_get_collection(name):
    docs = FIRESTORE_CLIENT.collection(name).stream()
    result = []
    for d in docs:
        data = d.to_dict()
        data['id'] = d.id
        result.append(data)
    return result


def _fs_get_doc(collection, doc_id):
    d = FIRESTORE_CLIENT.collection(collection).document(doc_id).get()
    if not d.exists:
        return None
    data = d.to_dict()
    data['id'] = d.id
    return data


def _fs_add_doc(collection, data):
    ref = FIRESTORE_CLIENT.collection(collection).document()
    data['id'] = ref.id
    ref.set(data)
    return data


def _fs_update_doc(collection, doc_id, data):
    FIRESTORE_CLIENT.collection(collection).document(doc_id).update(data)


def _fs_delete_doc(collection, doc_id):
    FIRESTORE_CLIENT.collection(collection).document(doc_id).delete()


def _fs_get_settings():
    d = FIRESTORE_CLIENT.collection('settings').document('global').get()
    if d.exists:
        return d.to_dict()
    return {}


def _fs_set_settings(data):
    FIRESTORE_CLIENT.collection('settings').document('global').set(data, merge=True)


# ----- Local JSON fallback -----

def _json_load():
    global _db_cache, _db_mtime
    try:
        mtime = os.path.getmtime(DATABASE_FILE)
        if _db_cache is not None and mtime <= _db_mtime:
            return _db_cache
    except OSError:
        pass
    try:
        with open(DATABASE_FILE, 'r', encoding='utf-8') as f:
            data = json.load(f)
        _db_mtime = os.path.getmtime(DATABASE_FILE)
    except (FileNotFoundError, json.JSONDecodeError):
        data = {"orders": [], "menu_items": [], "portions": ["1 porcja", "2 porcje", "Pól porcji"],
                "extras": [], "custom_message": "Witaj w Barze Węgielstwo!", "danie_dnia": ""}
        _db_mtime = 0
    if 'custom_message' not in data: data['custom_message'] = "Witaj w Barze Węgielstwo!"
    if 'portions' not in data: data['portions'] = []
    if 'extras' not in data: data['extras'] = []
    if 'receipt_counter' not in data: data['receipt_counter'] = 0
    for order in data.get('orders', []):
        _normalize_order(order)
    for item in data.get('menu_items', []):
        if 'category' not in item: item['category'] = 'Inne'
    _db_cache = data
    return data


def _json_save(data):
    global _db_cache, _db_mtime
    _db_cache = data
    with open(DATABASE_FILE, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, separators=(',', ':'))
    try:
        _db_mtime = os.path.getmtime(DATABASE_FILE)
    except OSError:
        _db_mtime = 0


# ----- Public API -----

def get_orders():
    if FIREBASE_AVAILABLE:
        orders = _fs_get_collection('orders')
        for o in orders:
            _normalize_order(o)
        return orders
    return _json_load().get('orders', [])


def get_order(order_id):
    if FIREBASE_AVAILABLE:
        return _fs_get_doc('orders', order_id)
    db = _json_load()
    for o in db.get('orders', []):
        if o['id'] == order_id:
            return o
    return None


def create_order(data):
    timestamp = datetime.now().isoformat()
    order = {
        'items': data.get('items', []),
        'status': 'Zamówione',
        'order_number': generate_order_number(),
        'customer_name': data.get('customer_name', 'Gość'),
        'timestamp': timestamp,
        'notes': data.get('notes', ''),
        'reason': ''
    }
    if FIREBASE_AVAILABLE:
        return _fs_add_doc('orders', order)
    db = _json_load()
    order['id'] = str(uuid.uuid4())
    db['orders'].append(order)
    _json_save(db)
    return order


def update_order(order_id, updates):
    if FIREBASE_AVAILABLE:
        _fs_update_doc('orders', order_id, updates)
        return
    db = _json_load()
    for o in db['orders']:
        if o['id'] == order_id:
            if 'status' in updates: o['status'] = updates['status']
            if 'reason' in updates: o['reason'] = updates['reason']
            _json_save(db)
            return
    raise KeyError('Zamówienie nie znalezione')


def delete_order(order_id):
    if FIREBASE_AVAILABLE:
        _fs_delete_doc('orders', order_id)
        return
    db = _json_load()
    db['orders'] = [o for o in db['orders'] if o['id'] != order_id]
    _json_save(db)


def clear_all_orders():
    if FIREBASE_AVAILABLE:
        docs = FIRESTORE_CLIENT.collection('orders').list_documents()
        batch = FIRESTORE_CLIENT.batch()
        for d in docs:
            batch.delete(d)
        batch.commit()
        return
    db = _json_load()
    db['orders'] = []
    _json_save(db)


def get_menu_items():
    if FIREBASE_AVAILABLE:
        items = _fs_get_collection('menu_items')
        for it in items:
            if 'category' not in it: it['category'] = 'Inne'
        return items
    return _json_load().get('menu_items', [])


def add_menu_item(data):
    item = {
        'name': data['name'],
        'emoji': data.get('emoji', '\U0001f37d'),
        'available': data.get('available', True),
        'category': data.get('category', 'Inne')
    }
    if FIREBASE_AVAILABLE:
        return _fs_add_doc('menu_items', item)
    db = _json_load()
    db['menu_items'].append(item)
    _json_save(db)
    return item


def update_menu_item(name, updates):
    if FIREBASE_AVAILABLE:
        docs = FIRESTORE_CLIENT.collection('menu_items').where('name', '==', name).stream()
        for d in docs:
            _fs_update_doc('menu_items', d.id, updates)
            return
        raise KeyError('Potrawa nie znaleziona')
    db = _json_load()
    for it in db['menu_items']:
        if it['name'] == name:
            for k in ['name', 'emoji', 'available', 'category']:
                if k in updates:
                    it[k] = updates[k]
            _json_save(db)
            return
    raise KeyError('Potrawa nie znaleziona')


def delete_menu_item(name):
    if FIREBASE_AVAILABLE:
        docs = FIRESTORE_CLIENT.collection('menu_items').where('name', '==', name).stream()
        for d in docs:
            _fs_delete_doc('menu_items', d.id)
            return
        return
    db = _json_load()
    db['menu_items'] = [it for it in db['menu_items'] if it['name'] != name]
    _json_save(db)


def get_extras():
    if FIREBASE_AVAILABLE:
        extras = _fs_get_collection('extras')
        for e in extras:
            if 'available' not in e: e['available'] = True
            if 'emoji' not in e: e['emoji'] = ''
        return extras
    raw = _json_load().get('extras', [])
    return [e if isinstance(e, dict) else {'name': e, 'emoji': '', 'available': True} for e in raw]


def add_extra(data):
    extra = {'name': data['name'], 'emoji': data.get('emoji', ''), 'available': True}
    if FIREBASE_AVAILABLE:
        return _fs_add_doc('extras', extra)
    db = _json_load()
    if 'extras' not in db: db['extras'] = []
    db['extras'].append(extra)
    _json_save(db)
    return extra


def update_extra(name, updates):
    if FIREBASE_AVAILABLE:
        docs = FIRESTORE_CLIENT.collection('extras').where('name', '==', name).stream()
        for d in docs:
            _fs_update_doc('extras', d.id, updates)
            return
        return
    db = _json_load()
    for e in db.get('extras', []):
        en = e['name'] if isinstance(e, dict) else e
        if en == name:
            if not isinstance(e, dict):
                idx = db['extras'].index(e)
                db['extras'][idx] = {'name': e, 'emoji': '', 'available': True}
                e = db['extras'][idx]
            if 'available' in updates: e['available'] = updates['available']
            _json_save(db)
            return


def delete_extra(name):
    if FIREBASE_AVAILABLE:
        docs = FIRESTORE_CLIENT.collection('extras').where('name', '==', name).stream()
        for d in docs:
            _fs_delete_doc('extras', d.id)
            return
        return
    db = _json_load()
    db['extras'] = [e for e in db.get('extras', []) if (e['name'] if isinstance(e, dict) else e) != name]
    _json_save(db)


def get_settings_value(key, default=''):
    if FIREBASE_AVAILABLE:
        s = _fs_get_settings()
        return s.get(key, default)
    return _json_load().get(key, default)


def set_settings_value(key, value):
    if FIREBASE_AVAILABLE:
        _fs_set_settings({key: value})
    else:
        db = _json_load()
        db[key] = value
        _json_save(db)


def get_receipt_counter():
    if FIREBASE_AVAILABLE:
        s = _fs_get_settings()
        return s.get('receipt_counter', 0)
    return _json_load().get('receipt_counter', 0)


def set_receipt_counter(val):
    if FIREBASE_AVAILABLE:
        _fs_set_settings({'receipt_counter': val})
    else:
        db = _json_load()
        db['receipt_counter'] = val
        _json_save(db)


def get_dzwonek():
    if FIREBASE_AVAILABLE:
        s = _fs_get_settings()
        return s.get('dzwonek', False)
    return _json_load().get('_dzwonek_flag', False)


def set_dzwonek(val):
    if FIREBASE_AVAILABLE:
        _fs_set_settings({'dzwonek': val})
    else:
        db = _json_load()
        db['_dzwonek_flag'] = val
        _json_save(db)


def get_portions():
    if FIREBASE_AVAILABLE:
        s = _fs_get_settings()
        return s.get('portions', ["1 porcja", "2 porcje", "Pól porcji"])
    return _json_load().get('portions', [])
