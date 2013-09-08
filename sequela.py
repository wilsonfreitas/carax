from bottle import route, run, template, request, view, static_file, post, get,\
	response
import sqlite3
import os
import json

@route('/')
def index():
	return template('index')


@route("/spec/<filepath:path>")
def serve_spec(filepath):
	return static_file(filepath, root=os.path.join(os.getcwd(), 'spec'))


@route("/static/<filepath:path>")
def serve_static(filepath):
	return static_file(filepath, root=os.path.join(os.getcwd(), 'static'))


@post('/execute')
def do_execute():
	return execute(sqlite3.connect(request.forms.get('database')),
		request.forms.get('query'))


@get('/execute')
def get_execute():
	return execute(sqlite3.connect(request.query.get('database')),
		request.query.get('query'))


def execute(con, query):
	"""
	Execute the query in database. 
	con is a SQLite connection and query is a string.
	Returns a dict with the query, the rows and column's names in the 
	description item.
	"""
	c = con.cursor()
	data = {}
	data['query'] = query
	data['rows'] = c.execute(query).fetchall()
	data["description"] = c.description
	return json.dumps(data)


@route('/check')
def check():
	return str(os.path.exists(request.query.get('database'))).lower()

'''
Functions to help with the test cases (actually they call it specs, but I can't
understand why.)
'''

@post('/test')
def do_test():
	param = request.forms.get('param1')
	name = request.forms.get('name')
	return json.dumps(dict(param=param, age=37, name=name))

@get('/testparams')
def testparams():
	param = request.query.get('param1')
	name = request.query.get('name')
	return json.dumps(dict(param=param, age=37, name=name))

@get('/testxml')
def testxml():
	response.content_type = 'text/xml'
	return "<span>true</span>"

@post('/ie') # internalerror
def do_test():
	raise Exception("Exception raised")

@route('/test')
def test():
	return "true"

run(host='localhost', port=8080, debug=True, reloader=True)
