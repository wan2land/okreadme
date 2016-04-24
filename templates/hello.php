<?php

function foo()
{
	echo "Foo";
}

/* area_func_bar { */
function bar()
{
	echo "Bar";
	if (true) {
		echo "!!!!";
	}
}
/* } */

function main() {
	bar();
}
