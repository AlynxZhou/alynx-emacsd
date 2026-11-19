;;; packages-emacs.el --- Alynx's Emacs package configurations. -*- lexical-binding: t; -*-

;;; Commentary:
;; Emacs bundled package-specific configurations.

;;; Code:

(require 'alynx/utils)

;; There is actually no `emacs` package, but it is useful if you have some
;; config that does not belong to any package and you want to manage them with
;; `use-package`.
(use-package emacs
  :hook ((minibuffer-setup . cursor-intangible-mode)
         ;; Highlight trailing whitespace in `prog-mode` only.
         (prog-mode . (lambda () (setq show-trailing-whitespace t)))
         (nxml-mode . (lambda () (setq show-trailing-whitespace t)))
         (yaml-ts-mode . (lambda () (setq show-trailing-whitespace t))))
  ;; Some files does not have a major mode, and I don't want to define a major
  ;; mode for it, so just use some `lambda` for them.
  ;;
  ;; NOTE: `auto-mode-alist` can only run a function for each regex, so just
  ;; add all needed settings here.
  :mode (("COMMIT_EDITMSG\\'" . (lambda ()
                                  (display-fill-column-indicator-mode 1)
                                  (setq display-fill-column-indicator-column (+ 1 72))
                                  (setq show-trailing-whitespace t)))
         ;; It's a little bit strange that SUSE use 66 in changes files.
         ("\\.changes\\'" . (lambda ()
                              (display-fill-column-indicator-mode 1)
                              (setq display-fill-column-indicator-column (+ 1 66))
                              (setq show-trailing-whitespace t)))
         ;; `osc` generate temp files for `vc`.
         ("\\.changes\\.vctmp\\." . (lambda ()
                                      (display-fill-column-indicator-mode 1)
                                      (setq display-fill-column-indicator-column (+ 1 66))
                                      (setq show-trailing-whitespace t))))
  ;; Vertico requires those.
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
  (initial-scratch-message ";; -*- lexical-binding: t; -*-\n;; Happy hacking here!\n")
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
  ;; Decrease scrolling CPU usage.
  (fast-but-imprecise-scrolling t)
  (redisplay-skip-fontification-on-input t)
  (jit-lock-defer-time 0)
  (minibuffer-prompt-properties
   '(read-only t cursor-intangible t face minibuffer-prompt))
  ;; Enable recursive minibuffers.
  (enable-recursive-minibuffers t)
  ;; Move autosave files and list into backup dir.
  (auto-save-list-file-prefix (locate-user-emacs-file ".local/backup/.saves-"))
  ;; Prevent `.#` lock files, so we won't mess up project if crashed.
  (create-lockfiles nil)
  ;; Emacs GC is not so good now, let's see how many times we trigger it.
  (garbage-collection-messages t)
  ;; See <https://emacs-china.org/t/emacs/21053/14>.
  (process-adaptive-read-buffering nil)
  (fill-column 80)
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

;; List dirs first in dired.
(use-package ls-lisp
  :defer t
  :custom
  (ls-lisp-dirs-first t))

(use-package dired
  :defer t
  :custom
  (dired-dwim-target t)
  (dired-listing-switches "-alh --group-directories-first"))

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

(use-package mouse
  :defer t
  :custom
  ;; Yank to cursor, not where mouse clicked.
  (mouse-yank-at-point t))

(use-package xt-mouse
  :config
  (xterm-mouse-mode 1))

;; Disable menu bar, tool bar, scroll bar and cursor blink.

;; Emacs NS also reads macOS defaults to decide whether shows menu bar, disable
;; menu bar entirely by exec `defaults write org.gnu.Emacs Menus -string NO`.
(use-package menu-bar
  :defer t
  :config
  (menu-bar-mode -1))

(use-package tool-bar
  :defer t
  :config
  (tool-bar-mode -1))

;; Scroll bar is too narrow to click, better to disable it.
(use-package scroll-bar
  :defer t
  :config
  (scroll-bar-mode -1))

(use-package frame
  :defer t
  :config
  (blink-cursor-mode -1))

(use-package window
  :bind (("C-c C-v" . scroll-other-window)
         ("C-c M-v" . scroll-other-window-down)
         ("C-c b" . switch-to-buffer-other-window)))

;; Display line number and column number of cursor in mode line.
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
  (backup-directory-alist
   `(("." . ,(locate-user-emacs-file ".local/backup/"))))
  (auto-save-file-name-transforms
   `((".*" ,(locate-user-emacs-file ".local/backup/") t))))

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

(use-package tramp-cache
  :defer t
  :custom
  ;; Move tramp cache into cache dir.
  (tramp-persistency-file-name (locate-user-emacs-file ".local/cache/tramp")))

(use-package uniquify
  :defer t
  :custom
  (uniquify-buffer-name-style 'forward))

;; Typing chars will replace selection, this is the default behavior of most
;; editors.
(use-package delsel
  :config
  (delete-selection-mode 1))

(use-package display-line-numbers
  :config
  (global-display-line-numbers-mode 1)
  :custom
  ;; Calculate max number to prevent shaking.
  (display-line-numbers-width-start t)
  (display-line-numbers-grow-only t))

(use-package hl-line
  :config
  (global-hl-line-mode 1))

(use-package whitespace
  ;; Sometimes manually enabling this is a good idea to check whitespaces.
  :defer t
  :custom
  ;; Showing newlines is annoying, I don't need that.
  (whitespace-style '(face spaces tabs trailing space-mark tab-mark)))

;; Built-in minor mode to display column ruler.
(use-package display-fill-column-indicator
  ;; I only use this in `prog-mode`.
  :hook ((prog-mode . display-fill-column-indicator-mode)
         (nxml-mode . display-fill-column-indicator-mode)
         (yaml-ts-mode . display-fill-column-indicator-mode)
         (conf-unix-mode . display-fill-column-indicator-mode))
  ;; Currently there are still some problems that preventing us from using
  ;; stipple as fill column indicator:
  ;; 	- If you scale text to some values of width, there is a Emacs bug that it
  ;; 	  will draw two bars when you only gives one.
  ;; 	- It does not use a buffer-local face, so scaling text in one buffer will
  ;; 	  affect another.
  ;; 	- I don't know how to make the initial state correct.
  ;; :functions (alynx/make-bar-stipple alynx/update-window-fill-column-indicator)
  :config
  ;; (defun alynx/make-bar-stipple (left fill)
  ;;   "Make stipple to draw bar for FILL and LEFT padding pixels."
  ;;   (let* ((width (window-font-width))
  ;;          (num-bytes (/ (+ width 7) 8))
  ;;          (num-left-bits (floor (* width left)))
  ;;          (num-fill-bits (floor (* width fill)))
  ;;          (fill-bits (- (ash 1 num-fill-bits) 1))
  ;;          ;; Remember lower bit is the left.
  ;;          (bits (ash fill-bits num-left-bits))
  ;;          (bytes '()))
  ;;     ;; (message "width: %d, num-fill-bits: %d, num-left-bits: %d" width num-fill-bits num-left-bits)
  ;;     (dotimes (i num-bytes)
  ;;       (let* ((num-shift-bits (* i 8))
  ;;              (left-bits (ash bits (- num-shift-bits)))
  ;;              (byte (logand left-bits #xFF)))
  ;;         ;; (message (format "%x" byte))
  ;;         (push byte bytes)))
  ;;     ;; (message (format "%S" bytes))
  ;;     `(,width 1 ,(apply 'unibyte-string (reverse bytes)))))
  ;; (defun alynx/update-window-fill-column-indicator ()
  ;;   "Update fill-column-indicator on window change."
  ;;   (if (display-graphic-p)
  ;;       (progn
  ;;         (set-face-attribute 'fill-column-indicator nil :stipple (alynx/make-bar-stipple 0.125 0.25))
  ;;         ;; Hide the character in GUI while using stipple.
  ;;         (setq display-fill-column-indicator-character ?\s))
  ;;     (set-face-attribute 'fill-column-indicator nil :stipple nil)
  ;;     (setq display-fill-column-indicator-character nil)))
  ;; (add-hook 'emacs-startup-hook 'alynx/update-window-fill-column-indicator)
  ;; (add-hook 'text-scale-mode-hook 'alynx/update-window-fill-column-indicator)
  ;; HACK: `display-fill-column-indicator` does not follow fontset fallback,
  ;; force it to use Menlo.
  (when (alynx/macos-p)
    (set-face-attribute 'fill-column-indicator nil :family "Menlo"))
  :custom
  ;; Set column ruler at 80 columns. However Emacs displays it in given column,
  ;; so actually we need to add 1 column.
  (display-fill-column-indicator-column (+ 1 80))
  ;; HACK: `display-fill-column-indicator` uses ASCII `|` when it finds the
  ;; box-drawing character cannot be drawn with the default font. This is silly.
  (display-fill-column-indicator-character ?│))

(use-package paren
  :defer t
  :custom
  ;; This is really confusing, because it looks like your cursor jumps.
  (show-paren-when-point-inside-paren nil))

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

;; Better keybindings for replace, because `isearch-backward` is hardly used.
(use-package replace
  :bind (("C-r" . query-replace)
         ("C-M-r" . query-replace-regexp))
  :custom
  ;; No, don't do case insensitive replace.
  (case-fold-search nil))

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

(use-package profiler
  :bind (("C-c p b" . profiler-start)
         ("C-c p e" . profiler-stop)
         ("C-c p r" . profiler-report)))

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
  ;; (add-to-list 'major-mode-remap-alist
  ;;              '(c-mode . c-ts-mode))
  ;; (add-to-list 'major-mode-remap-alist
  ;;              '(c++-mode . c++-ts-mode))
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

;; Built-in shell written in Emacs Lisp. I hardly use this, but it has a dir.
(use-package eshell
  :defer t
  :custom
  ;; Redirect its data dir.
  (eshell-directory-name (locate-user-emacs-file ".local/eshell/")))

(use-package ibuffer
  ;; The default Buffer List is ugly, it is said no one uses it except RMS, so
  ;; replace it with IBuffer. However I don't use them either.
  :bind (("C-x C-b" . ibuffer))
  :custom
  (ibuffer-use-other-window t))

(use-package bookmark
  :defer t
  :custom
  (bookmark-default-file (locate-user-emacs-file ".local/bookmarks.eld")))

;; Highlight Markdown-style `inline code block` in comments.
;;
;; Emacs prefer `this', I prefer `that`.
(use-package font-lock
  :config
  ;; Tree-sitter modes works differently, so don't add them here.
  (dolist (mode '(emacs-lisp-mode
                  lisp-interaction-mode
                  c-mode
                  c++-mode
                  js-mode
                  js2-mode
                  web-mode
                  css-mode
                  python-mode
                  java-mode
                  meson-mode
                  rpm-spec-mode))
    (font-lock-add-keywords
     mode
     '(("`\\([^`'\n]+\\)`"
        ;; `4` means comments only and `8` means comments and strings, use `4`
        ;; here because JavaScript template string also uses backquote.
        (1 (when (save-excursion (nth 4 (syntax-ppss (match-beginning 0))))
             'font-lock-constant-face)
           prepend)))
     'append)))

(provide 'alynx/packages-emacs)

;;; packages-emacs.el ends here.
