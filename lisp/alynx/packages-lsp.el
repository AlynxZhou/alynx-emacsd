;;; packages-lsp.el --- Alynx's LSP packages configurations. -*- lexical-binding: t; -*-

;;; Commentary:
;; LSP-related package-specific configurations.

;;; Code:

(require 'alynx/utils)

;; Not every one loves `lsp-bridge`, but it works well for me.

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

(provide 'alynx/packages-lsp)

;;; packages-lsp.el ends here.
