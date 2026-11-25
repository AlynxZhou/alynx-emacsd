;;; packages-editing.el --- Alynx's editing packages configurations. -*- lexical-binding: t; -*-

;;; Commentary:
;; Editing-related package-specific configurations.

;;; Code:

(require 'alynx/utils)

(use-package files
  :bind (("C-x M-f" . find-sibling-file)
         ("C-c C-f" . find-file-other-window)
         ("C-c r" . revert-buffer)
         ("<f5>" . revert-buffer))
  :custom
  (find-file-visit-truename t)
  (find-file-suppress-same-file-warnings nil)
  (find-sibling-rules '(("\\([^/]+\\)\\.c\\'" "\\1.h")
                        ("\\([^/]+\\)\\.h\\'" "\\1.c")
                        ("\\([^/]+\\)\\.rej\\'" "\\1")))
  ;; Backup file is generated when you save file. Autosave file is generated
  ;; every few seconds or every few characters.
  ;;
  ;; See <https://emacsredux.com/blog/2013/05/09/keep-backup-and-auto-save-files-out-of-the-way/>.
  ;;
  ;; Disable backup files.
  (make-backup-files nil)
  ;; Move backup files into backup dir.
  (backup-directory-alist `(("." . ,(locate-user-emacs-file ".local/backup/"))))
  (auto-save-file-name-transforms
   `((".*" ,(locate-user-emacs-file ".local/backup/") t))))

(use-package simple
  ;; :config
  ;; This only affects the built-in mode line.
  ;; (line-number-mode 1)
  ;; (column-number-mode 1)
  ;; This makes it hard to copy spaces so I disable it.
  ;; (kill-ring-deindent-mode 1)
  :custom
  ;; By default if you press backspace on indentations, Emacs will turn a tab
  ;; into spaces and delete one space, I think no one likes this.
  (backward-delete-char-untabify-method nil)
  (kill-do-not-save-duplicates t)
  (shell-command-prompt-show-cwd t))

;; See <https://dougie.io/emacs/indentation/>.
;;
;; Auto-indent line when pressing enter.
(use-package electric
  :defer t
  :custom
  ;; Looks like `:custom` can handle `setq-default` correctly.
  (electric-indent-inhibit nil))

(use-package mouse
  :defer t
  :custom
  ;; Yank to cursor, not where mouse clicked.
  (mouse-yank-at-point t))

(use-package xt-mouse
  :config
  (xterm-mouse-mode 1))

;; Typing chars will replace selection, this is the default behavior of most
;; editors.
(use-package delsel
  :config
  (delete-selection-mode 1))

;; Atom style indent left or right.
;;
;; TODO: Currently they will indent by a `tab-width`, I want to modify them to
;; use `indent-offset`. But I find just re-indent with `TAB` is enough, I hardly
;; need to manually tweak indent levels.
;;
;; See <https://dougie.io/emacs/indent-selection/>.
;;
;; NOTE: `M-[` happens to be the terminal escape prefix `\e[` (`Esc [`) so we
;; cannot use it, otherwise escape sequences will be directly inserted into
;; buffer because the prefix is handled as keybinding. For example, with iTerm2,
;; if you focus out and focus in it, you'll see `OI` inserted into buffer,
;; because they are `\e[O` and `\e[I`.
;; (use-package indent
;;   :bind (("M-[" . indent-rigidly-left-to-tab-stop)
;;          ("M-[" . indent-rigidly-left-to-tab-stop)))

;; I use this in Atom.
(use-package newcomment
  :bind (("C-;" . comment-dwim)))

;; Better keybindings for replace, because `isearch-backward` is hardly used.
(use-package replace
  :bind (("C-r" . query-replace)
         ("C-M-r" . query-replace-regexp))
  :custom
  ;; No, don't do case insensitive replace.
  (case-fold-search nil))

;; Atom-like move regine / current line up and down.
(use-package move-text
  :ensure t
  :bind (("M-p" . move-text-up)
         ("M-n" . move-text-down)))

;; If there is no region, behave like current line is current region like Atom.
;;
;; Works on indent / outdent, comment block, cut (kill), copy, paste (yank).
(use-package whole-line-or-region
  :ensure t
  :demand t
  ;; See <https://github.com/purcell/whole-line-or-region/commit/ba193b2034388bbc384cb04093150fca56f7e262>.
  :bind (:map whole-line-or-region-local-mode-map
              ([remap indent-rigidly-left-to-tab-stop] . whole-line-or-region-indent-rigidly-left-to-tab-stop)
              ([remap indent-rigidly-right-to-tab-stop] . whole-line-or-region-indent-rigidly-right-to-tab-stop))
  :config
  (whole-line-or-region-global-mode 1))

;; Redo like most editors.
(use-package undo-tree
  :ensure t
  :config
  (global-undo-tree-mode 1)
  :custom
  ;; Why you guys always generate garbage in project dir by default?
  (undo-tree-history-directory-alist
   `(("." . ,(locate-user-emacs-file ".local/undo-tree/")))))

(use-package editorconfig
  :ensure t
  :config
  (editorconfig-mode 1))

;; Not sure why it does not work for me. It always set to English even I
;; manually switched to RIME. I also want to use Chinese for `find-file` or
;; `consult-line`.
;; (use-package sis
;;   :ensure t
;;   :disabled t
;;   :init
;;   (setq sis-respect-start nil)
;;   :config
;;   (sis-ism-lazyman-config "xkb:us::eng" "rime" 'ibus)
;;   (sis-global-respect-mode t))

;; Dependency of `lsp-bridge`.
(use-package yasnippet
  :ensure t
  :hook ((prog-mode . yas-minor-mode))
  :config
  ;; OK, I finally give up, maybe I need to sync snippets so don't exclude them.
  (make-directory (locate-user-emacs-file "snippets/") t))

;; Dependency of `lsp-bridge`.
(use-package yasnippet-snippets
  :ensure t
  :defer t)

(provide 'alynx/packages-editing)

;;; packages-editing.el ends here.
