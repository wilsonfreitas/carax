from bottle import route, run, template, request, view
import sqlite3
import os
import json

db_path = None

@route('/execute', method='POST')
@view('index')
def executequery():
	db_path = request.forms.get('db_path')
	data = {}
	if db_path:
		db = sqlite3.connect(db_path)
		c = db.cursor()
		data['db_path'] = db_path
		data['db_info'] = c.execute('select type,name,tbl_name from sqlite_master').fetchall()
		data['db_desc'] = c.description
		query = request.forms.get('query')
		if query:
			data['query'] = query	
			data['rows'] = c.execute(query).fetchall()
			data["description"] = c.description
	return data

@route('/execute', method='GET')
def execute_get():
	db_path = request.query.get('db_path')
	db = sqlite3.connect(db_path)
	c = db.cursor()
	query = request.query.get('query')
	data = {}
	data['query'] = query
	data['rows'] = c.execute(query).fetchall()
	data["description"] = c.description
	return json.dumps(data)

@route('/database')
def database():
	db_path = request.query.get('path')
	return "OK"

@route('/')
def index():
	return template('index', db_path=db_path)

run(host='localhost', port=8080, debug=True, reloader=True)
