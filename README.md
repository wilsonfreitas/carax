sequela
=======

A web interface for SQLite made on top of Bottlepy.

Editing:

	function createNavListLink(o) {
	  return Link(o.name, '#', function () {
	    alert(o.name + ' ' + o.sql);
	    $('#myTab a:last').tab('show');
	  }).getElement();
	}

To send table information to *Table info* panel.

## Sections

- Tables
- Indexes
- Views
- Queries

## Other areas

- Structure
	- Table
	- Index
	- View
	- Query
- Execute SQL
