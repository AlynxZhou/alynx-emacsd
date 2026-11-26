;;; alynx-one-themes.el --- Alynx's One Dark theme. -*- lexical-binding: t -*-

;;; Commentary:
;; Alynx's One Dark theme.

;;; Code:

(require 'alynx-one-themes)

(defconst alynx-one--dark-colors
  '(:accent "#528BFF"
            :fg "#ABB2BF"
            :bg "#282C34"
            :bg-1 "#121417"
            :bg-hl "#2C323C"
            :selection "#3E4451"
            :ui-fg "#9DA5B4"
            :level-3-color "#21252B"
            :border "#181A1F"
            :gutter "#4B5363"
            :guide "#3C4049"
            :insert "#43D08A"
            :change "#E0C285"
            :delete "#E05252"
            :info "#6494ED"
            :success "#73C900"
            :warning "#E2C08D"
            :error "#FF6347"
            :mono-1 "#ABB2BF"
            :mono-2 "#828997"
            :mono-3 "#5C6370"
            :cyan "#56B6C2"
            :blue "#61AFEF"
            :purple "#C678DD"
            :green "#98C379"
            :red-1 "#E06C75"
            :red-2 "#BE5046"
            :orange-1 "#D19A66"
            :orange-2 "#E5C07B"
            :gray "#3E4451"
            :silver "#9DA5B4"
            :black "#21252B")
  "Dark variant colors of Alynx One themes.")

(deftheme alynx-one-dark
  "Alynx One Dark - Alynx's Emacs port of the Atom One Dark theme."
  :family 'alynx-one
  :kind 'color-scheme
  :background-mode 'dark)

(alynx-one--set-faces 'alynx-one-dark alynx-one--dark-colors)

(provide-theme 'alynx-one-dark)

;;; alynx-one-dark-theme.el ends here.
