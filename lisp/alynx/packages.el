;;; packages.el --- Alynx's package configurations. -*- lexical-binding: t; -*-

;;; Commentary:
;; Package-specific configurations.

;;; Code:

(require 'alynx/utils)

;; This is needed for first running because we will install `use-package`.
(require 'package)
;; Use TUNA mirrors for faster downloading.
(setq package-archives
      '(("gnu" . "https://mirrors.tuna.tsinghua.edu.cn/elpa/gnu/")
        ("nongnu" . "https://mirrors.tuna.tsinghua.edu.cn/elpa/nongnu/")
        ("melpa" . "https://mirrors.tuna.tsinghua.edu.cn/elpa/melpa/")))
;; Always prefer MELPA.
(setq package-archive-priorities
      '(("gnu" . 0)
        ("nongnu" . 0)
        ("melpa" . 100)))

;; About `package-initialize`, `package-activate-all` and `package-quickstart`:
;;
;; If I am not wrong, you should never call `package-initialize`, because since
;; Emacs 27.1, the old `package-initialize` is splitted into two parts:
;;
;;   - `package-initialize`: load all lisp files of all packages (expensive) and
;;     call `package-activate-all`.
;;   - `package-activate-all`: load autoloads for all packages (cheap).
;;
;; And what about `package-quickstart`? It just writes all autoloads in a single
;; file when you call `package-quickstart-refresh`, and if you have such a file,
;; `package-activate-all` will load it instead of many files. This reduces only
;; 0.1s for me, but maybe very helpful for HDD users.
;;
;; See <https://git.savannah.gnu.org/cgit/emacs.git/commit/?id=6dfdf0c9e8e4aca77b148db8d009c862389c64d3>.
;;
;; So basically you only need `package-activate-all`, and autoloads will load
;; the actual packages when you call them. Any articles telling you write
;; `package-initialize` before Emacs 27.1 is wrong now.
;;
;; Also, Emacs now call `package-activate-all` between `early-init.el` and
;; `init.el`, so if you want to control package loading in `init.el` like me,
;; you need to set `package-enable-at-startup` to `nil` in `early-init.el`.
(setq package-quickstart t)
;; Put quick start cache into cache dir.
(setq package-quickstart-file
      (locate-user-emacs-file ".local/cache/package-quickstart.el"))
;; Cache will not be used until we call `package-quickstart-refresh` manually.
(unless (file-exists-p package-quickstart-file)
  (package-quickstart-refresh))
;; Make sure quick start cache is refreshed after operations in package menu,
;; for example upgrading packages.
;;
;; See <https://www.manueluberti.eu/emacs/2021/03/08/package/>.
(advice-add 'package-menu-execute :after-while 'package-quickstart-refresh)

(package-activate-all)

;; Install `use-package`.
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)

;; Not all variables supports `custom-theme-set-variables`, so just let
;; `use-package` use `custom-set-variables`. I really don't use custom file.
(setq use-package-use-theme nil)

;; Setting `use-package-always-ensure` to `t` will also set `:ensure t` for
;; built-in packages.
;;
;; However, you should never set `:ensure t` for built-in packages, it will mess
;; things up when using `package-activate-all` instead of `package-initialize`.
;;
;; See <https://github.com/jwiegley/use-package/issues/977>.
;;
;; (setq use-package-always-ensure t)

;; Install and configure packages.

;; NOTE: If you have both `:bind` / `:mode` / `:interpreter` / `:commands` and
;; enabling global mode in `:config`, it will never work, because `use-package`
;; will lazy load packages with those keywords. Add `:demand t` to break lazy
;; loading for this.
;;
;; See <https://sh.alynx.one/posts/Emacs-Lazy-Loading-use-package/>.
;;
;; See <https://github.com/jwiegley/use-package#notes-about-lazy-loading>.
;;
;; `(use-package PACKAGE)` block by default loads a package at startup if no
;; lazy loading generated, but sometimes I only want to set some custom
;; variables for a package, but don't load it (for example, move tramp's cache
;; file, but don't load tramp at startup), just use `:defer t` to prevent
;; loading them, `:custom` will still work.
;;
;; If a package is not needed since startup and has no keyword to make
;; `use-package` auto load it, but is needed later, add `:defer 1` to load it
;; after 1 second.
;;
;; Difference between `:defer t` and `:defer 1`: `:defer 1` will load package
;; after 1 second, but `:defer t` does not load package, expects other code
;; triggers it.

