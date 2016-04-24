Is You README Ok?
===

if you want **require** syntax in README.md...

README.ok.md -> README.md

## Installation

```sh
$ git clone git@github.com:wan2land/is-your-readme-ok.git
$ cd is-your-readme-ok
$ cp okreadme /your/path/bin
```

type `okreadme -v`. print `Is Your README OK? v0.x`.

### Git pre-commit Hook

```sh
$ cp pre-commit.sample /your/path/project/.git/hooks/pre-commit
```

## How to use

`README.ok.md` 파일을 다음과 같이 작성합시다.

```
%% insert templates/hello.c
```

그리고 `templates/hello.c`라는 파일이 다음과 같이 작성되어있다면,

%% insert templates/hello.c

**Command**

```
$ okreadme > README.md
```

이는 다음과 같이 출력합니다. (아래 예시에서 `'''`는 코드블럭 Markdown입니다.)

```
'''c

#include<stdio.h>

int main() {
	printf("Hello Worldn");
	return 0;
}

'''
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
%% insert src/main.c
```

### 2. Print subset by line numbers.

```
%% insert src/main.c:4-20
```

### 3. Print subset by function name.

The language using the `{`, `}` chracters as a code block is all available.
(cf. c, php, javascript, ... )

```
%% insert src/main.c@int main()
```

## Todos

- tab index
- insert inner
- install script
- all language support.... (....i don't know.....)

## Ref.

- http://www.dreamy.pe.kr/zbxe/CodeClip/3766012
- http://tldp.org/LDP/abs/html/comparison-ops.html
