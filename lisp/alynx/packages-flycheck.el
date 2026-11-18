;;; packages-flycheck.el --- Alynx's flycheck package configurations. -*- lexical-binding: t; -*-

;;; Commentary:
;; Flycheck related package-specific configurations.

;;; Code:

(require 'alynx/utils)

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

;; `lsp-bridge` has error popups and looks better than it.
;; (use-package flycheck-posframe
;;   :ensure t
;;   :disabled t
;;   :hook ((flycheck-mode . flycheck-posframe-mode))
;;   :config
;;   (flycheck-posframe-configure-pretty-defaults))

(provide 'alynx/packages-flycheck)

;;; packages-flycheck.el ends here.
