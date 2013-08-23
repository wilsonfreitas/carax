from bottle import route, run, template, request, view
import sqlite3
import os

@route('/execute', method='POST')
@view('index')
def executequery():
	db_path = request.forms.get('db_path')
	db = sqlite3.connect(db_path)
	c = db.cursor()
	query = request.forms.get('query')
	result = c.execute(query).fetchall()
	return dict(rows=result, query=query, db_path=db_path,
		description=c.description)

@route('/')
def index():
	return template('index')

run(host='localhost', port=8080, debug=True, reloader=True)
