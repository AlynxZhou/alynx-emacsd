;;; packages-completion.el --- Alynx's completion packages configurations. -*- lexical-binding: t; -*-

;;; Commentary:
;; Completion-related package-specific configurations.

;;; Code:

(require 'alynx/utils)

;;; Helm, ivy, ido, and now vertico, who knows the next fashion?

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
  ;; Prevent lazy-loading, otherwise it won't work.
  :demand t
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
;;   :disabled t
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

(provide 'alynx/packages-completion)

;;; packages-completion.el ends here.