;; Built-in packages.

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
  ;; `display-fill-column-indicator` does not follow fontset fallback, force it
  ;; use Menlo.
  (when (alynx/macos-p)
    (set-face-attribute 'fill-column-indicator nil :family "Menlo"))
  :custom
  ;; Set column ruler at 80 columns. However Emacs displays it in given column,
  ;; so actually we need to add 1 column.
  (display-fill-column-indicator-column (+ 1 80))
  ;; `display-fill-column-indicator` uses ASCII `|` when it finds the box-drawing
  ;; character cannot be drawn with the default font. This is silly.
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
  (add-to-list 'major-mode-remap-alist
               '(python-mode . python-ts-mode))
  (add-to-list 'major-mode-remap-alist
               '(css-mode . css-ts-mode))
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

;; I prefer Linux coding style for C, not GNU.
(use-package cc-vars
  :defer t
  :config
  ;; The linux style of Emacs does not really follow linux style, correct it.
  ;;
  ;; See <https://emacs-china.org/t/emacs/19319/7>.
  ;;
  ;; See <https://www.gnu.org/software/emacs/manual/html_mono/ccmode.html#index-c_002doffsets_002dalist-1>.
  (c-add-style "alynx" '("linux" (c-offsets-alist (arglist-close . 0))))
  :custom
  (c-default-style '((java-mode . "java")
                     (awk-mode . "awk")
                     (other . "alynx"))))

(use-package cc-mode
  ;; I am a modern guy.
  :hook ((c-mode . (lambda () (setq comment-start "//"
                                    comment-end "")))))

(use-package elisp-mode
  ;; `C-j` is used by `join-next-line`.
  :bind (("C-c C-j" . eval-print-last-sexp)))

;; It turns out that if I enable `c-ts-mode` here it will automatically remap
;; all C files to itself, I don't want this.
;; (use-package c-ts-mode
;;   ;; I am a modern guy.
;;   :hook ((c-ts-mode . (lambda () (setq comment-start "//"
;;                                        comment-end ""))))
;;   :custom
;;   (c-ts-mode-indent-style 'linux))

(use-package json-ts-mode
  :mode (("\\.bowerrc\\'" . json-ts-mode)
         ("\\.jshintrc\\'" . json-ts-mode)
         ("\\.json_schema\\'" . json-ts-mode)
         ("\\.json\\'" . json-ts-mode)))

(use-package typescript-ts-mode
  :mode (("\\.ts\\'" . typescript-ts-mode)))

(use-package yaml-ts-mode
  :mode (("\\.yml\\'" . yaml-ts-mode)
         ("\\.yaml\\'" . yaml-ts-mode)))

(use-package rust-ts-mode
  :mode (("\\.rs\\'" . rust-ts-mode)))

(use-package lua-ts-mode
  :mode (("\\.lua\\'" . lua-ts-mode)
         ;; DaVinci Resolve's fuse scripts, it uses lua.
         ("\\.fuse\\'" . lua-ts-mode)))

(use-package cmake-ts-mode
  :mode (("CMakeLists\\.txt\\'" . cmake-ts-mode)
         ("\\.cmake\\'" . cmake-ts-mode)))

;; External modes and tools for different languages.

(use-package js2-mode
  :ensure t
  :hook ((js2-mode . js2-imenu-extras-mode))
  :mode (("\\.js\\'" . js2-mode)
         ("\\.mjs\\'" . js2-mode)))

(use-package js2-refactor
  :ensure t
  :config
  (js2r-add-keybindings-with-prefix "C-c C-r")
  :hook ((js2-mode . js2-refactor-mode))
  :bind (:map js2-mode-map ("C-k" . js2r-kill)))

(use-package xref-js2
  :ensure t
  :hook ((js2-mode . (lambda ()
                       (add-hook 'xref-backend-functions
                                 'xref-js2-xref-backend nil t))))
  :bind (:map js-mode-map ("M-." . nil))
  :custom (xref-js2-search-program 'rg))

;; Emacs now has internal `json-ts-mode`, should be enough for me.
;; (use-package json-mode
;;   :ensure t
;;   :disabled t
;;   :bind (:map json-mode-map ("C-c <tab>" . json-mode-beautify))
;;   :mode (("\\.bowerrc\\'" . json-mode)
;;          ("\\.jshintrc\\'" . json-mode)
;;          ("\\.json_schema\\'" . json-mode)
;;          ("\\.json\\'" . json-mode)))

;; I hardly write lua and `lua-ts-mode` should be enough.
;; (use-package lua-mode
;;   :ensure t
;;   :mode (("\\.lua\\'" . lua-mode)
;;          ;; DaVinci Resolve's fuse scripts, it uses lua.
;;          ("\\.fuse\\'" . lua-mode)))

(use-package markdown-mode
  :ensure t
  ;; Don't cover my `move-text` keybindings! They are more useful.
  :bind (:map gfm-mode-map
              ("M-n" . nil)
              ("M-p" . nil))
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . gfm-mode)
         ("\\.markdown\\'" . gfm-mode))
  ;; It changes `tab-width` to 4 by default, which is bad.
  :hook ((gfm-mode . (lambda () (set-tab-width 8))))
  :custom
  (markdown-command "marked")
  (markdown-gfm-use-electric-backquote nil)
  (markdown-indent-on-enter nil))

(use-package web-mode
  :ensure t
  :mode (("\\.njk\\'" . web-mode)
         ("\\.j2\\'" . web-mode)
         ;; `web-mode` can highlight JavaScript and CSS inside HTML.
         ("\\.html\\'" . web-mode))
  :custom
  ;; I prefer not to indent control blocks of templating.
  (web-mode-enable-control-block-indentation nil))

;; Emacs now has internal `yaml-ts-mode`, should be enough for me.
;; (use-package yaml-mode
;;   :ensure t
;;   :disabled t
;;   :mode (("\\.yml\\'" . yaml-mode) ("\\.yaml\\'" . yaml-mode)))

(use-package meson-mode
  :ensure t
  :mode (("meson\\.build\\'" . meson-mode)
         ("meson\\.options\\'" . meson-mode)
         ("meson_options\\.txt\\'" . meson-mode)))

;; See <https://github.com/stigbjorlykke/rpm-spec-mode/issues/16>.
;;
;; Currently this package does not work with Emacs after 28.1, and the repo
;; seems not actively maintained, so I manually bundle it in `site-lisp/`, and
;; apply the patch from Fedora.
;;
;; See <https://src.fedoraproject.org/rpms/emacs-rpm-spec-mode/blob/rawhide/f/fix-define-obsolete-variable-alias.patch>.
(use-package rpm-spec-mode
  ;; Don't ensure it, the MELPA one is old.
  :mode (("\\.spec\\'" . rpm-spec-mode))
  ;; This mode disables many other modes, but I need them.
  :hook ((rpm-spec-mode . (lambda ()
                            (display-line-numbers-mode 1)
                            (whole-line-or-region-local-mode 1)
                            (display-fill-column-indicator-mode 1)
                            (diff-hl-mode 1)
                            (highlight-indent-guides-mode 1)
                            ;; (indent-bars-mode 1)
                            (hl-todo-mode 1)
                            (rainbow-mode 1)))))

;; Simple packages that have no dependencies.

;; I hardly try.
;; (use-package try
;;   :ensure t
;;   :defer 1)

;; My favorite themes with my own tweaks.
;;
;; Don't defer themes, I need them all time.

(use-package alynx-one-dark-theme
  :config
  (load-theme 'alynx-one-dark t))

;; Or sometimes I want light theme.
(use-package alynx-one-light-theme)

;; Or if you like `nano-theme`.
;; (use-package nano-theme
;;   :ensure t
;;   :disabled t
;;   :config
;;   (load-theme 'nano-dark t))

;; Finally I decide to write my own mode line so I can modify it easily.
(use-package alynx-mode-line
  ;; Well, Emacs does not generate and call autoloads for local library, and
  ;; `flycheck` will be unhappy because the function is not declared. We could
  ;; use `:commands` to let `use-package` generate and call autoloads here, but
  ;; it will also defer the package and `:demand t` is needed then. Actually I
  ;; don't really need autoloads for this, I just need to declare it, this could
  ;; be done via `:functions`.
  ;; :demand t
  ;; :commands (alynx-mode-line-mode)
  :functions (alynx-mode-line-mode)
  :custom
  (alynx-mode-line-mode-indent-offset-alist alynx/mode-indent-offsets)
  :config
  (alynx-mode-line-mode 1))

;; (use-package nano-modeline
;;   :ensure t
;;   :disabled t
;;   :config
;;   (nano-modeline-mode 1)
;;   :custom
;;   (nano-modeline-position 'bottom))

(use-package olivetti
  :ensure t
  :bind (("C-c t o" . olivetti-mode)))

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

;; FIXME: High CPU usage on scrolling.
(use-package highlight-indent-guides
  :ensure t
  ;; I only use this in `prog-mode`.
  :hook ((prog-mode . highlight-indent-guides-mode)
         (nxml-mode . highlight-indent-guides-mode)
         ;; `yaml-mode` should be `prog-mode`, anyway.
         (yaml-ts-mode . highlight-indent-guides-mode))
  :custom
  ;; Highlight indent guides could generate font faces via background
  ;; automatically, but it's too dark. I have color in themes so disable it.
  (highlight-indent-guides-auto-enabled nil)
  ;; Bitmap is modern, but has some issues (wrong color after switching theme,
  ;; wrong size after changing font size), and character is faster. A problem of
  ;; character is that it shows in default face in candidates of `consult-line`,
  ;; I have some hacks for it in `consult`.
  (highlight-indent-guides-method 'character)
  (highlight-indent-guides-character ?│)
  ;; (highlight-indent-guides-method 'bitmap)
  (highlight-indent-guides-bitmap-function
   'highlight-indent-guides--bitmap-line))

;; Currently there are still a problem that preventing us from using indent-bars:
;; If you scale text to some values of width, there is a Emacs bug that it will
;; draw two bars when you only gives one.
(use-package indent-bars
  :ensure t
  :disabled t
  ;; I only use this in `prog-mode`.
  :hook ((prog-mode . indent-bars-mode)
         (nxml-mode . indent-bars-mode)
         ;; `yaml-mode` should be `prog-mode`, anyway.
         (yaml-ts-mode . indent-bars-mode))
  :custom
  (indent-bars-pattern ".")
  ;; (indent-bars-color 'shadow)
  (indent-bars-width-frac 0.25)
  (indent-bars-pad-frac 0.125)
  (indent-bars-starting-column 0)
  (indent-bars-display-on-blank-lines t)
  (indent-bars-zigzag nil)
  (indent-bars-color-by-depth nil)
  (indent-bars-highlight-current-depth nil))

;; Highlight FIXME, TODO, NOTE or HACK.
;; `svg-tag-mode` could also achieve this, it looks fancy, but has some bugs.
(use-package hl-todo
  :ensure t
  :hook ((prog-mode . hl-todo-mode)
         (nxml-mode . hl-todo-mode)
         (yaml-ts-mode . hl-todo-mode)))

;; `diff-hl` supports more VCS than `git-gutter` and `git-gutter-fringe`.
(use-package diff-hl
  :ensure t
  :config
  (define-fringe-bitmap 'alynx/diff-hl-bmp-insert
    [#b11100000]
    nil nil '(center repeated))
  (define-fringe-bitmap 'alynx/diff-hl-bmp-insert-hi-res
    [#b1111110000000000]
    nil nil '(center repeated))
  (define-fringe-bitmap 'alynx/diff-hl-bmp-change
    [#b11100000]
    nil nil '(center repeated))
  (define-fringe-bitmap 'alynx/diff-hl-bmp-change-hi-res
    [#b1111110000000000]
    nil nil '(center repeated))
  (define-fringe-bitmap 'alynx/diff-hl-bmp-delete
    [#b11110000
     #b11100000
     #b11000000
     #b10000000]
    nil nil 'top)
  (define-fringe-bitmap 'alynx/diff-hl-bmp-delete-hi-res
    [#b1111111100000000
     #b1111111000000000
     #b1111110000000000
     #b1111100000000000
     #b1111000000000000
     #b1110000000000000
     #b1100000000000000
     #b1000000000000000]
    nil nil 'top)
  ;; Don't use `diff-hl`'s background, it's ugly.
  ;;
  ;; I altered those faces in my themes instead of here.
  ;; (set-face-background 'diff-hl-insert nil)
  ;; (set-face-background 'diff-hl-delete nil)
  ;; (set-face-background 'diff-hl-change nil)
  (global-diff-hl-mode 1)
  :custom
  ;; Like `flycheck`, we choose bigger icons if needed.
  (diff-hl-fringe-bmp-function (lambda (type pos)
                                 (let* ((fringe-width
                                         (pcase diff-hl-side
                                           (`left (car (window-fringes)))
                                           (`right (cadr (window-fringes)))))
                                        (hi-res (>= fringe-width 16)))
                                   (intern (format
                                            (if hi-res
                                                "alynx/diff-hl-bmp-%s-hi-res"
                                              "alynx/diff-hl-bmp-%s")
                                            type)))))
  (diff-hl-draw-borders nil))

(use-package which-key
  :ensure t
  :config
  (which-key-mode 1))

(use-package rainbow-mode
  :ensure t
  ;; Defining our functions that calls package functions in `:preface` is a
  ;; solution to make byte-compiler happy, but we still needs `:functions` to
  ;; work when we call functions from packages in `:config` directly.
  ;;
  ;; See <https://github.com/jwiegley/use-package/issues/1032#issuecomment-1397951772>
  ;; :functions (rainbow-x-color-luminance)
  :hook ((prog-mode . rainbow-mode)
         (nxml-mode . rainbow-mode)
         (yaml-ts-mode . rainbow-mode))
  :config
  ;; FIXME: To make `flycheck` happy, before we fix `:functions`.
  (declare-function rainbow-x-color-luminance "rainbow-mode" (color))
  ;; Using overlay so it has higher priority than `hl-line`. After Emacs 29 we
  ;; have fantastic optimizations about overlay so it won't be a problem.
  (defun alynx/rainbow-colorize-with-overlay (color &optional match)
    (let* ((match (or match 0))
           (ov (make-overlay (match-beginning match) (match-end match))))
      (overlay-put ov 'ov-rainbow t)
      (overlay-put ov 'face
                   `((:foreground ,(if (> 0.5 (rainbow-x-color-luminance color))
                                       "white"
                                     "black"))
                     (:background ,color)))))
  (advice-add 'rainbow-colorize-match :override
              'alynx/rainbow-colorize-with-overlay))

;; FIXME: High CPU usage on scrolling.
;; (use-package rainbow-delimiters
;;   :ensure t
;;   :disabled t
;;   :hook ((prog-mode . rainbow-delimiters-mode)))

(use-package editorconfig
  :ensure t
  :config
  (editorconfig-mode 1))

;; I use this to control popup window position and behavior.
(use-package popper
  :ensure t
  ;; Prevent lazy loading so it can manage popup since Emacs starts.
  :demand t
  :bind (("C-'" . popper-toggle)
         ("M-'" . popper-cycle)
         ("C-M-'" . popper-toggle-type))
  :config
  (popper-mode 1)
  (popper-echo-mode 1)
  :custom
  ;; Some popup windows are focused, but others are not, let them all focused,
  ;; so I could easily close them.
  (popper-reference-buffers '("\\*Backtrace\\*"
                              "\\*Warnings\\*"
                              ;; This will shown when you click TAB on `M-:`.
                              "\\*Completions\\*"
                              "\\*Compile-Log\\*"
                              "\\*Flycheck checkers\\*"
                              "\\*Flycheck errors\\*"
                              ;; Popper is not suitable for copying output.
                              ;; "\\*Async Shell Command\\*"
                              ;; "\\*Shell Command Output\\*"
                              ;; Compilation log deserves a big window.
                              ;; compilation-mode
                              help-mode))
  ;; Don't add extra segment because it does not follow my segments. Must use
  ;; empty string, because popper removes mode-line entirely with `nil`.
  (popper-mode-line ""))

;; A sticky header, can stick function headers of different languages.
(use-package topsy
  :ensure t
  :hook ((prog-mode . topsy-mode)))

;; Not sure why it does not work for me. It always set to English even I
;; manually switched to RIME. I also want to use Chinese for `find-file` or
;; `consult-line`.
;; (use-package sis
;;   :ensure t
;;   :init
;;   (setq sis-respect-start nil)
;;   :config
;;   (sis-ism-lazyman-config "xkb:us::eng" "rime" 'ibus)
;;   (sis-global-respect-mode t))

;; It turns out I never use Emacs for email.
;; (use-package mu4e
;;   :load-path (lambda ()
;;                (if (alynx/macos-p)
;;                    "/opt/homebrew/share/emacs/site-lisp/mu/mu4e"
;;                  "/usr/share/emacs/site-lisp/mu4e"))
;;   :defer 1
;;   :custom
;;   (mail-user-agent 'mu4e)
;;   (mu4e-maildir "~/Mail/gmail")
;;   (mu4e-get-mail-command "mbsync -a")
;;   (mu4e-index-lazy-check t)
;;   (mu4e-update-interval 300)
;;   (mu4e-compose-reply-to-address "alynx.zhou@gmail.com")
;;   (mu4e-sent-folder "/[Gmail]/Sent Mail")
;;   (mu4e-drafts-folder "/[Gmail]/Drafts")
;;   (mu4e-trash-folder  "/[Gmail]/Trash")
;;   (mu4e-refile-folder "/[Gmail]/All Mail")
;;   (mu4e-compose-format-flowed nil)
;;   (mu4e-use-fancy-chars t)
;;   (user-mail-address "alynx.zhou@gmail.com")
;;   (user-full-name "Alynx Zhou"))

(use-package keycast
  :ensure t
  :config
  ;; I have custom mode-line, `keycast-mode-line-mode` won't work.
  (keycast-invisible-mode 1))

;; Complex packages that have dependencies.
;;
;; Don't change the sequence, because the latter needs to obey the former's
;; `:custom`, for example `projectile` and `counsel-projectile`. If a package
;; depends on other package, it should be placed after all of its dependencies.
;;
;; I don't use `:after` here, because we may have keybindings for dependencies,
;; which leads into an autoload, and if you have 2 dependencies in `:after`,
;; you need to first press both keybindings of those 2 dependencies, then
;; configurations of the 2 packages will be run, it won't work before those
;; keybindings. I don't want this, I just want to run `:custom` of dependencies
;; first, so keep the sequence is the easiest.
;;
;; See <https://github.com/jwiegley/use-package/issues/976#issuecomment-1056017784>.

;; Dependency of `vertico-posframe` and `flycheck-posframe`.
;; (use-package posframe
;;   :ensure t
;;   :defer t)

;; Vertico and Consult need this to behave like `ivy--regex-plus`.
(use-package orderless
  :ensure t
  ;; Orderless always returns too many unrelated results, especially for auto
  ;; completing, so only use it in minibuffer.
  ;;
  ;; See <https://emacs-china.org/t/orderless-completion/20455/3>.
  ;;
  ;; Well, that's not a problem after using `lsp-bridge`. `lsp-bridge` has its
  ;; own completion style so it won't be affected by orderless.
  ;; :hook ((minibuffer-setup . (lambda ()
  ;;                              (setq-local completion-styles '(orderless basic)
  ;;                                          completion-category-overrides '((file . ((styles . (partial-completion)))))))))
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file . ((styles . (partial-completion))))))
  ;; Allow escape space with backslash.
  (orderless-component-separator 'orderless-escapable-split-on-space))

(use-package marginalia
  :ensure t
  ;; Vertico will load it so we don't load it manually.
  ;; :demand t
  :bind (:map minibuffer-local-map
              ("M-A" . marginalia-cycle))
  :config
  (marginalia-mode 1))

(use-package vertico
  :ensure t
  :config
  (vertico-mode 1)
  :custom
  (vertico-resize t)
  (vertico-cycle t))

;; Fancy, but not so useful, for example, it blocks search results.
;; (use-package vertico-posframe
;;   :ensure t
;;   :config
;;   (vertico-posframe-mode 1))

(use-package consult
  :ensure t
  :bind (("C-s" . consult-line)
         ("C-M-s" . consult-ripgrep)
         ([remap switch-to-buffer] . consult-buffer)
         ([remap switch-to-buffer-other-window] . consult-buffer-other-window)
         ([remap switch-to-buffer-other-frame] . consult-buffer-other-frame)
         ([remap project-switch-to-buffer] . consult-project-buffer)
         ([remap recentf-open] . consult-recent-file)
         ([remap yank-pop] . consult-yank-pop)
         ([remap goto-line] . consult-goto-line)
         ([remap repeat-complex-command] . consult-complex-command)
         ([remap bookmark-jump] . consult-bookmark)
         ([remap imenu] . consult-imenu)
         ("M-g I" . consult-imenu-multi)
         ;; `M-s` bindings (`search-map`).
         ("M-s d" . consult-find)
         ("M-s D" . consult-locate)
         ("M-s g" . consult-grep)
         ("M-s G" . consult-git-grep)
         ("M-s r" . consult-ripgrep)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi)
         ("M-s k" . consult-keep-lines)
         ("M-s u" . consult-focus-lines)
         ;; Isearch integration.
         :map isearch-mode-map
         ([remap isearch-edit-string] . consult-isearch-history)
         ;; Needed by `consult-line` to detect isearch.
         ("M-s l" . consult-line)
         ;; Needed by `consult-line` to detect isearch.
         ("M-s L" . consult-line-multi)
         ;; Minibuffer history
         :map minibuffer-local-map
         ;; `M-s`.
         ([remap next-matching-history-element] . consult-history)
         ;; `M-r`.
         ([remap previous-matching-history-element] . consult-history)
         ;; ("M-g e" . consult-compile-error)
         ;; Alternative: `consult-outline`.
         ;; ("M-g o" . consult-org-heading)
         ;; ("M-g m" . consult-mark)
         ;; ("M-g k" . consult-global-mark)
         ;; ;; `C-c` bindings (`mode-specific-map`)
         ;; ("C-c h" . consult-history)
         ;; ("C-c m" . consult-mode-command)
         ;; ("C-c k" . consult-kmacro)
         ;; ;; Custom M-# bindings for fast register access
         ;; ("M-#" . consult-register-load)
         ;; ("M-'" . consult-register-store)
         ;; ("C-M-#" . consult-register)
         )
  ;; Enable automatic preview at point in the `*Completions*` buffer. This is
  ;; relevant when you use the default completion UI.
  :hook ((completion-list-mode . consult-preview-at-point-mode))
  ;; Make flycheck happy.
  :functions (consult--customize-put)
  :config
  ;; Optionally tweak the register preview window.
  ;; This adds thin lines, sorting and hides the mode line of the window.
  (advice-add 'register-preview :override 'consult-register-window)
  ;; Press `C-s` twice to search last item.
  (defvar my-consult-line-map
    (let ((map (make-sparse-keymap)))
      (define-key map (kbd "C-s") 'previous-history-element)
      map))
  (consult-customize consult-line :keymap my-consult-line-map)
  :custom
  ;; Optionally configure the register formatting. This improves the register
  ;; preview for `consult-register`, `consult-register-load`,
  ;; `consult-register-store` and the Emacs built-ins.
  (register-preview-delay 0.5)
  (register-preview-function 'consult-register-format)
  ;; Use Consult to select xref locations with preview.
  (xref-show-xrefs-function 'consult-xref)
  (xref-show-definitions-function 'consult-xref)
  ;; Optionally configure the narrowing key.
  ;; Both `<` and `C-+` work reasonably well.
  (consult-narrow-key "<")
  ;; HACK: `consult-line` cannot handle font face of `highlight-indent-guides`
  ;; properly, and I don't really need syntax highlight in search candidates,
  ;; this just ignores all text properties, so it also hides indent guides.
  (consult-fontify-preserve nil))

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
                            "* TODO %<%Y-%m-%d %H:%M:%S> %?\n"
                            :empty-lines 1)
                           ("n" "Note 笔记" entry
                            (file+headline org-default-notes-file "笔记")
                            "* %<%Y-%m-%d %H:%M:%S> %?\n"
                            :empty-lines 1)
                           ("j" "Journal 日志" entry
                            (file+olp+datetree org-default-notes-file "日志")
                            "* %<%Y-%m-%d %H:%M:%S> %?\n"
                            :empty-lines 1)))
  (org-refile-targets '((org-agenda-files :maxlevel . 3)))
  ;; Record time when task is done.
  (org-log-done 'time)
  (org-agenda-skip-scheduled-if-done t)
  (org-agenda-skip-deadline-if-done t)
  (org-refile-use-outline-path 'file)
  (org-outline-path-complete-in-steps nil))

(use-package org-bullets
  :ensure t
  :hook ((org-mode . org-bullets-mode)))

(use-package flycheck
  :ensure t
  :hook ((prog-mode . flycheck-mode)
         ;; (nxml-mode . flycheck-mode)
         (yaml-ts-mode . flycheck-mode)
         (markdown-mode . flycheck-mode)
         (org-mode . flycheck-mode))
  :config
  ;; There is no hi-res version of `flycheck-fringe-bitmap-continuation`, on
  ;; normal screen the lower 8 bits are used.
  (define-fringe-bitmap 'flycheck-fringe-bitmap-continuation
    [#b0111000001110000
     #b0011100000111000
     #b0001110000011100
     #b0000111000001110]
    nil nil '(top repeated))
  ;; By default right double arrow is used, let's draw custom icon.
  (define-fringe-bitmap 'flycheck-fringe-bitmap-double-arrow
    [#b00000111]
    nil nil '(center repeated))
  (define-fringe-bitmap 'flycheck-fringe-bitmap-double-left-arrow-hi-res
    [#b0000000000111111]
    nil nil '(center repeated))
  ;; I don't like double arrow, without anti-aliasing they looks very ugly.
  ;; (define-fringe-bitmap 'flycheck-fringe-bitmap-double-arrow
  ;;   [#b00000100
  ;;    #b00001100
  ;;    #b00011100
  ;;    #b00111100
  ;;    #b00111100
  ;;    #b00011100
  ;;    #b00001100
  ;;    #b00000100]
  ;;   nil nil 'center)
  ;; (define-fringe-bitmap 'flycheck-fringe-bitmap-double-left-arrow-hi-res
  ;;   [#b0000000000000100
  ;;    #b0000000000011100
  ;;    #b0000000001111100
  ;;    #b0000000111111100
  ;;    #b0000011111111100
  ;;    #b0001111111111100
  ;;    #b0001111111111100
  ;;    #b0000011111111100
  ;;    #b0000000111111100
  ;;    #b0000000001111100
  ;;    #b0000000000011100
  ;;    #b0000000000000100]
  ;;   nil nil 'center)
  :custom
  ;; Otherwise it complains about my configuration modules.
  (flycheck-emacs-lisp-load-path 'inherit)
  ;; Currently `flycheck` is unable to run local `standardx` with `npx`.
  ;;
  ;; See <https://github.com/flycheck/flycheck/issues/1428>.
  (flycheck-javascript-standard-executable "/usr/bin/standardx")
  ;; Leave left fringe to VCS states.
  (flycheck-indication-mode 'right-fringe)
  ;; Prevent check on modifications, it makes Emacs laggy.
  (flycheck-check-syntax-automatically '(save mode-enabled)))

(use-package consult-flycheck
  :ensure t
  :bind (("M-g f" . consult-flycheck)))

;; `lsp-bridge` also has error popups and looks better than it.
;; (use-package flycheck-posframe
;;   :ensure t
;;   :disabled t
;;   :hook ((flycheck-mode . flycheck-posframe-mode))
;;   :config
;;   (flycheck-posframe-configure-pretty-defaults))

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

;; Looks like that I need to alter JSON files under `langserver` to add
;; parameters to `clangd`, but I can also modify `~/.config/clangd/config.yaml`
;; to let it find `compile_commands.json` under `build/`.
;;
;; On macOS, according to Python's horrible dependencies management and venv,
;; you have no way to install dependencies to where it could be loaded
;; automatically, you have to use `uv`, which is the only dependencies
;; management tool `lsp-bridge` supports. You must install `uv` via Homebrew
;; first, and then run `uv sync` in `~/.emacs.d/site-lisp/lsp-bridge`, and soft
;; link `python-lsp-bridge` into `PATH`.
;;
;; And you are still not able to use it because some dependencies may not
;; support the latest Python. You may use `uv sync --python 3.13` to request a
;; working Python version.
(use-package lsp-bridge
  ;; This is not in MELPA and installed as submodules.
  :load-path "site-lisp/lsp-bridge/"
  :hook ((prog-mode . lsp-bridge-mode)
         (nxml-mode . lsp-bridge-mode)
         (yaml-ts-mode . lsp-bridge-mode))
  :custom
  ;; Latest typescript compiler is rewritten by go, which does not provide
  ;; `tsserver`, instead, `tsc --lsp` should be used, however, currently
  ;; `typescript-language-server` only supports `tsserver`, so we cannot use it.
  ;;
  ;; `lsp-bridge` supports `tsgo --lsp`, which is the previous name, so we could
  ;; symlink it like `ln -s $(which tsc) ~/bin/tsgo` to use it.
  ;;
  ;; This is a temp work around, until `lsp-bridge` or
  ;; `typescript-language-server` supports `tsc --lsp` directly.
  (lsp-bridge-javascript-lsp-server (if (executable-find "tsgo")
                                        'javascript-go
                                      'javascript))
  (lsp-bridge-typescript-lsp-server (if (executable-find "tsgo")
                                        'typescript-go
                                      'typescript))
  (lsp-bridge-enable-hover-diagnostic t)
  ;; See <https://github.com/manateelazycat/lsp-bridge/commit/46ff1693558901f7867d9e7ab7dba98efdecd21c>.
  ;;
  ;; lsp-bridge now use acm frame instead of posframe, which also fixed strange
  ;; black rectangle in wrong place for me.
  (lsp-bridge-signature-show-function 'lsp-bridge-signature-show-with-frame)
  (lsp-bridge-signature-show-with-frame-position 'point)
  ;; I use none of them.
  (acm-enable-tabnine nil)
  (acm-enable-codeium nil)
  (acm-enable-copilot nil)
  ;; It is fancy, but noisy.
  (acm-enable-doc nil))

;; Magit and `gptel` uses this, and we need to redirect its files.
(use-package transient
  :ensure t
  :defer t
  :custom
  (transient-history-file (locate-user-emacs-file ".local/transient/history.el"))
  (transient-levels-file (locate-user-emacs-file ".local/transient/levels.el"))
  (transient-values-file (locate-user-emacs-file ".local/transient/values.el")))

(use-package magit
  :ensure t
  :bind (("C-x g" . magit-status))
  :custom
  ;; Without line numbers, fringe is too small to see.
  (magit-section-disable-line-numbers nil))

;; If you want to use self-host LLMs with Ollama, see `unused.el`.
(use-package gptel
  :ensure t
  :defer 1
  :custom
  (gptel-backend (gptel-make-deepseek "DeepSeek"
                   :stream t
                   :key 'gptel-api-key-from-auth-source
                   :models '(deepseek-flash))))

(use-package svg-lib
  :disabled t
  :ensure t
  :custom
  (svg-lib-icons-dir (locate-user-emacs-file ".local/svg-lib/")))

;; I don't enable this, because it makes part of syntax highlighting disappears,
;; and has bug with `emacsclient`.
;;
;; See <https://github.com/rougier/svg-lib/issues/18>.
(use-package svg-tag-mode
  :disabled t
  :ensure t
  :functions (global-svg-tag-mode svg-tag-mode)
  ;; A workaround to delay style calculating.
  ;; :init
  ;; (defun first-graphical-frame-hook-function ()
  ;;   (remove-hook 'focus-in-hook 'first-graphical-frame-hook-function)
  ;;   (provide 'my-gui))
  ;; (add-hook 'focus-in-hook 'first-graphical-frame-hook-function)

  ;; (with-eval-after-load 'my-gui
  ;;   (setq svg-lib-style-default (svg-lib-style-compute-default)))
  ;; Maybe use with hooks.
  :config
  ;; Make byte-compiler happy (for flycheck) until `:functions` really works.
  (declare-function global-svg-tag-mode "svg-tag-mode" (&optional arg))
  (declare-function svg-tag-mode "svg-tag-mode" (&optional arg))
  ;; (global-svg-tag-mode 1)
  :custom
  ;; See <https://github.com/rougier/svg-tag-mode#usage-example>.
  (svg-tag-tags
   '(("\\(:[A-Z]+:\\)" . ((lambda (tag)
                            (svg-tag-make tag :beg 1 :end -1))))
     ("TODO:" . ((lambda (tag)
                   (svg-tag-make tag
                                 :beg 0 :end -1 :inverse t :face 'warning))))
     ("FIXME:" . ((lambda (tag)
                    (svg-tag-make tag :beg 0 :end -1 :inverse t :face 'error))))
     ("NOTE:" . ((lambda (tag)
                   (svg-tag-make tag :beg 0 :end -1 :inverse t))))
     ("HACK:" . ((lambda (tag)
                   (svg-tag-make tag
                                 :beg 0 :end -1 :inverse t :face 'success))))
     ("XXX:" . ((lambda (tag)
                  (svg-tag-make tag :beg 0 :end -1)))))))

(provide 'alynx/packages)

;;; packages.el ends here.
