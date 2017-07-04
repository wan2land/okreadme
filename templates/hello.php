<?php

function dummy()
{
    // do something
}


// section:code-by-section-name
function codeBySectionName() {
    bar();
}
// endsection

class TestClass
{
    public function codeIndentMultilineMethod()
    {
        // section:code-indent-multiline
        if (something()) {
            return false;
        }
        return true;
        // endsection
    }
}