# Explaination
## .ai files
```
name="readChars"
where="system/io"
desc="reads len bytes into the buffer a starting at a[start]. Returns the actual number of bytes that have been read which may be less than len (if not as many bytes are remaining), but not greater."
syntax="proc readChars(f: File; a: var openArray[char]; start, len: Natural): int"
warn="this usage is deprecated"
note="use other `readChars` overload, possibly via: readChars(toOpenArray(buf, start, len-1))"
```
- `name`: API name
- `where`: where is the API located
- `desc`: Description, usage,... of the API
- `syntax`: how to call the API
- `warn`: Potential danger when using the API
- `note`: Note when using the API

## HTML files
The order of the generating `final.html` process: `head.html` -> `custom.html` -> `sidenav.html (auto-generated)` -> `doc.html (auto-generated)`

- `sidenav.html`: Navigation bar (generated from .ai files). This file can be extended by using `sidenav-extend.html`
- `doc.html`: Documentation (generated from .ai files). This file can be extended by using `doc-extend.html`
- `head.html`: Use for \<head\> section. If it does not exist, the \<head\> element will be:
  
  ```
  <head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" type="text/css" href="style.css">
  </head>
  ```
- `custom.html`: Use for user-specific purpose, optional.

## Style
- Take a look at [style.css](https://github.com/hanhlinux/genhtml/blob/main/style.css)
