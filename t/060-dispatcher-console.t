#!perl6

use v6;

use Test;
use Lumberjack;

use IO::MiddleMan;

my $hijack = IO::MiddleMan.hijack: $*ERR;

Lumberjack.dispatchers.append: Lumberjack::Dispatcher::Console.new;

class Banana does Lumberjack::Logger {
    method do-debug() {
        self.log-debug("debug message");
    }
    method do-trace() {
        self.log-trace("trace message");
    }
    method do-info() {
        self.log-info("info message");
    }
    method do-warn() {
        self.log-warn("warn message");
    }
    method do-error() {
        self.log-error("error message");
    }
    method do-fatal() {
        self.log-fatal("fatal message");
    }
}

Banana.log-level = Lumberjack::All;

my $banana = Banana.new;

lives-ok { $banana.do-trace }, "trace";

like $hijack.Str, /'[Trace] Banana log : trace message'/, "got expected text";
$hijack.data = ();

lives-ok { $banana.do-debug }, "debug";

like $hijack.Str, /'[Debug] Banana log : debug message'/, "got expected text";
$hijack.data = ();

lives-ok { $banana.do-info }, "info";

like $hijack.Str, /'[Info] Banana log : info message'/, "got expected text";
$hijack.data = ();

lives-ok { $banana.do-warn }, "warn";

like $hijack.Str, /'[Warn] Banana log : warn message'/, "got expected text";
$hijack.data = ();

lives-ok { $banana.do-error }, "error";

like $hijack.Str, /'[Error] Banana log : error message'/, "got expected text";
$hijack.data = ();

lives-ok { $banana.do-fatal }, "fatal";

like $hijack.Str, /'[Fatal] Banana log : fatal message'/, "got expected text";
$hijack.data = ();

Lumberjack.dispatchers = ( Lumberjack::Dispatcher::Console.new(:colour));

lives-ok { $banana.do-trace }, "trace with colour";

like $hijack.Str, /'[Trace] Banana log : trace message'/, "got expected text";
$hijack.data = ();

lives-ok { $banana.do-debug }, "debug with colour";

like $hijack.Str, /'[Debug] Banana log : debug message'/, "got expected text";
$hijack.data = ();

lives-ok { $banana.do-info }, "info with colour";

like $hijack.Str, /'[Info] Banana log : info message'/, "got expected text";
$hijack.data = ();

lives-ok { $banana.do-warn }, "warn with colour";

like $hijack.Str, /'[Warn] Banana log : warn message'/, "got expected text";
$hijack.data = ();

lives-ok { $banana.do-error }, "error with colour";

like $hijack.Str, /'[Error] Banana log : error message'/, "got expected text";
$hijack.data = ();

lives-ok { $banana.do-fatal }, "fatal with colour";

like $hijack.Str, /'[Fatal] Banana log : fatal message'/, "got expected text";
$hijack.data = ();

done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
