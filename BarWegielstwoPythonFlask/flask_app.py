from flask import Flask, render_template, request, jsonify, send_from_directory
import json
import os
import subprocess
from datetime import datetime
from pathlib import Path
from firebase_db import (
    init_firebase, get_orders, get_order, create_order, update_order,
    delete_order, clear_all_orders, get_menu_items, add_menu_item,
    update_menu_item, delete_menu_item, get_extras, add_extra,
    update_extra, delete_extra, get_settings_value, set_settings_value,
    get_dzwonek, set_dzwonek, get_portions, get_receipt_counter,
    set_receipt_counter
)

try:
    from fpdf import FPDF
except ImportError:
    FPDF = None

app = Flask(__name__, template_folder='.', static_folder='.', static_url_path='')
app.config['SECRET_KEY'] = 'restaurant_sosny_secret'
app.json.ensure_ascii = False

BASE_DIR = Path(__file__).resolve().parent

init_firebase()


@app.route('/static/<path:filename>')
def serve_static(filename):
    return send_from_directory('static', filename)


# ----- Pages -----

@app.route('/')
def zamow():
    return render_template('zamow.html')

@app.route('/manage')
def manage():
    return render_template('manage.html')

@app.route('/releases')
def releases():
    return render_template('releases.html')

@app.route('/bazadanych.json')
def database_json():
    return jsonify({
        'orders': get_orders(),
        'menu_items': get_menu_items(),
        'portions': get_portions(),
        'extras': get_extras(),
        'custom_message': get_settings_value('custom_message', 'Witaj w Barze Węgielstwo!'),
        'danie_dnia': get_settings_value('danie_dnia', '')
    })


# ----- Orders API -----

@app.route('/api/orders', methods=['GET', 'POST'])
def api_orders():
    if request.method == 'POST':
        data = request.get_json()
        if not data:
            return jsonify({'error': 'Brak danych zamówienia'}), 400

        order = create_order(data)
        receipt = _zapisz_paragon(order)
        return jsonify({'success': True, 'order': order, 'receipt': receipt}), 201

    return jsonify(get_orders())


@app.route('/api/orders/clear', methods=['DELETE'])
def api_orders_clear():
    clear_all_orders()
    return jsonify({'success': True})


@app.route('/api/orders/<order_id>', methods=['PUT', 'DELETE'])
def api_order(order_id):
    if request.method == 'PUT':
        data = request.get_json() or {}
        updates = {}
        if 'status' in data: updates['status'] = data['status']
        if 'reason' in data: updates['reason'] = data['reason']
        try:
            update_order(order_id, updates)
            order = get_order(order_id)
            return jsonify({'success': True, 'order': order})
        except KeyError:
            return jsonify({'error': 'Zamówienie nie znalezione'}), 404

    elif request.method == 'DELETE':
        delete_order(order_id)
        return jsonify({'success': True})


# ----- Menu API -----

@app.route('/api/menu', methods=['GET', 'POST'])
def api_menu():
    if request.method == 'POST':
        data = request.get_json()
        if not data or 'name' not in data:
            return jsonify({'error': 'Brak nazwy potrawy'}), 400
        item = add_menu_item(data)
        return jsonify({'success': True, 'item': item}), 201

    return jsonify(get_menu_items())


@app.route('/api/menu/<name>', methods=['PUT', 'DELETE'])
def api_menu_item(name):
    if request.method == 'PUT':
        data = request.get_json() or {}
        try:
            update_menu_item(name, data)
            return jsonify({'success': True})
        except KeyError:
            return jsonify({'error': 'Potrawa nie znaleziona'}), 404

    elif request.method == 'DELETE':
        delete_menu_item(name)
        return jsonify({'success': True})


# ----- Extras API -----

