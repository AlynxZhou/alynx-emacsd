;;; packages-magit.el --- Alynx's Magit packages configurations. -*- lexical-binding: t; -*-

;;; Commentary:
;; Magit-related package-specific configurations.

;;; Code:

(require 'alynx/utils)

(use-package magit
  :ensure t
  :bind (("C-x g" . magit-status))
  :hook ((magit-mode . (lambda () (toggle-truncate-lines -1))))
  :custom
  ;; Without line numbers, fringe is too small to see.
  (magit-section-disable-line-numbers nil))

(provide 'alynx/packages-magit)

;;; packages-magit.el ends here.
