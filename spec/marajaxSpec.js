describe("Marajax", function() {
    it("it should call falsely the success function", function() {
        spyOn(marajax, 'go')
            .andCallFake(function(e) {
            e.success("true");
        });
        marajax.go({
            url: "/test",
            success: function(obj) {
                expect(obj)
                    .toEqual("true");
                expect(typeof obj)
                    .toEqual("string");
            }
        });
    });

    it("it should format a query string", function() {
        var q = marajax.queryString({
            param: "param1"
        });
        expect(q)
            .toEqual("param=param1&");
        q = marajax.queryString({
            param1: "param1",
            param2: 2
        });
        expect(q)
            .toEqual("param1=param1&param2=2&");
    });

    it("it should run success for responseProcessor (text)", function() {
        var ajax = new marajax.Marajax();
        ajax.request = {
            readyState: 4,
            status: 200,
            responseText: 'true',
        };
        ajax.responseProcessor({
            output: 'text',
            success: function(obj) {
                expect(obj)
                    .toEqual("true");
                expect(typeof obj)
                    .toEqual("string");
            }
        })();
    });

    it("it should run success for responseProcessor (json)", function() {
        var ajax = new marajax.Marajax();
        ajax.request = {
            readyState: 4,
            status: 200,
            responseText: 'true',
        };
        ajax.responseProcessor({
            output: 'json',
            success: function(obj) {
                expect(obj)
                    .toEqual(true);
                expect(typeof obj)
                    .toEqual("boolean");
            }
        })();
    });

    it("it should run success for responseProcessor (xml)", function() {
        var ajax = new marajax.Marajax();
        var p = document.createElement('p');
        p.innerHTML = 'true';
        ajax.request = {
            readyState: 4,
            status: 200,
            responseText: p.outerHTML,
            responseXML: p
        };
        ajax.responseProcessor({
            output: 'text',
            success: function(obj) {
                expect(obj)
                    .toEqual('<p>true</p>');
                expect(typeof obj)
                    .toEqual("string");
            }
        })();
        ajax.responseProcessor({
            output: 'xml',
            success: function(obj) {
                expect(typeof obj)
                    .toEqual("object");
                expect(obj.innerHTML)
                    .toEqual("true");
            }
        })();
    });

    it("it should run fail for responseProcessor (Error404)", function() {
        var ajax = new marajax.Marajax();
        ajax.request = {
            readyState: 4,
            status: 404,
            statusText: 'Not Found'
        };
        ajax.responseProcessor({
            fail: function(obj) {
                expect(obj.state)
                    .toEqual(4);
                expect(obj.status)
                    .toEqual(404);
                expect(obj.statusText)
                    .toEqual('Not Found');
                expect(typeof obj)
                    .toEqual("object");
            }
        })();
    });

    it("it should run fail for responseProcessor (Error500)", function() {
        var ajax = new marajax.Marajax();
        ajax.request = {
            readyState: 4,
            status: 500,
            statusText: 'Internal Server Error'
        };
        ajax.responseProcessor({
            fail: function(obj) {
                expect(obj.state)
                    .toEqual(4);
                expect(obj.status)
                    .toEqual(500);
                expect(obj.statusText)
                    .toEqual('Internal Server Error');
                expect(typeof obj)
                    .toEqual("object");
            }
        })();
    });

    it("it shouldn't run callback inside responseProcessor", function() {
        var callback = jasmine.createSpy();
        var ajax = new marajax.Marajax();
        ajax.request = {
            readyState: 1
        };
        ajax.responseProcessor({
            fail: callback
        })();
        expect(callback)
            .not.toHaveBeenCalled();
    });
});

