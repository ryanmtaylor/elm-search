module Page.DesignGuidelines where

import Effects as Fx
import StartApp
import Task

import Component.Blog as Blog



-- WIRES


app =
  StartApp.start
    { init = Blog.init content
    , view = Blog.view
    , update = Blog.update
    , inputs = []
    }


main =
  app.html


port worker : Signal (Task.Task Fx.Never ())
port worker =
  app.tasks



-- CONTENT


content : String
content = """

# Design Guidelines

These guidelines are meant to promote consistency and quality across all Elm
packages. It is a collection of best practices that will help you write better
APIs and your users write better code. Here is the overview, but it is
important to read through and see why these recommendations matter.

  * [Design for a concrete use case](#design-for-a-concrete-use-case)
  * [Avoid gratuitous abstraction](#avoid-gratuitous-abstraction)
  * [Write helpful documentation with examples](#write-helpful-documentation-with-examples)
  * [The data structure is always the last argument](#the-data-structure-is-always-the-last-argument)
  * [Keep tags and record constructors secret](#keep-tags-and-record-constructors-secret)
  * [Naming](#naming)
    - [Use human readable names](#use-human-readable-names)
    - [Module names should not reappear in function names](#module-names-should-not-reappear-in-function-names)
    - [Avoid infix operators](#avoid-infix-operators)


## Design for a concrete use case

Before you start writing a library, think about what your goal is.

* What is the concrete problem you want to solve?
* What would it mean for your API to be a success?
* Who has this problem? What do they want from an API?
* What specific things are needed to solve that problem?
* Have other people worked on this problem? What lessons can be learned from them?
  Are there specific weaknesses you want to avoid?

Actually think about these things. Write ideas on paper. Ask for advice
from someone you trust. It will make your library better. If you are doing
this right, you will have example code and a tentative API before you
start implementing anything.


## Avoid gratuitous abstraction

Some functional programmers like to make their API as general as possible.
This will reliably make your API harder to understand. Is that worth it?
What concrete benefits are users gaining? Does that align with the concrete
use case you have in mind for your library?

Abstraction is a tool, not a design goal. Unless abstraction is
making someones life easier, it is not a good idea. If you cannot
*demonstrate* why your abstraction is helpful, there is a problem with your API.


## Write helpful documentation with examples

[This document](/help/documentation-format) describes how documentation works
in Elm, and you can preview your docs [here](/help/docs-preview).

Providing examples of common uses is extremely helpful. Do it! The standard
libraries all make a point to have examples that show how one *should* be using
those functions.

Also, make the documentation for the library itself helpful. Perhaps have an
example that shows how to use many functions together, showcasing the API.

Finally, think hard about the order that the functions appear in and what kind
of title each section gets. People will read documentation linearly when learning
a library, so give them some structure!


## The data structure is always the last argument

Function composition works better when the data structure is the last argument:

```elm
getCombinedHeight people =
    people
      |> map .height
      |> foldl (+) 0
```

Folding also works better when the data structure is the last argument of the
accumulator function. `foldl`, `foldr`, and `foldp` all work this way:

```elm
-- Good API
remove : String -> Dict String a -> Dict String a

filteredPeople =
    foldr remove people ["Steve","Tom","Sally"]


-- Bad API
without : Dict String a -> String -> Dict String a

filteredPeople =
    foldr (flip without) people ["Steve","Tom","Sally"]
```

The order of arguments in fold is specifically intended to make this very
straight-forward: *the data structure is always the last argument*.


## Keep tags and record constructors secret

It's convenient to be able to write `Point x y` instead of `{x = x, y = y}`. But
what happens when you want to add a third dimension, or switch to a polar
representation? Then you have to break everyone's code in a major version
release. Instead, provide a function like `fromXY` to construct a point. Then
you can add `fromPolar` or `fromXYZ` later.

If your points are type aliased records or tuples, and the type is completely
hidden, other people can't write type annotations without knowing and relying on
the type. Exported or not, client code can construct and inspect the values
without your library, which is also bad when it comes time to extend it.

Instead, use a union type where the type is exported but the tags are not, known
as an _opaque_ type. It's not hidden since you can see that it's there, but you
can't see into it, hence it's opaque. To create such a type, you include it in
the list of values that the module exports. So the first line of your file might
be `module MyModule (myFunction, MyType) where`. In this example, `MyType` (if
it is a union type) will be opaque. Then `myFunction` can take or return the
opaque type.

You can (and often should) use opaque types even if there is only one tag. If
you have a dozen values to track, you can tag a record. Then you can change the
record even between minor releases.


## Naming

### Use human readable names

Abbreviations are generally a silly idea for an API. Having an API
that is clear is more important than saving three or four characters
by dropping letters from a name.

Infix operators are not a substitute for human readable names.
They are impossible to Google for. They encourage users to not use
module prefixes, making it impossible to figure out what module they
came from. This makes them even harder to find. More on this later.

### Module names should not reappear in function names

A function called `State.runState` is redundant and silly. More importantly, it
encourages people to use `import State exposing (..)` which does not scale well.
In files with many so-called "unqualified" dependencies, it is essentially
impossible to figure out where functions are coming from. This can make large
code bases impossible to understand, especially if custom infix operators are
used as well. Repeating the module name actively encourages this kind of
unreadable code.

With a name like `State.run` the user is encouraged to disambiguate functions
with namespacing, leading to a codebase that will be clearer to people reading
the project for the first time. A great example from the standard library is
`Bitwise.and`. This reads a lot better than `&`, which brings us to...

### Avoid infix operators

They should never take the place of a well-named human readable
function. In a large code base that is maintained by many people,
infix operators are typically a bad idea.

  * They are difficult to search for online.
  * They are difficult to search for in a codebase too because they are rarely
    prefixed with the module they were imported from.
  * They usually offer no insight into what they actually do. To the uninitiated,
    things like `(<*>)` and `(!?)` are meaningless.

Now lets assume you have a really great infix operator, an operator that actually
represents its meaning in a very direct way, like `(<~)`. In this case, it is still
recommended that you do not add the infix operator.

Okay, but lets say you want to do it anyway. One way to do it is to provide a
recommended set of infix operators at the end of your library documentation.
Experienced users can go see if they like them and define them if they really want.
That way the API can be nice and human readable *and* encourage its users to write code
that is nice and human readable.

Okay, but lets say you just don't care about recommendations and you have a great
infix operator. Add them in a separate module. When someone sees an infix operator
they are unfamiliar with, they can scan the imports for a `Whatever.Infix` module
and limit the scope of their annoying search for your dumb operator.

"""
