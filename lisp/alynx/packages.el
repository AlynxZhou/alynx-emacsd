;;; packages.el --- Alynx's packages configurations. -*- lexical-binding: t; -*-

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
(setq package-archive-priorities '(("gnu" . 0)
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

;; Sequence matters.
;;
;; For example, if A and B depends on C, C must be placed before A and B, because
;; the latter needs to obey the former's `:custom` section.
;;
;; I don't use `:after` here, because we may have keybindings for dependencies,
;; which leads into an autoload, and if you have 2 dependencies in `:after`,
;; you need to first press both keybindings of those 2 dependencies to load them,
;; then configurations of the 2 packages will be run, it won't work before those
;; keybindings. I don't want this, I just want to run `:custom` of dependencies
;; first, so keep the sequence is the easiest.
;;
;; See <https://github.com/jwiegley/use-package/issues/976#issuecomment-1056017784>.

(require 'alynx/packages-general)

(require 'alynx/packages-editing)

(require 'alynx/packages-appearance)

(require 'alynx/packages-modes)

(require 'alynx/packages-completion)

(require 'alynx/packages-flycheck)

(require 'alynx/packages-lsp)

(require 'alynx/packages-org)

(require 'alynx/packages-magit)

;; If you want to use self-host LLMs with Ollama, see `unused.el`.
;; (use-package gptel
;;   :ensure t
;;   :disabled t
;;   :defer 1
;;   :custom
;;   (gptel-backend (gptel-make-deepseek "DeepSeek"
;;                    :stream t
;;                    :key 'gptel-api-key-from-auth-source
;;                    :models '(deepseek-flash))))

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

(provide 'alynx/packages)

;;; packages.el ends here.
