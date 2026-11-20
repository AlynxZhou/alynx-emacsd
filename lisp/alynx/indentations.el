;;; indentations.el --- Alynx's indentations configurations. -*- lexical-binding: t; -*-

;;; Commentary:
;; The correct way to indent code in Emacs.

;;; Code:

(require 'alynx/utils)

;; The ultimate solution to set different indent offsets for different modes, and
;; automatically guess indent offset from file content.
;;
;; Those are the default settings, which means if major mode does not set those
;; value, I'll use tabs and it's length should be 8 chars.

;; Making tab other length than 8 sounds like define PI to 3, if you don't want
;; 8, you should also use spaces instead of tabs.
(setq-default tab-width 8)
;; `indent-tabs-mode` does not mean use tabs only, it means if the indent level
;; can be divided by `tab-width`, use tabs, and use spaces for the remaining.
(setq-default indent-tabs-mode t)

;; Based on `editorconfig-indentation-alist` and `doom-modeline-indent-alist`.
;;
;; See <https://github.com/editorconfig/editorconfig-emacs/blob/master/editorconfig.el#L175>.
;;
;; See <https://github.com/seagle0128/doom-modeline/blob/master/doom-modeline-core.el#L282>.
(defconst alynx/mode-indent-offsets
  '((apache-mode apache-indent-level)
    (awk-mode c-basic-offset)
    (bpftrace-mode c-basic-offset)
    (c-mode c-basic-offset)
    (c-ts-mode c-ts-mode-indent-offset)
    (c++-mode c-basic-offset)
    (c++-ts-mode c-ts-mode-indent-offset)
    (cmake-mode cmake-tab-width)
    (cmake-ts-mode cmake-ts-mode-indent-offset)
    (coffee-mode coffee-tab-width)
    (cperl-mode cperl-indent-level)
    (crystal-mode crystal-indent-level)
    (csharp-mode c-basic-offset)
    (css-mode css-indent-offset)
    (css-ts-mode css-indent-offset)
    (d-mode c-basic-offset)
    (emacs-lisp-mode lisp-indent-offset)
    (enh-ruby-mode enh-ruby-indent-level)
    (erlang-mode erlang-indent-level)
    (ess-mode ess-indent-offset)
    (f90-mode f90-associate-indent
              f90-continuation-indent
              f90-critical-indent
              f90-do-indent
              f90-if-indent
              f90-program-indent
              f90-type-indent)
    (feature-mode feature-indent-offset
                  feature-indent-level)
    (fsharp-mode fsharp-continuation-offset
                 fsharp-indent-level
                 fsharp-indent-offset)
    (groovy-mode groovy-indent-offset)
    (haskell-mode haskell-indent-spaces
                  haskell-indent-offset
                  haskell-indentation-layout-offset
                  haskell-indentation-left-offset
                  haskell-indentation-starter-offset
                  haskell-indentation-where-post-offset
                  haskell-indentation-where-pre-offset
                  shm-indent-spaces)
    (haxor-mode haxor-tab-width)
    (idl-mode c-basic-offset)
    (jade-mode jade-tab-width)
    (java-mode c-basic-offset)
    (js-mode js-indent-level)
    (js-ts-mode js-indent-level)
    (js-jsx-mode js-indent-level sgml-basic-offset)
    (js2-mode js2-basic-offset)
    (js2-jsx-mode js2-basic-offset sgml-basic-offset)
    (js3-mode js3-indent-level)
    (json-mode js-indent-level)
    (json-ts-mode json-ts-mode-indent-offset)
    (julia-mode julia-indent-offset)
    (kotlin-mode kotlin-tab-width)
    (latex-mode tex-indent-basic)
    (lisp-mode lisp-indent-offset)
    (lisp-interaction-mode lisp-indent-offset)
    (livescript-mode livescript-tab-width)
    (lua-mode lua-indent-level)
    (matlab-mode matlab-indent-level)
    (meson-mode meson-indent-basic)
    (mips-mode mips-tab-width)
    (mustache-mode mustache-basic-offset)
    (nasm-mode nasm-basic-offset)
    (nginx-mode nginx-indent-level)
    (nxml-mode nxml-child-indent)
    (objc-mode c-basic-offset)
    (octave-mode octave-block-offset)
    (perl-mode perl-indent-level)
    (php-mode c-basic-offset)
    (pike-mode c-basic-offset)
    (ps-mode ps-mode-tab)
    (pug-mode pug-tab-width)
    (puppet-mode puppet-indent-level)
    (python-mode python-indent-offset)
    (python-ts-mode python-indent-offset)
    (rjsx-mode js-indent-level sgml-basic-offset)
    (ruby-mode ruby-indent-level)
    (rust-mode rust-indent-offset)
    (rustic-mode rustic-indent-offset)
    (scala-mode scala-indent:step)
    (scss-mode css-indent-offset)
    (sgml-mode sgml-basic-offset)
    (sh-mode sh-basic-offset sh-indentation)
    (slim-mode slim-indent-offset)
    (sml-mode sml-indent-level)
    (tcl-mode tcl-indent-level
              tcl-continued-indent-level)
    (terra-mode terra-indent-level)
    (typescript-mode typescript-indent-level)
    (typescript-ts-base-mode typescript-ts-mode-indent-offset)
    (typescript-ts-mode typescript-ts-mode-indent-offset)
    (verilog-mode verilog-indent-level
                  verilog-indent-level-behavioral
                  verilog-indent-level-declaration
                  verilog-indent-level-module
                  verilog-cexp-indent
                  verilog-case-indent)
    (web-mode web-mode-attr-indent-offset
              web-mode-attr-value-indent-offset
              web-mode-code-indent-offset
              web-mode-css-indent-offset
              web-mode-markup-indent-offset
              web-mode-sql-indent-offset
              web-mode-block-padding
              web-mode-script-padding
              web-mode-style-padding)
    (yaml-mode yaml-indent-offset))
  "Indent offset variables of different major modes.
If a major mode has different indent offset variables, all of them will be set
in order.")

(defun alynx/get-mode-indent-offsets ()
  "Get indent offset variables of current major mode."
  (cdr (assoc major-mode alynx/mode-indent-offsets)))

;; If you quote a list, not only itself, but it's elements won't be evaluated,
;; either, `interactive` wants a list of integers to fill arguments, so we
;; can't quote here, because we need to evaluate `read-number`.
;;
;; Using `list` will evaluate elements and return a list, using `\`` with `,`
;; can quote but evaluate selected elements.
(defun set-indent-offset (num)
  "Set indent offset to NUM chars.
If NUM is negative, indent offset will be nil."
  (interactive `(,(read-number "Indent offset (chars): ")))
  (dolist (mode-indent-offset (alynx/get-mode-indent-offsets))
    ;; We change the actual offset variable, so use `set` instead of `setq` here.
    ;; `setq` sets buffer-local value automatically, but we need to do this
    ;; manually for `set`.
    (make-local-variable mode-indent-offset)
    (if (< num 0)
        (set mode-indent-offset nil)
      (set mode-indent-offset num))))

(defun indent-tabs (num)
  "Mark this buffer to indent with tabs and set indent offset to NUM chars.
If NUM is negative, indent offset will be nil."
  (interactive `(,(read-number "Indent offset (chars): ")))
  (indent-tabs-mode 1)
  (set-indent-offset num))

(defun indent-spaces (num)
  "Mark this buffer to indent with spaces and set indent offset to NUM chars.
If NUM is negative, indent offset will be nil."
  (interactive `(,(read-number "Indent offset (chars): ")))
  (indent-tabs-mode -1)
  (set-indent-offset num))

;; Most projects saying that they are using 2 as `tab-width` actually means they
;; are using 2 as `indent-offset`. If you don't use spaces to indent,
;; `tab-width` has no meaning for you. You should call `(indent-spaces 2)` for
;; those projects.
;;
;; There are also other projects like GTK using 2 as `indent-offset`, and they
;; actually also assume `tab-width` is 8 and use tabs to indent. If you set
;; `tab-width` to 2, you'll find some 4-level code is 1-level, which is wrong.
;; You should call `(indent-tabs 2)` for those projects.
;;
;; So most of time you should not change `tab-width`, but maybe some crazy
;; projects use tabs for indent and they don't want `tab-width` to be 8, then
;; call this via `M-x` manually. I personally think they should use 2 spaces.
(defun set-tab-width (num)
  "Mark this buffer to set tab width to NUM chars."
  (interactive `(,(read-number "Tab width (chars): " tab-width)))
  (when (/= tab-width num)
    (setq tab-width num)))

(defconst alynx/skip-guess-indent-modes '(lisp-mode
                                          emacs-lisp-mode
                                          lisp-interaction-mode)
  "Don't guess indent for those major modes.")

