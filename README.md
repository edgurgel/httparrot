# HTTParrot [![Build Status](https://travis-ci.org/edgurgel/httparrot.png?branch=master)](https://travis-ci.org/edgurgel/httparrot)

http://httpbin.org clone

## Endpoints

* / This page.
* /ip Returns Origin IP.
* /user-agent Returns user-agent.
* /headers Returns header dict.
* /get Returns GET data.
* /post Returns POST data.
* /put Returns PUT data.
* /patch Returns PATCH data.
* /delete Returns DELETE data
* /gzip Returns gzip-encoded data.
* /status/:code Returns given HTTP Status code.
* /response-headers?key=val Returns given response headers.
* /redirect/:n 301 Redirects n times.
* /redirect-to?url=foo 301 Redirects to the foo URL.
* /relative-redirect/:n 301 Relative redirects n times.
* /cookies Returns cookie data.
* /cookies/set?name=value Sets one or more simple cookies.
* /cookies/set/name/value Sets one cookie .
* /cookies/delete?name Deletes one or more simple cookies.
* /basic-auth/:user/:passwd Challenges HTTPBasic Auth.
* /hidden-basic-auth/:user/:passwd 404'd BasicAuth.
* /digest-auth/:qop/:user/:passwd Challenges HTTP Digest Auth.
* /stream/:n Streams n–100 lines.
* /delay/:n Delays responding for n–10 seconds.
* /html Renders an HTML Page.
* /robots.txt Returns some robots.txt rules.
* /deny Denied by robots.txt file.
* /cache Returns 200 unless an If-Modified-Since header is provided, when it returns a 304 Not Modified.
* /base64/:value Decodes base64url-encoded string.
* /image Return an image based on Accept header.
* /websocket Echo message received through websocket

## TODO

* [ ] /gzip Returns gzip-encoded data.
* [ ] /response-headers?key=val Returns given response headers.
* [ ] /digest-auth/:qop/:user/:passwd Challenges HTTP Digest Auth.

## License

    Copyright :copyright: 2013-2014 Eduardo Gurgel <eduardo@gurgel.me>

    This work is free. You can redistribute it and/or modify it under the
    terms of the MIT License. See the LICENSE file for more details.
