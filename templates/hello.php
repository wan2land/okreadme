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

function baz_with_tab()
{
	/* area_func_baz_with_tab { */
	echo "Hi I'm baz with tab";

	// end
	/* } */
}

function baz_with_space()
{
    /* area_func_baz { */
    echo "Hi I'm baz with space";

    // end
    /* } */
}

function main() {
	bar();
}


/* area_issue1 { */
$container = new \Wandu\DI\Container();
/* } */
