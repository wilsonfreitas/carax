
describe("Sequela", function() {
    var seq, res;


    var catchResponse = function() {
      return function(obj) {
        res = obj;
      };
    };


    beforeEach(function() {
        seq = sequela.createSequela();
        res = null;
    });


    describe("check", function() {


        it("it should call the callback function to check database", function() {
            var callback = jasmine.createSpy();
            seq.check(null, callback);
            waitsFor(function() { return callback.callCount > 0; });
            runs(function() {
                expect(callback).toHaveBeenCalled();
            });
        });


        it("it should check the database (it exists)", function() {
            seq.check('test.db', catchResponse());
            waitsFor(function() { return res !== null; });
            runs(function() {
                expect(res).toEqual(true);
            });
        });


        it("it should check the database (it doesn't exist)", function() {
            seq.check('doesntexist.db', catchResponse());
            waitsFor(function() { return res !== null; });
            runs(function() {
                expect(res).toEqual(false);
            });
        });
        
    });


    describe("execute", function() {


        it("it should execute a query in the database", function () {
            var q = 'select type,name,sql from sqlite_master';
            seq.execute('test.db', q, catchResponse());
            waitsFor(function() { return res !== null; });
            runs(function() {
                expect(res.query).toBeDefined();
                expect(res.query).toEqual(q);
                expect(res.rows.length).toEqual(1);
                expect(res.description.length).toEqual(3);
                expect(res.description[0][0]).toEqual('type');
                expect(res.description[1][0]).toEqual('name');
                expect(res.description[2][0]).toEqual('sql');
                expect(res.error).toBeDefined();
                expect(res.error).toBeNull();
            });
        });


        it("it should execute a query and the result should be wrapped by QueryResult", function () {
            var q = 'select type,name,sql from sqlite_master';
            var seq = sequela.createSequela(sequela.createQueryResult)
            seq.execute('test.db', q, catchResponse());
            waitsFor(function() { return res !== null; });
            runs(function() {
                expect(res.query).toBeDefined();
                expect(res.query).toEqual(q);
                expect(res.rows.length).toEqual(1);
                expect(res.colnames.length).toEqual(3);
                expect(res.colnames[0]).toEqual('type');
                expect(res.colnames[1]).toEqual('name');
                expect(res.colnames[2]).toEqual('sql');
                expect(res.error).toBeDefined();
                expect(res.error).toBeNull();
            });
        });


        it("it should execute an invalid query in the database", function () {
            var q = 'select * from blah';
            seq.execute('test.db', q, catchResponse());
            waitsFor(function() { return res !== null; });
            runs(function() {
                expect(res.query).toEqual(q);
                expect(res.rows).toBeNull();
                expect(res.description).toBeNull();
                expect(res.colnames).toBeUndefined();
                expect(res.error).toEqual('no such table: blah');
            });
        });


    });


    describe("QueryResult", function () {


        it('it should create a successful query result', function () {
            var res = {
                query: "select",
                rows: [[1,2,3],[4,5,6]],
                description: [ ['a',0], ['b',0], ['c', 0] ],
                error: null
            };
            var qr = sequela.createQueryResult(res);
            expect(qr.query).toEqual('select');
            expect(qr.rows[0][0]).toEqual(1);
            expect(qr.rows[1]).toEqual([4,5,6]);
            expect(qr.colnames[0]).toEqual('a');
            expect(qr.error).toEqual(null);
        });


        it('it should create a failing query result', function () {
            var res = {
                query: "select",
                rows: null,
                description: null,
                error: 'error'
            };
            var qr = sequela.createQueryResult(res);
            expect(qr.query).toEqual('select');
            expect(qr.rows).toEqual(null);
            expect(qr.colnames).toEqual(null);
            expect(qr.error).toEqual('error');
        });


    });

});
