
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
            waitsFor(function() {
                return callback.callCount > 0;
            });
            runs(function() {
                expect(callback).toHaveBeenCalled();
            });
        });

        it("it should check the database (it exists)", function() {
            seq.check('test.db', catchResponse());
            waitsFor(function() {
                return typeof res.value !== 'undefined';
            });
            runs(function() {
                expect(res.value).toEqual(true);
            });
        });

        it("it should check the database (it doesn't exist)", function() {
            seq.check('doesntexist.db', catchResponse());
            waitsFor(function() {
                return typeof res.value !== 'undefined';
            });
            runs(function() {
                expect(res.value).toEqual(false);
            });
        });
    });

});
