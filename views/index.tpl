%	setdefault('__app_name__', 'sequela')
%	setdefault('__app_desc__', 'a minimalistic SQLite frontend')
<html>
<head>
	<meta http-equiv="Content-type" content="text/html; charset=utf-8">
	<title>{{__app_name__}}—{{__app_desc__}}</title>
	<link href="/static/css/sequela.css" rel="stylesheet" media="screen">
	<!-- <link href="/static/css/bootstrap.min.css" rel="stylesheet" media="screen"> -->
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
				<p id="table-info"></p>
		    <span class="float-divider"></span></div></div>

		  <div id="pragma"><div class="oi2">
				<p><table style="visibility: hidden"
				id="table-info-pragma" class="database-results">
				</table></p>
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
  <script src="/static/js/sequela.js"></script>
  <!-- // <script src="/static/js/bootstrap.min.js"></script> -->
</body>
</html>