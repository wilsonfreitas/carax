
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

    it("it should call check the database", function() {
        seq.check('test.db', catchResponse());
        waitsFor(function() {
            return typeof res.value !== 'undefined';
        });
        runs(function() {
            expect(res.value).toEqual(true);
        });
    });

});
