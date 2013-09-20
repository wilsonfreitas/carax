var sequela = (function () {
    'use strict';


    function QueryResult(serverResult) {
        var i, that = {};
        that.query = serverResult.query;
        that.rows = serverResult.rows;
        that.colnames = null;
        that.error = serverResult.error;
        if (serverResult.description !== null) {
            that.colnames = [];
            for (i = 0; i < serverResult.description.length; i += 1) {
                that.colnames[that.colnames.length] = serverResult.description[i][0];
            }
        }
        return that;
    }

    var identity = function identity(x) {
        return x;
    }, createQueryResult = function createQueryResult(result) {
        return new QueryResult(result);
    };

    function Sequela(resultWraper) {
        resultWraper = resultWraper || identity;
        var that = {},
            wrapToQueryResult = function (callback) {
                return function (serverResult) {
                    callback(resultWraper(serverResult));
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
        that.check = function (database, callback) {
            marajax.go({
                url: '/check',
                params: { database: database },
                success: callback,
                output: 'json'
            });
        };
        return that;
    }

    return {
        createSequela: function (qrFactory) {
            return new Sequela(qrFactory);
        },
        createQueryResult: createQueryResult
    };
}());