@app.route('/api/extras', methods=['GET', 'POST'])
def api_extras():
    if request.method == 'POST':
        data = request.get_json()
        if not data or 'name' not in data:
            return jsonify({'error': 'Brak nazwy'}), 400
        name = data['name'].strip()
        if not name:
            return jsonify({'error': 'Nazwa nie może być pusta'}), 400
        add_extra(data)
        return jsonify({'success': True, 'extras': get_extras()}), 201

    return jsonify({'extras': get_extras()})


@app.route('/api/extras/<name>', methods=['PUT', 'DELETE'])
def api_extra(name):
    if request.method == 'PUT':
        data = request.get_json() or {}
        updates = {}
        if 'available' in data: updates['available'] = data['available']
        update_extra(name, updates)
        return jsonify({'success': True, 'extras': get_extras()})

    elif request.method == 'DELETE':
        delete_extra(name)
        return jsonify({'success': True, 'extras': get_extras()})


# ----- Portions -----

@app.route('/api/portions')
def api_portions():
    return jsonify({'portions': get_portions()})


# ----- Dzwonek -----

@app.route('/api/dzwonek', methods=['GET', 'POST'])
def api_dzwonek():
    if request.method == 'POST':
        set_dzwonek(True)
        return jsonify({'success': True})
    v = get_dzwonek()
    set_dzwonek(False)
    return jsonify({'ring': v})


# ----- Message / Misc -----

@app.route('/api/message', methods=['GET', 'POST'])
def api_message():
    if request.method == 'POST':
        data = request.get_json()
        if not data or 'message' not in data:
            return jsonify({'error': 'Brak wiadomości'}), 400
        set_settings_value('custom_message', data['message'])
        return jsonify({'success': True, 'message': data['message']})

    return jsonify({'message': get_settings_value('custom_message', '')})


@app.route('/api/danie-dnia', methods=['GET', 'POST'])
def api_danie_dnia():
    if request.method == 'POST':
        data = request.get_json()
        if not data or 'danie' not in data:
            return jsonify({'error': 'Brak dania'}), 400
        set_settings_value('danie_dnia', data['danie'])
        return jsonify({'success': True, 'danie': data['danie']})

    return jsonify({'danie': get_settings_value('danie_dnia', '')})


@app.route('/api/cleanup', methods=['POST'])
def api_cleanup():
    now = datetime.now()
    cutoff = now.timestamp() - 24 * 3600
    orders = get_orders()
    before = len(orders)
    for o in orders:
        try:
            ts_str = o.get('timestamp', '')
            if ts_str and datetime.fromisoformat(ts_str).timestamp() < cutoff:
                delete_order(o['id'])
        except Exception:
            pass
    after = len(get_orders())
    return jsonify({'deleted': before - after, 'last_run': now.isoformat()})


def _zapisz_paragon(order):
    PARAGON_DIR = Path(r'C:\Users\wegiel\Pictures\kitchen\paragony')
    PARAGON_DIR.mkdir(exist_ok=True)

    counter = get_receipt_counter()
    numer = f"{counter:04d}"
    set_receipt_counter(counter + 1)

    filename = f"paragon_{numer}.txt"
    filepath = PARAGON_DIR / filename

    lines = []
    lines.append("Bar Węgielstwo")
    lines.append("-" * 36)
    try:
        lines.append(f"Data: {datetime.fromisoformat(order['timestamp']).strftime('%d.%m.%Y %H:%M:%S')}")
    except Exception:
        lines.append(f"Data: {datetime.now().strftime('%d.%m.%Y %H:%M:%S')}")
    lines.append(f"Numer: {numer}")
    for item in order.get('items', []):
        name = item.get('name', 'Pozycja')
        portion = item.get('portion', '')
        lines.append(f"{name} ({portion}) ...... 0,00 zł")
    lines.append("-" * 36)
    lines.append("**DO ZAPŁACENIA:** 0,00 zł")
    lines.append("**Płatność:** Brak")
    lines.append("-" * 36)
    lines.append("Dziękujemy za wizytę!")

    full_text = "\n".join(lines)

    try:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(full_text)
    except Exception:
        pass

    return full_text


application = app

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=6969, debug=False)
