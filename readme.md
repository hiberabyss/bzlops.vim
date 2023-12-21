# What's this

Manipulate bazel `BUILD` rule base on current file.
Support new/delete rule, add/remove dependency base on current line.

# Prerequirement

Need to install buildozer via following command:

```sh
go install github.com/bazelbuild/buildtools/buildozer@latest
```

# Commands

- `BzlNew` will create new bazel rule base on current file.
  dependencies will be added
  - Will add public visibility when has `!`
- `BzlDelete` will delete current file and corresponding rule
- `BzlAddDep` will add dependency base on current line
- `BzlRmDep` will delete current line and corresponding dependency
- `BzlLoadDeps` will load all dependencies base on include/import lines

The default dependency is decided via file path and filename.
For example, `#include "/path/to/file.h"` will be recognized as dependency `//path/to:file`.
There could be custom rule for the filetype via `custom_rule` handler.

Some commands will do the action base on filetype.
Currenttly supported filetypes:

- `cpp`
- `proto`

To support new filetypes, take a look at `ftplugin/proto.vim`.

# Demo

Prepare the demo:

```sh
mkdir /tmp/demo
cd /tmp/demo

mkdir -p cpp
touch cpp/hello.h
touch cpp/main.cc
```

Open file `cpp/hello.h`, execute `BzlNew`.
File `cpp/BUILD` will be built with following content:

```text
cc_library(
    name = "hello",
    srcs = ["hello.h"],
)
```

Write following content into file `cpp/main.cc`:

```cpp
#include "cpp/hello.h"

int main(int argc, char *argv[]) {
  return 0;
}
```

Execute `BzlNew`, `cpp/BUILD` will become:

```text
cc_library(
    name = "hello",
    srcs = ["hello.h"],
)

cc_binary(
    name = "main",
    srcs = ["main.cc"],
    stamp = 1,
    deps = [":hello"],
)
```

Open file `cpp/hello.h`, execute `BzlDelete`.
`hello.h` will be deleted and `BUILD` file becomes:

```text
cc_binary(
    name = "main",
    srcs = ["main.cc"],
    stamp = 1,
    deps = [":hello"],
)
```

Open file `cpp/main.cc`, go to line `#include "cpp/hello.h"`, execute `BzlRmDep`.
The line will be deleted and `BUILD` becomes:

```text
cc_binary(
    name = "main",
    srcs = ["main.cc"],
    stamp = 1,
)
```
