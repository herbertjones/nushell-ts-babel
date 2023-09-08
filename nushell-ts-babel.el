;;; nushell-ts-babel.el --- org babel support for Nushell  -*- lexical-binding: t; -*-

;; Copyright (C) 2022-2023 Free Software Foundation, Inc.

;; Author     : Herbert Jones <jones.herbert@gmail.com>
;; Maintainer : Herbert Jones <jones.herbert@gmail.com>
;; Created    : September 2023
;; Homepage   : https://github.com/herbertjones/nushell-ts-babel
;; Keywords   : nu nushell org-mode org-babel

;; Package-Version: 0.0.1
;; Package-Requires: ((emacs "29.1") (nushell-ts-mode "0.0.1"))

;; SPDX-License-Identifier: GPL-3.0-or-later

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; This package enables syntax highlighting and code execution of nushell code
;; inside of org-mode source code blocks.

;;; Code:

(require 'org-src)
(require 'ob-core)

(require 'nushell-ts-mode)

(defcustom nushell-ts-babel-nu-path "nu"
  "Path to the Nushell \"nu\" command."
  :type 'string
  :group 'nushell-ts-babel)

(defun org-babel-variable-assignments:nushell (params)
  "Return a list of Nushell const statements.

PARAMS is a quasi-alist of header args, which may contain
multiple entries for the key `:var'.  This function returns a
list of the cdr of all the `:var' entries."
  (mapcar
   (lambda (pair)
     (format "const %s = \"%s\""
             (car pair)
             (cdr pair)))
   (org-babel--get-vars params)))

;; Define a function to execute code for your custom language
(defun org-babel-execute:nushell (body params)
  "Execute a block of Nushell commands with Babel.
This function is called by `org-babel-execute-src-block'.

BODY is expanded using PARAMS."
  (let ((tmp-src-file (org-babel-temp-file "nushell-src-" ".nu"))
        (full-body
         (org-babel-expand-body:generic body params
          (org-babel-variable-assignments:nushell params))))
    (with-temp-file tmp-src-file
      (insert full-body))
    (let ((results (org-babel-eval (concat nushell-ts-babel-nu-path " --no-config-file " tmp-src-file) "")))
      (when results
        (setq results (org-trim (org-remove-indentation results)))
        (org-babel-reassemble-table
         (org-babel-result-cond (cdr (assq :result-params params))
           (org-babel-read results t)
           (let ((tmp-file (org-babel-temp-file "nushell-")))
             (with-temp-file tmp-file (insert results))
             (org-babel-import-elisp-from-file tmp-file)))
         (org-babel-pick-name
          (cdr (assq :colname-names params)) (cdr (assq :colnames params)))
         (org-babel-pick-name
          (cdr (assq :rowname-names params)) (cdr (assq :rownames params))))))))

;; Connect the language to your custom major mode for syntax highlighting
(add-to-list 'org-src-lang-modes '("nushell" . nushell-ts))

(provide 'nushell-ts-babel)

;;; nushell-ts-babel.el ends here
