;;; utils.el --- Alynx's util configurations. -*- lexical-binding: t; -*-

;;; Commentary:
;; Common helper functions required by other modules.

;;; Code:

;; According to Emacs Lisp naming conventions, add `p` for single word and add
;; `-p` for multiple words.

(defun alynx/macosp ()
  "Check whether current system is macOS."
  (eq system-type 'darwin))

(provide 'alynx/utils)

;;; utils.el ends here.
