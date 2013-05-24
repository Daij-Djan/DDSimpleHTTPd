DDSimpleHTTPd
========

This is a simple web server written in Objective C using the CCFNetwork (for OSX and iOS)

It's based on SimpleHTTPd which Alex Potsites derived from SimpleHTTPServer written by Jurgen of Cultured Code (ace Mac developer of Things fame) and the article he wrote for O'Reilly's Mac Dev Center. 

SimpleHTTPd made serveral improvements including handling POST requests, handling requests split over multiple packets, changing the listening port, the web root, and advertising the server via Bonjour.

#####Now 5 years later I wrote DDSimpleHTTPd based on that.

#####1. I did some maintenance 
- It it is no longer limited to Cocoa Apps but can also be used in commandline tools
- It is no longer limited OSX but also works on iOS now.
- It uses Arc
- properties are now realized via `@properties`
- It uses a lot of new syntactic sugar of the objC language. Also I cleaned up the naming of the vars a bit and overall tried to make the code 'nicer'
- It builds as a framework for OSX and a static library for IOS. (The xcode project contains a cocoa mac app, an ios demo app and a OSX commandline app as Demos)
- I dropped PPC and 32 bit support only using the new 64bit/armv7(s) runtimes

####2. I added some fixes, features
- When the server is told to `stopListening` it now does correclty clean up after itself and closes the socket handle, allowing it to be reused
- the path for the requested resource is now correctly appended to the webroot. Before GETs often didnt work
- when the server gets a request (POST/GET) it now asks the delegate first and only if the delegate does not handle it, it does it using the built-in solution
- The responder now has a property `isListening` that returns the state of the server
- `loggingEnabled` controls NSLogs 
- **The server can now autogenerate directory index files by itself.** Set `autogenerateIndex` to YES and it automatically creates a basic html with a list of anchors for the directory contents.
- WAY more mime types are now supported by default
- the webRoot can now point to a single file, in which case the actual URL is ignored (single file mode)
- …
