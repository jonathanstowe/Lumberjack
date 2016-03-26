use v6.c;

use Staticish;

class Lumberjack is Static {

    class Message { ... };

    has Supplier $!supplier     = Supplier.new;
    has Supply   $.all-messages = $!supplier.Supply;

    enum Level <Off Fatal Error Warn Info Debug Trace All> does role {
        multi method ACCEPTS(Message $m) {
            $m.level == self;
        }
    };

    has Supply $.fatal-messages = $!all-messages.grep(Fatal);
    has Supply $.error-messages = $!all-messages.grep(Error);
    has Supply $.warn-messages  = $!all-messages.grep(Warn);
    has Supply $.info-messages  = $!all-messages.grep(Info);
    has Supply $.debug-messages = $!all-messages.grep(Debug);
    has Supply $.trace-messages = $!all-messages.grep(Trace);


    has Level $.default-level is rw = Error;

    class Message {
        has Mu          $.class;
        has Level       $.level;
        has Backtrace   $.backtrace;
        has Str         $.message is required;
        has DateTime    $.when;

        multi method ACCEPTS(Level $l) {
            $!level == $l;
        }

        method Numeric() {
            $!level;
        }

        submethod BUILD(:$!class, Level :$!level, Backtrace :$!backtrace, Str :$!message!) is hidden-from-backtrace {
            if not $!level.defined {
                $!level = Lumberjack.default-level;
            }
            if not $!backtrace.defined {
                $!backtrace = Backtrace.new;
            }
            $!when = DateTime.now;
        }
        method gist {
            "{$!when} [{ $!level.Str.uc }] { $!message }";
        }

    }

    method log(Message $message) {
        $!supplier.emit($message);
    }

    role Logger {
        my Level $level;

        method log-level() returns Level is rw {
            $level;
        }

        proto method log(|c) { * }

        multi method log(Message $message) is hidden-from-backtrace {
            Lumberjack.log($message);
        }

        multi method log(Level $level, Str $message) is hidden-from-backtrace {
            my $backtrace = Backtrace.new;
            my $class = $?CLASS;
            my $mess = Message.new(:$level, :$message, :$backtrace, :$class);
            samewith $mess;
        }

    }

    has Supply $.filtered-messages = supply {
        whenever $!all-messages -> $m {
            my $filter-level = do if $m.class ~~ Logger {
                $m.class.log-level;
            }
            else {
                $!default-level;
            }
            if $m.level <= $filter-level {
                emit $m;
            }
        }
    }
}

# vim: expandtab shiftwidth=4 ft=perl6
