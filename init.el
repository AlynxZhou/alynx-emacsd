;;; init.el --- Alynx's init configurations. -*- lexical-binding: t; -*-

;;; Commentary:
;; Entry for each configuration modules under `lisp/alynx/`.

;;; Code:

(add-to-list 'load-path (locate-user-emacs-file "lisp/"))

;; Sequence matters.
(require 'alynx/utils)
(require 'alynx/tweaks)
(require 'alynx/fonts)
(require 'alynx/indentations)
(require 'alynx/keybindings)
(require 'alynx/packages)

;;; init.el ends here.
