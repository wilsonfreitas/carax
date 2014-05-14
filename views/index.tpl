%	setdefault('__app_name__', 'Sequela')
%	setdefault('__app_desc__', 'a minimalistic SQLite frontend')
<!DOCTYPE html>
<html lang="en">
<head>
	<title>{{__app_name__}}—{{__app_desc__}}</title>
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<meta name="description" content="">
	<meta name="author" content="">
	<!-- Bootstrap -->
	<!-- <link href="/static/css/bootstrap.css" rel="stylesheet"> -->
	<!-- <link href="/static/css/bootstrap-responsive.css" rel="stylesheet"> -->
	<link href="http://netdna.bootstrapcdn.com/bootswatch/3.1.1/simplex/bootstrap.min.css" rel="stylesheet">
	<!-- <link href="http://netdna.bootstrapcdn.com/bootswatch/3.1.1/cyborg/bootstrap.min.css" rel="stylesheet"> -->
	<link href='http://fonts.googleapis.com/css?family=Petit+Formal+Script' rel='stylesheet' type='text/css'>
	<link href="/static/css/local.css" rel="stylesheet">
</head>

<body>
<nav class="navbar navbar-default navbar-static-top" role="navigation">
	<div class="container">
		<div class="navbar-header">
			<button type="button" class="navbar-toggle" data-toggle="collapse" data-target="#bs-example-navbar-collapse-1">
				<span class="sr-only">Toggle navigation</span>
				<span class="icon-bar"></span>
				<span class="icon-bar"></span>
				<span class="icon-bar"></span>
			</button>
			<a class="navbar-brand" href="/"><span style="font-family:'Petit Formal Script';">{{ __app_name__ }}</span></a>
		</div>
		<div class="collapse navbar-collapse">
			<form class="navbar-form" name="database">
				<div class="form-group">
					<label for="path" class="control-label sr-only">Select database</label>
					<input type="text" class="form-control" id="path" name="database">
				</div>
				<button class="btn btn-primary">Connect to database</button>
			</form>
			<!-- <ul class="nav navbar-nav navbar-left">
				<li><a href="#about">About</a></li>
				<li><a href="#contact">Contact</a></li>
			</ul> -->
		</div>
	</div>
</nav>
<div class="container">
	<div class="row" id="message">
	</div>
	<div class="row">
		<div class="col-md-3 column">
			<h4>Database info</h4>
			<div id='database-info'></div>
		</div>
		<div class="col-md-9 column">
			<div class="tabbable"> <!-- Only required for left/right tabs -->
				<ul class="nav nav-tabs" id="myTab">
					<li><a href="#tab1" data-toggle="tab">Execute SQL</a></li>
					<li><a href="#tab2" data-toggle="tab">Table info</a></li>
				</ul>
				<div class="tab-content">
					<div class="tab-pane" id="tab1">
						<div class="row">
							<!-- <h4>SQL statements:</h4> -->
							<select class="col-md-12 column form-control" id="history"></select>
							<form name="executeQuery">
								<input type="hidden" name="database" value="" id="database">
								<textarea class="form-control" name="sqlCode" id="sql-code" rows="5" placeholder="Enter SQL code here!"></textarea>
								<button type="submit" class="btn btn-block btn-large btn-primary" id="execute-sql">
									Execute SQL</button>
							</form>
						</div>
						<div class="row">
							<h4>Results:</h4>
							<div id="query-results">
							</div>
						</div>
					</div>
					<div class="tab-pane" id="tab2">
						<div class="row" id='table-info'>
							<!-- table-info: information about table structure -->
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
</div> <!-- /container -->

<script type="text/javascript" src="http://code.jquery.com/jquery.js"></script>
<script type="text/javascript" src="/static/js/bootstrap.min.js"></script>
<script type="text/javascript" src="/static/js/marajax.js"></script>
<script type="text/javascript" src="/static/js/sequela.js"></script>
<script type="text/javascript" charset="utf-8">
// The following statement sets the first tab to appear.
// 
$('#myTab a').click(function (e) {
	e.preventDefault()
	$(this).tab('show')
});

$('#myTab a:first').tab('show');

// $(function () {
// 	$('#myTab li:eq(0) a').tab('show');
// });
  
// function to check if the given parameter is an element or the element's id
//
function checkElement(elm) {
	if (typeof elm === 'string') elm = document.getElementById(elm);
	return elm;
}

// function to define the action of an element
//
function setAction(elm, action, func) {
	elm = checkElement(elm);
	elm[action] = func;
}

function cleanElement(elm) {
	elm = checkElement(elm);
	while (elm.hasChildNodes()) {
		elm.removeChild(elm.lastChild);
	}
}

function replaceWithContent(elm, content) {
	elm = checkElement(elm);
	cleanElement(elm);
	elm.appendChild(content);
}

// Start by focusing the form where the database's path is defined.
// 
setAction(window, 'onload', function () {
	document.getElementById('path').focus();
});

