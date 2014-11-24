## Why is it needed
This bash script is created to extract files from blackboard. Blackboard has a
horrible way of creating a zipfile. This tries to fix it.

## Usage
This bash script is used to unpack the zipfile blackboard generates when
you download all the files in the "full grade center" -> Assignment Download
File -> select all students -> download zipfile. Use help functionality to
guide you to use this bash script.

The following output is generated when you call the script with -h.

~~~
Help documentation for bb_extract.

Basic usage: bb_extract gradebook.zip

Command line switches are optional. The following switches are recognized.
-d --Set output directory. /tmp/bb_cleaned.
-h --Displays this help message. No further functions are performed.

Example: bb_extract -d assignment1 gradebook.zip
~~~

## advise
Clone this repo into your ~/.config directory and add it to your the path into
your `$PATH` env variable for maximum convenience.

## References
This guy helped me in making the bashscript useable for other people:
http://tuxtweaks.com/2014/05/bash-getopts/

You'll notice that some of the code is directly copied, but also altered to fit
my needs.

