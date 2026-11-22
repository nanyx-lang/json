# nanyx.json

Reading and writing JSON in [Nanyx](https://github.com/nanyx-lang/nanyx): a `Json` value, a parser that says where
text stops being JSON and why, a printer and a pretty-printer, and decoders and encoders that turn JSON into types of
your own and back.

## Install

In a package:

```bash
nanyx install nanyx.json
```

That adds `(package = "nanyx.json", version = "0.2")` to the manifest's `dependencies`, locks the version in
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

  match json.decode('{"name": "Bob", "born": "1990", "shapes": []}', into = type User)
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

CI builds and tests the package with the latest released compiler. To release, set the manifest's `version` (or run
`nanyx bump`) and run `nanyx publish`, which creates the GitHub release with the `.nyxpkg` and registers the version
with the [package index](https://github.com/nanyx-lang/packages).
