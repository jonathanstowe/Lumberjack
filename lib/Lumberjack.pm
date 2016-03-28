use v6.c;

use Staticish;

class Lumberjack is Static {

    class Message { ... };

    has Supplier $!supplier;
    has Supply   $.all-messages;

    enum Level <Off Fatal Error Warn Info Debug Trace All> does role {
        multi method ACCEPTS(Message $m) {
            $m.level == self;
        }
    };

    has Supply $.fatal-messages;
    has Supply $.error-messages;
    has Supply $.warn-messages;
    has Supply $.info-messages;
    has Supply $.debug-messages;
    has Supply $.trace-messages;


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

    method log(Message $message) is hidden-from-backtrace {
        $!supplier.emit($message);
    }

    role Logger {
        my Level $level;

        method log-level() returns Level is rw {
            $level;
        }

        proto method log(|c) is hidden-from-backtrace { * }

        multi method log(Message $message) is hidden-from-backtrace {
            Lumberjack.log($message);
        }

        multi method log(Level $level, Str $message) is hidden-from-backtrace {
            my $backtrace = Backtrace.new;
            my $class = $?CLASS;
            my $mess = Message.new(:$level, :$message, :$backtrace, :$class);
            samewith $mess;
        }

        method log-trace(Str() $message) is hidden-from-backtrace {
            self.log(Trace, $message);
        }

        method log-debug(Str() $message) is hidden-from-backtrace {
            self.log(Debug, $message);
        }

        method log-info(Str() $message) is hidden-from-backtrace {
            self.log(Info, $message);
        }

        method log-warn(Str() $message) is hidden-from-backtrace {
            self.log(Warn, $message);
        }

        method log-error(Str() $message) is hidden-from-backtrace {
            self.log(Error, $message);
        }

        method log-fatal(Str() $message) is hidden-from-backtrace {
            self.log(Fatal, $message);
        }
    }

    role Dispatcher {
        has Mu $.levels   = Level;
        has Mu $.classes; 

        method log(Message $message) {
            ...
        }
    }

    has Dispatcher @.dispatchers;

    has Supply $.filtered-messages; 

    submethod BUILD() {
        $!supplier       = Supplier.new;
        $!all-messages   = $!supplier.Supply;
        $!fatal-messages = $!all-messages.grep(Fatal);
        $!error-messages = $!all-messages.grep(Error);
        $!warn-messages  = $!all-messages.grep(Warn);
        $!info-messages  = $!all-messages.grep(Info);
        $!debug-messages = $!all-messages.grep(Debug);
        $!trace-messages = $!all-messages.grep(Trace);
        $!filtered-messages = supply {
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

        $!filtered-messages.tap(-> $message {
            for @!dispatchers -> $dispatcher {
                if ($message.level ~~ $dispatcher.levels) && ($message.class ~~ $dispatcher.classes) {
                    $dispatcher.log($message);
                }
            }
        });
    }

    sub default-date-formatter(DateTime $date-time) returns Str {
        use DateTime::Format::RFC2822;
        DateTime::Format::RFC2822.new.to-string($date-time);
    }

    sub format-message(Str $format, Message $message, :&date-formatter = &default-date-formatter, Int :$callframes) returns Str is export(:FORMAT) {
        my $message-frame = $callframes.defined ?? $message.backtrace.list[$callframes] !! $message.backtrace.list[*-1];
        my %expressions =   D => { date-formatter($message.when) },
						    P => { $*PID },
                            C => { $message.class.^name },
                            L => { $message.level.Str },
                            M => { $message.message },
                            N => { $*PROGRAM-NAME },
                            F => { $message-frame.file },
                            l => { $message-frame.line },
                            S => { $message-frame.subname };
        $format.subst(/'%'(<{%expressions.keys}>)/, -> $/ { %expressions{~$0}.() }, :g);
    }

    class Dispatcher::Console does Dispatcher {
        has Bool        $.colour = False;
        has IO::Handle  $.handle = $*ERR;
        has Str         $.format = "%D [%L] %C %S : %M"; 
        has Int         $.callframes = 4;
        has Int         %.colours   = Trace => 23,
                                      Debug => 21,
                                      Info  => 40,
                                      Warn  => 214,
                                      Error => 202,
                                      Fatal => 196;

        method log(Message $message) {
            my $format = $!colour ?? "\e[38;5;{%!colours{$message.level}}m{$!format}\e[0m" !! $!format;
            $!handle.say: format-message($format, $message, callframes => $!callframes);
        }
    }

    class Dispatcher::File does Dispatcher {
        has Str         $.file;
        has IO::Handle  $.handle;
        has Int         $.callframes = 4;
        has Str         $.format = "%D [%L] %C %S : %M"; 

        class X::NoFile is Exception {
            has Str $.message = "One of file or handle must be provided";
        }

        method log(Message $message) {
            if not $!handle.defined {
                if $!file.defined {
                    $!handle = $!file.IO.open(:a);
                }
                else {
                    X::NoFile.new.throw;
                }
            }
            $!handle.say: format-message($!format, $message, callframes => $!callframes);
        }
    }
}

# vim: expandtab shiftwidth=4 ft=perl6