describe("Marajax asynchronous integration", function() {
    var catchResponse = function(res) {
        return function(obj) {
            res.value = obj;
            res.type = typeof obj;
        };
    };

    it("it should execute asynchronous call", function() {
        var callback = jasmine.createSpy();
        marajax.go({
            url: "/test",
            success: callback,
        });
        waitsFor(function() {
            return callback.callCount > 0;
        });
        runs(function() {
            expect(callback)
                .toHaveBeenCalled();
        });
    });

    it("it should raise an exception for missing URL", function() {
        expect(function() {
            marajax.go({});
        })
            .toThrow("URL must be provided in order to execute a request.");
    });

    it("it should GO asynchronously, text response", function() {
        var res = {};
        marajax.go({
            url: "/test",
            success: catchResponse(res),
            output: 'text'
        });
        waitsFor(function() {
            return typeof res.value !== 'undefined';
        });
        runs(function() {
            expect(res.value)
                .toEqual('true');
            expect(res.type)
                .toEqual("string");
        });
    });

    it("it should GO asynchronously, json response", function() {
        var res = {};
        marajax.go({
            url: "/test",
            success: catchResponse(res),
            output: 'json'
        });
        waitsFor(function() {
            return typeof res.value !== 'undefined';
        });
        runs(function() {
            expect(res.value)
                .toEqual(true);
            expect(res.type)
                .toEqual("boolean");
        });
    });

    it("it should GO asynchronously, GET with parameters", function() {
        var res = {};
        marajax.go({
            url: "/testparams",
            success: catchResponse(res),
            params: {
                param1: 1,
                name: 'wilson freitas\ntestando'
            },
            output: 'json'
        });
        waitsFor(function() {
            return typeof res.value !== 'undefined';
        });
        runs(function() {
            expect(res.value.age)
                .toEqual(37);
            expect(res.value.param)
                .toEqual("1");
            expect(res.value.name)
                .toEqual("wilson freitas\ntestando");
            expect(res.type)
                .toEqual("object");
        });
    });

    it("it should GO asynchronously, json response (spy)", function() {
        var callback = jasmine.createSpy();
        var res = {};
        marajax.go({
            url: "/test",
            success: function(obj) {
                callback();
                res.value = obj;
                res.type = typeof obj;
            },
            output: 'json'
        });
        waitsFor(function() {
            return callback.callCount > 0;
        });
        runs(function() {
            expect(callback)
                .toHaveBeenCalled();
            expect(res.value)
                .toEqual(true);
            expect(res.type)
                .toEqual("boolean");
        });
    });

    it("it should GO asynchronously, xml response", function() {
        var res = {};
        marajax.go({
            url: "/testxml",
            success: catchResponse(res),
            output: 'xml'
        });
        waitsFor(function() {
            return typeof res.value !== 'undefined';
        });
        runs(function() {
            expect(res.value.childNodes.length)
                .toEqual(1);
            expect(res.value.childNodes[0].tagName)
                .toEqual('span');
            expect(res.value.childNodes[0].firstChild.nodeValue)
                .toEqual('true');
            expect(res.type)
                .toEqual("object");
        });
    });

    it("it should GO asynchronously, with POST method", function() {
        var res = {};
        marajax.go({
            url: "/test",
            success: catchResponse(res),
            post: true,
            output: "json",
            params: {
                param1: 1,
                name: 'wilson freitas\ntestando'
            }
        });
        waitsFor(function() {
            return typeof res.value !== 'undefined';
        });
        runs(function() {
            expect(res.type)
                .toEqual("object");
            expect(res.value.param)
                .toEqual("1");
            expect(res.value.age)
                .toEqual(37);
            expect(res.value.name)
                .toEqual('wilson freitas\ntestando');
        });
    });

    it("it should fail on excuting GO, with GET method (Error404)", function() {
        var res = {};
        marajax.go({
            url: "/testerror",
            fail: catchResponse(res)
        });
        waitsFor(function() {
            return typeof res.value !== 'undefined';
        });
        runs(function() {
            expect(res.value.state)
                .toEqual(4);
            expect(res.value.status)
                .toEqual(404);
            expect(res.value.statusText)
                .toEqual('Not Found');
            expect(res.type)
                .toEqual("object");
        });
    });

    it("it should fail on executing GO, with POST method (Error500)", function() {
        var res = {};
        marajax.go({
            url: "/ie",
            post: true,
            fail: catchResponse(res)
        });
        waitsFor(function() {
            return typeof res.value !== 'undefined';
        });
        runs(function() {
            expect(res.value.state)
                .toEqual(4);
            expect(res.value.status)
                .toEqual(500);
            expect(res.value.statusText)
                .toEqual('Internal Server Error');
            expect(res.type)
                .toEqual("object");
        });
    });

    it("it should fail on executing GO, with POST method (Error405)", function() {
        var res = {};
        marajax.go({
            url: "/ie",
            fail: catchResponse(res)
        });
        waitsFor(function() {
            return typeof res.value !== 'undefined';
        });
        runs(function() {
            expect(res.value.state)
                .toEqual(4);
            expect(res.value.status)
                .toEqual(405);
            expect(res.value.statusText)
                .toEqual('Method Not Allowed');
            expect(res.type)
                .toEqual("object");
        });
    });

});
