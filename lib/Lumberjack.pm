use v6;

use Staticish;

class Lumberjack {

    enum Level <Off Fatal Error Warn Info Debug Trace All>;

    class Message {
        has Level $.level;
        has Backtrace $.backtrace;
        has Str $.message;

        method gist {
            "[{ $!level.Str.uc }] { $!message }";
        }
    }
}

# vim: expandtab shiftwidth=4 ft=perl6
