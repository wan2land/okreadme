<?php

function foo()
{
	echo "Foo";
}

function bar()
{
	// section:block
	echo "Bar";
	if (true) {
		echo "!!!!";
	}
	//endsection
}

function baz_with_tab()
{
	/* section:area_func_baz_with_tab { */
	echo "Hi I'm baz with tab";
	/* endsection */
}

function baz_with_space()
{
    /* section:area_func_baz */
    echo "Hi I'm baz with space";
	/* endsection */
}

// section:main
function main() {
	bar();
}
// endsection

/* section:area_issue1 */
$container = new \Wandu\DI\Container();
/* endsection */
