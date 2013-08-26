%	setdefault('__app_name__', 'carax')
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
		this.loadXMLDoc = function (url, loadHandler) {
			if (this.request) {
				this.request.open('GET', url, true);
				this.request.onreadystatechange = function() {loadHandler(me)};
				this.request.setRequestHeader("Content-Type", "text/xml");
				this.request.send("");
			}
		}
	};
	
	var app = new Object();
	
	function setDatabase(input) {
		var setdbReq = new Ajax();
		var ret;
		setdbReq.loadXMLDoc("/execute?db_path=" + input.value + 
		"&query=select type,name,tbl_name from sqlite_master", 
		function(req) {
			req = req.request;
			if (req.readyState === 4 && req.status === 200) {
				ret = eval('(' + req.responseText + ')');
				app.db_path = input.value;
				createDBInfoTable(ret.rows);
				document.queryForm.query.focus();
			}
		});
		return true;
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
	
	function tableCreate() {
		var body = document.getElementsByTagName('body')[0];
		var tbl = document.createElement('table');
		tbl.style.width = '100%';
		tbl.setAttribute('border','1');
		var tbdy = document.createElement('tbody');
		for (var i=0 ; i<3 ; i++) {
			var tr = document.createElement('tr');
			for (var j=0 ; j<2 ; j++) {
				if (i==2 && j==1) {
					break;
				} else {
					var td = document.createElement('td');
					td.appendChild(document.createTextNode('\u0020'));
					i==1 && j==1 ? td.setAttribute('rowSpan','2') : null;
					tr.appendChild(td)
				}
			}
			tbdy.appendChild(tr);
		}
		tbl.appendChild(tbdy);
		body.appendChild(tbl)
	}
	
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
	
	String.prototype.supplant = function (o) {
	    return this.replace(/{([^{}]*)}/g,
	        function (a, b) {
	            var r = o[b];
	            return typeof r === 'string' || typeof r === 'number' ? r : a;
	        }
	    );
	};
	
	function executeQuery(input) {
		var setdbReq = new Ajax();
		var ret;
		setdbReq.loadXMLDoc("/execute?db_path=" + app.db_path + 
		"&query=" + input.value, 
		function(req) {
			req = req.request;
			if (req.readyState === 4 && req.status === 200) {
				ret = eval('(' + req.responseText + ')');
				createTable(ret.rows);
				document.queryForm.query.focus();
			}
		});
		return true;
	};
	
	</script>
</head>
<body id="body" onload="document.database.path.focus();">
	<h1 id="gina">
		<a href="/">{{__app_name__}}—Your best friend, SQLite user!</a></h1>
	<div id="database">
		<form action="#" method="get" accept-charset="utf-8"
		name="database" onsubmit="return false;">
			<p>Database file path:
				<input type="text" name="path" value=""
				id="db_path" size=100 onchange="setDatabase(this);">
				<input type="submit" value="Set database"
				onclick="return false;">
			</p>
		</form>
	</div>
	<div id="main">
		<h3>Query:</h3>
		<hr/>
		<form action="execute" method="post" accept-charset="utf-8"
		name="queryForm">
			<p><textarea name="query" rows="8" cols="40"></textarea></p>
			<p><input type="submit" value="Send" onclick="return false;"></p>
		</form>
		<p>
		Query: <span id="query"></span>
		</p>
		<p>
		%if defined('rows'):
		<table>
			<tr>
				<th> </th>
				%for col in description:
				<th>{{col[0]}}</th>
				%end
			</tr>
			%for i, row in enumerate(rows):
			<tr>
				<td>{{i+1}}</td>
				%for col in row:
				<td>{{col}}</td>
				%end
			</tr>
			%end
		</table>
		%end
		</p>
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