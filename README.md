# Lumberjack

A simple logging framework.

![Build Status](https://github.com/jonathanstowe/Lumberjack/workflows/CI/badge.svg)

## Synopsis

```raku

use Lumberjack;

# Output to $*ERR by default - in colour!
Lumberjack.dispatchers.append: Lumberjack::Dispatcher::Console.new(:colour);

class MyClass does Lumberjack::Logger {
	method start() {
       self.log-info("Starting ...");
       ...
   }

   method do-stuff() {
      self.log-debug("Doing stuff ...");
      ...
      if $something-went-wrong {
         self.log-error("Something went wrong");
      }
   }
   method stop() {
       ...
       self.log-info("Stopped.");
   }
}

MyClass.log-level = Lumberjack::Debug;


```

## Descriptiom

This is more of a sketch for a logging framework, or perhaps even a
logging framework framework. It provides the minimum interface that
classes can consume a role to provide themselves logging facilities
and set a class wide logging level and have the messages delivered to
dispatchers which can do what they want with the messages and specify
the levels of messages that they want to handle.

It doesn't mandate any particular configuration format as the setup is
entirely programmatic, I foresee that people providing their own higher
level configuration driven things on top of this.

I'm sure this doesn't yet have all the features to support all the
requirements people, but it is released with the basic interface
complete so it can actually be used.

The approach taken reflects a patten that I have found useful in large
object oriented programmes, where having the logging methods on a class
means that you have the means to make log messages wherever you have
an instance of the class without having to obtain a separate logger
object.

There are a couple of simple log dispatchers included which should get
you started, but I would envisage that more useful ones may be provided
as separate modules, though they are sufficiently simple to implement
you can provide your own as required.

## Installation

Assuming you have a working Rakudo installation you should be able to install this directly with zef:

    zef install Lumberjack

Or if you have the source code locally:

    zef install .

For a brief period between the 2020.02 and 2020.05 releases of Rakudo the `Backtrace` implementation in `rakudo` changed in a way that breaks the tests, so if you see test failures with a Rakudo you are probably safe to use `--force-install`.

## Support

This is quite experimental and subject to change in the way it is
implemented, however I would like to keep the basic interface fairly
stable and simple.  You are encouraged to create your own log dispatchers
and high level configuration modules to work with it.

However if it is missing a basic functionality you need that can't be
provided by some extension and would be useful to others please let me
know. And of course if you find that it has some unanticipated bug I'd
also like to know.

Reports, requests, suggestions and patches can be sent to [github](https://github.com/jonathanstowe/Lumberjack/issues)

# Licence and Copyright

This is free software, please see the [LICENCE](LICENCE) file for full description.

© Jonathan Stowe 2016 - 2021

