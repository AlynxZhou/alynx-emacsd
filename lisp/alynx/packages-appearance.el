;;; packages-appearance.el --- Alynx's appearance packages configurations. -*- lexical-binding: t; -*-

;;; Commentary:
;; Appearance-related package-specific configurations.

;;; Code:

(require 'alynx/utils)

(require 'alynx/indentations)

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

(use-package uniquify
  :defer t
  :custom
  (uniquify-buffer-name-style 'forward))

(use-package paren
  :defer t
  :custom
  ;; This is really confusing, because it looks like your cursor jumps.
  (show-paren-when-point-inside-paren nil))

(use-package hl-line
  :config
  (global-hl-line-mode 1))

(use-package display-line-numbers
  :config
  (global-display-line-numbers-mode 1)
  :custom
  ;; Calculate max number to prevent shaking.
  (display-line-numbers-width-start t)
  (display-line-numbers-grow-only t))

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
  (when (alynx/macosp)
    (set-face-attribute 'fill-column-indicator nil :family "Menlo")
    ;; We have to redo this each time we toggle theme.
    (add-hook 'enable-theme-functions
              (lambda (theme)
                (set-face-attribute 'fill-column-indicator nil :family "Menlo"))))
  :custom
  ;; Set column ruler at 80 columns. However Emacs displays it in given column,
  ;; so actually we need to add 1 column.
  (display-fill-column-indicator-column (+ 1 80))
  ;; HACK: `display-fill-column-indicator` uses ASCII `|` when it finds the
  ;; box-drawing character cannot be drawn with the default font. This is silly.
  (display-fill-column-indicator-character ?│))

(use-package whitespace
  ;; Sometimes manually enabling this is a good idea to check whitespaces.
  :defer t
  :custom
  ;; Showing newlines is annoying, I don't need that.
  (whitespace-style '(face spaces tabs trailing space-mark tab-mark)))

;; Prefer global font scaling instead of buffer content font scaling. Actually,
;; the non-global variant looks strange.
(use-package face-remap
  :bind (("C-x C-=" . global-text-scale-adjust)
         ("C-x C-+" . global-text-scale-adjust)
         ("C-x C--" . global-text-scale-adjust)
         ("C-x C-0" . global-text-scale-adjust)))

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

(use-package custom
  :bind (("C-c t t". toggle-theme))
  :config
  ;; Some modes like `svg-tag-mode` uses color from theme, reset them.
  (advice-add 'toggle-theme :after 'font-lock-flush))

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

(use-package keycast
  :ensure t
  :config
  ;; I have custom mode-line, `keycast-mode-line-mode` won't work.
  (keycast-invisible-mode 1))

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

(provide 'alynx/packages-appearance)

;;; packages-appearance.el ends here.
