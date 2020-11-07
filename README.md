# python-folding.vim
Python code folding in vim

I wouldn't recommend using this as it hangs on any code that uses type annotation syntax.

So far this supports folding the following constructs:
* initial imports (might be wonky with inline ones, I haven't tried yet
* classes, functions, and methods
* decorators are included in method folding
