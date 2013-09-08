var sequela = (function () {
    'use strict';


    function QueryResult(serverResult) {
        var i, that = {};
        that.query = serverResult.query;
        that.rows = serverResult.rows;
        that.colnames = new Array();
        for (i=0 ; i<serverResult.description.length ; i++) {
            that.colnames[that.colnames.length] = serverResult.description[i][0];
        }
        return that;
    };


    function Sequela() {
        var that = {};
        var wrapToQueryResult = function (callback) {
            return function (serverResult) {
                callback(new QueryResult(serverResult));
            };
        };
        that.execute = function (database, query, callback) {
            marajax.go({
                url: '/execute',
                params: { database: database, query: query },
                success: wrapToQueryResult(callback),
                output: 'json',
                post: true
            });
        };
        that.executeQuery = function (query, id) {
            query = query.replace(/\n/g, ' ');
            return app.execute(query, function(ret) {
                clearTable(id);
                createTable(ret.rows, ret.description, id);
                document.queryForm.query.focus();
            });
        };
        that.check = function (database, callback) {
            marajax.go({
                url: '/check',
                params: { database: database },
                success: callback,
                output: 'json',
            });
        };
        return that;
    };
    
    return {
        create: function() {
            return new Sequela();
        }
    };
})();
