;;; alynx-one-light-theme.el --- Alynx's One Light theme. -*- lexical-binding: t -*-

;;; Commentary:
;; Alynx's One Light theme.

;;; Code:

(require 'alynx-one-themes)

(defconst alynx-one--light-colors
  '(:accent "#526EFF"
            :fg "#383A42"
            :bg "#FAFAFA"
            :bg-1 "#E5E5E6"
            :bg-hl "#F0F0F1"
            :selection "#E5E5E6"
            :ui-fg "#424243"
            :level-3-color "#EAEAEB"
            :border "#DBDBDC"
            :gutter "#C2C2C3"
            :guide "#D3D3D5"
            :insert "#2DB448"
            :change "#F2A60D"
            :delete "#FF1414"
            :info "#1492FF"
            :success "#2DB448"
            :warning "#D5880B"
            :error "#F42A2A"
            :mono-1 "#383A42"
            :mono-2 "#696C77"
            :mono-3 "#A0A1A7"
            :cyan "#0184BC"
            :blue "#4078F2"
            :purple "#A626A4"
            :green "#50A14F"
            :red-1 "#E45649"
            :red-2 "#CA1243"
            :orange-1 "#B76B01"
            :orange-2 "#CB7701"
            :gray "#E5E5E6"
            :silver "#EAEAEB"
            :black "#424243")
  "Light variant colors of Alynx One themes.")

(deftheme alynx-one-light
  "Alynx One Light - Alynx's Emacs port of the Atom One Light theme."
  :family 'alynx-one
  :kind 'color-scheme
  :background-mode 'light)

(alynx-one--set-faces 'alynx-one-light alynx-one--light-colors)

(provide-theme 'alynx-one-light)

;;; alynx-one-light-theme.el ends here.
