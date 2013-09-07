from bottle import route, run, template, request, view, static_file, post, get,\
	response
import sqlite3
import os
import json

@route("/spec/<filepath:path>")
def serve_spec(filepath):
	return static_file(filepath, root=os.path.join(os.getcwd(), 'spec'))

@route("/static/<filepath:path>")
def serve_static(filepath):
	return static_file(filepath, root=os.path.join(os.getcwd(), 'static'))

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

@route('/')
def index():
	return template('index')

run(host='localhost', port=8080, debug=True, reloader=True)
