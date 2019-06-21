---
layout: post
title:  "NodeJS and Python interoperability!"
date:   2019-06-14 13:00:00 -0600
comments: true
disqus_url: "http://fridgerator.github.io/2019/06/14/nodejs-and-python-interoperability.html"
disqus_identifier: "/2019/06/14/nodejs-and-python-interoperability.html"
---

# Calling python functions from node

NodeJS <-> Python interoperability is ~~relatively easy~~ doable.  I'm not talking about using string interpolated system calls and parsing command line returns, or some other janky method.  Both languages are written in C/C++, so interop is possible via their native bindings.  Follow me on my journey of using the low level API's of two languages I really dont even like that much! 🙁🤣 (full disclosure... just being honest)

And in the spirit of this blog, <span style="font-size:1.3em"><b><i>BEER</i></b><span> <span>&dArr;</span>

![hazy beer](https://i.imgur.com/sbebRux.jpg)

**Drumroll APA**

#### V8

[V8](https://v8.dev/) is the engine Node is written in.  You can create javascript classes and functions in C++, and convert parameters and return values between javascript types and V8 types pretty easily. I have found this useful for data processing in C++, where javascript was too slow.  I could return large arrays to javascript to plot in graphs without the need to serialize / deserialize large objects first. Using [NaN](https://github.com/nodejs/nan) (Native Abstractions for Node.js) makes this even easier.  I'm not going to get into the specifics of using V8 and NaN however there are plenty of blog posts on the topic, and plenty of native node modules to use as examples.

#### Embedding Python

A *somewhat* similar concept exists for Python - [Embedding Python](https://docs.python.org/3/extending/embedding.html).  You can run snippets of Python code or open existing files (modules) and call functions directly, again converting between C++ and Python types for parameters and return values.  A Python interpreter is still required for this to work, however portability can still be achieved, more on this later.  A very good blog post over at [awasu.com](https://awasu.com) gives a very detailed explanation with examples of [writing a Python wrapper in C++](https://awasu.com/weblog/embedding-python/writing-a-c-wrapper-library-part3/).

#### The Code

Full source code available [here](https://github.com/fridgerator/PyNode)

First thing in the [`Initialize` function](https://github.com/fridgerator/node-python/blob/master/main.cc#L48) we set up some search paths so Python can find the interpreter and required libraries and pass them to [`Py_SetPath`](https://docs.python.org/3/c-api/init.html#c.Py_SetPath).  Next we [initialize the Python interpreter](https://docs.python.org/3/c-api/init.html#c.Py_Initialize), and append the current directory Python's system path so it can found our local python module.  Finally we can tell Python to decode our `tools.py` file and import it so we can call it later on.

We've added a `multiply` function to our node module exports, which will call our [`Multiply` c++ function](https://github.com/fridgerator/node-python/blob/master/main.cc#L8).  After checking our arguments, we create a couple of `double` variables from them using the handy [`Nan::To`](https://github.com/nodejs/nan/blob/master/doc/converters.md#nanto) helper methods.  We load our python function using [`PyObject_GetAttrString`](https://docs.python.org/3/c-api/object.html#c.PyObject_GetAttrString) and make sure we've found a callable function with [`PyCallable_Check`](https://docs.python.org/3/c-api/object.html#c.PyCallable_Check).

Assuming we have two valid arguments passed from javascript and we've found a callable `multiply` function, the next setp is to convert these two `double` variables into python function arguments.  We create a new Python tuple with a size of 2, and then add those `double` variables to the tuple.  And now the magic moment we've been waiting for: `pValue = PyObject_CallObject(pFunc, pArgs);`.  Assuming `pValue` isn't `NULL`, we've successfully called the python function from node and have received a return value.  We convert `pValue` to a `long` and then set the return value for our node function!

Pretty freakin cool IMO

#### Portability

In this code example I have downloaded and built Python 3.7.3 locally, if you check out the `binding.gyp` file you'll notice the local folder includes.  It is also possible to build a portable Python distribution to ship with the node application.  This could be useful for an Electron application.  Another detailed [blog post by João Ventura](http://joaoventura.net/blog/2016/embeddable-python-osx/) describes how to do so in OSX.

#### Conclusion

This certainly is much more work than using `child_process.spawn` to run python.  Is the extra effort worth it? I dont really know.

Its a more direct call with the benefit of having the ability to check argument and return types.  It's even possible to create a hexdump of our python file as a c `char` variable and then include it at compile time using `xxd -i tools.py`.

I'm going to be playing around more with this idea to find out what else might be possible.
