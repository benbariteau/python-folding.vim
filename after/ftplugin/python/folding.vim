func! Python_folding(lnum)
python << EOF
import vim
import re

import_re = re.compile('^\\b(import|from)\\b')
blank_re = re.compile('^\\s*$')
class_re = re.compile('^\\bclass\\b')
func_re = re.compile('^(\\s*)\\bdef\\b')
decorator_re = re.compile('^(\\s*)@')

def getline(lnum):
    return vim.eval('getline({0})'.format(lnum))

def indent_match(lnum, spaces):
    if len(spaces) == 0:
        # this is a top-level function
        return '>1'

    curr = lnum - 1
    current = getline(curr)
    while not (class_re.search(current) or func_re.search(current)):
        curr -= 1
        current = getline(curr)

    if class_re.search(current):
        # this is a method
        return '>2'
    else:
        prev_func_match = func_re.search(current)
        prev_spaces = prev_func_match.group(1)
        if len(spaces) > len(prev_spaces):
            # this is a nested function, don't fold
            return '='
        else:
            # method
            return '>2'
    return '>1'

def foldexpr(lnum):
    current_line = getline(lnum)
    previous_line = getline(lnum-1)
    previous2_line = getline(lnum-2)
    next_line = getline(lnum+1)
    next2_line = getline(lnum+2)

    if (
        import_re.search(current_line) and
        not import_re.search(previous_line) and
        not import_re.search(previous2_line)
    ):
        return '>1'

    if (
        import_re.search(current_line) and
        not import_re.search(next_line) and
        not import_re.search(next2_line)
    ):
        return '<1'

    if class_re.search(current_line):
        return '>1'

    func_match = func_re.search(current_line)
    if (
        func_match and
        not decorator_re.search(previous_line)
    ):
        spaces = func_match.group(1)
        return indent_match(lnum, spaces)

    decorator_match = decorator_re.search(current_line)
    if (
        decorator_match and
        not decorator_re.search(previous_line)
    ):
        spaces = decorator_match.group(1)
        return indent_match(lnum, spaces)

    return '='

lnum = int(vim.eval('a:lnum'))

fold = foldexpr(lnum)

vim.command("let foldval = '{0}'".format(fold))
EOF
return foldval
endfunc

func! Python_foldtext()
python << EOF
import string


def foldtext(foldstart, foldend):
    current = foldstart
    start_line = vim.eval('getline({0})'.format(foldstart))
    current_line = start_line

    import_re = re.compile('^\\b(import|from)\\b')
    decorator_re = re.compile('^\\s*@')
    method_re = re.compile('^\\s+\\bdef\\b')
    def_re = re.compile('^\\s*\\bdef\\b')
    enddef_re = re.compile('\\):$')

    if import_re.search(start_line):
        return 'import ...'

    if decorator_re.search(start_line):
        while not def_re.search(current_line):
            current += 1
            current_line = getline(current)

    if (
        def_re.search(current_line) and
        not enddef_re.search(current_line)
    ):
        beginning_line = current_line
        signature_parts = list()
        while not enddef_re.search(getline(current+1)):
            current += 1
            signature_parts.append(
                string.strip(
                    getline(current),
                ).replace(',', ''),
            )
        current_line = beginning_line + ', '.join(signature_parts) + string.strip(getline(current+1))

    return current_line

foldstart = int(vim.eval('v:foldstart'))
foldend = int(vim.eval('v:foldend'))

text = foldtext(foldstart, foldend)
text = text + ' ({0} lines)'.format(foldend-foldstart)

vim.command("let text = '{0}'".format(text))
EOF
return text
endfunc

setlocal foldexpr=Python_folding(v:lnum)
setlocal foldtext=Python_foldtext()
setlocal foldmethod=expr
setlocal foldcolumn=3
