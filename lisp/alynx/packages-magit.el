;;; packages-magit.el --- Alynx's Magit packages configurations. -*- lexical-binding: t; -*-

;;; Commentary:
;; Magit-related package-specific configurations.

;;; Code:

(require 'alynx/utils)

(require 'alynx/appearance)

(use-package magit
  :ensure t
  ;; Load Magit as soon as possible, so it will process all Git related buffers.
  ;; Ideally we should never defer it, but it is too heavy.
  :defer 1
  :bind (("C-x g" . magit-status))
  :hook ((magit-mode . (lambda () (toggle-truncate-lines -1)))
         (git-commit-setup . (lambda () (set-fill-column-indicator 72))))
  :custom
  ;; Without line numbers, fringe is too small to see.
  (magit-section-disable-line-numbers nil))

(provide 'alynx/packages-magit)

;;; packages-magit.el ends here.
