Description
===========

Quirk is a command line utility for tracking good and bad habits.

Installation
============

    % gem install quirk

Then configure your habits in a plaintext file:

    % quirk -e
    mile-run: monday, wednesday, thursday
    walk-dog: everyday
    ; comments start with semi-colons
    ^quit-tv: friday

If a habit is prefixed with `^`, it means you're trying to break that habit.
In this case you're trying to quit TV on Fridays.

By default, all this does is edit the `~/.quirk` file.  You can configure
which file to use by setting the environment variable `QUIRKFILE`.

Usage
=====

When you've done something, mark it with:

    % quirk -m mile-run

To see a single habit (green days are good, red is bad):

    % quirk -c mile-run
          Jan 2012
    Su Mo Tu We Th Fr Sa
     1  2  3  4  5  6  7
     8  9 10 11 12 13 14
    15 16 17 18 19 20 21
    22 23 24 25 26 27 28
    29 30 31

Looking for a specific year?

    % quirk mile-run -y 2011

See all of your current streaks:

    % quirk -s
    17 mile-run
     3 walk-dog
    -3 quit-tv

Habits are stored in plaintext in `~/.quirk`.  You can use `quirk -e` to
add/remove entries.  Note that habits start on the day of the first mark
by default.  You can also specify the first day using `^`:

    2012/01/01 walk-dog
    2012/01/01 ^quit-tv

The first line means you walked the dog on `1/1`.  The second line means you
started the habit of quitting TV.  This is especailly handy for starting
quitting habits on a green day.

Zsh Tab Completion
==================

Here's an example zsh completion function:

    #compdef quirk
    compadd `quirk -l`

Put this into your `site-functions` directory (wherever `$fpath` points to):

    % echo $fpath
    /usr/share/zsh/site-functions /usr/share/zsh/4.3.11/functions
    % sudo vim /usr/share/zsh/site-functions/_quirk

TODO
====

* add error notification for day parsing

License
=======

Copyright 2012 Hugh Bien - http://hughbien.com.
Released under BSD License, see LICENSE.md for more info.
