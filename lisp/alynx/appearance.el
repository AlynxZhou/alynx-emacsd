;;; appearance.el --- Alynx's appearance configurations. -*- lexical-binding: t; -*-

;;; Commentary:
;; Appearance-related configurations.

;;; Code:

(require 'alynx/utils)

(defvar alynx/transparent nil
  "Whether frame transparency is enabled.")
(defvar alynx/opacity 95
  "Opacity of all frames.")
(defun toggle-transparency ()
  "Toggle transparency for all frames."
  (interactive)
  (setq alynx/transparent (not alynx/transparent))
  (let ((key (if (featurep 'ns) 'alpha 'alpha-background))
        (value (if alynx/transparent alynx/opacity 100)))
    (modify-all-frames-parameters `((,key . ,value)))))
;; Emacs has a lowest opacity of 10 so we can safely accept `0`.
(defun set-opacity (num)
  "Set opacity to NUM percents."
  (interactive `(,(read-number "Opacity (0-100): ")))
  (cond
   ((< num 0) (setq alynx/opacity 0))
   ((> num 100) (setq alynx/opacity 100))
   (t (setq alynx/opacity num)))
  (setq alynx/transparent nil)
  (toggle-transparency))

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
