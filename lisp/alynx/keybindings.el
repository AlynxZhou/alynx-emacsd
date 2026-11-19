;;; keybindings.el --- Alynx's keybinding configurations. -*- lexical-binding: t; -*-

;;; Commentary:
;; Global keybindings belong to no package.

;;; Code:

(require 'alynx/utils)

;; I maybe use this as prefix for some custom keybindings, but currently I prefer
;; `C-c`, because `C-z` is hard to press.
(global-unset-key (kbd "C-z"))

;; Prefer global font scaling instead of buffer content font scaling.
(dolist (key '("=" "+" "-" "0"))
  ;; Actually, this looks strange.
  ;; (global-set-key (kbd (concat "C-x C-M-" key)) 'text-scale-adjust)
  (global-set-key (kbd (concat "C-x C-" key)) 'global-text-scale-adjust))

;; Keybindings for setting indentations.
(global-set-key (kbd "C-c i TAB") 'indent-tabs)
(global-set-key (kbd "C-c i SPC") 'indent-spaces)
(global-set-key (kbd "C-c i o") 'set-indent-offset)
(global-set-key (kbd "C-c i w") 'set-tab-width)
(global-set-key (kbd "C-c i g") 'guess-indent)
;; Atom style indent left or right.
;;
;; TODO: Currently they will indent by a `tab-width`, I want to modify them to
;; use `indent-offset`. But I find just re-indent with `TAB` is enough, I hardly
;; need to manually tweak indent levels.
;;
;; See <https://dougie.io/emacs/indent-selection/>.
;;
;; NOTE: `M-[` happens to be the terminal escape prefix `\e[` (`Esc [`) so we
;; cannot use it, otherwise escape sequences will be directly inserted into
;; buffer because the prefix is handled as keybinding. For example, with iTerm2,
;; if you focus out and focus in it, you'll see `OI` inserted into buffer,
;; because they are `\e[O` and `\e[I`.
;; (global-set-key (kbd "M-[") 'indent-rigidly-left-to-tab-stop)
;; (global-set-key (kbd "M-]") 'indent-rigidly-right-to-tab-stop)

;; I use this in Atom, but by default `M-;` is used in Emacs, so I may use this
;; keybinding for others in future.
(global-set-key (kbd "C-;") 'comment-dwim)

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

;; By default, `join-line` will join current line into previous line. But in
;; Atom, I typically join next line into current line.
;;
;; See <https://emacsredux.com/blog/2013/05/30/joining-lines/>.
(defun join-next-line ()
  "Join the current line with the next line."
  (interactive)
  (join-line 1))

;; `C-j` is used to insert evaluated value in `lisp-interaction-mode`, maybe I
;; should find another keybinding for this.
(global-set-key (kbd "C-j") 'join-next-line)

;; See <https://emacsredux.com/blog/2013/05/22/smarter-navigation-to-the-beginning-of-a-line/>.
;;
;; Maybe `mwim` package is better? But do I really to move between code and
;; trailing comment?
(defun smarter-move-beginning-of-line (arg)
  "Move point back to indentation of beginning of line.

Move point to the first non-whitespace character on this line.
If point is already there, move to the beginning of the line.
Effectively toggle between the first non-whitespace character and
the beginning of the line.

If ARG is not nil or 1, move forward ARG - 1 lines first.  If
point reaches the beginning or end of the buffer, stop there."
  (interactive "^p")
  (setq arg (or arg 1))

  ;; Move lines first.
  (when (/= arg 1)
    (let ((line-move-visual nil))
      (forward-line (1- arg))))

  (let ((orig-point (point)))
    (back-to-indentation)
    (when (= orig-point (point))
      (move-beginning-of-line 1))))

;; Remap `C-a`, `Home` to `smarter-move-beginning-of-line`.
(global-set-key [remap move-beginning-of-line] 'smarter-move-beginning-of-line)

;; I found that vim style line insert commands helpful.
;;
;; `reindent-then-newline-and-indent` simulates what happens when press `ENTER`,
;; and for `open-previous-line`, we need to indent the new line manually.
(defun open-next-line ()
  "Insert an empty line below the current line."
  (interactive)
  (end-of-line)
  (reindent-then-newline-and-indent))

(defun open-previous-line ()
  "Insert an empty line above the current line."
  (interactive)
  (beginning-of-line)
  (reindent-then-newline-and-indent)
  (forward-line -1)
  (indent-according-to-mode))

(global-set-key (kbd "C-o") 'open-next-line)
;; `C-S-o` does not work well in terminal.
(global-set-key (kbd "M-o") 'open-previous-line)
(global-set-key (kbd "C-S-o") 'open-previous-line)

;; Find sibling file, but do not select it. We need this because we want to show
;; the result in other window. Just replace `find-file` with
;; `find-file-noselect` in `find-sibling-file`.
(defun find-sibling-file-noselect (file)
  "Read a \"sibling\" file of FILE into a buffer and return the buffer."
  (interactive (progn
                 (unless buffer-file-name
                   (user-error "Not visiting a file"))
                 (list buffer-file-name)))
  (unless find-sibling-rules
    (user-error "The `find-sibling-rules' variable has not been configured"))
  (let ((siblings (find-sibling-file-search (expand-file-name file)
                                            find-sibling-rules)))
    (cond
     ((null siblings)
      (user-error "Couldn't find any sibling files"))
     ((length= siblings 1)
      (find-file-noselect (car siblings)))
     (t
      (let ((relatives (mapcar (lambda (sibling)
                                 (file-relative-name
                                  sibling (file-name-directory file)))
                               siblings)))
        (find-file-noselect
         (completing-read (format-prompt "Find file" (car relatives))
                          relatives nil t nil nil (car relatives))))))))

;; Like `find-file-other-window`, but use `find-sibling-file-noselect`.
(defun find-sibling-file-other-window (file)
  "Visit a \"sibling\" file of FILE, in another window."
  (interactive (progn
                 (unless buffer-file-name
                   (user-error "Not visiting a file"))
                 (list buffer-file-name)))
  (switch-to-buffer-other-window
   (find-sibling-file-noselect file)))

(global-set-key (kbd "C-c M-f") 'find-sibling-file-other-window)

(defun show-file-path ()
  "Show the full file path of current buffer in the minibuffer."
  (interactive)
  (message "%s" buffer-file-name))

(global-set-key (kbd "C-c s") 'show-file-path)

(defun edit-config ()
  "Open `user-emacs-directory' to edit configurations."
  (interactive)
  (find-file user-emacs-directory))

(global-set-key (kbd "C-c ,") 'edit-config)

;; Some modes like `svg-tag-mode` uses color from theme, reset them.
(advice-add 'toggle-theme :after 'font-lock-flush)
(global-set-key (kbd "C-c t t") 'toggle-theme)

(defvar alynx/transparent nil
  "Whether frame transparency is enabled.")
(defun toggle-transparency ()
  "Toggle transparency for all frames."
  (interactive)
  (setq alynx/transparent (not alynx/transparent))
  (let ((key (if (featurep 'ns) 'alpha 'alpha-background))
        (value (if alynx/transparent 95 100)))
  (modify-all-frames-parameters `((,key . ,value)))))

(global-set-key (kbd "C-c t a") 'toggle-transparency)

(provide 'alynx/keybindings)

;;; keybindings.el ends here.
