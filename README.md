# nanyx.json

Reading and writing JSON in [Nanyx](https://github.com/nanyx-lang/nanyx): a `Json` value, a parser that says where
text stops being JSON and why, a printer and a pretty-printer, and decoders and encoders that turn JSON into types of
your own and back.

## Install

In a package:

```bash
nanyx install nanyx.json
```

That adds `(package = "nanyx.json", version = "0.1")` to the manifest's `dependencies`, locks the version in
`nanyx.lock` and downloads it.

## Use

```nanyx
module main

import nanyx.json/json as json

@entry
def main = {
  match json.parse('{"name": "Ada", "born": 1815}')
    | #some(value) -> println(json.printPretty(value, indent = 2))
    | #error(e) -> println("{e.line}:{e.column} {e.message}")
}
```

Import `nanyx.json/json` under a name, `as json`: its `print` would otherwise clash with the console's. The encoders
are in `nanyx.json/encode`, since their names are the decoders'.

The reference, with more examples, is on the docs site: [json](https://nanyx.dev/docs/stdlib/json),
[decoders](https://nanyx.dev/docs/stdlib/json-typed) and
[encoders](https://nanyx.dev/docs/stdlib/encode).

## Develop

The tests are scripts in `tests/`, each with the output it should print in a `.expected` file beside it:

```bash
tests/run.sh                 # with nanyx on the PATH
NANYX=path/to/nanyx tests/run.sh
```

CI builds and tests the package with the latest released compiler. To release, set the manifest's `version` (or run
`nanyx bump`) and run `nanyx publish`, which creates the GitHub release with the `.nyxpkg` and registers the version
with the [package index](https://github.com/nanyx-lang/packages).
