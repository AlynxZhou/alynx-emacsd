;;; appearance.el --- Alynx's appearance configurations. -*- lexical-binding: t; -*-

;;; Commentary:
;; Appearance-related configurations.

;;; Code:

(require 'alynx/utils)

(defvar alynx/transparent nil
  "Whether frame transparency is enabled.")
(defun toggle-transparency ()
  "Toggle transparency for all frames."
  (interactive)
  (setq alynx/transparent (not alynx/transparent))
  (let ((key (if (featurep 'ns) 'alpha 'alpha-background))
        (value (if alynx/transparent 95 100)))
    (modify-all-frames-parameters `((,key . ,value)))))

(when (featurep 'ns)
  (defun alynx/sync-ns-appearance (theme)
    "Sync native appearance with THEME."
    (let* ((properties (get theme 'theme-properties))
           (appearance (plist-get properties :background-mode)))
      (when (memq appearance '(light dark))
        (modify-all-frames-parameters `((ns-appearance . ,appearance))))))
  (add-hook 'enable-theme-functions 'alynx/sync-ns-appearance))

(provide 'alynx/appearance)

;;; appearance.el ends here.
