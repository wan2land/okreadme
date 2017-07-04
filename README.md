OK! Readme
==========

If you want **require** syntax in Markdown, use it.

**OKReadme** change `README.ok.md` file to `README.md`. it's very simple.

## Installation

```sh
$ git clone git@github.com:wan2land/okreadme
$ cd okreadme
$ make
$ cp okreadme /your/path/bin
```

type `okreadme -v`, the output is as follows:

```
OK Readme 0.1.0
Is Your Readme OK? :-)
```

## How to use

create `README.ok.md` file, then write the flowing. 

```
@code("templates/hello.c")
```

the command is also very easy.

```sh
$ okreadme > README.md
$ okreadme README.ok.md > README.md # default input is README.ok.md
```

**Result**

```c
#include<stdio.h>

int main() {
	// hello world :-)

	printf("Hello World\n");

	return 0;
}
```


## Syntax

### 1. Print all source.

show [templates/hello.c](templates/hello.c) file.

```
@code("templates/hello.c")
```

**Result**

```c
#include<stdio.h>

int main() {
	// hello world :-)

	printf("Hello World\n");

	return 0;
}
```


### 2. Print subset by line numbers.

show [templates/hello.c](templates/hello.c) file.

```
@code("templates/hello.c:4-8")
```

**Result**

```c
// hello world :-)

printf("Hello World\n");

return 0;
```

### 3. Print subset by section name.

show [templates/hello.php](templates/hello.php) file.

```
@code("templates/hello.php@code-by-section-name")
```

**Result**

```php
function codeBySectionName() {
    bar();
}
```


## Ref.

- http://www.dreamy.pe.kr/zbxe/CodeClip/3766012
- http://tldp.org/LDP/abs/html/comparison-ops.html
