;;; keybindings.el --- Alynx's keybinding configurations. -*- lexical-binding: t; -*-

;;; Commentary:
;; Keybindings belong to no package.

;;; Code:

(require 'alynx/utils)

(require 'alynx/indentations)

(require 'alynx/editing)

(require 'alynx/appearance)

;; I maybe use this as prefix for some custom keybindings, but currently I prefer
;; `C-c`, because `C-z` is hard to press.
(global-unset-key (kbd "C-z"))

;; Keybindings for setting indentations.
(global-set-key (kbd "C-c i TAB") 'indent-tabs)
(global-set-key (kbd "C-c i SPC") 'indent-spaces)
(global-set-key (kbd "C-c i o") 'set-indent-offset)
(global-set-key (kbd "C-c i w") 'set-tab-width)
(global-set-key (kbd "C-c i g") 'guess-indent)

;; See <https://www.gnu.org/software/emacs/manual/html_node/efaq/Backspace-invokes-help.html>.
;;
;; A long story: Old terminals make Backspace generate the same code as `C-h`,
;; and make Delete generate `DEL` code. Emacs binds backward delete to `DEL`
;; code and help prefix to `C-h` (Maybe that's why by default HHKB has a Delete
;; key in Backspace's place).
;;
;; But in GUI, Emacs makes Backspace generate `DEL` code, and make Delete
;; generate another code which is bound to forward delete. Also GNOME Terminal
;; makes Backspace generate `DEL` code by default, too.
;;
;; Another problem is that GNOME Terminal makes Delete generate escape sequence
;; by default, Emacs cannot handle it. But there are also conflict with other
;; keybindings, so I just suggest not to use Emacs in terminal.
;;
;; It's not good enough to translate Delete to `DEL` code and bind Backspace to
;; functions like `backward-delete-char`, because many backward delete related
;; functions are actually bound to `DEL` code.
;;
;; So what should do is to make `C-h` generate `DEL` code so it has the same
;; behavior as Backspace (like `C-i` for `TAB`), and don't forget to make `M-h`
;; the same as `M-DEL`.
;;
;; See <https://www.emacswiki.org/emacs/BackspaceKey>.
;;
;; I am not using `keyboard-translate` here, since it only accept 1 char (or a
;; key code), `M-DEL` does not generate a single key code, but a sequence.
;;
;; I use `kbd` because it's easy to read, char constant or vector is also OK.
;;
;; See <https://ftp.gnu.org/old-gnu/Manuals/emacs-20.7/html_node/emacs_451.html>.
;;
;; Since we make `C-h` generate `DEL`, it should not be the default help prefix
;; now, by default we have another help perfix key `<f1>`, just unset it so
;; `<f1>` will be used as default help prefix.
(global-unset-key (kbd "C-h"))
(define-key key-translation-map (kbd "C-h") (kbd "DEL"))
(define-key key-translation-map (kbd "M-h") (kbd "M-DEL"))

;; `C-j` is used to insert evaluated value in `lisp-interaction-mode`, maybe I
;; should find another keybinding for this.
(global-set-key (kbd "C-j") 'join-next-line)

;; Remap `C-a`, `Home` to `smarter-move-beginning-of-line`.
(global-set-key [remap move-beginning-of-line] 'smarter-move-beginning-of-line)

(global-set-key (kbd "C-o") 'open-next-line)
;; `C-S-o` does not work well in terminal.
(global-set-key (kbd "M-o") 'open-previous-line)
(global-set-key (kbd "C-S-o") 'open-previous-line)

(global-set-key (kbd "C-c M-f") 'find-sibling-file-other-window)

(global-set-key (kbd "C-c s") 'show-file-path)

(global-set-key (kbd "C-c ,") 'edit-config)

(global-set-key (kbd "C-c t a") 'toggle-transparency)

(provide 'alynx/keybindings)

;;; keybindings.el ends here.
