MooXtract
=========

A simple Haskell program for extracting Moodle submissions.

Installation
------------

It should just install with cabal.

    cabal install --bindir=/path/to/where/you/want/the/bin

Usage
-----

Currently MooXtract should be used as follows. First download the
giant .zip archive of all of the moodle submissions. Let's say this is
called `submissions.zip`, then in order to extract all of them into
a marking directory you might do:

    mkdir marking
    cd marking
    unzip ~/Downloads/submissions.zip
    MooXtract

MooXtract will list submissions that it could not extract. These
submissions probably did not follow the correct format, but it's a
good idea to double check.

Issues
------

MooXtract will **NOT** handle submissions that have extra periods in
the file name.