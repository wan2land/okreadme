Is You README Ok?
===

`README.ok.md` 파일을 다음과 같이 작성합시다.

```
%% insert templates/hello.c
```

그리고 `templates/hello.c`라는 파일이 다음과 같이 작성되어있다면,

%% insert templates/hello.c

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


## Todos

 - Git Hook
 - add command `insert template/hello.c:2-7`
 - add command `insert template/hello.c/int main()`


## Ref.

- http://www.dreamy.pe.kr/zbxe/CodeClip/3766012
- http://tldp.org/LDP/abs/html/comparison-ops.html
