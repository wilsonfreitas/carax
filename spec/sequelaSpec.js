describe("Marajax", function() {
  it("format query string", function() {
    var q = marajax.queryString({ param: "param1" });
    expect(q).toEqual("param=param1&");
    q = marajax.queryString({ param1: "param1", param2: 2 });
    expect(q).toEqual("param1=param1&param2=2&");
  });
  
  it("it should execute GET", function() {
    marajax.get({
      url: "/test",
      success: function(obj) {
        expect(obj).toEqual("true");
        expect(typeof obj).toEqual("string");
      },
      output: 'text'
    });
    marajax.get({
      url: "/test",
      success: function(obj) {
        expect(obj).toEqual(true);
        expect(typeof obj).toEqual("boolean");
      },
      output: 'json'
    });
    marajax.get({
      url: "/test",
      success: function(obj) {
        expect(obj).toEqual(null);
        expect(typeof obj).toEqual("object");
      },
      output: 'xml'
    });
  });

  it("it should execute POST", function() {
    marajax.post({
      url: "/test",
      success: function(obj) {
        expect(typeof obj).toEqual("object");
        expect(obj.param).toEqual('1');
        expect(obj.age).toEqual(37);
        expect(obj.name).toEqual('wilson freitas\ntestando');
      },
      output: 'json',
      params: { param1: 1, name: 'wilson freitas\ntestando' }
    });
  });

  it("it should go", function () {
    expect(function () {
      marajax.go({ });
    }).toThrow("URL must be provided in order to execute a request.");
  });

  it("it should fail on excuting GET", function() {
    marajax.get({
      url: "/testerror",
      fail: function(obj) {
        expect(obj.state).toEqual(4);
        expect(obj.status).toEqual(404);
        expect(obj.statusText).toEqual('Not Found');
        expect(typeof obj).toEqual("object");
      }
    });
  });

  it("it should fail on executing POST", function() {
    marajax.post({
      url: "/ie",
      fail: function(obj) {
        expect(obj.state).toEqual(4);
        expect(obj.status).toEqual(500);
        expect(obj.statusText).toEqual('Internal Server Error');
        expect(typeof obj).toEqual("object");
      },
    });
  });

  // describe("when song has been paused", function() {
  //   beforeEach(function() {
  //     player.play(song);
  //     player.pause();
  //   });
  // 
  //   it("should indicate that the song is currently paused", function() {
  //     expect(player.isPlaying).toBeFalsy();
  // 
  //     // demonstrates use of 'not' with a custom matcher
  //     expect(player).not.toBePlaying(song);
  //   });
  // 
  //   it("should be possible to resume", function() {
  //     player.resume();
  //     expect(player.isPlaying).toBeTruthy();
  //     expect(player.currentlyPlayingSong).toEqual(song);
  //   });
  // });
  // 
  // // demonstrates use of spies to intercept and test method calls
  // it("tells the current song if the user has made it a favorite", function() {
  //   spyOn(song, 'persistFavoriteStatus');
  // 
  //   player.play(song);
  //   player.makeFavorite();
  // 
  //   expect(song.persistFavoriteStatus).toHaveBeenCalledWith(true);
  // });
  // 
  // //demonstrates use of expected exceptions
  // describe("#resume", function() {
  //   it("should throw an exception if song is already playing", function() {
  //     player.play(song);
  // 
  //     expect(function() {
  //       player.resume();
  //     }).toThrow("song is already playing");
  //   });
  // });
});


// var request;
// var queryString;   //will hold the POSTed data
// function sendData(  ){
//     setQueryString(  );
//     var url="http://www.parkerriver.com/s/sender";
//     httpRequest("POST",url,true);
// }
// 
// /* Initialize a request object that is already constructed.
//  Parameters:
//    reqType: The HTTP request type, such as GET or POST.
//    url: The URL of the server program.
//    isAsynch: Whether to send the request asynchronously or not. */
// function initReq(reqType,url,isAsynch){
//     /* Specify the function that will handle the HTTP response */
//     request.onreadystatechange=handleResponse;
//     request.open(reqType,url,isAsynch);
//     /* Set the Content-Type header for a POST request */
//     request.setRequestHeader("Content-Type",
//             "application/x-www-form-urlencoded; charset=UTF-8");
//     request.send(queryString);
// }
// 
// function setQueryString(  ){
//     queryString="";
//     var frm = document.forms[0];
//     var numberElements =  frm.elements.length;
//     for(var i = 0; i < numberElements; i++) {
//         if(i < numberElements-1) {
//             queryString += frm.elements[i].name+"="+
//                            encodeURIComponent(frm.elements[i].value)+"&";
//         } else {
//             queryString += frm.elements[i].name+"="+
//                            encodeURIComponent(frm.elements[i].value);
//         }
// 
//     }
// }
// 
// /* Wrapper function for constructing a request object.
//  Parameters:
//   reqType: The HTTP request type, such as GET or POST.
//   url: The URL of the server program.
//   asynch: Whether to send the request asynchronously or not. */
//   
// function httpRequest(reqType,url,asynch){
//     //Mozilla-based browsers
//     if(window.XMLHttpRequest){
//         request = new XMLHttpRequest(  );
//     } else if (window.ActiveXObject){
//         request=new ActiveXObject("Msxml2.XMLHTTP");
//         if (! request){
//             request=new ActiveXObject("Microsoft.XMLHTTP");
//         }
//     }
//     //the request could still be null if neither ActiveXObject
//     //initialization succeeded
//     if(request){
//         initReq(reqType,url,asynch);
//     } else {
//         alert("Your browser does not permit the use of all "+
//               "of this application's features!");
//     }
// }
