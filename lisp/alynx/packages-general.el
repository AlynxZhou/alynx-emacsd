;;; packages-general.el --- Alynx's general packages configurations. -*- lexical-binding: t; -*-

;;; Commentary:
;; General package-specific configurations.

;;; Code:

(require 'alynx/utils)

;; There is actually no `emacs` package, but it is useful if you have some
;; config that does not belong to any package and you want to manage them with
;; `use-package`.
(use-package emacs
  :hook ((minibuffer-setup . cursor-intangible-mode))
  ;; Some files does not have a major mode, and I don't want to define a major
  ;; mode for it, so just use `lambda` for them.
  ;;
  ;; NOTE: `auto-mode-alist` can only run a function for each regex, so just
  ;; add all needed settings here.
  ;;
  ;; When Magit is used, `COMMIT_EDITMSG` is handled by `git-commit-mode`.
  :mode (("COMMIT_EDITMSG\\'" . (lambda () (set-fill-column-indicator 72)))
         ;; It's a little bit strange that SUSE use 66 in changes files.
         ("\\.changes\\'" . (lambda () (set-fill-column-indicator 66)))
         ;; `osc` generate temp files for `vc`.
         ("\\.changes\\.vctmp\\." . (lambda () (set-fill-column-indicator 66))))
  :config
  ;; Contrary to what many Emacs users have in their configs, you only need this
  ;; to make UTF-8 the default coding system.
  (set-language-environment "UTF-8")
  (put 'narrow-to-region 'disabled nil)
  ;; Add prompt indicator to `completing-read-multiple`.
  ;;
  ;; We display [CRM<separator>], e.g., [CRM,] if the separator is a comma.
  ;; (defun crm-indicator (args)
  ;;   (cons (format "[CRM%s] %s"
  ;;                 (replace-regexp-in-string
  ;;                  "\\`\\[.*?]\\*\\|\\[.*?]\\*\\'" ""
  ;;                  crm-separator)
  ;;                 (car args))
  ;;         (cdr args)))
  ;; (advice-add 'completing-read-multiple :filter-args 'crm-indicator)
  :custom
  ;; Disable startup buffer. It's OK but it's not beautiful and not helpful.
  (inhibit-startup-screen t)
  ;; (fancy-splash-image (locate-user-emacs-file "emacs-e.svg"))
  (initial-scratch-message
   ";; -*- lexical-binding: t; -*-\n;; Happy hacking here!\n")
  ;; Disable annoying bell.
  (ring-bell-function 'ignore)
  ;; (visible-bell nil)
  ;; `set-language-enviornment` sets `default-input-method`, which is unwanted.
  (default-input-method nil)
  ;; Use y or n instead of yes or no.
  (use-short-answers t)
  ;; Set cursor to underline.
  (cursor-type 'hbar)
  (cursor-in-non-selected-windows nil)
  (highlight-nonselected-windows nil)
  ;; Disable line spacing, it makes `highlight-indent-guides` wired.
  ;; (line-spacing nil)
  ;; FIXME: High CPU usage on scrolling.
  ;;
  ;; By default Emacs will jump a half screen if your cursor is out of screen,
  ;; this makes it behave like other editors, but sometimes it still jumps.
  (scroll-margin 3)
  (scroll-conservatively 101)
  (scroll-preserve-screen-position t)
  (auto-window-vscroll nil)
  ;; Scaling text decorations supported in Emacs 32.
  (underline-line-scaling-flag t)
  (overline-line-scaling-flag t)
  (strike-through-line-scaling-flag t)
  ;; Decrease scrolling CPU usage.
  (fast-but-imprecise-scrolling t)
  (redisplay-skip-fontification-on-input t)
  (jit-lock-defer-time 0)
  ;; Vertico requires those.
  ;; Enable recursive minibuffers.
  (enable-recursive-minibuffers t)
  ;; Hide commands in `M-x` which do not work in the current mode. Vertico
  ;; commands are hidden in normal buffers.
  (read-extended-command-predicate #'command-completion-default-include-p)
  ;; Do not allow the cursor in the minibuffer prompt.
  (minibuffer-prompt-properties
   '(read-only t cursor-intangible t face minibuffer-prompt))
  ;; Move autosave files and list into backup dir.
  (auto-save-list-file-prefix (locate-user-emacs-file ".local/backup/.saves-"))
  ;; Prevent `.#` lock files, so we won't mess up project if crashed.
  (create-lockfiles nil)
  ;; Emacs GC is not so good now, let's see how many times we trigger it.
  (garbage-collection-messages t)
  ;; See <https://emacs-china.org/t/emacs/21053/14>.
  (process-adaptive-read-buffering nil)
  (fill-column 80)
  (show-trailing-whitespace t)
  (display-raw-bytes-as-hex t)
  (sentence-end-double-space nil)
  ;; Don't show default indicators, they are useless and ugly.
  (fringe-indicator-alist nil))

(use-package server
  :defer t
  :custom
  ;; HACK: If this is `t` with PGTK, server will try to raise new frames via
  ;; calling `gtk_window_present_with_time()`, which has some bugs like unsetting
  ;; maximized frames and still show window decorations in maximized state, just
  ;; disable it as a workaround. (Emacs itself never raises its frame, only
  ;; Emacs server does this, so I don't think it's necessary.)
  (server-raise-frame (not (featurep 'pgtk)))
  (server-log nil))

(use-package window
  :bind (("C-c C-v" . scroll-other-window)
         ("C-c M-v" . scroll-other-window-down)
         ("C-c b" . switch-to-buffer-other-window)))

(use-package windmove
  :demand t
  :bind
  (("C-c w C-n" . windmove-down)
   ("C-c w C-p" . windmove-up)
   ("C-c w C-f" . windmove-right)
   ("C-c w C-b" . windmove-left))
  :config
  ;; `S-<arrow>` to move between windows (`S` means Shift).
  (windmove-default-keybindings))

(use-package comp
  :defer t
  :custom
  ;; Silence compiler warnings as they can be pretty disruptive.
  (native-comp-async-report-warnings-errors 'silent))

(use-package compile
  :defer t
  :custom
  (compilation-scroll-output t)
  ;; Don't set that, very annoying.
  ;; (compilation-auto-jump-to-first-error t)
  (compilation-max-output-line-length nil))

(use-package project
  ;; I hardly do single-file compiling.
  :bind (("C-x c" . project-compile)
         ("<f9>" . project-compile))
  :custom
  (project-list-file (locate-user-emacs-file ".local/projects.eld")))

;; Enable `pixel-scroll-precision-mode` added in Emacs 29.
;; FIXME: Leading into strange cursor position jumping with splited windows.
;; (use-package pixel-scroll
;;   :config
;;   (pixel-scroll-precision-mode 1))

;; Always follow symlinks instead of asking, because the minibuffer prompt might
;; be covered by other messages.
(use-package vc-hooks
  :defer t
  :custom
  (vc-follow-symlinks t))

;; Built-in minor mode to save recent files.
(use-package recentf
  ;; `ivy-use-virtual-buffers` and `consult-buffer` need it.
  :config
  (recentf-mode 1)
  :custom
  (recentf-save-file (locate-user-emacs-file ".local/recentf")))

;; Built-in minor mode to open files at last-edited position.
(use-package saveplace
  ;; Don't defer this if you want it to work on the first file you opened.
  :config
  (save-place-mode 1)
  :custom
  (save-place-file (locate-user-emacs-file ".local/places")))

(use-package savehist
  :config
  (add-to-list 'savehist-additional-variables 'kill-ring)
  (savehist-mode 1)
  :custom
  (savehist-file (locate-user-emacs-file ".local/history")))

(use-package autorevert
  :config
  (global-auto-revert-mode 1))

;; List dirs first in dired.
(use-package ls-lisp
  :defer t
  :custom
  (ls-lisp-dirs-first t))

(use-package dired
  :hook ((dired-mode . diff-hl-dired-mode))
  :custom
  (dired-dwim-target t)
  (dired-listing-switches "-alh --group-directories-first"))

;; See <https://git.savannah.gnu.org/cgit/emacs.git/tree/admin/notes/tree-sitter/starter-guide?h=feature/tree-sitter>.
;;
;; Building <https://github.com/casouri/tree-sitter-module/> is needed, because
;; the release is not up to date sometimes.
;;
;; Articles from the feature author are also helpful.
;;
;; See <https://archive.casouri.cc/note/2023/tree-sitter-in-emacs-29/>.
;;
;; See <https://archive.casouri.cc/note/2023/tree-sitter-starter-guide/>.
(use-package treesit
  :config
  ;; Well, `c-ts-mode` not works well sometimes.
  ;; (add-to-list 'major-mode-remap-alist '(c-mode . c-ts-mode))
  ;; (add-to-list 'major-mode-remap-alist '(c++-mode . c++-ts-mode))
  (add-to-list 'major-mode-remap-alist '(python-mode . python-ts-mode))
  (add-to-list 'major-mode-remap-alist '(css-mode . css-ts-mode))
  :custom
  (treesit-extra-load-path `(,(locate-user-emacs-file ".local/treesit"))))

;; Save customization data in a specific file, without littering my init files.
(use-package cus-edit
  :config
  (unless (file-exists-p custom-file)
    (make-empty-file custom-file))
  (load-file custom-file)
  :custom
  (custom-file (locate-user-emacs-file ".local/custom-file.el")))

(use-package ibuffer
  ;; The default Buffer List is ugly, it is said no one uses it except RMS, so
  ;; replace it with IBuffer. However I don't use them either.
  :bind (("C-x C-b" . ibuffer))
  :custom
  (ibuffer-use-other-window t))

(use-package profiler
  :bind (("C-c p b" . profiler-start)
         ("C-c p e" . profiler-stop)
         ("C-c p r" . profiler-report)))

;; Built-in shell written in Emacs Lisp. I hardly use this, but it has a dir.
(use-package eshell
  :defer t
  :custom
  ;; Redirect its data dir.
  (eshell-directory-name (locate-user-emacs-file ".local/eshell/")))

(use-package bookmark
  :defer t
  :custom
  (bookmark-default-file (locate-user-emacs-file ".local/bookmarks.eld")))

(use-package tramp-cache
  :defer t
  :custom
  ;; Move tramp cache into cache dir.
  (tramp-persistency-file-name (locate-user-emacs-file ".local/cache/tramp")))

;; I hardly try.
;; (use-package try
;;   :ensure t
;;   :disabled t
;;   :defer 1)

(provide 'alynx/packages-general)

;;; packages-general.el ends here.
