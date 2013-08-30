%	setdefault('__app_name__', 'sequela')
%	setdefault('__app_desc__', 'a minimalistic SQLite frontend')
<html>
<head>
	<meta http-equiv="Content-type" content="text/html; charset=utf-8">
	<title>{{__app_name__}}—{{__app_desc__}}</title>
	<style type="text/css" media="screen">	
	body { font-family: sans-serif; font-size: 90%; }
	a {	color: black; text-decoration: none; }
	a:hover { color: red; text-decoration: underline; }
	hr { border: 0px solid black;}
	p { padding: 0; margin: 0; border: 0; }
	textarea { width: 100%; height: 65%; font-size: 120%;}
	h3 {font-size: 90%;}
	table { table-collapse: collapse; border-spacing: 1px; font-size: 80%; background: black; margin: 2px;}
	td {border: 0px solid black; padding: 3px; background-color: white;}
	th {border: 0px solid black; padding: 3px; background-color: grey; color: white;}
	/*	.database-results { font-size: 70%;}*/
	.first-col-head, .first-col-body { text-align: center; background: grey; color: white;}
	.float-divider { clear:both; display:block;
	  height:1px; font-size:1px; line-height:1px; }
	.oi1 { margin:0; padding:2px; }
	.oi2 { margin:5px; padding:5px; }
	#main { width: 100%; }
	
	#nav { float:left; width:30%; min-width:75px; }
	#content { float:left; width:70%; min-width:150px; }
	#nav .oi2 { height: 200px;}
	#content .oi2 { overflow: auto; height: 200px;}

	#nav2 { float:left; width:40%; height: 300px; }
	#content2 { float:left; width:60%; height: 300px;}
	#nav2 .oi2 { overflow: auto; height: 100%;}
	#content2 .oi2 { overflow: auto; height: 100%;}

	#path { width: 100%;}
	#header { margin:7px; padding:5px;}
	#title  { float:left;  min-width:280px; max-width:500px; margin-left:0; }
	#search { float:right; min-width:280px; width:50%; margin-right:0; }
	</style>
</head>
<body id="body" onload="document.database.database.focus();">
	<div id="header">
		<h1 id="title" style="margin: 0; padding: 0;"><a href="/">{{__app_name__}}</a>
			<br><span style="font-size: 60%;">{{__app_desc__}}</span></h1>
		<!--  -->
		<div id="search"> <h3 style="margin: 0; padding: 0;">Database:</h3>
			<form action="#" method="get" accept-charset="utf-8"
			name="database" onsubmit="return app.check(this.path.value);">
				<input type="text" name="database" value="" id="path">
					<input type="submit" value="Check database">
			</form>
	  </div>
	  <div class="float-divider"></div>
	</div>

	<div id="main">
		<div class="oi1">
		  <div id="nav"><div class="oi2">
				<h3 id="database_info">Database info</h3>
				<p style="overflow: auto; height: 155px;">
					<table style="visibility: hidden"
				id="database-info" class="database-results">
				</table></p>
			</div></div>

		  <div id="content"><div class="oi2">
		    <span class="float-divider"></span></div></div>
		  <div class="float-divider"></div>
		</div>
	</div>

	<hr/>

	<div id="main"><div class="oi1">
	  <div id="nav2"><div class="oi2"> <h3>Execute query</h3>
			<form action="#" method="get" accept-charset="utf-8"
			name="queryForm" onsubmit="return app.executeQuery(this.query.value, 'table-results');">
				<p><textarea name="query" rows="8" cols="40"></textarea></p>
				<p><input type="submit" value="Send"></p>
			</form>
		</div></div>
	  <div id="content2"><div class="oi2"> <h3>Query results</h3>
			<p><table id="table-results" class="database-results" style="visibility: hidden;"></table></p>
	    <span class="float-divider"></span></div></div>
	  <div class="float-divider"></div></div>
	</div>

	<!-- END of the page -->
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
					var q = 'select type,name,tbl_name,sql from sqlite_master';
					that.execute(q, function (ret) {
						// createDBInfoTable(ret.rows);
						clearTable('database-info');
						createTable(ret.rows, ret.description, 'database-info');
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
	</script>
</body>
</html>