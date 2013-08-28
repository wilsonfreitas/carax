%	setdefault('__app_name__', 'sequela')
<html>
<head>
	<meta http-equiv="Content-type" content="text/html; charset=utf-8">
	<title>{{__app_name__}}—Your best friend, SQLite user!</title>
	<style type="text/css" media="screen">
	body {
		max-width: 80%;
		margin-left: auto;
		margin-right: auto;
		font-family: sans-serif;
		font-size: 80%;
	}
	a {
		color: black;
		text-decoration: none;
	}
	a:hover {
		color: red;
		text-decoration: underline;
	}
	div {
		margin-right: 10px;
		padding: 5px;
		/*border: 1px solid black;*/
	}
	#database {
		float: left;
		width: 100%;
		margin-bottom: 5px;
	}
	#main {
		float: left;
	}
	#panel {
		float: left;
		width: 50%;
	}
	textarea {
		width: 500px;
		height: 100px;
		min-height: 100px;
	}
	table {
		table-collapse: collapse;
		border-spacing: 0;
		width: 100%;
		font-size: 90%;
	}
	td {border: 1px groove black; padding: 7px; background-color: #CCFFCC;}
	th {border: 1px groove black; padding: 7px; background-color: #FFFFCC;}
	</style>
	<script type="text/javascript" charset="utf-8">
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
		this.loadJSON = function (url, loadHandler) {
			if (this.request) {
				this.request.open('GET', url, true);
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
		that.execute = function (query, contentHandler) {
			var setdbReq = new Ajax();
			var qs = "/execute?query={query}&database={database};".supplant({
				'query': query,
				'database': that.database
			});
			setdbReq.loadJSON(qs, function(ret) { contentHandler(ret) });
			return false;
		};
		that.executeQuery = function (query) {
			return app.execute(query, function(ret) {
				clearTable();
				createTable(ret.rows, ret.description);
				document.queryForm.query.focus();
			});
		};
		that.check = function (database) {
			var setdbReq = new Ajax();
			var qs = "/check?database={database};".supplant({ 'database': database });
			setdbReq.loadJSON(qs, function(r) {
				if (r) {
					that.database = database;
					var q = 'select type,name,tbl_name from sqlite_master';
					that.execute(q, function (ret) {
						createDBInfoTable(ret.rows);
						document.queryForm.query.focus();
					});
				}
			});
			return false;
		};
		return that;
	};
	
	var app = new Sequela();
	
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
	
	function createTable(rows, description) {
		var tr, td, row;
		var i, j;
		var table = document.getElementById("table-results");
		var thead = document.createElement('thead');
		table.appendChild(thead);
		tr = thead.insertRow(0);
		td = document.createElement('th');
		td.innerHTML = 'N';
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
			for (j=1 ; j<(row.length+1) ; j++) {
				td = tr.insertCell(tr.cells.length);
				td.innerHTML = row[j-1];
			}
		}
		table.style.visibility = 'visible';
	};
	
	function clearTable() {
		var i;
		var table = document.getElementById("table-results");
		var rc = table.rows.length;
		for (i=0 ; i<rc ; i++) {
			table.deleteRow(i);
			rc--;
			i--;
		}
		// document.getElementById("db_info_table").style.visibility = 'visible';
	};
	</script>
</head>
<body id="body" onload="document.database.database.focus();">
	<h1 id="gina">
		<a href="/">{{__app_name__}}—Your best friend, SQLite user!</a></h1>
	<div id="database">
		<form action="#" method="get" accept-charset="utf-8"
		name="database" onsubmit="return false;">
			<p>Database file path:
				<input type="text" name="database" value=""
				id="db_path" size=100 onchange="app.check(this.value);">
				<input type="submit" value="Check database"
				onclick="return false;">
			</p>
		</form>
	</div>
	<div id="main">
		<h3>Query:</h3>
		<hr/>
		<form action="#" method="get" accept-charset="utf-8"
		name="queryForm" onsubmit="return app.executeQuery(this.query.value);">
			<p><textarea name="query" rows="8" cols="40"></textarea></p>
			<p><input type="submit" value="Send"></p>
		</form>
		<p>Query: <span id="query"></span></p>
		<p><table id="table-results" style="visibility: hidden; width: 100%;"></table></p>
	</div>
	<div id="panel">
		<h3 id="database_info">Database info</h3>
		<hr/>
		<table style="visibility: hidden" id="db_info_table">
			<thead>
				<tr>
					<th>N</th>
					<th>TYPE</th>
					<th>NAME</th>
					<th>TBL_NAME</th>
				</tr>
			</thead>
			<tbody id="db_info"></tbody>
		</table>
	</div>
</body>
</html>