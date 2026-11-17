;;; utils.el --- Alynx's util configurations. -*- lexical-binding: t; -*-

;;; Commentary:
;; Common helper functions required by other modules.

;;; Code:

(defun alynx/macos-p ()
  "Check whether current system is macOS."
  (eq system-type 'darwin))

(provide 'alynx/utils)

;;; utils.el ends here.