;; This function is not perfect, it is based on that "if the file is indented
;; with spaces, lines are never started with tabs, and the shortest space prefix
;; length except 0 or 1 is the indent offset".
;;
;; For example, projects like GTK uses 2 spaces per indent level, we will have
;; following lines:
;; 	1. 0 space prefix (preprocessors).
;; 	2. 1 space prefix (comment content of the first level comment blocks).
;; 	3. 2 spaces prefix (1 indent level, indent offset we want).
;; 	4. 4 spaces prefix (2 indent levels).
;; 	5. 6 spaces prefix (3 indent levels).
;; 	6. 1 tab prefix (4 indent levels, use tab).
;; 	7. 1 tab and 2 spaces prefix (5 indent levels).
;; 	(more...)
;;
;; This function cannot handle condition that first you use tab to indent and
;; you have the following code:
;;
;; ```c
;; int a(int b,
;;       int c);
;; ```
;;
;; Here you use 5 spaces to align arguments, and this function will use 5 spaces
;; per indent level. A proper but impossible solution is ignore function header,
;; because obviously editors cannot understand every languages. We may also
;; record space or tab lines and do some comparation, but that's not precious.
;;
;; Anyway, this function is just guessing indentation, so user should correct it
;; manually if it returns wrong value.
(defun guess-indent ()
  "Guess and set indent-offset and tab/space for current buffer."
  (interactive)
  (if (memq major-mode alynx/skip-guess-indent-modes)
      (message "Skip guess-indent for %s." major-mode)
    ;; Ideally we should iterate the whole buffer, but that's impossible for big
    ;; files. Let's assume we always have 1-level indented code in the first 200
    ;; lines.
    (let ((shortest-spaces 0)
          (has-tab nil))
      (save-mark-and-excursion
        (save-restriction
          (widen)
          (goto-char (point-min))
          (let ((lines 0))
            (while (and (< lines 200) (not (eobp)))
              (cond
               ;; We assume no one uses indent offset which is larger than 1 tab
               ;; width, so there won't be 1 tab plus 2 spaces as 1 level. We
               ;; also assume there is no line that contains only tabs.
               ((eq (char-after) ?\t) (setq has-tab t))
               ((eq (char-after) ?\s)
                ;; Calculate how many spaces in prefix.
                (let ((spaces (skip-chars-forward " ")))
                  ;; You may have lines only contains spaces in a file that
                  ;; indented with tabs. Just ignore those lines.
                  ;;
                  ;; Let's assume no one uses 1-char indent offset.
                  (when (and (not (memq (char-after) '(nil ?\n ?\r)))
                             (> spaces 1)
                             (or (= shortest-spaces 0)
                                 (< spaces shortest-spaces)))
                    (setq shortest-spaces spaces)))))
              (forward-line 1)
              (setq lines (1+ lines))))))
      ;; If a file uses tabs to indent, and we cannot get shortest spaces, this
      ;; file is likely to only use tabs, and the indent offset is tab width,
      ;; otherwise the shortest spaces length is indent offset.
      ;;
      ;; If we don't find tabs, just assume this file does not use tabs, this is
      ;; not correct because we may just not have tabs in first 200 lines but
      ;; that is the best effort we can do. And then if we cannot get shortest
      ;; spaces, it means that there is no indent level in first 200 lines, so
      ;; just skip it.
      (if has-tab
          (if (/= shortest-spaces 0)
              (indent-tabs shortest-spaces)
            (indent-tabs tab-width))
        (when (/= shortest-spaces 0)
          (indent-spaces shortest-spaces))))))

;; If installed more modes, add them here as
;; `(mode-name tab/space indent-offset)`.
(defconst alynx/modes-default-indent '((prog-mode tab 8)
                                       (c-mode tab 8)
                                       (c-ts-mode tab 8)
                                       (java-mode tab 8)
                                       (markdown-mode tab 8)
                                       (gfm-mode tab 8)
                                       ;; By default `lisp-indent-offset` is
                                       ;; `nil`, which works better.
                                       (lisp-mode space -1)
                                       (emacs-lisp-mode space -1)
                                       (lisp-interaction-mode space -1)
                                       (js-mode space 2)
                                       (js2-mode space 2)
                                       (json-ts-mode space 2)
                                       (typescript-ts-mode space 2)
                                       (css-mode space 2)
                                       (html-mode space 2)
                                       (nxml-mode space 2)
                                       (web-mode space 2)
                                       (yaml-mode space 2)
                                       ;; `yaml-ts-mode` is a `text-mode`, it
                                       ;; has no indent offset variable and tab
                                       ;; is used to align, so this just let it
                                       ;; use spaces.
                                       (yaml-ts-mode space -1)
                                       (meson-mode space 2)
                                       (lua-mode space 3)
                                       (python-mode space 4))
  "Default indentation for different modes.")

;; Instead of add hook to different mode, we just use
;; `change-major-mode-after-body-hook`, Emacs will run this hook first when
;; changing major mode, then our function is called to set default value, then
;; we may guess indent from the buffer, and then project's `.editorconfig` is
;; loaded, and then our custom `.dir-local.el` is loaded, then
;; `after-change-major-mode-hook` is called.
;;
;; See <https://github.com/editorconfig/editorconfig-emacs/issues/141>.
;;
;; `add-hook` by default adds function to the beginning of hook, so add
;; `guess-indent` first and it will run last.
(add-hook 'change-major-mode-after-body-hook 'guess-indent)

(add-hook 'change-major-mode-after-body-hook
          (lambda ()
            ;; Check which list our current `major-mode` is inside.
            (let* ((pair (assq major-mode alynx/modes-default-indent))
                   (mode (nth 1 pair))
                   (indent-offset (nth 2 pair)))
              (cond
               ((eq mode 'tab) (indent-tabs indent-offset))
               ((eq mode 'space) (indent-spaces indent-offset))))))

(provide 'alynx/indentations)

;;; indentations.el ends here.
