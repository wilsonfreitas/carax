String.prototype.supplant = function (o) {
	return this.replace(/{([^{}]*)}/g,
		function (a, b) {
			var r = o[b];
			return typeof r === 'string' || typeof r === 'number' ? r : a;
		}
	);
};

function Ajax() {
	var me = this;
	var req = null;
	if (window.XMLHttpRequest) {
		try {
			req = new XMLHttpRequest();
		} catch (e) {
			req = null;
		}
	} else {
		alert('This application requires a browser with XML support.');
	}
	this.request = req;
	this.loadJSON = function (url, loadHandler, async) {
		async = async || true;
		if (this.request) {
			this.request.open('GET', url, async);
			this.request.onreadystatechange = function() {
				req = me.request;
				if (req.readyState === 4 && req.status === 200) {
					loadHandler(eval('(' + req.responseText + ')'))
				}
			};
			this.request.setRequestHeader("Content-Type", "text/xml");
			this.request.send("");
		}
	};
};

var Sequela = function () {
	var that = {};
	that.database = null;
	that.execute = function (query, contentHandler, async) {
		async = async || true;
		var setdbReq = new Ajax();
		var qs = "/execute?query={query}&database={database};".supplant({
			'query': query,
			'database': that.database
		});
		setdbReq.loadJSON(qs, function(ret) { contentHandler(ret) }, async);
		return false;
	};
	that.executeQuery = function (query, id) {
		query = query.replace(/\n/g, ' ');
		return app.execute(query, function(ret) {
			clearTable(id);
			createTable(ret.rows, ret.description, id);
			document.queryForm.query.focus();
		});
	};
	that.check = function (database) {
		var setdbReq = new Ajax();
		var qs = "/check?database={database};".supplant({ 'database': database });
		setdbReq.loadJSON(qs, function(r) {
			if (r) {
				that.database = database;
				var q = 'select type,name,sql from sqlite_master';
				that.execute(q, function (ret) {
					clearTable('database-info');
					var nret = prepareTableInfo(ret.rows, ret.description);
					createTable(nret.rows, nret.description, 'database-info');
					document.queryForm.query.focus();
				});
			}
		});
		return false;
	};
	return that;
};

var TableInfo = function(info) {
	var that = {
		type: info[0],
		name: info[1],
		sql: info[2],
		count: 0,
		info: null
	};
	var query;
	if (that.type === 'table') {
		query = 'select count(*) as count from {name}'.supplant(that);
		app.execute(query, function(ret) {
			that.count = ret.rows[0][0];
		}, false);
	}
	query = 'pragma {type}_info({name})'.supplant(that);
	app.execute(query, function(ret) {
		that.info = ret;
	}, false);
	return that;
}

var tableInfos = {};
var app = new Sequela();

function prepareTableInfo(rows, description) {
	var newRows = new Array();
	var newDesc = [['type'], ['name']];
	var i, ti;
	var a;
	
	for (i=0 ; i<rows.length ; i++) {
		ti = new TableInfo(rows[i]);
		tableInfos[ti.name] = ti;
		a = '<a href="#" onclick="return showTableInfo(\'{name}\');">{name}</a>'.supplant(ti);
		newRows[i] = [ti.type, a];
	}
	
	return {
		description: newDesc,
		rows: newRows
	};
};

function showTableInfo(name) {
	var ti = tableInfos[name];
	var p = document.getElementById("table-info");
	p.innerHTML = "Name: {name}<br>Type: {type}<br>SQL: {sql}<br>Count: {count}".supplant(ti);
	clearTable('table-info-pragma');
	createTable(ti.info.rows, ti.info.description, 'table-info-pragma');
	return false;
};

function createDBInfoTable(rows) {
	var tr, td, row;
	var i, j;
	var tbody = document.getElementById("db_info");
	var row_count = tbody.rows.length;
	for (i=0 ; i<row_count ; i++) {
		tbody.deleteRow(i);
		row_count--;
		i--;
	}
	for (i=0 ; i<rows.length ; i++) {
		row = rows[i];
		tr = tbody.insertRow(tbody.rows.length);
		td = tr.insertCell(tr.cells.length);
		td.innerHTML = getDBInfoLink(row[1], row[0], i+1);
		for (j=1 ; j<(row.length+1) ; j++) {
			td = tr.insertCell(tr.cells.length);
			td.innerHTML = row[j-1];
		}
	}
	document.getElementById("db_info_table").style.visibility = 'visible';
};

function getDBInfoLink(entity, entity_type, i) {
	var link;
	if (entity_type === 'table') {
		link = '<a href="/execute?query=pragma table_info({entity})' +
		'&db_path={db_path}" class="info">{i}</a>';
	} else {
		link = '<a href="/execute?query=pragma index_info({entity})' +
		'&db_path={db_path}" class="info">{i}</a>';
	}
	return link.supplant({'entity': entity, 'db_path': app.db_path, 'i': i});
};

function createTable(rows, description, id) {
	var tr, td, row;
	var i, j;
	var table = document.getElementById(id);
	var thead = document.createElement('thead');
	table.appendChild(thead);
	tr = thead.insertRow(0);
	td = document.createElement('th');
	td.innerHTML = 'N';
	td.className = 'first-col-head';
	tr.appendChild(td);
	for (i=0 ; i<description.length ; i++) {
		td = document.createElement('th');
		td.innerHTML = description[i][0].toUpperCase();
		tr.appendChild(td);
	}
	var tbody = document.createElement('tbody');
	table.appendChild(tbody);
	for (i=0 ; i<rows.length ; i++) {
		row = rows[i];
		tr = tbody.insertRow(tbody.rows.length);
		td = tr.insertCell(tr.cells.length);
		td.innerHTML = i+1;
		td.className = 'first-col-body';
		for (j=1 ; j<(row.length+1) ; j++) {
			td = tr.insertCell(tr.cells.length);
			td.innerHTML = row[j-1];
		}
	}
	table.style.visibility = 'visible';
};

function clearTable(id) {
	var i;
	var table = document.getElementById(id);
	var rc = table.rows.length;
	for (i=0 ; i<rc ; i++) {
		table.deleteRow(i);
		rc--;
		i--;
	}
	// document.getElementById("db_info_table").style.visibility = 'visible';
};