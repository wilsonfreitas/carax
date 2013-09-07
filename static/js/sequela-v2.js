var sequela = (function() {
    'use strict';

    function Sequela() {
        var that = {};
        that.database = null;
        that.execute = function(query, contentHandler, async) {
            async = async || true;
            var setdbReq = new Ajax();
            var qs = "/execute?query={query}&database={database};".supplant({
                'query': query,
                'database': that.database
            });
            setdbReq.loadJSON(qs, function(ret) {
                contentHandler(ret)
            }, async);
            return false;
        };
        that.executeQuery = function(query, id) {
            query = query.replace(/\n/g, ' ');
            return app.execute(query, function(ret) {
                clearTable(id);
                createTable(ret.rows, ret.description, id);
                document.queryForm.query.focus();
            });
        };
        that.check = function(database, callback) {
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
