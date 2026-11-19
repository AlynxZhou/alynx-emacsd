;;; packages-org.el --- Alynx's org package configurations. -*- lexical-binding: t; -*-

;;; Commentary:
;; Org related package-specific configurations.

;;; Code:

(require 'alynx/utils)

(use-package org
  :ensure t
  :bind (("C-c a" . org-agenda)
         ("C-c c" . org-capture)
         ("C-c l" . org-store-link))
  :config
  (make-directory org-directory t)
  :custom
  (org-directory (expand-file-name "~/org"))
  (org-default-notes-file (expand-file-name "notes.org" org-directory))
  (org-agenda-files `(,org-default-notes-file))
  (org-capture-templates '(("t" "Task 任务" entry
                            (file+headline org-default-notes-file "任务")
                            "* TODO %<%Y-%m-%d %H:%M:%S> %?\n")
                           ("n" "Note 笔记" entry
                            (file+headline org-default-notes-file "笔记")
                            "* %<%Y-%m-%d %H:%M:%S> %?\n")
                           ("j" "Journal 日志" entry
                            (file+olp+datetree org-default-notes-file "日志")
                            "* %<%Y-%m-%d %H:%M:%S> %?\n")))
  (org-refile-targets '((org-agenda-files :maxlevel . 3)))
  ;; Record time when task is done.
  (org-log-done 'time)
  (org-hide-emphasis-markers t)
  (org-agenda-skip-scheduled-if-done t)
  (org-agenda-skip-deadline-if-done t)
  (org-refile-use-outline-path 'file)
  (org-outline-path-complete-in-steps nil))

(use-package org-bullets
  :ensure t
  :hook ((org-mode . org-bullets-mode)))

;; Works with `org-hide-emphasis`.
(use-package org-appear
  :ensure t
  :hook ((org-mode . org-appear-mode))
  :custom
  (org-appear-delay 0.5))

(provide 'alynx/packages-org)

;;; packages-org.el ends here.
