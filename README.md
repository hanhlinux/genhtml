# genhtml
A dumb program to generate HTML, mainly for API documentation

## Compilation
- Clone the repo (or just fetch `genhtml.nim` file)
- Compile the `genhtml.nim` file: `nim c path/to/genhtml.nim`

## Usage
```
Usage: genhtml [options]

Option:
-h | --help
            Print this message
-d | --dir=[dir]
            Path to directory which contains the files
style.css can be used to apply style for HTML file(s). There is an example
```

## Example
Compile `genhtml.nim` and move to example then run `./genhtml`. You will see `final.html` as the result of the process.

See the [EXPLANATION.md](https://github.com/hanhlinux/genhtml/blob/main/EXPLANATION.md) file also
