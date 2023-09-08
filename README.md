# Nushell Tree-Sitter Babel Integration

[![License GPL 3](https://img.shields.io/badge/license-GPL_3-green.svg)](http://www.gnu.org/licenses/gpl-3.0.txt)

Add org-babel support for [nushell-ts-mode](https://github.com/herbertjones/nushell-ts-mode).

## Features

* Highlighting
* Execute source code blocks


## Installation

### Install package

You will need to clone the repo and load it manually or use whatever package manager you use.

```emacs-lisp
(straight-use-package
 '(nushell-ts-babel :type git :host github :repo "herbertjones/nushell-ts-babel"))
```

For instance, on my system I have:
```emacs-lisp
(with-eval-after-load 'org-contrib
    (org-babel-do-load-languages
     'org-babel-load-languages
     '((emacs-lisp . t)
       ;; ...
       (nushell . t))))
```
