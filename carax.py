from bottle import route, run, template, request, view
import sqlite3
import os
import json

@route('/execute')
def execute():
	db_path = request.query.get('db_path')
	db = sqlite3.connect(db_path)
	c = db.cursor()
	data = {}
	data['query'] = request.query.get('query')
	data['rows'] = c.execute(data['query']).fetchall()
	data["description"] = c.description
	return json.dumps(data)

@route('/')
def index():
	return template('index')

run(host='localhost', port=8080, debug=True, reloader=True)
