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
;;
;; Sequence matters.

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

(require 'alynx/packages-emacs)

(require 'alynx/packages-modes)

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
;; (use-package indent-bars
;;   :ensure t
;;   :disabled t
;;   ;; I only use this in `prog-mode`.
;;   :hook ((prog-mode . indent-bars-mode)
;;          (nxml-mode . indent-bars-mode)
;;          ;; `yaml-mode` should be `prog-mode`, anyway.
;;          (yaml-ts-mode . indent-bars-mode))
;;   :custom
;;   (indent-bars-pattern ".")
;;   ;; (indent-bars-color 'shadow)
;;   (indent-bars-width-frac 0.25)
;;   (indent-bars-pad-frac 0.125)
;;   (indent-bars-starting-column 0)
;;   (indent-bars-display-on-blank-lines t)
;;   (indent-bars-zigzag nil)
;;   (indent-bars-color-by-depth nil)
;;   (indent-bars-highlight-current-depth nil))

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
;;   :disabled t
;;   :init
;;   (setq sis-respect-start nil)
;;   :config
;;   (sis-ism-lazyman-config "xkb:us::eng" "rime" 'ibus)
;;   (sis-global-respect-mode t))

;; It turns out I never use Emacs for email.
;; (use-package mu4e
;;   :load-path (lambda ()
;;                (if (alynx/macosp)
;;                    "/opt/homebrew/share/emacs/site-lisp/mu/mu4e"
;;                  "/usr/share/emacs/site-lisp/mu4e"))
;;   :disabled t
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
;; `:custom`, for example `consult`, `flycheck` and `consult-flycheck`. If a
;; package depends on other packages, it should be placed after them.
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

(require 'alynx/packages-completion)

(require 'alynx/packages-org)

(require 'alynx/packages-flycheck)

(require 'alynx/packages-lsp)

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

;; (use-package svg-lib
;;   :ensure t
;;   :disabled t
;;   :custom
;;   (svg-lib-icons-dir (locate-user-emacs-file ".local/svg-lib/")))

;; I don't enable this, because it makes part of syntax highlighting disappears,
;; and has bug with `emacsclient`.
;;
;; See <https://github.com/rougier/svg-lib/issues/18>.
;; (use-package svg-tag-mode
;;   :ensure t
;;   :disabled t
;;   :functions (global-svg-tag-mode svg-tag-mode)
;;   ;; A workaround to delay style calculating.
;;   ;; :init
;;   ;; (defun first-graphical-frame-hook-function ()
;;   ;;   (remove-hook 'focus-in-hook 'first-graphical-frame-hook-function)
;;   ;;   (provide 'my-gui))
;;   ;; (add-hook 'focus-in-hook 'first-graphical-frame-hook-function)

;;   ;; (with-eval-after-load 'my-gui
;;   ;;   (setq svg-lib-style-default (svg-lib-style-compute-default)))
;;   ;; Maybe use with hooks.
;;   :config
;;   ;; Make byte-compiler happy (for flycheck) until `:functions` really works.
;;   (declare-function global-svg-tag-mode "svg-tag-mode" (&optional arg))
;;   (declare-function svg-tag-mode "svg-tag-mode" (&optional arg))
;;   ;; (global-svg-tag-mode 1)
;;   :custom
;;   ;; See <https://github.com/rougier/svg-tag-mode#usage-example>.
;;   (svg-tag-tags
;;    '(("\\(:[A-Z]+:\\)" . ((lambda (tag)
;;                             (svg-tag-make tag :beg 1 :end -1))))
;;      ("TODO:" . ((lambda (tag)
;;                    (svg-tag-make tag
;;                                  :beg 0 :end -1 :inverse t :face 'warning))))
;;      ("FIXME:" . ((lambda (tag)
;;                     (svg-tag-make tag :beg 0 :end -1 :inverse t :face 'error))))
;;      ("NOTE:" . ((lambda (tag)
;;                    (svg-tag-make tag :beg 0 :end -1 :inverse t))))
;;      ("HACK:" . ((lambda (tag)
;;                    (svg-tag-make tag
;;                                  :beg 0 :end -1 :inverse t :face 'success))))
;;      ("XXX:" . ((lambda (tag)
;;                   (svg-tag-make tag :beg 0 :end -1)))))))

(provide 'alynx/packages)

;;; packages.el ends here.
