;;; tweaks.el --- Alynx's tweak configurations. -*- lexical-binding: t; -*-

;;; Commentary:
;; Tweaks belong to no package and should be done during initialization.

;;; Code:

(require 'alynx/utils)

;; Show loading details after startup.
(add-hook 'emacs-startup-hook
          (lambda ()
            (let ((packages-activated (length package-activated-list)))
              (message
               "Emacs is ready with %s, called %s and took %s."
               (format "%d activated %s"
                       packages-activated
                       (if (> packages-activated 1) "packages" "package"))
               (format "%d garbage %s"
                       gcs-done
                       (if (> gcs-done 1) "collections" "collection"))
               (emacs-init-time "%.2fs")))))

(if (alynx/macosp)
    (add-to-list 'load-path "/opt/homebrew/share/emacs/site-lisp/")
  (add-to-list 'load-path "/usr/share/emacs/site-lisp/"))
;; Non-ELPA packages.
(add-to-list 'load-path (locate-user-emacs-file "site-lisp/"))

;; Create local dir to redirect package-generated files.
;;
;; It's better not to move `eln-cache` and `elpa` into local dir, `eln-cache` is
;; defined in `native-comp-eln-load-path`, which is a list contains user one and
;; system one, I am even not sure whether this is used to save compiled cache,
;; maybe it's only used to load. `elpa` is defined in `package-user-dir`, I
;; don't want to modify it, either.
;;
;; The last non-nil argument makes `make-directory` silience if dir exists.
(make-directory (locate-user-emacs-file ".local/") t)
;; Cache dir which contains package caches that you can safely remove it.
(make-directory (locate-user-emacs-file ".local/cache/") t)
;; Backup dir which contains backup files and auto save lists.
(make-directory (locate-user-emacs-file ".local/backup/") t)

;; `make-variable-buffer-local` must be called at toplevel.
;;
;; In order to set it per-project in `.dir-locals.el`.
(make-variable-buffer-local 'compile-command)

;; On macOS we set PATH in shell profile, so if we are not starting Emacs from
;; shell (for example from launchpad), it cannot get PATH correctly, but we need
;; it to load `lsp-bridge`.
(when (alynx/macosp)
  (add-to-list 'exec-path (expand-file-name "~/bin"))
  (add-to-list 'exec-path (expand-file-name "/opt/homebrew/bin"))
  (setenv "PATH" (format "%s:%s:%s"
                         (expand-file-name "/opt/homebrew/bin")
                         (expand-file-name "~/bin")
                         (getenv "PATH"))))

(when (featurep 'ns)
  (defun alynx/sync-ns-appearance (theme)
    "Sync native appearance with THEME."
    (let* ((properties (get theme 'theme-properties))
           (appearance (plist-get properties :background-mode)))
      (when (memq appearance '(light dark))
        (modify-all-frames-parameters `((ns-appearance . ,appearance))))))
  (add-hook 'enable-theme-functions 'alynx/sync-ns-appearance))

(provide 'alynx/tweaks)

;;; tweaks.el ends here.
