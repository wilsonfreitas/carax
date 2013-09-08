
describe("Sequela", function() {
    var seq, res;
    
    var catchResponse = function() {
      return function(obj) {
        res.value = obj;
      };
    };
    
    beforeEach(function() {
        seq = sequela.create();
        res = {};
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
            waitsFor(function() { return typeof res.value !== 'undefined'; });
            runs(function() {
                expect(res.value).toEqual(true);
            });
        });

        it("it should check the database (it doesn't exist)", function() {
            seq.check('doesntexist.db', catchResponse());
            waitsFor(function() { return typeof res.value !== 'undefined'; });
            runs(function() {
                expect(res.value).toEqual(false);
            });
        });
        
    });
    
    
    describe("execute", function() {
        
        it("it should execute a query in the database", function () {
            var q = 'select type,name,sql from sqlite_master';
            seq.execute('test.db', q, catchResponse());
            waitsFor(function() { return typeof res.value !== 'undefined'; });
            runs(function() {
                console.log(res.value);
                expect(res.value.query).toEqual(q);
                expect(res.value.rows.length).toEqual(1);
                expect(res.value.colnames.length).toEqual(3);
                expect(res.value.colnames[0]).toEqual('type');
                expect(res.value.colnames[1]).toEqual('name');
                expect(res.value.colnames[2]).toEqual('sql');
            });
        });
        
    });

});
