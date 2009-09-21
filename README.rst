Just Played
===========

Just Played is an iPhone app that helps you find out what song that was on the radio.  People have been doing this since the dawn of radio with everything from pen and paper to a host of fancy gadgets.  But Just Played differs in several minor aspects, plus one important one:

* It runs on your iPhone or iPod Touch; you don't need a separate device.
* All it does is offer buttons to bookmark a radio station at a given time; you don't need a microphone or data connection while you're listening.
* When you're looking up your songs later, it syncs over WiFi; you don't need any cables.
* The source code for the iPhone app and the lookup server are freely available under an open source license.  Want to add an esoteric talk radio station?  Go right ahead!

What It's Made Of
-----------------

Just Played uses the ASIHTTPRequest_ library to make network requests in the background and keep the app snappy.  If you build the app in a special debugging mode, it will also contain an `embedded Web server`_ and `GUI testing library`_, so that you can inspect and control the app remotely from most programming languages.  In fact, the entire program was developed test-first.  Each feature was described first in Cucumber_ before being implemented.

How to Tinker With the App
--------------------------

If you're using Mercurial 1.3 or later, run this command:

  hg clone http://bitbucket.org/undees/justplayed

If you're using Git, run the following commands::

  git clone git://github.com/undees/justplayed
  git clone git://github.com/undees/brominet justplayed/brominet
  git clone git://github.com/undees/cocoahttpserver justplayed/server
  git clone git://github.com/undees/asi-http-request justplayed/asi-http-request

How to Tinker With the Server
-----------------------------

Just Played will work with any Web server that has the following properties:

* Responds to http://example.com/stations with a plist_-formatted array of dictionaries, each of which has a name and link, like this::

  <plist version="1.0">
  <array>
  <dict>
  <key>name</key>
  <string>KNRK</string>
  <key>link</key>
  <string>http://www.947.fm</string>
  </dict>
  </array>
  </plist>

* Responds to http://example.com/[station]/[time] with a plist-formatted dictionary containing a title and artist.  Times must be in ISO8601 combined UTC format; e.g., 2009-06-07T12:00:00Z.  Here's a sample result::

  <plist version="1.0">
  <dict>
  <key>title</key>
  <string>Belong</string>
  <key>artist</key>
  <string>R.E.M.</string>
  </dict>
  </plist>

This spec is simple enough to implement in just about any language or framework.  You might want to build on Dielectric, the demonstration server that was made for Just Played (source available in two_ main_ repositories).  This implementation fetches Creative-Commons-licensed data provided by http://api.yes.com.  If you deploy your own server somewhere using this or other data, make sure you follow whatever terms of service they set forth.

Once you've deployed your own server somewhere, you can point Just Played at at by entering your URL into the app's Settings bundle (Home button >> Settings >> Just Played >> Lookup Server).

Enjoy!

Credits
-------

Thanks to DRB62 on flickr.com for the CC-licensed `speaker photo`_ used in the icon.

.. _ASIHTTPRequest: http://allseeing-i.com/ASIHTTPRequest
.. _embedded Web server: http://code.google.com/p/cocoahttpserver
.. _GUI testing library: http://code.google.com/p/bromine
.. _Cucumber: http://cukes.info
.. _forest extension: http://www.selenic.com/mercurial/wiki/ForestExtension
.. _plist: http://developer.apple.com/documentation/Darwin/Reference/ManPages/man5/plist.5.html
.. _two: http://bitbucket.org/undees/dielectric
.. _main: http://github.com/undees/dielectric
.. _speaker photo: http://www.flickr.com/photos/drb62/3012428460
