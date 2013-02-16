Description
===========

Quirk is a command line utility for tracking good and bad habits.

Installation
============

    $ gem install quirk

Then configure your habits in a plaintext file:

    $ quirk -e
    mile-run: monday, wednesday, thursday
    walk-dog: everyday
    ^quit-tv: friday ; comments start with semi-colons

By default, all this does is edit the `~/.quirk` file.  You can configure
which file to use by setting the environment variable `QUIRKFILE`.

If a habit is prefixed with `^`, it means you're trying to break that habit.
In this case you're trying to quit TV on Fridays.


Usage
=====

When you've done something, mark it with:

    $ quirk -m mile-run

To see a single habit (green days are good, red is bad):

    $ quirk -c mile-run
          Jan 2012
    Su Mo Tu We Th Fr Sa
     1  2  3  4  5  6  7
     8  9 10 11 12 13 14
    15 16 17 18 19 20 21
    22 23 24 25 26 27 28
    29 30 31

Looking for a specific year?

    $ quirk mile-run -y 2011

See all of your current streaks:

    $ quirk
    17 mile-run
     3 walk-dog
    -3 quit-tv

See which habits are pending for today:

    $ quirk -t
    mile-run
    walk-dog

Habits are stored in plaintext in `~/.quirk`.  You can use `quirk -e` to
add/remove entries.  Note that habits start on the day of the first mark
by default.  You can also specify the first day using `^`:

    2012/01/01 walk-dog
    2012/01/01 ^quit-tv

The first line means you walked the dog on `1/1`.  The second line means you
started the habit of quitting TV.  This is especially handy for starting
quitting habits on a green day.

You can specify the last day for a habit using `$`:

    2012/01/01 ^quit-tv
    2012/01/30 $quit-tv
    2012/01/15 quit-tv
    2012/01/16 quit-tv

The first line means on `1/1`, I'm going to start quitting TV.  The second line
means I'll stop the habit on `1/30`, it's just a temporary goal for 1 month.
The last two lines means I watched TV on `1/15` and `1/16` (two red days).

Zsh Tab Completion
==================

Here's an example zsh completion function:

    #compdef quirk
    compadd `quirk -l`

Put this into your `site-functions` directory (wherever `$fpath` points to):

    $ echo $fpath
    /usr/share/zsh/site-functions /usr/share/zsh/4.3.11/functions
    $ vim /usr/share/zsh/site-functions/_quirk

Tmux and Other Notifications Integration
========================================

Use `quirk -t` to see which habits are pending for today.  Habits are separated
by a newline.  Use `xargs` and/or `tr` to format as you see fit:

    $ quirk -t
    mile-run
    wlak-dog
    $ quirk -t | xargs
    mile-run walk-dog
    $ quirk -t | xargs | tr " " ,
    mile-run,walk-dog

This is useful for `tmux`'s status as a reminder of which habits are pending.
Put this in your `.tmux.conf` file:

    set -g status-right '#[fg=yellow]#(quirk -t | xargs | tr " " ,)'

License
=======

Copyright Hugh Bien - http://hughbien.com.
Released under BSD License, see LICENSE.md for more info.
