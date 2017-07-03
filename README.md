Is You README Ok?
=================

if you want **require** syntax in README.md...

README.ok.md -> README.md

## Installation

```sh
$ git clone git@github.com:wan2land/is-your-readme-ok.git
$ cd is-your-readme-ok
$ cp okreadme /your/path/bin
```

type `okreadme -v`. print `Is Your README OK? v0.x`.

## How to use

`README.ok.md` 파일을 다음과 같이 작성합시다.

```
```c

#include<stdio.h>

int main() {
	// section:main
	printf("Hello World\n");
	return 0;
	// endsection
}
```
```

그리고 `templates/hello.c`라는 파일이 다음과 같이 작성되어있다면,

```c

#include<stdio.h>

int main() {
	// section:main
	printf("Hello World\n");
	return 0;
	// endsection
}
```

**Command**

```
$ okreadme > README.md
```

## Command

```
$ okreadme {targetfile}
```

That's all. Default `{targetfile}` is `README.ok.md`
If you want to save output, use command below.

```
$ okreadme {targetfile} > README.md
```

## Syntax

### 1. Print all source.

```
ok,, include templates/hello.c
```

**Result**

ok,, include templates/hello.c

### 2. Print subset by line numbers.

```
ok,, include templates/hello.c, 4, 20 # line 4 ~ 20
ok,, include templates/hello.c, 4     # line 4 ~ end
ok,, include templates/hello.c, , 20  # line start ~ 20
```

ok,, include templates/hello.c, 4, 20 # line 4 ~ 20
ok,, include templates/hello.c, 4     # line 4 ~ end
ok,, include templates/hello.c, , 20  # line start ~ 20

### 3. Print subset by function name.

The language using the `{`, `}` chracters as a code block is all available.
(cf. c, php, javascript, ... )

```
ok,, include templates/hello.c, "int main()"
```

or,

```php
/* area_func_bar { */
function bar()
{
	echo "Bar";
	if (true) {
		echo "!!!!";
	}
}
/* } */
```

```
%% include src/main.c@area_func_bar
```

## Todos

- tab index
- install script

## Ref.

- http://www.dreamy.pe.kr/zbxe/CodeClip/3766012
- http://tldp.org/LDP/abs/html/comparison-ops.html
