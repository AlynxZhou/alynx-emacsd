;;; packages-modes.el --- Alynx's mode package configurations. -*- lexical-binding: t; -*-

;;; Commentary:
;; Mode related package-specific configurations.

;;; Code:

(require 'alynx/utils)

(require 'alynx/indentations)

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
  :load-path "site-lisp/rpm-spec-mode/"
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

(provide 'alynx/packages-modes)

;;; packages-modes.el ends here.
