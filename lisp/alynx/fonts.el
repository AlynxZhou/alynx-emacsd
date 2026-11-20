;;; fonts.el --- Alynx's fonts configurations. -*- lexical-binding: t; -*-

;;; Commentary:
;; The correct way to set default and fallback fonts in Emacs.

;;; Code:

(require 'alynx/utils)

;; Forget it.
;; (setq font-use-system-font t)

;; By default fixed pitch faces use monospace, but not all my systems use Monaco
;; as monospace, for example macOS, so explicitly set Monaco here for them to
;; solve this.
;;
;; `display-fill-column-indicator` and `highlight-indent-guide` uses box-drawing
;; characters to draw bars, but the default characters in Monaco is not so good,
;; it has padding before and after it. To fix this I used my patched Monaco
;; which merges Menlo's box-drawing characters into it.
(dolist (face '(default fixed-pitch fixed-pitch-serif))
  (set-face-attribute face nil
                      :family "Monaco"
                      ;; :slant 'normal
                      ;; :width 'normal
                      ;; :weight 'normal
                      ;; 1 height is 1/10 pt. 140 is too small on macOS.
                      :height (if (alynx/macosp) 180 140)))

;; Set fallback fonts, like 中文 or 😸.
;;
;; Emacs does not handle fonts fallback with FontConfig directly, instead it has
;; something called `fontset`. While there are more then one `fontset`s, we only
;; need to handle `fontset-default` mostly.
;;
;; You can modify `fontset` by `set-fontset-font`, but it's not a simple list of
;; fonts, it contains different lists for different charsets. If you don't give
;; a charset, you are changing the default charset, however, it's not for every
;; chars, but only for chars that cannot be found in other charsets. So at least
;; we have to modify all charsets we need.
;;
;; See <https://archive.casouri.cc/note/2019/emacs-%E5%AD%97%E4%BD%93%E4%B8%8E%E5%AD%97%E4%BD%93%E9%9B%86/>.
;;
;; Don't set size here, otherwise when scaling Chinese won't scale.
;;
;; NOTE: Noto Sans CJK has no italic version, so if you cannot see CJK in
;; italic, it's not a bug. Maybe Sarasa Fixed has a generated italic version.
;;
;; See <https://github.com/notofonts/noto-fonts/issues/1466#issuecomment-469384694>.
(defun alynx/clear-and-set-fallback-fonts ()
  "Clear fontset and set fallback fonts."
  (dolist (charset '(han kana hangul symbol cjk-misc bopomofo))
    ;; FIXME: Not sure why Emacs prefers Sarasa Fixed, even I add Noto Sans Mono
    ;; CJK SC before it, I have to clear the list before adding fonts.
    (set-fontset-font t charset nil)
    ;; Prepend to the beginning of charset font lists.
    (set-fontset-font t charset
                      (font-spec :family (if (alynx/macosp)
                                             "Apple Color Emoji"
                                           "Noto Color Emoji"))
                      nil 'prepend)
    (set-fontset-font t charset
                      (font-spec :family (if (alynx/macosp)
                                             "PingFang SC"
                                           "Noto Sans Mono CJK SC"))
                      nil 'prepend)
    (set-fontset-font t charset
                      (font-spec :family "Monaco")
                      nil 'prepend))
  ;; Fix Monaco box-drawing characters and block elements (`▀▄█░▒▓` ) on macOS.
  (when (alynx/macosp)
    (set-fontset-font t '(#x2500 . #x257F)
                      (font-spec :family "Menlo"))
    (set-fontset-font t '(#x2580 . #x259F)
                      (font-spec :family "Menlo"))))

;; Follow fontset choices for symbols instead of preferring the default font.
;; This is required by the macOS Monaco workaround.
(setq use-default-font-for-symbols nil)

;; HACK: Set fallback fonts directly does not work for `emacsclient`. When
;; client starts a daemon, it firstly does not have GUI and those font related
;; setups are ignored. So we need to call this after frame created.
;;
;; See <https://www.reddit.com/r/emacs/comments/3a5kim/comment/cs9i9qd/?utm_source=share&utm_medium=web2x&context=3>.
(if (daemonp)
    (add-hook 'after-make-frame-functions
              (lambda (frame)
                (select-frame frame)
                (alynx/clear-and-set-fallback-fonts)))
  (alynx/clear-and-set-fallback-fonts))

;; Previously I use `("Noto Sans Mono CJK SC" . 0.85)`, because Noto Sans Mono
;; CJK has a larger ascent and descent to contain some tall glphys, which makes
;; it impossible to align it with Monaco and enlarges line height.
;;
;; However, it does have correct metrics in `OS/2` table, but it does not set
;; `USE_TYPO_METRICS` bit of `fsSelection`, so harfbuzz won't use it, I finally
;; patch those fonts to set that bit, then it will align with Monaco.
;;
;; See <https://github.com/AlynxZhou/alynx-arch-packages/tree/master/packages/noto-fonts-cjk-alynx>.
;;
;; I have no idea on `PingFang SC`, so still use this way.
(setq face-font-rescale-alist '(("PingFang SC" . 0.9)))
;; There is also another solution that enlarge line spacing and line height, but
;; it breaks box-drawing characters. If we are using stipple, this is OK, but
;; currently there are also problems with stipple.
;; (setq default-text-properties '(line-spacing 0.2 line-height 1.2))

;; Don't clean font-caches during GC.
(setq inhibit-compacting-font-caches t)

(provide 'alynx/fonts)

;;; fonts.el ends here.
