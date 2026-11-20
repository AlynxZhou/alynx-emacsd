;;; editing.el --- Alynx's editing configurations. -*- lexical-binding: t; -*-

;;; Commentary:
;; Editing-related functions.

;;; Code:

(require 'alynx/utils)

;; By default, `join-line` will join current line into previous line. But in
;; Atom, I typically join next line into current line.
;;
;; See <https://emacsredux.com/blog/2013/05/30/joining-lines/>.
(defun join-next-line ()
  "Join the current line with the next line."
  (interactive)
  (join-line 1))

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

(defun show-file-path ()
  "Show the full file path of current buffer in the minibuffer."
  (interactive)
  (message "%s" buffer-file-name))

(defun edit-config ()
  "Open `user-emacs-directory' to edit configurations."
  (interactive)
  (find-file user-emacs-directory))

(provide 'alynx/editing)

;;; editing.el ends here.
