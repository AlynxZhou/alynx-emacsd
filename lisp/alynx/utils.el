;;; utils.el --- Alynx's utils configurations. -*- lexical-binding: t; -*-

;;; Commentary:
;; Common helpers and utils required by other modules.

;;; Code:

;; According to Emacs Lisp naming conventions, add `p` for single word and add
;; `-p` for multiple words.

(defun alynx/macosp ()
  "Check whether current system is macOS."
  (eq system-type 'darwin))

(defun alynx/clamp (num low high)
  "Clamp NUM between LOW and HIGH."
  (max low (min num high)))

(provide 'alynx/utils)

;;; utils.el ends here.