// Define onsubmit the database call
// 
setAction(document.database, "onsubmit", function () {
	var pathElement = this.path, dbi = checkDatabase({
		database: this.path.value,
		success: function () {
			var entities = {};
			dbi.entities.forEach(function (o) {
				if (typeof entities[o.type] === 'undefined') {
					entities[o.type] = [o];
				} else {
					entities[o.type].push(o);
				}
			});
			cleanElement(document.getElementById('message'));
			var navList = new NavList(entities, createNavListLink);
			replaceWithContent('database-info', navList.getElement());
			document.executeQuery.database.value = dbi.database;
			document.executeQuery.sqlCode.focus();
		},
		fail: function () {
			var div = document.createElement('div');
			div.className = "alert alert-error";
			div.innerHTML = '<button type="button" class="close" data-dismiss="alert">&times;</button>'
			+ "<strong>Error!</strong> The given path is invalid: "
			+ dbi.database;
			replaceWithContent(document.getElementById('message'), div);
			pathElement.focus();
		}
	});
	return false;
});

// Execute SQL / Send SQL to database
//
setAction(document.executeQuery, "onsubmit", function () {
	var query = this.sqlCode.value,
	database = this.database.value;
	sequela.execute(database, query, function (qr) {
		if (qr.error) {
			var div = document.createElement('div');
			div.className = "alert alert-error";
			div.innerHTML = '<button type="button" class="close" data-dismiss="alert">&times;</button>'
			+ "<strong>Error!</strong> "
			+ qr.error;
			replaceWithContent('message', div);
		} else if (qr.colnames !== null && qr.rows !== null) {
			var table = sequela.createTable('table-query-results', 'table table-hover table-bordered table-condensed'),
			history = document.getElementById('history'),
			option = document.createElement('option');
			table.addContent(qr);
			replaceWithContent('query-results', table.getElement());
			option.innerHTML = qr.query;
			option.selected = 'selected';
			history.appendChild(option);
		} else {
			cleanElement('query-results');
		}
	});
	this.sqlCode.focus();
	return false;
});

// Define onchange action
//
setAction('history', 'onchange', function () {
	document.executeQuery.sqlCode.value += this.options[this.selectedIndex].text;
});

// Functions
//
function DescriptionList(content) {
	var that = {}, dt, dd,
	dl = document.createElement('dl');

	content.forEach(function (o) {
		var dt = document.createElement('dt'), dd = document.createElement('dd');
		decorate = o.decorate || identity;
		dt.appendChild(document.createTextNode(o.label));
		dd.appendChild(decorate(document.createTextNode(o.text)));
		dl.appendChild(dt);
		dl.appendChild(dd);
	});

	that.getElement = function () {
		return dl;
	};
	return that;
}

function TableInfoDiv(tableInfo) {
	var that = {}, div = document.createElement('div');
	div.className = 'well';
	div.appendChild(DescriptionList([
		{ label: 'Name:', text: tableInfo.name },
		{ label: 'Type:', text: tableInfo.type },
		{ label: 'SQL:', text: tableInfo.sql , decorate: function (e) {
			var pre = document.createElement('pre');
			pre.appendChild(e);
			return pre;
		}},
		]).getElement());
		that.getElement = function () {
			return div;
		}
		return that;
	}

	function NavList(entities, createLink) {
		var that = {}, i, j, inEl,
		list = document.createElement('ul');
		createLink = createLink || function (x) {
			return document.createTextNode(x);
		};
		list.className = 'nav nav-list';

		for (i in entities) {
			inEl = document.createElement('li');
			inEl.className = 'nav-header';
			inEl.innerHTML = i;
			list.appendChild(inEl);
			entities[i].forEach(function (o) {
				inEl = document.createElement('li');
				inEl.appendChild(createLink(o));
				list.appendChild(inEl);
			});
		}

		that.getElement = function () {
			return list;
		};

		return that;
	}

	function Link(text, href, onclick) {
		var that = {},
		a = document.createElement('a');
		a.href = href;
		a.onclick = onclick;
		a.title = text;
		a.appendChild(document.createTextNode(text));
		that.getElement = function () {
			return a;
		};
		return that;
	}

	function createNavListLink(o) {
		return Link(o.name, '#', function () {
			replaceWithContent('table-info', TableInfoDiv(o).getElement());
			$('#myTab li:eq(1) a').tab('show');
		}).getElement();
	}

	var checkDatabase = function checkDatabase(o) {
		var dbi = sequela.createDatabaseInfo(o.database);
		when(dbi.checked, o.success, o.fail);
		return dbi;
	}

	function when(pred, success, fail, counter) {
		counter = counter || 0;
		counter += 1;
		window.setTimeout(function () {
			if (pred()) {
				success();
			} else {
				if (counter == 100) {
					fail();
				}
				when(pred, success, fail, counter);
			}
		}, 10);
	}

	String.prototype.supplant = function (o) {
		return this.replace(/{([^{}]*)}/g,
		function (a, b) {
			var r = o[b];
			return typeof r === 'string' || typeof r === 'number' ? r : a;
		}
	);
}

Array.prototype.unique = function() {
	var o = {}, i, l = this.length, r = [];
	for(i=0; i<l;i+=1) o[this[i]] = this[i];
	for(i in o) r.push(o[i]);
	return r;
};

var identity = function identity(x) {
	return x;
};

// return (function () { alert(this.path.value); return false; }());
</script>