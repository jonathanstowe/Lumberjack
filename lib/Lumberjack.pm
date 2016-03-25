use v6.c;

use Staticish;

class Lumberjack is Static {


    has Supplier $!supplier;


    enum Level <Off Fatal Error Warn Info Debug Trace All>;

    class Message {
        has Level $.level;
        has Backtrace $.backtrace;
        has Str $.message;

        method gist {
            "[{ $!level.Str.uc }] { $!message }";
        }

    }

    role Logger {
        my Level $level;

        method log-level() returns Level is rw {
            $level;
        }

        proto method log(|c) { * }

        multi method logx(Message $message) {
            Lumberjack.log($message);
        }

        multi method log(Level $level, Str $message) {
            my $backtrace = Backtrace.new;
            my $mess = Message.new(:$level, :$message, :$backtrace);
            samewith $message;
        }

    }

}

# vim: expandtab shiftwidth=4 ft=perl6
