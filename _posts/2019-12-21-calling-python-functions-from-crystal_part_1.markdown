---
layout: post
title:  "Calling python functions from crystal - Part 1"
date:   2019-12-21 8:00:00 -0600
comments: false
disqus_url: "http://fridgerator.github.io/2019/12/21/calling-python-functions-from-crystal_part_1.html"
disqus_identifier: "/2019/12/21/calling-python-functions-from-crystal_part_1.html"
---

Ever wanted to call Python functions from Crystal?  Me either, but I'll show you how anyways. Its not pretty, like at all, but it works - much like my life story.  Perhaps some of this could be expanded to a more generic solution, but I had to write a bunch of C code to get this work.

![belching beaver](https://i.imgur.com/n4E4nWk.jpg)
Belching Beaver Mango IPA is really good, would recommend.

Unlike [calling python functions from node](http://localhost:4000/2019/06/14/nodejs-and-python-interoperability.html) via c++ bindings, Crystal can only [bind to c libraries](https://crystal-lang.org/reference/syntax_and_semantics/c_bindings/).  So that's exactly what I'm going to do.  Build a c library that calls into Python's internal functions and returns some structs and values that can be read in by Crystal.

Just like [PyNode](https://github.com/fridgerator/pynode), there is some boilerplate stuff we have to do to initialize python.  We have to [start the python interpreter](https://github.com/fridgerator/GlassySnek/blob/master/c/main.c#L34) by calling `Py_Initialize()`.  Also a [utility function](https://github.com/fridgerator/GlassySnek/blob/master/c/main.c#L44) for extending pythons search paths, so that it finds our python 3rd party libraries.  Finally, a function to [open our python file](https://github.com/fridgerator/GlassySnek/blob/master/c/main.c#L54).

I started off just trying to call a really simple [`add`](https://github.com/fridgerator/GlassySnek/blob/master/src/python/tools.py) function in python, that takes 2 parameters and returns their sum, just to see if this experiment would work.  The way this library binding works currently, each python function needs its own corresponding function written in C, which passes the correct parameters and returns the correct types.

Our C [`add`](https://github.com/fridgerator/GlassySnek/blob/master/c/main.c#L65) function takes two `int` parameters, gets the [corresponding python function](https://github.com/fridgerator/GlassySnek/blob/master/c/main.c#L68), and [ensures that we can call it](https://github.com/fridgerator/GlassySnek/blob/master/c/main.c#L69).  Next we build [build a python tuple](https://github.com/fridgerator/GlassySnek/blob/master/c/main.c#L75-L77) from our function arguments.  Finally [call our python function](https://github.com/fridgerator/GlassySnek/blob/master/c/main.c#L79), and [return the result](https://github.com/fridgerator/GlassySnek/blob/master/c/main.c#L81) as an int.  The [crystal binding](https://github.com/fridgerator/GlassySnek/blob/master/src/lib_glassysnek.cr#L33-L36) for this file is pretty simple, just a few `fun` declarations.

The next step is to turn this C code into a library.  First turn it into an object file: `gcc -c -o libglassysnek.o main.c -I$(python-config --cflags)`.  Then turn the object file into a shared library: `ar rcs libglassysnek.a libglassysnek.o`.  To use this, modify your library search paths or just copy this to `/usr/local/lib`.

Alright, lets try calling into our C / Python code now!

```python
# tools.py
def add(a, b):
  return a + b
```

```ruby
# GlassySnek.cr
LibGlassySnek.startInterpreter()
LibGlassySnek.appendSysPath("./src/python")
LibGlassySnek.openFile("tools")
x = LibGlassySnek.add(3, 4)
pp x
pp x.class
```

And here's the output:

![add output](https://i.imgur.com/yINdK3S.png)

Cool, that worked.

This simple function didnt really require all THAT much C code, but this is an extremely simple example.  In Part 2 I'll work through a more complicated example.
