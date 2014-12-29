# Description

Quirk is a command line utility for tracking good and bad habits.

# Installation

    $ gem install quirk

Then configure your habits in a plaintext file:

    $ quirk -e
    mile-run: monday, wednesday, thursday ; comments start with semi-colons
    walk-dog: everyday

By default, all this does is edit the `~/.quirk` file.  You can configure which file to use by
setting the environment variable `QUIRKFILE`.

# Usage

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

    $ quirk -c mile-run -y 2011

See all of your current streaks:

    $ quirk
    17 mile-run
     3 walk-dog
    -3 quit-tv

Habits are stored in plaintext in `~/.quirk`.  You can use `quirk -e` to add/remove entries.  Habits
start on the day of the first mark by default.

    2012/01/01 walk-dog

The first line means you walked the dog on `1/1`.  You can specify the last day for a habit using
the `$` prefix:

    2012/01/30 $walk-dog

This means I'll stop the habit on `1/30`, it's just a temporary goal for 1 month.

# TODO

* remove quitting habits
* remove ^ start habit days
* mark habit should re-use date entries if available
* streaks action should respect definition order as secondary

# License

Copyright Hugh Bien - http://hughbien.com.
Released under BSD License, see LICENSE.md for more info.
