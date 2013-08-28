from bottle import route, run, template, request, view
import sqlite3
import os
import json

@route('/execute')
def execute():
	db = sqlite3.connect(request.query.get('database'))
	c = db.cursor()
	data = {}
	data['query'] = request.query.get('query')
	data['rows'] = c.execute(data['query']).fetchall()
	data["description"] = c.description
	return json.dumps(data)

@route('/check')
def check():
	return str(os.path.exists(request.query.get('database'))).lower()

@route('/')
def index():
	return template('index')

run(host='localhost', port=8080, debug=True, reloader=True)
