# nanyx.json

Reading and writing JSON in [Nanyx](https://github.com/nanyx-lang/nanyx): a `Json` value, a parser that says where
text stops being JSON and why, a printer and a pretty-printer, and decoders and encoders that turn JSON into types of
your own and back.

## Install

In a package:

```bash
nanyx install nanyx.json
```

That adds `(package = "nanyx.json", version = "0.5")` to the manifest's `dependencies`, locks the version in
`nanyx.lock` and downloads it.

## Use

```nanyx
module main

import nanyx.json/json as json

type Shape = #circle(float) | #rect(width: float, height: float)

type User = (name: string, born: int, nickname: #some(string) | #none, shapes: list(Shape))

@entry
def main = {
  def ada = User(name = "Ada", born = 1815, nickname = #none, shapes = [#circle(1.5)])

  match json.encode(ada)
    | #some(text) -> println(text)
    | failure -> println(json.describe(failure))
  -- {"name":"Ada","born":1815,"shapes":[{"circle":1.5}]}

  match json.decode(type User, '{"name": "Bob", "born": "1990", "shapes": []}')
    | #some(user) -> println(user.name)
    | failure -> println(json.describe(failure))
  -- born: Expected a whole number, found a string
}
```

`json.encode` writes a value of any type, and `json.decode` reads one into the type it is given, by walking the
type, with no encoder or decoder written for it. A record is an object, a tuple an array, a tag with no payload its
name as a string and a tag with one `{"tag": payload}`, and an option `#some(x) | #none` is `x` or `null`, left out
when it is a field. A field's key is its name, or the name a `@json(name = "user_id")` attribute before it gives. A
function, or a nominal type whose structure the package can't see, is a `#cannotEncode` failure (an `EncodeError`)
with the path to it.

An object keeps its members in order: `json.parse` reads them in the order the text writes them and `json.print`
writes them back so, and `json.encode` writes a record's fields in the order its type declares them. A `Json` object
is `#object(list((string, Json)))`, a list of its members, and `json.member(members, "name")` finds one. A key written
twice in the text is read once, where it is first written, with the value written last. A `map` is written in the
map's own order.

A recursive type is walked as any other: a tree is a tag inside a tag, and a field of type `json.Json` is written
and read as itself. `json.encodeValue` writes a value as a `Json` value instead of text, to put in a larger one or to
print with `json.printPretty`.

Limits: `json.encode` sees even a nominal type of your own module as one it can't show, until a compiler fix lands
([nanyx#2382](https://github.com/nanyx-lang/nanyx/issues/2382)), so write one with
`json.encodeWith(x, json.encoderFor(type T))`; and a set, or a map whose keys aren't strings, can't be decoded: read
a list, and make one of it.

To write or read a type another way, build a `json.Decoder` and a `json.Encoder` from smaller ones and run them with
`json.decodeWith` and `json.encodeWith`; `json.decoderFor(type T)` and `json.encoderFor(type T)` walk a part of the
value. `json.parse` reads text into a `Json` value, and `json.print` and `json.printPretty` write one. A failure is a
tag of its own: `#invalidJson` (a `JsonError`) for text that isn't JSON, and `#doesNotFit` (a `DecodeError`) for a
value that doesn't fit, with the path to it.

Import `nanyx.json/json` under a name, `as json`: its `print` would otherwise clash with the console's. The encoders
are in `nanyx.json/encode`, since their names are the decoders'.

The reference is the doc comments in `src/`, which an editor shows when you hover over a name. Guides with more
examples are on the docs site: [json](https://nanyx.dev/docs/stdlib/json),
[decoders](https://nanyx.dev/docs/stdlib/json-typed) and [encoders](https://nanyx.dev/docs/stdlib/encode).

## Develop

The tests are scripts in `tests/`, each with the output it should print in a `.expected` file beside it:

```bash
tests/run.sh                 # with nanyx on the PATH
NANYX=path/to/nanyx tests/run.sh
```

CI builds and tests the package with the compiler release its workflow names, 0.44.1. To release, set the manifest's
`version` (or run `nanyx bump`) in a pull request. When it merges, CI's `publish` job runs `nanyx publish`, which
creates the GitHub release `v<version>` with the `.nyxpkg`, and the [package index](https://github.com/nanyx-lang/packages)
records it. A merge whose version is already released publishes nothing.
