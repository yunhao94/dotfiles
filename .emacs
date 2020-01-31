;;; .emacs --- Personal configuration.  -*- lexical-binding: t; no-byte-compile: t; -*-

;;; License:

;; This file is not part of GNU Emacs

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; For a full copy of the GNU General Public License
;; see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Personal initialization file of Emacs

;; The skeleton of this configuration is highly inspired by TheBB (Eivind
;; Fonn)'s personal configuration, see <https://github.com/TheBB/dotemacs/>.

;; To make it easier to navigate this file, `outline-minor-mode' is used for
;; org-mode-like folding: use `<backtab>' to hide/show the outline summary.

;;; Code:

(let ((minver "26.3"))
  (when (version< emacs-version minver)
    (error "Your Emacs is too old -- this config requires v%s or higher" minver)))

(setq load-prefer-newer t)

(setq gc-cons-threshold most-positive-fixnum)

(defvar +file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)
(add-hook 'emacs-startup-hook (lambda () (setq file-name-handler-alist +file-name-handler-alist)))

;;* Initialize package and setup use-package

;; (setq package-archives '(("gnu" . "https://elpa.gnu.org/packages/")
;;                          ("melpa" . "https://melpa.org/packages/")))

(if (file-exists-p (locate-user-emacs-file "elpa-snapshot/archive-contents"))
    (setq package-archives `(("snapshot" . ,(locate-user-emacs-file "elpa-snapshot/"))))
  (setq package-archives '(("snapshot" . "https://raw.githubusercontent.com/yunhao94/elpa-snapshot/master/"))))

(setq package-enable-at-startup nil)
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-and-compile
  (setq use-package-always-defer t
        use-package-enable-imenu-support t
        use-package-expand-minimally t
        use-package-verbose 'errors
        use-package-always-ensure t))

(eval-when-compile
  (require 'use-package))

;;* Packages that should be loaded early

(use-package gnu-elpa-keyring-update)

(use-package quelpa-use-package
  ;; :demand t
  :init
  (setq quelpa-checkout-melpa-p nil
        quelpa-self-upgrade-p nil
        quelpa-use-package-inhibit-loading-quelpa t)
  :config
  (quelpa-use-package-activate-advice))

(use-package general
  :demand t
  :config
  (defalias 'gsetq #'general-setq)
  (defalias 'gsetq-default #'general-setq-default)

  (general-evil-setup))

(use-package no-littering
  :demand t)

(use-package hydra)

;;* Theme and mode-line

(use-package modus-operandi-theme
  :init
  (load-theme 'modus-operandi t))

(use-package modus-vivendi-theme)

(use-package minions
  :preface
  (defun +set-mode-line-misc-info (variable string &optional append)
    "With the help of `minions-mode', it's easy to keep the mode-line clean by
displaying information with `mode-line-misc-info', like `sly--mode-line-format'
and `eglot--mode-line-format'."
    (if (assq variable mode-line-misc-info)
        (setcar (cdr (assq variable mode-line-misc-info))
                (list "[" string "] "))
      (add-to-list 'mode-line-misc-info `(,variable ("[" ,string "] ")) append))
    ;; ensure `global-mode-string' at the end of `mode-line-misc-info'
    (let ((end (assq 'global-mode-string mode-line-misc-info)))
      (setq mode-line-misc-info (append (remove end mode-line-misc-info) `(,end)))))
  :init
  (minions-mode)
  :config
  (add-to-list 'minions-direct 'defining-kbd-macro))

;;* General Emacs settings (bindings, built-ins, etc.)

(use-package emacs
  :init
  (gsetq create-lockfiles nil
         enable-recursive-minibuffers t
         fast-but-imprecise-scrolling t
         history-delete-duplicates t
         indicate-empty-lines t
         kill-buffer-query-functions nil
         menu-bar-mode nil
         ring-bell-function 'ignore
         text-quoting-style 'grave
         tool-bar-mode nil
         truncate-partial-width-windows nil
         use-file-dialog nil

         ;; bindings.el
         column-number-indicator-zero-based nil
         mode-line-frame-identification "  "

         ;; cus-edit.el
         custom-file (no-littering-expand-etc-file-name "custom.el")

         ;; dired.el
         dired-dwim-target t
         dired-recursive-copies 'always
         dired-recursive-deletes 'top

         ;; files.el
         auto-save-default nil
         confirm-kill-emacs #'y-or-n-p
         confirm-kill-processes nil
         confirm-nonexistent-file-or-buffer t
         make-backup-files nil
         require-final-newline t

         ;; ibuf-ext.el
         ibuffer-show-empty-filter-groups nil

         ;; indent.el
         tab-always-indent nil

         ;; mouse.el
         mouse-yank-at-point t

         ;; mule-cmds.el
         current-language-environment 'UTF-8
         default-input-method 'TeX

         ;; scroll-bar.el
         scroll-bar-mode nil

         ;; simple.el
         column-number-mode t
         kill-do-not-save-duplicates t
         save-interprogram-paste-before-kill t
         shift-select-mode nil

         ;; startup.el
         inhibit-startup-buffer-menu t
         inhibit-startup-screen t
         initial-major-mode 'fundamental-mode
         initial-scratch-message nil

         ;; tooltip.el
         tooltip-mode nil

         ;; uniquify.el
         uniquify-buffer-name-style 'forward

         ;; vc-hooks.el
         vc-follow-symlinks t)

  (gsetq-default fill-column 80
                 fringes-outside-margins t
                 indent-tabs-mode nil
                 tab-width 4
                 truncate-lines t
                 vertical-scroll-bar nil
                 word-wrap t)

  (defalias 'yes-or-no-p #'y-or-n-p)

  (put #'compose-mail 'disabled t)
  (put #'dired-find-alternate-file 'disabled nil)
  (put #'narrow-to-region 'disabled nil)

  (general-def
    [remap just-one-space] #'cycle-spacing            ; M-SPC
    [remap delete-horizontal-space] #'delete-blank-lines ; M-\
    [remap capitalize-word] #'capitalize-dwim            ; M-c
    [remap downcase-word] #'downcase-dwim                ; M-l
    [remap upcase-word] #'upcase-dwim)                   ; M-u

  (general-def
    "M-g" nil                           ; `goto-map'
    "M-o" nil                           ; `facemenu-keymap'
    "M-s" nil)                          ; `search-map'

  (general-def
    "<f2>" #'universal-argument)        ; `2C-mode-map'

  (general-def universal-argument-map
    "<f2>" #'universal-argument-more)

  (general-def 'override
    "C-h" (general-key "DEL")
    ;; "C-u" (general-key "<C-S-backspace>")
    ;; "C-w" (general-key "<C-backspace>")
    "M-`" (general-key "<tab>"))

  (general-def 'override
    :predicate '(not (display-graphic-p))
    "C-@" (general-key "C-SPC")
    "C-M-@" (general-key "C-M-SPC"))

  (defun +find-custom-file ()
    "Edit file `custom-file'."
    (interactive)
    (find-file custom-file))

  (defun +find-org-default-notes-file ()
    "Edit file `org-default-notes-file'."
    (interactive)
    (require 'org)
    (find-file org-default-notes-file))

  (defun +find-user-init-file ()
    "Edit file `user-init-file'."
    (interactive)
    (find-file user-init-file))

  ;; see <http://endlessparentheses.com/emacs-narrow-or-widen-dwim.html>
  (defun +narrow-or-widen-dwim (arg)
    "Widen if buffer is narrowed, narrow-dwim otherwise.
With prefix ARG, don't widen, just narrow even if buffer is already narrowed."
    (interactive "P")
    (cond ((and (buffer-narrowed-p)
                (not arg))
           (widen))
          ((region-active-p)
           (narrow-to-region
            (region-beginning)
            (region-end))
           (deactivate-mark))
          ((derived-mode-p 'org-mode)
           (org-narrow-to-subtree))
          ((derived-mode-p 'latex-mode)
           (LaTeX-narrow-to-environment))
          (t
           (narrow-to-defun))))

  (defun +scratch (arg)
    "Switch to the `*scratch*' buffer in another window."
    (interactive "P")
    (let ((current-major-mode major-mode))
      (pop-to-buffer "*scratch*")
      (if arg
          (funcall current-major-mode)
        (when (eq major-mode 'fundamental-mode)
          (lisp-interaction-mode)))))

  (defun +switch-to-scratch-buffer ()
    "Switch to the `*scratch*'."
    (interactive)
    (switch-to-buffer "*scratch*"))

  (defun +view-help ()
    "View the `*Help*' buffer in another window, if it exists."
    (interactive)
    (if (get-buffer "*Help*")
        (with-current-buffer (help-buffer)
          (display-buffer (current-buffer)))
      (help-for-help)))

  (general-create-definer general-lmap
    :states '(normal visual motion insert emacs)
    :prefix-command 'leader-command
    :prefix-map 'leader-map
    :prefix "SPC"
    :non-normal-prefix "M-SPC")

  (general-def 'override
    :states '(normal visual motion)
    "SPC" #'leader-command)

  (general-lmap
    "a" '(:ignore t :which-key "action")
    "b" '(:ignore t :which-key "buffer")
    "c" '(:ignore t :which-key t)
    "f" '(:ignore t :which-key "file")
    "g" '(:ignore t :which-key "git")
    "h" '(:ignore t :which-key "help")
    "j" '(:ignore t :which-key "jump")
    "l" '(:ignore t :which-key "lsp")
    "n" '(:ignore t :which-key "narrow")
    "o" '(:ignore t :which-key "org")
    "p" '(:ignore t :which-key "project")
    "r" '(:ignore t :which-key "ctl-x-r")
    "s" '(:ignore t :which-key "search")
    "t" '(:ignore t :which-key "toggle")
    "x" '(:ignore t :which-key "ctl-x"))

  (general-def leader-map
    "c" (general-simulate-key "C-c")    ; C-c
    "h" 'help-command                   ; C-h
    "x" 'Control-X-prefix               ; C-x
    "n" narrow-map                      ; C-x n
    "r" ctl-x-r-map                     ; C-x r

    "1" #'shell-command                 ; M-!
    "7" #'async-shell-command           ; M-&
    ";" #'eval-expression               ; M-:
    "u" #'universal-argument            ; C-u

    "q" #'evil-quit                     ; :q
    "Q" #'evil-quit-all                 ; :qa
    "w" #'evil-write                    ; :w
    "W" #'evil-write-all                ; :wa
    "z" #'evil-save-modified-and-close  ; :wq
    "Z" #'evil-save-and-quit            ; :wqa

    "SPC" #'counsel-M-x
    "TAB" #'evil-switch-to-windows-last-buffer

    "bb" #'ivy-switch-buffer
    "bc" #'clone-indirect-buffer
    "bd" #'evil-delete-buffer
    "bD" #'dired-jump
    "bi" #'counsel-ibuffer
    "bI" #'ibuffer
    "bk" #'kill-buffer
    "bm" #'counsel-major
    "bn" #'evil-next-buffer
    "bp" #'evil-prev-buffer
    "br" #'revert-buffer
    "bs" #'+switch-to-scratch-buffer
    "bx" #'kill-current-buffer
    "bz" #'bury-buffer

    "fa" #'ff-find-other-file
    "fb" #'counsel-bookmark
    "fc" #'+find-custom-file
    "fd" #'counsel-dired-jump
    "fe" #'counsel-find-library
    "ff" #'find-file
    "fi" #'+find-user-init-file
    "fj" #'counsel-file-jump
    "fl" #'counsel-locate
    "fn" #'+find-org-default-notes-file
    "fp" #'project-find-file
    "fr" #'counsel-buffer-or-recentf
    "fs" #'save-some-buffers
    "fw" #'write-file

    "hc" #'describe-char
    "hg" #'describe-face
    "hG" #'describe-gnu-project
    "hh" #'+view-help
    "hH" #'view-hello-file
    "hL" #'view-lossage
    "hp" #'describe-package
    "hP" #'list-processes
    "hs" #'+scratch
    "ht" #'load-theme

    "nf" #'narrow-to-defun
    "nn" #'+narrow-or-widen-dwim
    "nr" #'narrow-to-region

    "td" #'toggle-debug-on-error
    "to" #'read-only-mode
    "tt" #'toggle-truncate-lines)

  (general-create-definer general-llmap
    :states '(normal visual motion insert emacs)
    :prefix ","
    :non-normal-prefix "M-,")

  (general-def 'override
    :states '(normal visual motion insert emacs)
    :prefix ","
    :non-normal-prefix "M-,"
    "," (general-simulate-key "C-c C-c" :which-key "C-c C-c")
    "." (general-simulate-key "C-c C-k" :which-key "C-c C-k")))

(use-package autorevert
  :ghook
  ('after-init-hook #'global-auto-revert-mode)
  :config
  (gsetq auto-revert-verbose nil))

(use-package bookmark
  :config
  (general-def
    [remap bookmark-yank-word] #'backward-kill-word))

(use-package compile
  :general
  (general-def leader-map
    :prefix "a"
    "c" #'compile)
  :config
  (gsetq compilation-scroll-output t)

  ;; see <https://endlessparentheses.com/ansi-colors-in-the-compilation-buffer-output.html>
  (defun +compile-ansi-color-apply-on-compilation ()
    "Colorize from `compilation-filter-start' to `point'."
    (require 'ansi-color)
    (with-silent-modifications
      (ansi-color-apply-on-region compilation-filter-start (point))))
  (general-add-hook 'compilation-filter-hook #'+compile-ansi-color-apply-on-compilation))

(use-package delsel
  :ghook
  ('after-init-hook #'delete-selection-mode))

(use-package display-line-numbers
  :ghook
  '(prog-mode-hook conf-mode-hook)
  :general
  (general-def leader-map
    :prefix "t"
    "n" #'+display-line-numbers-toggle-numbers)
  :config
  (gsetq display-line-numbers-type 'relative
         display-line-numbers-width-start t)

  (defun +display-line-numbers-toggle-numbers (arg)
    "Toggle display of line numbers in the buffer.
When ARG isn't nil, change the `display-line-numbers-type'."
    (interactive "P")
    (if (not arg)
        (setq-local display-line-numbers
                    (if (eq display-line-numbers display-line-numbers-type)
                        nil
                      display-line-numbers-type))
      (setq-local display-line-numbers-type
                  (or (eq display-line-numbers-type 'relative)
                      'relative))
      (+display-line-numbers-toggle-numbers nil))))

(use-package ediff
  :config
  (gsetq ediff-diff-options "-w"
         ediff-window-setup-function #'ediff-setup-windows-plain)

  ;; restore window config after quitting ediff
  ;; see <https://emacs.stackexchange.com/questions/7482/restoring-windows-and-layout-after-an-ediff-session>
  (defvar +ediff-winconf-saved nil)

  (defun +ediff-save-winconf ()
    (setq +ediff-winconf-saved (current-window-configuration)))
  (general-add-hook 'ediff-before-setup-hook #'+ediff-save-winconf)

  (defun +ediff-restore-winconf ()
    (when (window-configuration-p +ediff-winconf-saved)
      (set-window-configuration +ediff-winconf-saved)))
  (general-add-hook '(ediff-quit-hook ediff-suspend-hook) #'+ediff-restore-winconf t))

(use-package elec-pair
  :ghook
  ('(prog-mode-hook conf-mode-hook) #'electric-pair-local-mode))

(use-package eshell
  :general
  (general-def leader-map
    "'" #'+eshell)
  :config
  (gsetq eshell-prompt-function
         (lambda ()
           (concat (abbreviate-file-name (eshell/pwd))
                   (if (= (user-uid) 0) "\n# " "\nλ ")))
         eshell-prompt-regexp "^[^#λ\n]* ?[#λ] "

         eshell-cmpl-cycle-completions nil
         eshell-cmpl-ignore-case t
         eshell-glob-case-insensitive t
         eshell-hist-ignoredups t)

  (defun +eshell-exit-delete-window ()
    (unless (one-window-p)
      (delete-window)))
  (general-add-hook 'eshell-exit-hook #'+eshell-exit-delete-window)

  (defun +eshell (&optional arg)
    "Select an interactive Eshell buffer in another window."
    (interactive "P")
    (cl-assert eshell-buffer-name)
    (let ((buf (get-buffer-create eshell-buffer-name))
          (cwd default-directory))
      (cl-assert (and buf (buffer-live-p buf)))
      (pop-to-buffer buf)
      (unless (derived-mode-p 'eshell-mode)
        (eshell-mode))
      (when arg
        (if (eshell-process-interact 'process-live-p)
            (message "Won't change CWD because of running process.")
          (setq default-directory cwd)
          (eshell-reset)))))

  (with-eval-after-load 'counsel
    (general-def
      [remap eshell-list-history] #'counsel-esh-history)))

(use-package flyspell
  :general
  (general-def leader-map
    :prefix "t"
    "s" #'flyspell-mode)
  :ghook
  ('prog-mode-hook #'flyspell-prog-mode)
  ('text-mode-hook #'flyspell-mode))

(use-package hideshow
  :ghook
  ('prog-mode-hook #'hs-minor-mode)
  :general
  (general-def leader-map
    :prefix "t"
    "f" #'hs-minor-mode))

(use-package hl-line
  :ghook
  '(occur-mode-hook outline-mode-hook tabulated-list-mode-hook)
  :general
  (general-def leader-map
    :prefix "t"
    "h" #'hl-line-mode)
  :config
  (gsetq hl-line-sticky-flag nil)

  ;; disable `hl-line-mode' temporarily, `hl-line-mode' can make the selection region harder to see while in evil visual state
  ;; see <https://github.com/hlissner/doom-emacs/core/core-ui.el>
  (defvar +hl-line-need-to-be-enabled nil)

  (defun +hl-line-disable ()
    (when hl-line-mode
      (setq-local +hl-line-need-to-be-enabled t)
      (hl-line-mode -1)))
  (general-add-hook '(evil-visual-state-entry-hook activate-mark-hook) #'+hl-line-disable)

  (defun +hl-line-maybe-enable ()
    (when +hl-line-need-to-be-enabled
      (hl-line-mode 1)
      (kill-local-variable '+hl-line-need-to-be-enabled)))
  (general-add-hook '(evil-visual-state-exit-hook deactivate-mark-hook) #'+hl-line-maybe-enable))

(use-package ielm
  :general
  (general-def leader-map
    ":" #'+ielm)
  :config
  (defun +ielm ()
    (interactive)
    (let (old-point)
      (unless (comint-check-proc "*ielm*")
        (with-current-buffer (get-buffer-create "*ielm*")
          (unless (zerop (buffer-size)) (setq old-point (point)))
          (inferior-emacs-lisp-mode)))
      (pop-to-buffer "*ielm*")
      (when old-point (push-mark old-point)))))

(use-package man
  :general
  (general-def help-map
    "n" #'man))

(use-package mb-depth
  :ghook
  ('after-init-hook #'minibuffer-depth-indicate-mode))

(use-package midnight
  :defer 5
  :config
  (gsetq midnight-period 7200)

  (midnight-delay-set 'midnight-delay t))

(use-package paren
  :ghook
  ('after-init-hook #'show-paren-mode)
  :config
  (gsetq show-paren-delay 0))

(use-package recentf
  :defer 1
  :config
  (gsetq recentf-max-saved-items 200
         recentf-exclude
         '("/tmp/"
           "/ssh:"
           "/\\.dir-locals\\.el\\'"     ; `dir-locals-file'
           "/\\.emacs\\.d/elpa"         ; `package-user-dir'
           "/\\.emacs\\.d/var/"         ; `no-littering-var-directory'
           "/TAGS\\'"))

  (let ((inhibit-message t))
    (recentf-load-list)))

(use-package savehist
  :ghook
  'after-init-hook)

(use-package saveplace
  :ghook
  ('after-init-hook #'save-place-mode))

(use-package smerge-mode
  :general
  (general-def smerge-mode-map
    "C-c C-c" #'+hydra-smerge/body)
  :config
  ;; see <https://github.com/alphapapa/unpackaged.el#smerge-mode>
  (defhydra +hydra-smerge (:color pink :hint nil :post (smerge-auto-leave))
    "
^Move^       ^Keep^               ^Diff^                 ^Other^
^^-----------^^-------------------^^---------------------^^-------
_n_ext       _b_ase               _<_: upper/base        _C_ombine
_p_rev       _u_pper              _=_: upper/lower       _r_esolve
^^           _l_ower              _>_: base/lower        _K_ill current
^^           _a_ll                _R_efine
^^           _RET_: current       _E_diff
"
    ("n" smerge-next)
    ("p" smerge-prev)
    ("b" smerge-keep-base)
    ("u" smerge-keep-upper)
    ("l" smerge-keep-lower)
    ("a" smerge-keep-all)
    ("RET" smerge-keep-current)
    ("<" smerge-diff-base-upper)
    ("=" smerge-diff-upper-lower)
    (">" smerge-diff-base-lower)
    ("R" smerge-refine)
    ("E" smerge-ediff)
    ("C" smerge-combine-with-next)
    ("r" smerge-resolve)
    ("K" smerge-kill-current)
    ("q" nil "cancel" :color blue)))

(use-package whitespace
  :ghook
  '(prog-mode-hook conf-mode-hook)
  :general
  (general-def leader-map
    :prefix "t"
    "w" #'whitespace-mode)
  (general-def leader-map
    :prefix "a"
    "w" #'whitespace-cleanup)
  :config
  (gsetq whitespace-style '(face trailing tabs lines-tail tab-mark)
         whitespace-line-column nil))

(use-package winner
  :init
  (gsetq winner-dont-bind-my-keys t)
  :ghook
  'after-init-hook
  :config
  (general-def evil-window-map
    "u" #'winner-undo
    "C-r" #'winner-redo
    "C-u" #'winner-undo
    "U" #'winner-redo))

;;* Evil and Co.

(use-package evil
  :init
  (gsetq evil-want-integration t
         evil-want-keybinding nil
         evil-want-C-u-delete t
         evil-want-C-u-scroll t
         evil-want-C-w-in-emacs-state t
         evil-want-Y-yank-to-eol t

         evil-mode-line-format '(before . mode-line-mule-info)
         evil-normal-state-tag "N"
         evil-insert-state-tag "I"
         evil-visual-state-tag "V"
         evil-operator-state-tag "O"
         evil-replace-state-tag "R"
         evil-motion-state-tag "M"
         evil-emacs-state-tag "E")
  :ghook
  'after-init-hook
  :config
  (gsetq evil-ex-search-vim-style-regexp t
         evil-ex-substitute-global t
         evil-ex-visual-char-range t
         evil-kill-on-visual-paste nil)

  (gsetq-default evil-symbol-word-search t)

  ;; use `evil-search' as search module
  (evil-select-search-module 'evil-search-module 'evil-search)

  ;; better imenu integration
  (general-add-hook 'imenu-after-jump-hook #'evil-set-jump)

  (with-eval-after-load 'elisp-mode
    (add-to-list 'lisp-imenu-generic-expression
                 '("Evil commands"
                   "^\\s-*(evil-define-\\(?:command\\|operator\\|motion\\|text-object\\) +\\(\\_<[^ ()\n]+\\_>\\)"
                   1)))

  ;; go to REPL prompt on switching to insert state
  (defun +evil-repl-goto-prompt ()
    (when (derived-mode-p 'comint-mode
                          'eshell-mode
                          'term-mode)
      (goto-char (point-max))))
  (general-add-hook 'evil-insert-state-entry-hook #'+evil-repl-goto-prompt)

  ;; cleanup when exiting insert state
  (defun +evil-cleanup-insert-state ()
    (when (region-active-p)
      (deactivate-mark))
    (when (and (bound-and-true-p company-mode)
               (company--active-p))
      (company-abort)))
  (general-add-hook 'evil-insert-state-exit-hook #'+evil-cleanup-insert-state)

  ;; cleanup highlight with "C-l", inspired by vim-sensible
  (define-advice recenter-top-bottom (:before (&rest _) nohighlight)
    "Cleanup evil search highlights, if any."
    (when (evil-ex-hl-active-p 'evil-ex-search)
      (evil-ex-nohighlight)))

  (evil-declare-not-repeat #'recenter-top-bottom)

  ;; don't save `evil-jumps-history' permanently
  (general-add-advice #'evil--jumps-savehist-load :override #'ignore)

  ;; apply `evil-cross-lines' to f, F, t, T only
  (defun +advice-evil-find-char-cross-line (orig-func &rest args)
    "Make horizontal motions move to other lines."
    (let ((evil-cross-lines t))
      (apply orig-func args)))
  (general-add-advice (list #'evil-find-char
                            #'evil-find-char-backward
                            #'evil-find-char-to
                            #'evil-find-char-to-backward)
                      :around #'+advice-evil-find-char-cross-line)

  ;; don't copy when press C-w or C-u
  ;; see <https://github.com/noctuid/dotfiles/blob/master/emacs/.emacs.d/awaken.org>
  (defun +advice-evil-dont-kill-new (orig-func &rest args)
    "Run ORIG-FUNC with ARGS preventing any `kill-new's from running."
    ;; http://endlessparentheses.com/understanding-letf-and-how-it-replaces-flet.html
    (cl-letf (((symbol-function 'kill-new) #'ignore))
      (apply orig-func args)))
  (general-add-advice (list #'evil-delete-backward-word
                            #'evil-delete-back-to-indentation
                            #'lispyville-delete-backward-word
                            #'lispyville-delete-back-to-indentation)
                      :around #'+advice-evil-dont-kill-new)

  ;; extra text-objects
  (evil-define-text-object +evil-a-defun (count &optional beg end type)
    "Select a function."
    (evil-select-an-object 'evil-defun beg end type count))

  (evil-define-text-object +evil-inner-defun (count &optional beg end type)
    "Select inner defun."
    (evil-select-inner-object 'evil-defun beg end type count))

  (general-otomap
    "f" #'+evil-a-defun)

  (general-itomap
    "f" #'+evil-inner-defun)

  (with-eval-after-load 'lispyville
    (general-def lispyville-mode-map
      [remap +evil-a-defun] #'lispyville-a-function
      [remap +evil-inner-defun] #'lispyville-inner-function))

  (evil-define-text-object +evil-a-line (count &optional beg end type)
    "Select a line."
    (evil-select-an-object 'line beg end type count))

  (evil-define-text-object +evil-inner-line (count &optional beg end type)
    "Select inner line."
    (evil-range (save-excursion (evil-first-non-blank) (point)) (line-end-position)))

  (general-otomap
    "l" #'+evil-a-line)

  (general-itomap
    "l" #'+evil-inner-line)

  ;; show `evil-record-macro' register in the mode-line
  (defun +evil-record-macro-mode-line-format ()
    (if (bound-and-true-p evil-this-macro)
        (list " Def["
              (propertize (format "@%s" (char-to-string evil-this-macro))
                          'face 'mode-line-emphasis)
              "]")
      " Def"))
  (setcar (cdr (assq 'defining-kbd-macro minor-mode-alist))
          '(:eval (+evil-record-macro-mode-line-format)))

  ;; show line counts in the mode-line, ported from doom-modeline
  (defun +evil-count-lines-mode-line-format ()
    (propertize
     (let* ((beg evil-visual-beginning)
            (end evil-visual-end)
            (lines (count-lines beg end))
            (chars (- end beg)))
       (cond ((eq evil-visual-selection 'block)
              (let ((cols (abs (- (evil-column end) (evil-column beg)))))
                (format "%d×%dB" lines cols)))
             ((eq evil-visual-selection 'line)
              (format "%dL" lines))
             ((> lines 1)
              (format "%dC %dL" chars lines))
             (t
              (format "%dC" chars))))
     'face 'mode-line-emphasis))
  (+set-mode-line-misc-info 'evil-visual-state-minor-mode '(:eval (+evil-count-lines-mode-line-format)))

  ;; vimish key bindings
  (general-nmap
    "Q" "@q"
    "g." #'evil-ex-repeat
    "go" #'goto-char
    "gp" #'+evil-select-last-paste
    "gr" #'revert-buffer)

  (defun +evil-select-last-paste ()
    "`[v`]"
    (interactive)
    (evil-visual-select (evil-goto-mark ?\[ t) (evil-goto-mark ?\] t)))

  (general-vmap
    "Q" #'+evil-norm@q)

  (defun +evil-norm@q ()
    ":norm @q<CR>"
    (interactive)
    (cl-assert (evil-visual-state-p))
    (evil-ex-normal (region-beginning) (region-end) "@q"))

  ;; more convenient window moving
  (general-def evil-window-map
    "C-h" #'evil-window-left
    "C-j" #'evil-window-down
    "C-k" #'evil-window-up
    "C-l" #'evil-window-right
    "C-f" #'scroll-other-window
    "C-b" #'scroll-other-window-down)

  ;; ensure "RET"/"M-RET" consistency in terminal
  (general-mmap 'override
    "RET" (general-key "<return>")
    "M-RET" (general-key "<M-return>"))

  ;; if `evil-want-C-i-jump' is t, "TAB" will override "<tab>" in some modes
  (when evil-want-C-i-jump
    (general-mmap '(apropos-mode-map package-menu-mode-map process-menu-mode-map)
      "<tab>" #'forward-button))

  ;; "C-SPC" completion
  (general-imap
    "C-SPC" #'completion-at-point)

  ;; ":" -> ";"
  (general-mmap
    ";" #'evil-ex)

  ;; ";" -> "M-;", "," ->"M-,"
  (general-mmap
    "M-;" #'evil-repeat-find-char
    "M-," #'evil-repeat-find-char-reverse)

  ;; "C-i/o" fallback
  (general-mmap
    "g C-i" #'evil-jump-forward
    "g C-o" #'evil-jump-backward)

  ;; see <https://github.com/tpope/vim-rsi>
  (general-def evil-insert-state-map
    "C-a" nil                         ; `evil-paste-last-insertion' -> "C-x C-a"
    "C-d" nil                         ; `evil-shift-left' -> "C-x C-d"
    "C-e" nil                         ; `evil-copy-from-below' -> "M-y"
    "C-k" nil                         ; `evil-insert-digraph' -> "C-x C-v"
    "C-t" nil                         ; `evil-shift-right' -> "C-x C-t"
    "M-n" #'next-line
    "M-p" #'previous-line
    "M-y" #'evil-copy-from-below)

  (general-def evil-ex-completion-map
    "C-a" nil                           ; `evil-ex-completion'
    "C-b" nil                           ; `move-beginning-of-line'
    "C-d" nil                           ; `evil-ex-completion'
    "C-k" nil                           ; `evil-insert-digraph'
    "C-x C-r" #'yank-pop)

  (general-def minibuffer-local-map
    "C-n" #'next-line-or-history-element
    "C-p" #'previous-line-or-history-element
    "C-u" #'kill-whole-line
    "C-w" #'backward-kill-word
    "C-x C-r" #'yank-pop)

  ;; vim-rsi-styled "C-f" in minibuffer
  (general-def '(evil-ex-completion-map evil-ex-search-keymap)
    "C-f" nil)

  (general-def evil-ex-completion-map
    :predicate '(eolp)
    "C-f" #'evil-ex-command-window)

  (general-def evil-ex-search-keymap
    :predicate '(eolp)
    "C-f" #'evil-ex-search-command-window)

  ;; simulate i_CTRL-X
  (defhydra +hydra-evil-insert-ctl-x (:color blue :hint nil)
    "C-x completion"
    ;; ins-special-keys
    ("C-a" evil-paste-last-insertion :color red)
    ("C-d" evil-shift-left-line :color red)
    ("C-t" evil-shift-right-line :color red)
    ("C-v" (call-interactively #'evil-insert-digraph) :color red)
    ;; ins-completion
    ("C-]" company-etags "")
    ("C-f" company-files "")
    ("C-i" company-capf "")
    ("C-k" +counsel-fzf-complete-words "")
    ("C-l" eacl-complete-line "")
    ("C-n" +company-dabbrev "")
    ("C-o" counsel-company "")
    ("C-r" counsel-evil-registers "")
    ("C-s" company-yasnippet "")
    ("C-u" +counsel-tmux-complete "")
    ("C-y" counsel-yank-pop "")
    ("s" company-ispell "")
    ;; snippets
    ("C-c" aya-create)
    ("C-e" aya-expand)
    ("C-m" aya-open-line)
    ;; miscellaneous
    ("c" insert-char)
    ("l" lorem-ipsum-insert-list)
    ("t" hl-todo-insert))

  (general-imap 'override
    "C-x" #'+hydra-evil-insert-ctl-x/body))

(use-package evil-collection
  :after evil
  :demand t
  :init
  (defvar +evil-collection-disabled-modes '(outline lispy))
  :config
  (dolist (mode +evil-collection-disabled-modes)
    (setq evil-collection-mode-list (delq mode evil-collection-mode-list)))

  (evil-collection-init)

  (with-eval-after-load 'evil-collection-buff-menu
    (general-nmap Buffer-menu-mode-map
      "C-d" #'evil-scroll-down
      "D" #'Buffer-menu-delete-backwards
      "C-j" #'next-line
      "C-k" #'previous-line))

  (with-eval-after-load 'evil-collection-dired
    (general-nmap dired-mode-map
      "C-j" #'dired-next-line
      "C-k" #'dired-previous-line
      "C-n" #'dired-next-dirline
      "C-p" #'dired-prev-dirline
      "DEL" #'dired-unmark-backward))

  (with-eval-after-load 'evil-collection-eshell
    (defun +evil-collection-eshell-setup-keys ()
      (general-imap eshell-mode-map
        "C-d" #'+eshell-quit-or-delete-char
        "C-n" #'eshell-next-matching-input-from-input
        "C-p" #'eshell-previous-matching-input-from-input
        "C-u" #'eshell-kill-input
        "M-n" #'eshell-next-prompt
        "M-p" #'eshell-previous-prompt))
    (if (version< emacs-version "27.1")
        (general-add-hook 'eshell-first-time-mode-hook #'+evil-collection-eshell-setup-keys)
      (+evil-collection-eshell-setup-keys))

    (defun +eshell-quit-or-delete-char (n)
      "Delete a character (ahead of the cursor) or quit eshell if there's
nothing to delete."
      (interactive "p")
      (if (and (eolp) (looking-back eshell-prompt-regexp nil))
          (eshell-life-is-too-much)
        (delete-char n))))

  (with-eval-after-load 'evil-collection-flymake
    (general-nvmap flymake-diagnostics-buffer-mode-map
      "C-j" #'+flymake-show-diagnostic-next
      "C-k" #'+flymake-show-diagnostic-prev)

    (defun +flymake-show-diagnostic-next (n)
      (interactive "p")
      (forward-line n)
      (flymake-show-diagnostic (point)))

    (defun +flymake-show-diagnostic-prev (n)
      (interactive "p")
      (forward-line (- n))
      (flymake-show-diagnostic (point))))

  (with-eval-after-load 'evil-collection-geiser
    (general-imap geiser-repl-mode-map
      "C-n" #'comint-next-matching-input-from-input
      "C-p" #'comint-previous-matching-input-from-input
      "M-n" #'geiser-repl-next-prompt
      "M-p" #'geiser-repl-previous-prompt))

  (with-eval-after-load 'evil-collection-grep
    (general-nmap grep-mode-map
      [remap evil-search-next] #'evil-ex-search-next
      "p" #'ignore))

  (with-eval-after-load 'evil-collection-image
    (general-nmap image-mode-map
      "+" #'image-increase-size
      "-" #'image-decrease-size))

  (with-eval-after-load 'evil-collection-imenu-list
    (general-nmap imenu-list-major-mode-map
      "C-j" #'+imenu-list-display-next
      "C-k" #'+imenu-list-display-prev
      "M-RET" #'imenu-list-display-entry)

    (defun +imenu-list-display-next (n)
      (interactive "p")
      (forward-line n)
      (unless (hs-looking-at-block-start-p)
        (imenu-list-display-entry)))

    (defun +imenu-list-display-prev (n)
      (interactive "p")
      (forward-line (- n))
      (unless (hs-looking-at-block-start-p)
        (imenu-list-display-entry))))

  (with-eval-after-load 'evil-collection-info
    (general-nmap Info-mode-map
      "m" #'Info-menu
      "t" #'Info-top-node
      "f" #'Info-follow-reference
      "C-f" #'Info-scroll-up
      "C-b" #'Info-scroll-down))

  (with-eval-after-load 'evil-collection-ivy
    (general-nmap ivy-occur-mode-map
      "C-j" #'next-error-no-select
      "C-k" #'previous-error-no-select)

    (general-def ivy-occur-grep-mode-map
      "w" nil))

  (with-eval-after-load 'evil-collection-occur
    (general-nmap occur-mode-map
      "C-j" #'next-error-no-select
      "C-k" #'previous-error-no-select))

  (with-eval-after-load 'evil-collection-simple
    (general-nmap process-menu-mode-map
      "S" #'tabulated-list-sort
      "d" #'process-menu-delete-process
      "q" #'quit-window))

  (with-eval-after-load 'evil-collection-sly
    (general-imap sly-mrepl-mode-map
      "C-n" #'sly-mrepl-next-input-or-button
      "C-p" #'sly-mrepl-previous-input-or-button
      "M-n" #'sly-mrepl-next-prompt
      "M-p" #'sly-mrepl-previous-prompt))

  (with-eval-after-load 'evil-collection-view
    (general-nmap view-mode-map
      "C-j" #'View-scroll-line-forward
      "C-k" #'View-scroll-line-backward)))

(use-package evil-collection-unimpaired
  :ensure evil-collection
  :after evil
  :config
  ;; `evil-collection-unimpaired-mode' overrides "["/"]" prefixed bindings used
  ;; by `evil-magit', so disable the minor mode and rebind those manually
  (global-evil-collection-unimpaired-mode -1)

  (general-nmap
    "[ SPC" #'+evil-unimpaired-lines-add-above
    "] SPC" #'+evil-unimpaired-lines-add-below
    "[e" #'+evil-unimpaired-lines-exchange-above
    "]e" #'+evil-unimpaired-lines-exchange-below
    "[p" #'+evil-unimpaired-pasting-above
    "]p" #'+evil-unimpaired-pasting-bellow
    "[b" #'previous-buffer
    "]b" #'next-buffer
    "[q" #'previous-error
    "]q" #'next-error)

  (evil-define-command +evil-unimpaired-lines-add-above (count)
    "Add COUNT blank lines above the cursor."
    (interactive "p")
    (evil-exit-visual-state)
    (dotimes (_ count) (save-excursion (evil-insert-newline-above)))
    ;; if at the beginning of a line, move the point forward to the correct position
    (when (bolp) (forward-line count)))

  (evil-define-command +evil-unimpaired-lines-add-below (count)
    "Add COUNT blank lines below the cursor."
    (interactive "p")
    (evil-exit-visual-state)
    (dotimes (_ count) (save-excursion (evil-insert-newline-below))))

  (evil-define-command +evil-unimpaired-lines-exchange-above (count)
    "Exchange the current line with COUNT lines above it."
    (interactive "p")
    (cl-destructuring-bind (beg end)
        (if (evil-visual-state-p)
            (list (region-beginning) (region-end))
          (list (line-beginning-position) (1+ (line-end-position))))
      (evil-move beg end (- (line-number-at-pos beg) count 1))))

  (evil-define-command +evil-unimpaired-lines-exchange-below (count)
    "Exchange the current line with COUNT lines below it."
    (interactive "p")
    (cl-destructuring-bind (beg end)
        (if (evil-visual-state-p)
            (list (region-beginning) (region-end))
          (list (line-beginning-position) (1+ (line-end-position))))
      (evil-move beg end (+ (line-number-at-pos end) count -1))))

  ;; see <https://github.com/syl20bnr/spacemacs/blob/develop/layers/%2Bspacemacs/spacemacs-evil/local/evil-unimpaired/evil-unimpaired.el>
  (evil-define-command +evil-unimpaired-pasting-above (&optional register)
    "Paste after linewise, increasing indent."
    (interactive "<x>")
    (setq this-command 'evil-paste-after)
    (evil-insert-newline-above)
    (evil-paste-after 1 register))

  (evil-define-command +evil-unimpaired-pasting-bellow (&optional register)
    "Paste after linewise, decreasing indent."
    (interactive "<x>")
    (setq this-command 'evil-paste-after)
    (evil-insert-newline-below)
    (evil-paste-after 1 register)))

(use-package evil-args
  :after evil
  :ghook
  ('(emacs-lisp-mode-hook lisp-mode-hook scheme-mode-hook) #'+evil-args-lisp-delimiters)
  :general
  (general-mmap
    "]a" #'evil-forward-arg
    "[a" #'evil-backward-arg)
  (general-otomap
    "a" #'evil-outer-arg)
  (general-itomap
    "a" #'evil-inner-arg)
  :config
  (defun +evil-args-lisp-delimiters ()
    (setq-local evil-args-delimiters '(" "))))

(use-package evil-embrace
  :after evil-surround
  :init
  (evil-embrace-enable-evil-surround-integration)
  :ghook
  ('LaTeX-mode-hook #'embrace-LaTeX-mode-hook)
  ('emacs-lisp-mode-hook #'embrace-emacs-lisp-mode-hook)
  ('org-mode-hook #'embrace-org-mode-hook)
  ('(org-mode-hook LaTeX-mode-hook) #'+evil-embrace-latex-mode-hook)
  :config
  (gsetq evil-embrace-show-help-p nil)

  (defun +evil-embrace-latex-mode-hook ()
    (embrace-add-pair ?$ "$" "$")
    (embrace-add-pair-regexp ?\\ "\\[a-z]+{" "}" #'+evil-embrace--latex-command))

  (defun +evil-embrace--latex-command ()
    "LaTeX command support for embrace."
    (cons (format "\\%s{" (read-string "\\")) "}")))

(use-package evil-exchange
  :after evil
  :general
  (general-nmap
    "gx" #'evil-exchange
    "gX" #'evil-exchange-cancel)
  :config
  (gsetq evil-exchange-highlight-face 'evil-ex-substitute-replacement))

(use-package evil-indent-plus
  :after evil
  :general
  (general-otomap
    "i" #'evil-indent-plus-a-indent
    "k" #'evil-indent-plus-a-indent-up
    "j" #'evil-indent-plus-a-indent-up-down)
  (general-itomap
    "i" #'evil-indent-plus-i-indent
    "k" #'evil-indent-plus-i-indent-up
    "j" #'evil-indent-plus-i-indent-up-down))

(use-package evil-matchit
  :after evil
  :ghook
  '(org-mode-hook c-mode-hook c++-mode-hook python-mode-hook sh-mode-hook lua-mode-hook)
  :general
  (general-def leader-map
    :prefix "t"
    "%" #'evil-matchit-mode)
  (general-nvmap
    "g%" #'evilmi-jump-items)
  (general-otomap
    "%" #'evilmi-outer-text-object)
  (general-itomap
    "%" #'evilmi-inner-text-object)
  :config
  (general-nvmap evil-matchit-mode-map
    "g%" #'evil-jump-item)

  (+set-mode-line-misc-info 'evil-matchit-mode "%%" t))

(use-package evil-multiedit
  :after evil
  :init
  (gsetq evil-multiedit-state-tag "mN"
         evil-multiedit-insert-state-tag "mI")
  :ghook
  ('iedit-mode-hook #'+iedit-evil-multiedit-ensure)
  :general
  (general-nmap
    "M-i" #'evil-multiedit-match-all)
  (general-imap
    "M-v" #'evil-multiedit-toggle-marker-here)
  :config
  (defun +iedit-evil-multiedit-ensure ()
    "Always enable `evil-multiedit' state after starting up an iedit."
    (if (evil-insert-state-p)
        (evil-multiedit-insert-state)
      (evil-multiedit-state)))

  (general-def evil-multiedit-state-map
    "#" #'iedit-number-occurrences
    "*" #'iedit-restrict-function
    "n" #'evil-multiedit-next
    "N" #'evil-multiedit-prev
    "RET" #'evil-multiedit-toggle-or-restrict-region))

(use-package evil-nerd-commenter
  :after evil
  :general
  (general-nmap
    "gc" #'evilnc-comment-operator
    "gy" #'evilnc-copy-and-comment-operator)
  (general-otomap
    "c" #'evilnc-outer-commenter)
  (general-itomap
    "c" #'evilnc-inner-comment))

(use-package evil-numbers
  ;; :quelpa (evil-numbers :fetcher github :repo "janpath/evil-numbers")
  :after evil
  :general
  (general-nvmap
    "C-a" #'evil-numbers/inc-at-pt
    "C-x" #'evil-numbers/dec-at-pt
    "g C-a" #'evil-numbers/inc-at-pt-incremental
    "g C-x" #'evil-numbers/dec-at-pt-incremental)
  :config
  ;; `magit-file-mode-map' use hard-coded "C-x" instead of `ctl-x-map'
  (with-eval-after-load 'magit-files
    (general-def magit-file-mode-map
      "C-x" nil)

    (general-def ctl-x-map
      "g" #'magit-status
      "M-g" #'magit-dispatch)))

(use-package evil-quick-diff
  ;; :quelpa (evil-quick-diff :fetcher github :repo "rgrinberg/evil-quick-diff")
  :after evil
  :init
  (evil-ex-define-cmd "diff" #'+evil-ex-quick-diff)

  (evil-define-command +evil-ex-quick-diff (beg end type &optional bang)
    "Ediff two regions.
If BANG is non nil then cancel current pending diff."
    (interactive "<R><!>")
    (if bang
        (evil-quick-diff-cancel)
      (evil-quick-diff beg end type))))

(use-package evil-snipe
  :after evil
  :init
  (gsetq evil-snipe-override-evil-repeat-keys nil)

  (evil-snipe-override-mode)
  :config
  ;; ensure `evil-snipe-override-mode' always works
  (general-add-hook 'evil-snipe-override-local-mode-hook #'evil-normalize-keymaps)

  (gsetq evil-snipe-scope 'visible)

  (general-mmap evil-snipe-override-local-mode-map
    [remap evil-repeat-find-char] #'evil-snipe-repeat
    [remap evil-repeat-find-char-reverse] #'evil-snipe-repeat-reverse)

  (with-eval-after-load 'magit
    (general-add-hook 'magit-mode-hook #'turn-off-evil-snipe-override-mode)))

(use-package evil-surround
  :after evil
  :init
  (global-evil-surround-mode))

;;* Company and Co.

(use-package company
  :ghook
  ('after-init-hook #'global-company-mode)
  :general
  (general-def leader-map
    :prefix "t"
    "c" #'company-mode)
  :config
  (gsetq company-global-modes '(not comint-mode eshell-mode)
         company-minimum-prefix-length 2
         company-selection-wrap-around t
         company-show-numbers t
         company-tooltip-align-annotations t

         company-dabbrev-downcase nil
         company-dabbrev-ignore-case t)

  (define-advice company-begin-backend (:before (&rest _) abort-previous)
    "Allow users to switch between backends on the fly.
E.g. C-x C-s followed by C-x C-n, will switch from `company-yasnippet' to
`company-dabbrev-code'."
    (company-abort))

  (general-def company-active-map
    "C-h" nil
    "C-u" nil
    "C-w" nil
    "C-d" #'company-show-doc-buffer
    "C-t" #'company-other-backend
    "C-y" #'company-complete-selection)

  (general-imap company-mode-map
    "C-SPC" #'company-complete)

  ;; see <https://github.com/hlissner/doom-emacs/modules/completion/company/autoload.el>
  (defun +company-dabbrev ()
    "Invokes `company-dabbrev-code' in prog-mode buffers and `company-dabbrev'
everywhere else."
    (interactive)
    (call-interactively
     (if (derived-mode-p 'prog-mode)
         #'company-dabbrev-code
       #'company-dabbrev))))

(use-package company-prescient
  :after company
  :init
  (company-prescient-mode)
  :config
  (with-eval-after-load 'sly
    (defun +sly-disable-company-prescient ()
      (setq-local company-prescient-sort-length-enable nil))
    (general-add-hook 'sly-mode-hook #'+sly-disable-company-prescient)))

;;* Eglot and Co.

(use-package eglot
  :general
  (general-def leader-map
    :prefix "a"
    "l" #'eglot)
  (general-def leader-map
    :prefix "l"
    "l" #'eglot-reconnect
    "k" #'eglot-shutdown
    "r" #'eglot-rename
    "f" #'eglot-format
    "a" #'eglot-code-actions
    "h" #'eglot-help-at-point
    "c" #'eglot-signal-didChangeConfiguration
    "e" #'eglot-events-buffer)
  :config
  (gsetq eglot-autoshutdown t)

  (add-to-list 'eglot-server-programs '((c-mode c++-mode) . ("clangd")))

  (+set-mode-line-misc-info 'eglot--managed-mode eglot--mode-line-format))

(use-package flymake
  :general
  (general-def leader-map
    :prefix "t"
    "l" #'flymake-mode)
  (general-def leader-map
    :prefix "l"
    "n" #'flymake-goto-next-error
    "p" #'flymake-goto-prev-error)
  (general-mmap
    "[l" #'flymake-goto-prev-error
    "]l" #'flymake-goto-next-error)
  (general-def help-map
    "l" #'flymake-show-diagnostics-buffer)
  :config
  (defun +flymake-mode-line-format ()
    "Produce a pretty mode-line indicator, modified from the original
`flymake--mode-line-format'."
    (let* ((known (hash-table-keys flymake--backend-state))
           (running (flymake-running-backends))
           (disabled (flymake-disabled-backends))
           (reported (flymake-reporting-backends))
           (diags-by-type (make-hash-table))
           (all-disabled (and disabled (null running)))
           (some-waiting (cl-set-difference running reported)))
      (maphash (lambda (_b state)
                 (mapc (lambda (diag)
                         (push diag
                               (gethash (flymake--diag-type diag)
                                        diags-by-type)))
                       (flymake--backend-state-diags state)))
               flymake--backend-state)
      `(,@(pcase-let ((`(,ind ,face ,explain)
                       (cond ((null known)
                              '("?" mode-line "No known backends"))
                             (some-waiting
                              `("^" compilation-mode-line-run
                                ,(format "Waiting for %s running backend(s)"
                                         (length some-waiting))))
                             (all-disabled
                              '("!" compilation-mode-line-run
                                "All backends disabled"))
                             (t
                              '(nil nil nil)))))
            (when ind
              `(((:propertize ,ind
                              face ,face
                              help-echo ,explain
                              keymap
                              ,(let ((map (make-sparse-keymap)))
                                 (define-key map [mode-line mouse-1]
                                   'flymake-switch-to-log-buffer)
                                 map))))))
        ,@(unless (or all-disabled
                      (null known))
            (cl-loop
             with types = (hash-table-keys diags-by-type)
             with _augmented = (cl-loop for extra in '(:error :warning)
                                        do (cl-pushnew extra types
                                                       :key #'flymake--severity))
             for type in (cl-sort types #'> :key #'flymake--severity)
             for diags = (gethash type diags-by-type)
             for face = (flymake--lookup-type-property type
                                                       'mode-line-face
                                                       'compilation-error)
             when (or diags
                      (cond ((eq flymake-suppress-zero-counters t)
                             nil)
                            (flymake-suppress-zero-counters
                             (>= (flymake--severity type)
                                 (warning-numeric-level
                                  flymake-suppress-zero-counters)))
                            (t t)))
             collect `(:propertize
                       ,(format "%d" (length diags))
                       face ,face
                       mouse-face mode-line-highlight
                       keymap
                       ,(let ((map (make-sparse-keymap))
                              (type type))
                          (define-key map (vector 'mode-line
                                                  mouse-wheel-down-event)
                            (lambda (event)
                              (interactive "e")
                              (with-selected-window (posn-window (event-start event))
                                (flymake-goto-prev-error 1 (list type) t))))
                          (define-key map (vector 'mode-line
                                                  mouse-wheel-up-event)
                            (lambda (event)
                              (interactive "e")
                              (with-selected-window (posn-window (event-start event))
                                (flymake-goto-next-error 1 (list type) t))))
                          map)
                       help-echo
                       ,(concat (format "%s diagnostics of type %s\n"
                                        (propertize (format "%d"
                                                            (length diags))
                                                    'face face)
                                        (propertize (format "%s" type)
                                                    'face face))
                                (format "%s/%s: previous/next of this type"
                                        mouse-wheel-down-event
                                        mouse-wheel-up-event)))
             into forms
             finally return
             `(,@(cl-loop for (a . rest) on forms by #'cdr
                          collect a when rest collect
                          '(:propertize " "))))))))
  (+set-mode-line-misc-info 'flymake-mode '(:eval (+flymake-mode-line-format))))

;;* Ivy and Co.

(use-package ivy
  :ghook
  'after-init-hook
  :general
  (general-def leader-map
    "." #'ivy-resume)
  :config
  (gsetq ivy-count-format "(%d/%d) "
         ivy-fixed-height-minibuffer t
         ivy-read-action-function #'ivy-hydra-read-action
         ivy-use-selectable-prompt t
         ivy-use-virtual-buffers t
         ivy-virtual-abbreviate 'full

         projectile-completion-system 'ivy
         helm-make-completion-method 'ivy
         dumb-jump-selector 'ivy)

  (ivy-set-actions
   t
   `(("i" ,(lambda (x) (insert (if (stringp x) x (car x)))) "insert")
     ("y" ,(lambda (x) (kill-new (if (stringp x) x (car x)))) "yank")))

  (general-def ivy-minibuffer-map
    "C-M-SPC" #'ivy-restrict-to-matches
    "C-M-j" #'ivy-avy
    "C-j" #'ivy-immediate-done
    "C-u" #'ivy-kill-whole-line
    "C-w" #'ivy-backward-kill-word
    "RET" #'ivy-alt-done
    "TAB" #'ivy-partial)

  (general-def '(ivy-occur-mode-map ivy-occur-grep-mode-map)
    "M-RET" #'ivy-occur-press)

  ;; pinyin support
  (defvar +ivy--regex-plus-pinyin-traditional-p nil)

  (defun +ivy--regex-plus-pinyin (str)
    (ivy--regex-plus
     (pinyinlib-build-regexp-string str t +ivy--regex-plus-pinyin-traditional-p t)))

  (defun +ivy-toggle-pinyin (arg)
    "Toggle the re builder between `+ivy--regex-plus-pinyin' and `ivy--regex-plus'."
    (interactive "P")
    (require 'pinyinlib nil t)
    (setq ivy--old-re nil)
    (setq +ivy--regex-plus-pinyin-traditional-p arg)
    (if (eq ivy--regex-function '+ivy--regex-plus-pinyin)
        (setq ivy--regex-function 'ivy--regex-plus)
      (setq ivy--regex-function '+ivy--regex-plus-pinyin)))

  (general-def ivy-minibuffer-map
    "M-h" #'+ivy-toggle-pinyin))

(use-package counsel
  :after ivy
  :init
  (counsel-mode)
  :general
  (general-def leader-map
    :prefix "s"
    "a" #'counsel-ag
    "b" #'counsel-switch-buffer
    "f" #'counsel-fzf
    "g" #'+counsel-git-log
    "i" #'counsel-git-grep
    "j" #'counsel-imenu
    "k" #'+counsel-evil-jumps
    "l" #'counsel-ace-link
    "m" #'counsel-evil-marks
    "o" #'counsel-outline
    "r" #'counsel-rg
    "s" #'counsel-grep-or-swiper
    "t" #'counsel-tmm
    "u" #'counsel-unicode-char
    "v" #'counsel-set-variable)
  :config
  (gsetq ivy-initial-inputs-alist nil
         counsel-switch-buffer-preview-virtual-buffers nil
         counsel-yank-pop-preselect-last t
         counsel-yank-pop-separator "\n----\n")

  (ivy-add-actions 'counsel-buffer-or-recentf
                   '(("d" (lambda (file)
                            (setq recentf-list (delete file recentf-list)))
                      "delete from recentf")))

  (ivy-add-actions 'counsel-find-library
                   '(("l" (lambda (x)
                            (load-library
                             (get-text-property 0 'full-name x)))
                      "load library")))

  (defun +counsel-git-log ()
    "Call the \"git log --grep\" shell command, and visit the commit with magit."
    (interactive)
    (ivy-read "Show commit: " #'counsel-git-log-function
              :dynamic-collection t
              :action #'counsel-git-log-show-commit-action
              :caller 'counsel-git-log))

  ;; port of tmux-complete.vim <https://github.com/wellle/tmux-complete.vim>
  (defun +counsel-tmux-complete (arg)
    "Complete words in tmux.
With prefix ARG, complete for all panes the server processes."
    (interactive "P")
    (counsel-require-program "tmux")
    (let* ((cmd (concat "tmux list-panes" (when arg " -a") " -F '#D'"
                        " | xargs -n1 -I{} tmux capture-pane -p -J -t {}"))
           (cands (delete-dups (split-string (shell-command-to-string cmd)
                                             "[^a-zA-Z0-9_-]" t))))
      (setq ivy-completion-beg (- (point) (length (ivy-thing-at-point))))
      (setq ivy-completion-end (point))
      (ivy-read "tmuxcomplete: " cands
                :action #'ivy-completion-in-region-action
                :initial-input (ivy-thing-at-point)
                :re-builder #'ivy--regex-fuzzy)))

  ;; port of fzf-complete-word <https://github.com/junegunn/fzf.vim>
  (defun +counsel-fzf-complete-words ()
    "Complete words in /usr/share/dict/words."
    (interactive)
    (counsel-require-program "fzf")
    (let* ((words "/usr/share/dict/words")
           (counsel--fzf-dir "")
           (counsel-fzf-cmd (if (file-exists-p words)
                                (format "cat %s | fzf -f \"%%s\"" words)
                              (user-error "There is no %s" words))))
      (setq ivy-completion-beg (- (point) (length (ivy-thing-at-point))))
      (setq ivy-completion-end (point))
      (ivy-read "word: " #'counsel-fzf-function
                :initial-input (ivy-thing-at-point)
                ;; :re-builder #'ivy--regex-fuzzy
                :dynamic-collection t
                :action #'ivy-completion-in-region-action
                :unwind #'counsel-delete-process
                :caller 'counsel-fzf)))

  ;; see <https://github.com/hlissner/doom-emacs/modules/completion/ivy/autoload/ivy.el>
  (defun +counsel-evil-jumps ()
    "Go to an entry in evil's jumplist."
    (interactive)
    (let (buffers) ; buffers which should be cleanup after this procedure executed
      (unwind-protect
          (ivy-read "Jumps: "
                    (delete-dups
                     (mapcar (lambda (jump)
                               (let* ((pos (car jump))
                                      (file-name (cadr jump))
                                      (buf (get-file-buffer file-name)))
                                 (unless buf
                                   (push (setq buf (find-file-noselect file-name t))
                                         buffers))
                                 (save-excursion
                                   (with-current-buffer buf
                                     (goto-char pos)
                                     (font-lock-fontify-region (line-beginning-position) (line-end-position))
                                     (cons (format "%s:%d: %s"
                                                   (buffer-name)
                                                   (line-number-at-pos)
                                                   (string-trim-right (or (thing-at-point 'line) "")))
                                           (point-marker))))))
                             (evil--jumps-savehist-sync)))
                    :sort nil
                    :require-match t
                    :action (lambda (cand)
                              (let* ((mark (cdr cand))
                                     (buf (marker-buffer mark)))
                                (setq buffers (delq buf buffers))
                                (mapc #'kill-buffer buffers)
                                (setq buffers nil)
                                (with-current-buffer (switch-to-buffer buf)
                                  (goto-char (marker-position mark)))))
                    :caller '+counsel-evil-jumps)
        (mapc #'kill-buffer buffers)))))

(use-package swiper
  :general
  (general-mmap
    "C-s" #'swiper-isearch-thing-at-point
    "g C-s" #'swiper-multi)
  :config
  (gsetq swiper-goto-start-of-match t)

  (general-def swiper-map
    "C-M-j" #'swiper-avy))

(use-package ivy-hydra
  :after ivy
  :config
  (add-to-list 'ivy-dispatching-done-hydra-exit-keys '("C-o" hydra-ivy/body nil)))

(use-package ivy-prescient
  :after counsel
  :init
  (gsetq ivy-prescient-enable-filtering nil) ; I use `+ivy-toggle-prescient' manually

  (ivy-prescient-mode)
  :config
  (gsetq prescient-filter-method '(literal regexp initialism fuzzy)
         ivy-prescient-retain-classic-highlighting t
         ivy-prescient-sort-commands '(counsel-M-x
                                       counsel-bookmark
                                       counsel-describe-function
                                       counsel-describe-variable))

  (add-to-list 'ivy-re-builders-alist '(counsel-M-x . ivy-prescient-re-builder))

  (defun +ivy-toggle-prescient ()
    "Toggle the re builder between `ivy-prescient-re-builder' and `ivy--regex-plus'."
    (interactive)
    (setq ivy--old-re nil)
    (if (eq ivy--regex-function 'ivy-prescient-re-builder)
        (setq ivy--regex-function 'ivy--regex-plus)
      (setq ivy--regex-function 'ivy-prescient-re-builder)))

  (general-def ivy-minibuffer-map
    "M-z" #'+ivy-toggle-prescient))

(use-package ivy-xref
  :after ivy
  :init
  (when (>= emacs-major-version 27)
    (gsetq xref-show-definitions-function #'ivy-xref-show-defs))
  (gsetq xref-show-xrefs-function #'ivy-xref-show-xrefs))

;;* Lispy and Co.

(use-package lispy
  :ghook
  '(emacs-lisp-mode-hook lisp-mode-hook scheme-mode-hook)
  :config
  ;; use M-o to back to special, like `worf' and `lpy'
  (general-def lispy-mode-map
    "M-n" nil                           ; `lispy-left-maybe'
    "M-o" #'lispy-left-maybe)

  (with-eval-after-load 'lispyville
    (general-nmap lispyville-mode-map
      "M-o" #'lispyville-backward-up-list))

  ;; ported from evil-collection-lispy
  (defhydra +lh-g-knight (:color blue :hint nil :idle 1.0)
    "g-knight"
    ("j" lispy-knight-down "Down")
    ("k" lispy-knight-up "Up")
    ("g" lispy-beginning-of-defun)
    ("d" lispy-goto)
    ("D" lispy-goto-local))

  (general-def lispy-mode-map
    :definer 'lispy
    "q" #'ignore                        ; `lispy-ace-paren' -> f
    "f" #'lispy-ace-paren               ; `lispy-flow' -> n
    "n" #'lispy-flow                    ; `lispy-new-copy' -> y
    "y" #'lispy-new-copy                ; `lispy-occur' -> /
    "/" #'lispy-occur                   ; `lispy-splice' -> D
    "p" #'lispy-paste                   ; `lispy-eval-other-window' -> P
    "P" #'lispy-eval-other-window       ; `lispy-paste' -> p
    "g" #'+lh-g-knight/body             ; `lispy-goto' -> gd
    "G" #'end-of-defun                  ; `lispy-goto-local' -> gD
    "D" #'lispy-splice                  ; `pop-tag-mark' -> Q
    "Q" #'pop-tag-mark                  ; `lispy-ace-char' -> t
    "t" #'lispy-ace-char                ; `lispy-teleport' -> T
    "T" #'lispy-teleport)

  (with-eval-after-load 'lispyville
    (general-def lispy-mode-map
      :definer 'lispy
      "G" #'lispyville-end-of-defun))

  (with-eval-after-load 'evil
    ;; `lispy-meta-return'
    (defun +advice-evil-lispy-meta-return-enter-insert ()
      (lispy-move-end-of-line)
      (unless (evil-insert-state-p)
        (evil-change-state 'insert)))
    (general-add-advice (list #'lispy-meta-return #'lpy-meta-return)
                        :after #'+advice-evil-lispy-meta-return-enter-insert))

  (with-eval-after-load 'org
    (unless (version<= org-version "9.1.9") ; Emacs 26.3 comes with Org v9.1.9
      (define-advice lispy-shifttab (:around (orig-func &rest args) org-overview-workaround)
        (let ((org-outline-regexp-bol (concat "^" outline-regexp)))
          (apply orig-func args))))))

(use-package lispyville
  :after evil
  :ghook
  'lispy-mode-hook
  :general
  (general-nmap
    "g<" #'lispyville-<
    "g>" #'lispyville->)
  :config
  (gsetq lispyville-motions-put-into-special t)

  (lispyville-set-key-theme '(operators c-w c-u prettify commentary additional))

  ;; additional-motions
  (general-mmap lispyville-mode-map
    "(" #'lispyville-left
    ")" #'lispyville-right
    "[[" #'lispyville-previous-opening
    "]]" #'lispyville-next-closing
    "[]" #'lispyville-previous-closing
    "][" #'lispyville-next-opening)

  ;; mark-toggle
  (general-vmap lispyville-mode-map
    "M" #'lispyville-toggle-mark-type)

  (general-imap lispyville-mode-map
    :definer 'lispy
    "V" #'lispyville-toggle-mark-type))

(use-package lpy
  ;; :quelpa (lpy :fetcher github :repo "abo-abo/lpy")
  :mode ("\\.lpy\\'" . python-mode)
  :ghook
  'python-mode-hook
  :config
  (general-def lpy-mode-map
    [remap run-python] #'lpy-switch-to-shell
    [remap python-shell-switch-to-shell] #'lpy-switch-to-shell)

  (defhydra +lh-g-knight-python (:color blue :idle 1.0)
    "g-knight-python"
    ("g" beginning-of-defun)
    ("d" lpy-goto))

  (general-def lpy-mode-map
    :definer 'lpy
    "q" #'ignore                        ; `lpy-avy' -> f
    "f" #'lpy-avy                       ; `lpy-flow' -> n
    "n" #'lpy-flow                      ; `lispy-new-copy' -> y
    "y" #'lispy-new-copy                ; `lpy-occur' -> /
    "/" #'lpy-occur                     ; `lpy-contents' -> ?
    "?" #'lpy-contents
    "p" #'lispy-paste                   ; `self-insert-command'
    "g" #'+lh-g-knight-python/body      ; `lpy-goto' -> gd
    "G" #'end-of-defun
    "D" #'lpy-delete                    ; `pop-tag-mark' -> Q
    "Q" #'pop-tag-mark)

  (with-eval-after-load 'evil
    (defun +lpy-evil-back-to-special ()
      "This is the evil command equivalent of `lpy-back-to-special'."
      (interactive)
      (if (or (python-info-current-line-empty-p)
              (python-info-docstring-p))
          (progn
            (forward-line -1)
            (+lpy-evil-back-to-special))
        (back-to-indentation)
        (unless (lpy-line-left-p)
          (backward-char))
        (evil-change-state 'insert)))

    (general-nmap lpy-mode-map
      "M-o" #'+lpy-evil-back-to-special)

    (defun +lpy-evil-toggle-mark-type ()
      "Switch between evil visual state and lpy special with an active region."
      (interactive)
      (if (and (or (evil-insert-state-p)
                   (evil-emacs-state-p))
               (region-active-p))
          (evil-with-active-region (region-beginning) (region-end)
            (evil-change-state 'visual))
        (evil-change-state 'insert)
        (lpy-mark)))

    (general-imap lpy-mode-map
      :definer 'lpy
      "V" #'+lpy-evil-toggle-mark-type)

    (general-vmap lpy-mode-map
      "M" #'+lpy-evil-toggle-mark-type)))

(use-package worf
  :ghook
  'org-mode-hook
  :config
  (general-def worf-mode-map
    "<S-iso-lefttab>" nil               ; `worf-shifttab'
    "C-a" nil)                          ; `worf-beginning-of-line'

  (general-def worf-mode-map
    :definer 'worf
    "n" #'worf-new/body                 ; `worf-new-copy' -> y
    "y" #'worf-new-copy                 ; `worf-occur' -> /
    "/" #'worf-occur                    ; `worf-tab-contents' -> ?
    "?" #'worf-tab-contents
    "p" #'worf-paste                    ; `worf-property' -> P
    "P" #'worf-property                 ; `worf-paste' -> p
    "Q" #'pop-tag-mark)

  (general-mmap worf-mode-map
    "[[" #'worf-backward
    "]]" #'worf-forward
    "[]" #'worf-backward
    "][" #'worf-forward)

  (with-eval-after-load 'evil
    (defun +advice-evil-worf-maybe-enter-special (&rest _)
      "Potentially enter insert state to get into special."
      (when (and (worf--special-p)
                 (not (evil-insert-state-p)))
        (evil-change-state 'insert)))
    (general-add-advice (list #'worf-back-to-special
                              #'worf-forward
                              #'worf-backward)
                        :after #'+advice-evil-worf-maybe-enter-special)))

;;* Magit and Co.

(use-package magit
  :defer 3
  :general
  (general-def leader-map
    :prefix "g"
    "f" #'magit-file-dispatch
    "g" #'magit-dispatch
    "s" #'+magit-status)
  :config
  (gsetq magit-bury-buffer-function 'magit-mode-quit-window
         magit-display-buffer-function #'magit-display-buffer-fullframe-status-v1)

  (gsetq-default magit-diff-refine-hunk t)

  ;; see <https://github.com/alphapapa/unpackaged.el#improved-magit-status-command>
  (defun +magit-status ()
    "Open a `magit-status' buffer.
If a file was visited in the buffer that was active when this command was
called, go to its unstaged changes section."
    (interactive)
    (let* ((buffer-file-path (when buffer-file-name
                               (file-relative-name buffer-file-name
                                                   (locate-dominating-file buffer-file-name ".git"))))
           (section-ident `((file . ,buffer-file-path) (unstaged) (status))))
      (call-interactively #'magit-status)
      (when buffer-file-path
        (goto-char (point-min))
        (cl-loop until (when (equal section-ident (magit-section-ident (magit-current-section)))
                         (magit-section-show (magit-current-section))
                         (recenter)
                         t)
                 do (condition-case nil
                        (magit-section-forward)
                      (error
                       (cl-return (magit-status-goto-initial-section-1)))))))))

(use-package forge
  :after magit
  :demand t
  :general
  (general-def leader-map
    :prefix "g"
    "h" #'forge-dispatch))

(use-package transient
  :after magit
  :config
  (gsetq transient-highlight-mismatched-keys t
         transient-save-history nil)

  (transient-bind-q-to-quit)

  (general-def transient-map
    "<escape>" #'transient-quit-all))

(use-package evil-magit
  :after (evil magit)
  :demand t
  :config
  ;; need to refresh evil keymaps when `magit-blob-mode' is entered
  (general-add-hook 'magit-blob-mode-hook #'evil-normalize-keymaps)

  (general-nmap magit-status-mode-map
    "M-RET" #'magit-diff-show-or-scroll-up)

  (general-nvmap magit-diff-mode-map
    "gh" #'magit-section-up)

  (general-nvmap magit-blob-mode-map
    "[" #'magit-blob-previous
    "]" #'magit-blob-next)

  (general-nvmap magit-process-mode-map
    "K" #'magit-process-kill)

  (general-nmap magit-status-mode-map
    "gI" #'forge-jump-to-issues
    "gP" #'forge-jump-to-pullreqs)

  (general-nmap '(forge-topic-list-mode-map forge-repository-list-mode-map)
    "C-j" #'next-line
    "C-k" #'previous-line
    "q" #'quit-window))

(use-package magit-todos
  :after magit
  :init
  (let ((inhibit-message t))
    (magit-todos-mode))
  :config
  ;; FIXME infinite `magit-section-forward' when grouped
  ;; see <https://github.com/alphapapa/magit-todos/issues/66> for details
  (gsetq magit-todos-group-by nil))

;;* Projectile and Co.

(use-package projectile
  :ghook
  'after-init-hook
  :general
  (general-def leader-map
    "p" 'projectile-command-map)
  :config
  ;; treat current directory in dired as a "file in a project" and track it
  (general-add-hook 'dired-before-readin-hook #'projectile-track-known-projects-find-file-hook)

  (general-def projectile-command-map
    "A" #'projectile-add-known-project
    "K" #'projectile-remove-known-project
    "O" #'projectile-toggle-project-read-only
    "e" #'projectile-replace
    "r" #'projectile-recentf)

  ;; combine project name and buffer identification
  (defun +projectile-buffer-identification-format ()
    (if (and buffer-file-name
             (projectile-project-p))
        (let ((project-name (projectile-project-name))
              (relative-name (file-relative-name buffer-file-name (projectile-project-root)))
              (buffer-name (buffer-name))
              (truncate-width (- (window-width) 50)))
          (cond ((< (string-width (concat project-name "/" relative-name))
                    truncate-width)
                 (list project-name "/" (propertized-buffer-identification relative-name)))
                ((< (string-width (concat project-name ":" buffer-name))
                    truncate-width)
                 (list project-name ":" (propertized-buffer-identification buffer-name)))
                (t
                 (propertized-buffer-identification "%b"))))
      (propertized-buffer-identification "%12b")))
  (gsetq-default mode-line-buffer-identification '(:eval (+projectile-buffer-identification-format)))

  ;; see <https://github.com/joaotavora/eglot/issues/129>
  (with-eval-after-load 'project
    (defun +projectile-project-find-function (dir)
      "Bridge projectile and project together."
      (let ((root (projectile-project-root dir)))
        (and root (cons 'transient root))))
    (general-add-hook 'project-find-functions #'+projectile-project-find-function)))

(use-package counsel-projectile
  :after (counsel projectile)
  :init
  (defalias '+counsel-projectile-search-project
    (if (executable-find "rg")
        #'counsel-projectile-rg
      #'counsel-projectile-git-grep)
    "Sensible search function for `counsel-projectile'")
  :general
  (general-def leader-map
    :prefix "s"
    "p" #'counsel-projectile)
  (general-def projectile-mode-map
    [remap projectile-find-file] #'counsel-projectile-find-file
    [remap projectile-find-file-dwim] #'counsel-projectile-find-file-dwim
    [remap projectile-find-dir] #'counsel-projectile-find-dir
    [remap projectile-switch-to-buffer] #'counsel-projectile-switch-to-buffer
    [remap projectile-switch-project] #'counsel-projectile-switch-project)
  (general-def projectile-command-map
    :prefix "s"
    "s" #'+counsel-projectile-search-project
    "a" #'counsel-projectile-ag
    "g" #'counsel-projectile-grep
    "i" #'counsel-projectile-git-grep
    "r" #'counsel-projectile-rg)
  :config
  (gsetq counsel-projectile-sort-files t)

  (ignore-errors
    (counsel-projectile-modify-action
     'counsel-projectile-switch-project-action
     '((default counsel-projectile-switch-project-action-dired)
       (remove counsel-projectile-switch-project-action-org-agenda)
       (remove counsel-projectile-switch-project-action-org-capture)
       (remove counsel-projectile-switch-project-action-rg)
       (remove counsel-projectile-switch-project-action-ag)
       (remove counsel-projectile-switch-project-action-git-grep)
       (remove counsel-projectile-switch-project-action-grep)
       (add ("s" (lambda (project)
                   (let ((projectile-switch-project-action '+counsel-projectile-search-project))
                     (counsel-projectile-switch-project-by-name project)))
             "search project"))))))

(use-package ibuffer-projectile
  :after projectile
  :init
  (define-advice projectile-ibuffer (:around (orig-func &rest args) ibuffer-projectile-workaround)
    (let (ibuffer-hook
          ibuffer-filter-groups)
      (apply orig-func args)))
  :ghook
  ('ibuffer-hook #'+ibuffer-projectile-setup)
  :config
  (defun +ibuffer-projectile-setup ()
    (ibuffer-projectile-set-filter-groups)
    (unless (eq ibuffer-sorting-mode 'alphabetic)
      (ibuffer-do-sort-by-alphabetic))))

;;* Programming languages and other major modes

;;** Haskell

(use-package haskell-mode
  :config
  (with-eval-after-load 'evil
    ;; see <https://github.com/haskell/haskell-mode/issues/1265>
    (general-nmap haskell-mode-map
      [remap evil-open-above] #'+haskell-evil-open-above
      [remap evil-open-below] #'+haskell-evil-open-below)

    (defun +haskell-evil-open-above ()
      "Opens a line above the current mode"
      (interactive)
      (evil-digit-argument-or-evil-beginning-of-line)
      (haskell-indentation-newline-and-indent)
      (evil-previous-line)
      (haskell-indentation-indent-line)
      (evil-append-line nil))

    (defun +haskell-evil-open-below ()
      "Opens a line below the current mode"
      (interactive)
      (evil-append-line nil)
      (haskell-indentation-newline-and-indent))))

;;** Lisp

;; Emacs Lisp

(use-package elisp-mode
  :ensure emacs
  :config
  (add-to-list 'lisp-imenu-generic-expression
               '("Advices"
                 "^\\s-*(def\\(?:ine-\\)?advice +\\([^ )\n]+\\)"
                 1))

  ;; see <https://github.com/alphapapa/unpackaged.el#sort-sexps>
  (defun +sort-sexps (beg end)
    "Sort sexps in region, comments stay with the code below."
    (interactive "r")
    (cl-flet ((skip-whitespace
               ()
               (while (looking-at (rx (1+ (or space "\n"))))
                 (goto-char (match-end 0))))
              (skip-both
               ()
               (while (cond ((or (nth 4 (syntax-ppss))
                                 (ignore-errors
                                   (save-excursion
                                     (forward-char 1)
                                     (nth 4 (syntax-ppss)))))
                             (forward-line 1))
                            ((looking-at (rx (1+ (or space "\n"))))
                             (goto-char (match-end 0)))))))
      (save-excursion
        (save-restriction
          (narrow-to-region beg end)
          (goto-char beg)
          (skip-both)
          (cl-destructuring-bind (sexps markers)
              (cl-loop do (skip-whitespace)
                       for start = (point-marker)
                       for sexp = (ignore-errors
                                    (read (current-buffer)))
                       for end = (point-marker)
                       while sexp
                       ;; Collect the real string, then one used for sorting.
                       collect (cons (buffer-substring (marker-position start) (marker-position end))
                                     (save-excursion
                                       (goto-char (marker-position start))
                                       (skip-both)
                                       (buffer-substring (point) (marker-position end))))
                       into sexps
                       collect (cons start end)
                       into markers
                       finally return (list sexps markers))
            (setq sexps (sort sexps (lambda (a b)
                                      (string-lessp (cdr a) (cdr b)))))
            (cl-loop for (real . sort) in sexps
                     for (start . end) in markers
                     do (progn
                          (goto-char (marker-position start))
                          (insert-before-markers real)
                          (delete-region (point) (marker-position end)))))))))

  (general-llmap emacs-lisp-mode-map
    "e" #'lispy-eval
    ";" #'lispy-eval-expression
    "1" #'lispy-describe-inline
    "2" #'lispy-arglist-inline
    "m" #'macrostep-expand
    "s" #'+sort-sexps
    "d" #'debug-on-entry
    "D" #'cancel-debug-on-entry))

(use-package elisp-demos
  :after elisp-mode
  :init
  (general-add-advice #'describe-function-1 :after #'elisp-demos-advice-describe-function-1))

;; Common Lisp

(use-package lisp-mode
  :ensure emacs
  :config
  (general-llmap lisp-mode-map
    "'" #'sly
    "l" #'sly-load-file
    "z" #'+sly-mrepl
    "e" #'lispy-eval
    ";" #'lispy-eval-expression
    "m" #'macrostep-expand))

(use-package sly
  :gfhook
  #'+sly-mode-setup
  :config
  (gsetq inferior-lisp-program "sbcl")

  (defun +sly-mode-setup ()
    (unless (sly-connected-p)
      (when (executable-find inferior-lisp-program)
        (let ((sly-auto-start 'always))
          (sly-auto-start)))))

  (+set-mode-line-misc-info 'sly-mode sly--mode-line-format)

  (defun +sly-mrepl ()
    "Find or create the first useful REPL for the default connection.
`pop-to-buffer' will be called on the buffer."
    (interactive)
    (sly-mrepl #'pop-to-buffer)))

(use-package sly-macrostep
  :after sly)

(use-package sly-repl-ansi-color
  :after sly
  :init
  (add-to-list 'sly-contribs 'sly-repl-ansi-color))

(use-package common-lisp-snippets
  :after yasnippet)

;; Scheme

(use-package scheme
  :config
  (general-llmap scheme-mode-map
    "'" #'run-geiser
    "z" #'geiser-mode-switch-to-repl
    ":" #'geiser-set-scheme
    "[" #'geiser-squarify
    "]" #'geiser-squarify
    "e" #'lispy-eval
    ";" #'lispy-eval-expression))

(use-package geiser
  :ghook
  'scheme-mode-hook
  :config
  (gsetq geiser-active-implementations '(guile racket))

  (general-imap geiser-mode-map
    "M-\\" #'geiser-insert-lambda))

(use-package flymake-racket
  :ghook
  ('scheme-mode-hook #'flymake-racket-add-hook))

;;** Python

(use-package python
  :gfhook
  #'+python-mode-setup
  :config
  (gsetq python-indent-guess-indent-offset-verbose nil
         python-shell-prompt-detect-enabled nil
         python-shell-prompt-detect-failure-warning nil)

  (defun +python-mode-setup ()
    (setq fill-column 79)

    (setq-local company-idle-delay nil))

  (general-def python-mode-map
    "RET" #'newline-and-indent)

  (general-llmap python-mode-map
    "'" #'run-python
    "z" #'python-shell-switch-to-shell
    "e" #'lispy-eval
    ";" #'lispy-eval-expression
    "1" #'lispy-describe-inline
    "2" #'lispy-arglist-inline
    "v" #'pyvenv-activate
    "V" #'pyvenv-deactivate))

(use-package pyvenv
  :config
  (add-to-list 'global-mode-string '(pyvenv-virtual-env-name (" venv:" pyvenv-virtual-env-name " ")) t)

  (general-add-hook '(pyvenv-post-activate-hooks pyvenv-post-deactivate-hooks) #'force-mode-line-update))

;;** Shell-script

(use-package sh-script
  :gfhook
  ('sh-mode-hook #'+sh-mode-setup)
  :config
  (defun +sh-mode-setup ()
    (when (member sh-shell '(sh bash dash ksh))
      (flymake-mode))))

(use-package flymake-shellcheck
  :ghook
  ('sh-mode-hook #'flymake-shellcheck-load))

;;** LaTeX

(use-package tex
  :ensure auctex
  :config
  (gsetq TeX-auto-save t
         TeX-parse-self t
         TeX-source-correlate-start-server t)

  (gsetq-default TeX-master nil
                 TeX-engine 'xetex)

  (general-imap TeX-mode-map
    "M-\\" #'TeX-electric-macro)

  (general-imap LaTeX-mode-map
    "M-]" #'LaTeX-close-environment
    "M-e" #'LaTeX-environment
    "M-s" #'LaTeX-section)

  (general-llmap LaTeX-mode-map
    "SPC" #'TeX-command-run-all
    "`" #'TeX-next-error
    "?" #'TeX-documentation-texdoc
    "C" #'TeX-clean
    "E" #'TeX-error-overview
    "K" #'TeX-kill-job
    "L" #'TeX-recenter-output-buffer
    "a" #'TeX-command-run-all
    "b" #'TeX-command-buffer
    "r" #'TeX-command-region
    "v" #'TeX-view
    "]" #'LaTeX-close-environment
    "e" #'LaTeX-environment
    "s" #'LaTeX-section)

  (general-llmap LaTeX-mode-map
    :infix "f"
    ;; latex.el
    "a" (general-simulate-key (#'TeX-font "C-a") :which-key "mathcal")
    "b" (general-simulate-key (#'TeX-font "C-b") :which-key "textbf/mathbf")
    "c" (general-simulate-key (#'TeX-font "C-c") :which-key "textsc")
    "e" (general-simulate-key (#'TeX-font "C-e") :which-key "emph")
    "f" (general-simulate-key (#'TeX-font "C-f") :which-key "textsf/mathsf")
    "i" (general-simulate-key (#'TeX-font "C-i") :which-key "textit/mathit")
    "m" (general-simulate-key (#'TeX-font "C-m") :which-key "textmd")
    "n" (general-simulate-key (#'TeX-font "C-n") :which-key "textnormal/mathnormal")
    "r" (general-simulate-key (#'TeX-font "C-r") :which-key "textrm/mathrm")
    "s" (general-simulate-key (#'TeX-font "C-s") :which-key "textsl/mathbb")
    "t" (general-simulate-key (#'TeX-font "C-t") :which-key "texttt/mathtt")
    "u" (general-simulate-key (#'TeX-font "C-u") :which-key "textup")
    "d" (general-simulate-key (#'TeX-font "C-d") :which-key "delete font")
    ;; styles/amsfonts.el
    "k" (general-simulate-key (#'TeX-font "C-k") :which-key "mathfrak"))

  (general-llmap LaTeX-mode-map
    :infix "t"
    "p" #'TeX-PDF-mode
    "i" #'TeX-interactive-mode
    "s" #'TeX-source-correlate-mode
    "#" #'TeX-normal-mode
    "~" #'LaTeX-math-mode)

  (general-llmap LaTeX-mode-map
    :infix "m"
    "e" #'LaTeX-mark-environment
    "s" #'LaTeX-mark-section))

(use-package auctex-latexmk
  :after tex
  :init
  (auctex-latexmk-setup)
  :config
  (gsetq auctex-latexmk-inherit-TeX-PDF-mode t))

(use-package company-auctex
  :after (company tex)
  :ghook
  ('LaTeX-mode-hook #'+company-auctex-setup)
  :config
  (defun +company-auctex-setup ()
    (make-local-variable 'company-backends)
    (company-auctex-init)))

(use-package reftex
  :ghook
  ('LaTeX-mode-hook #'turn-on-reftex)
  :config
  (gsetq reftex-plug-into-AUCTeX t))

;;** Markdown

(use-package markdown-mode
  :mode ("README\\.md\\'" . gfm-mode)
  :config
  (when (executable-find "marked")
    (gsetq markdown-command "marked"))

  (general-nmap markdown-mode-map
    "<tab>" #'markdown-cycle)

  (general-nmap markdown-mode-map
    :predicate '(and (not (display-graphic-p))
                     (markdown-on-heading-p))
    "TAB" #'markdown-cycle)

  (general-nmap markdown-mode-map
    "M-j" #'markdown-move-down
    "M-k" #'markdown-move-up
    "M-h" #'markdown-promote
    "M-l" #'markdown-demote)

  (general-vmap markdown-mode-map
    "<" #'markdown-outdent-region
    ">" #'markdown-indent-region)

  (general-mmap markdown-mode-map
    "C-j" #'markdown-outline-next
    "C-k" #'markdown-outline-previous
    "gj" #'markdown-forward-same-level
    "gk" #'markdown-backward-same-level
    "gh" #'markdown-outline-up
    "gl" #'markdown-outline-next)

  (general-llmap markdown-mode-map
    "2" #'markdown-mark-subtree
    "e" #'markdown-edit-code-block
    "l" #'markdown-insert-link
    "s" '(:keymap markdown-mode-style-map :which-key "markdown-style"))

  (general-llmap markdown-mode-map
    :infix "t"
    "e" #'markdown-toggle-math
    "f" #'markdown-toggle-fontify-code-blocks-natively
    "i" #'markdown-toggle-inline-images
    "l" #'markdown-toggle-url-hiding
    "m" #'markdown-toggle-markup-hiding))

;;** Org

(use-package org
  :defer 5
  :general
  (general-def leader-map
    :prefix "o"
    "a" #'org-agenda
    "b" #'org-switchb
    "c" #'org-capture
    "i" #'org-insert-link-global
    "l" #'org-store-link
    "o" #'org-open-at-point-global)
  :config
  (unless (version< org-version "9.2")
    (add-to-list 'org-modules 'org-tempo))

  ;; various preferences
  (gsetq org-default-notes-file (expand-file-name "notes.org" org-directory)

         org-catch-invisible-edits 'show
         org-log-done 'time
         org-tags-column 80

         org-startup-indented t
         org-image-actual-width nil

         org-highlight-latex-and-related '(latex)
         org-special-ctrl-a/e t)

  (cl-loop for (prop value)
           on '(:scale 2.0 :background auto)
           by #'cddr
           do (plist-put org-format-latex-options prop value))

  ;; Capturing
  (gsetq org-capture-templates
         '(("t" "Todo" entry (file+headline "" "Inbox") ; "" => `org-default-notes-file'
            "* TODO %?\n%U\n" :clock-resume t :prepend t)
           ("n" "Note" entry (file+headline "" "Inbox")
            "* %? :NOTE:\n%U\n%a\n" :clock-resume t)))

  ;; Refiling
  (gsetq org-refile-targets '((nil :maxlevel . 5) (org-agenda-files :maxlevel . 5))
         ;; targets start with the file name - allows creating level 1 tasks
         org-refile-use-outline-path t
         org-outline-path-complete-in-steps nil
         ;; allow refile to create parent tasks with confirmation
         org-refile-allow-creating-parent-nodes 'confirm)

  (define-advice org-refile (:after (&rest _) save-buffers)
    "Save all Org buffer after `org-refile'."
    (org-save-all-org-buffers))

  ;; Archiving
  (gsetq org-archive-mark-done nil
         org-archive-location "%s_archive::* Archive")

  ;; To-do settings
  (gsetq org-todo-keywords
         '((sequence
            "TODO(t)"  ; A task that needs doing & is ready to do
            "PROJ(p)"  ; An ongoing project that cannot be completed in one step
            "NEXT(n)"  ; A task that is in progress
            "WAIT(w)"  ; Something is holding up this task; or it is paused
            "|"
            "DONE(d)"   ; Task successfully completed
            "KILL(k)")  ; Task was cancelled, aborted or is no longer applicable
           (sequence
            "[ ](T)"                    ; A task that needs doing
            "[-](N)"                    ; Task is in progress
            "[?](W)"                    ; Task is being held up or paused
            "|"
            "[X](D)"))
         org-todo-keyword-faces
         '(("[-]" :inherit (font-lock-keyword-face org-todo))
           ("NEXT" :inherit (font-lock-keyword-face org-todo))
           ("[?]" :inherit (font-lock-constant-face org-todo))
           ("WAIT" :inherit (font-lock-constant-face org-todo))
           ("PROJ" :inherit (font-lock-doc-face org-todo))))

  ;; Agenda views
  (gsetq org-agenda-files (list org-directory)
         org-agenda-span 10
         org-agenda-start-day "-3d"
         org-agenda-start-on-weekday nil
         org-agenda-sticky t)

  (general-add-hook 'org-agenda-mode-hook #'hl-line-mode)

  ;; Working with source code
  (gsetq org-src-window-setup 'current-window
         org-src-preserve-indentation t
         org-src-ask-before-returning-to-edit-buffer nil
         org-confirm-babel-evaluate nil
         org-babel-lisp-eval-fn #'sly-eval)

  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (latex . t)
     (python . t)))

  ;; Keybindings
  (general-def org-mode-map
    "<S-iso-lefttab>" nil)

  (general-llmap org-mode-map
    "RET" #'org-ctrl-c-ret
    "M-RET" #'org-insert-todo-heading
    "SPC" #'org-table-copy-down
    "\\" #'org-table-create-or-convert-from-region
    "1" #'org-time-stamp-inactive
    "2" #'org-mark-subtree
    "3" #'org-update-statistics-cookies
    "a" #'org-attach
    "A" #'org-archive-subtree-default
    "d" #'org-deadline
    "e" #'org-edit-special
    "f" #'org-footnote-new
    "F" #'org-toggle-latex-fragment
    "h" #'org-toggle-heading
    "i" #'org-toggle-item
    "I" #'org-toggle-inline-images
    "l" #'org-insert-link
    "n" #'org-add-note
    "p" #'org-set-property
    "P" #'org-priority
    "q" #'org-set-tags-command
    "r" #'org-refile
    "s" #'org-schedule
    "S" #'org-sort
    "t" #'org-todo
    "x" #'org-toggle-checkbox
    "X" #'org-export-dispatch))

(use-package org-agenda
  :ensure org
  :config
  (require 'hydra-examples nil t)

  (general-mmap org-agenda-mode-map
    "V" #'hydra-org-agenda-view/body)

  (general-llmap org-agenda-mode-map
    "d" #'org-agenda-deadline
    "q" #'org-agenda-set-tags
    "r" #'org-agenda-refile
    "s" #'org-agenda-schedule
    "t" #'org-agenda-todo))

(use-package evil-org
  :after evil
  :ghook
  'org-mode-hook
  :config
  (gsetq evil-org-retain-visual-state-on-shift t)

  (evil-org-set-key-theme '(navigation textobjects additional calendar))

  (general-add-hook '(org-insert-heading-hook org-capture-mode-hook) #'evil-insert-state)

  (general-add-hook 'org-open-at-point-functions #'evil-set-jump)

  (general-nmap org-mode-map
    :predicate '(and (not (display-graphic-p))
                     (or (org-at-heading-or-item-p)
                         (org-at-table-p)
                         (org-at-block-p)))
    "TAB" #'org-cycle)

  (general-nmap org-mode-map
    "g SPC" #'org-table-blank-field
    "g RET" #'org-insert-heading-respect-content
    "g M-RET" #'org-insert-todo-heading-respect-content)

  (general-mmap org-mode-map
    "C-j" #'org-next-visible-heading
    "C-k" #'org-previous-visible-heading))

(use-package evil-org-agenda
  :ensure evil-org
  :after org-agenda
  :demand t
  :config
  (evil-org-agenda-set-keys))

;;** Others

(use-package csv-mode)

(use-package gitattributes-mode)

(use-package gitconfig-mode)

(use-package gitignore-mode)

(use-package json-mode)

(use-package lua-mode)

(use-package pkgbuild-mode)

(use-package rust-mode)

(use-package yaml-mode)

;;* Miscellaneous

(use-package ace-link
  :general
  (general-def leader-map
    :prefix "j"
    "l" #'ace-link)
  (general-nmap xref--xref-buffer-mode-map
    "o" #'ace-link-xref)
  (general-nmap Info-mode-map
    "o" #'ace-link-info)
  (general-nmap compilation-mode-map
    "o" #'ace-link-compilation)
  (general-nmap help-mode-map
    "o" #'ace-link-help)
  (general-nmap woman-mode-map
    "o" #'ace-link-woman)
  (general-nmap eww-mode-map
    "o" #'ace-link-eww)
  (general-nmap custom-mode-map
    "o" #'ace-link-custom)
  (general-mmap org-agenda-mode-map
    "o" #'ace-link-org-agenda)
  :config
  (ace-link-setup-default))

(use-package ace-window
  :general
  (general-def
    "C-q" #'ace-window)
  :config
  (gsetq aw-scope 'frame))

(use-package auto-yasnippet
  :after yasnippet
  :config
  (gsetq aya-persist-snippets-dir (no-littering-expand-var-file-name "yasnippet/snippets/")
         aya-trim-one-line t))

(use-package avy
  :general
  (general-def leader-map
    :prefix "j"
    "." #'avy-resume
    "c" #'avy-goto-char
    "h" #'+avy-goto-char-pinyin
    "j" #'avy-goto-char-timer
    "n" #'avy-goto-line
    "s" #'avy-goto-symbol-1
    "w" #'avy-goto-word-0
    "y" #'avy-copy-line)
  :config
  (gsetq avy-background t
         avy-case-fold-search nil)

  (defun +avy-goto-char-pinyin (char &optional traditional-p)
    "Jump to Chinese characters with pinyin."
    (interactive (list (read-char "char: " t)
                       current-prefix-arg))
    (require 'pinyinlib nil t)
    (avy-with avy-goto-char
      (avy-jump
       (pinyinlib-build-regexp-char char nil traditional-p t)
       :window-flip nil))))

;; NOTE `avy-migemo' in MELPA is broken, but `avy-migemo-goto-char-timer' still works
(use-package avy-migemo
  ;; :quelpa (avy-migemo :fetcher github :repo "tam17aki/avy-migemo")
  :when (executable-find "cmigemo")
  :init
  (gsetq migemo-directory "/usr/share/migemo/utf-8/"
         migemo-isearch-enable-p nil
         migemo-coding-system 'utf-8)
  :general
  (general-def leader-map
    :prefix "j"
    "k" #'avy-migemo-goto-char-timer))

(use-package cal-china-x
  :after calendar
  :demand t
  :config
  (gsetq cal-china-x-important-holidays cal-china-x-chinese-holidays
         calendar-mark-holidays-flag t
         calendar-holidays (append cal-china-x-important-holidays
                                   cal-china-x-general-holidays
                                   holiday-other-holidays)))

(use-package diff-hl
  :ghook
  ('after-init-hook #'global-diff-hl-mode)
  ('dired-mode-hook #'diff-hl-dired-mode)
  :general
  (general-def leader-map
    :prefix "g"
    "d" #'diff-hl-diff-goto-hunk
    "r" #'diff-hl-revert-hunk
    "m" #'diff-hl-mark-hunk)
  (general-mmap
    "[h" #'diff-hl-previous-hunk
    "]h" #'diff-hl-next-hunk)
  :config
  (gsetq diff-hl-side 'right
         diff-hl-margin-symbols-alist
         '((insert . " ") (delete . " ") (change . " ") (unknown . " ") (ignored . " ")))

  (diff-hl-margin-mode)

  ;; integration with magit
  (with-eval-after-load 'magit
    (general-add-hook 'magit-post-refresh-hook #'diff-hl-magit-post-refresh))

  (with-eval-after-load 'evil
    (evil-declare-not-repeat #'diff-hl-revert-hunk)))

;; see <https://github.com/hlissner/doom-emacs/core/core-editor.el>
(use-package dtrt-indent
  :init
  (defvar +dtrt-indent-detect-indentation-excluded-modes '(fundamental-mode)
    "Major modes for which indentation should not be automatically detected.")

  (defvar-local +dtrt-indent-inhibit-indent-detection nil
    "A buffer-local flag that indicates whether `dtrt-indent' should be used.
This should be set by editorconfig if it successfully sets
indent_style/indent_size.")
  :ghook
  ('(change-major-mode-after-body-hook read-only-mode-hook) #'+dtrt-indent-detect-indentation)
  :config
  (defun +dtrt-indent-detect-indentation ()
    (unless (or (not after-init-time)
                +dtrt-indent-inhibit-indent-detection
                (memq major-mode +dtrt-indent-detect-indentation-excluded-modes)
                (member (substring (buffer-name) 0 1) '(" " "*")))
      ;; Don't display messages in the echo area, but still log them
      (let ((inhibit-message t))
        (dtrt-indent-mode 1))))

  ;; Reduced from the default of 5000 for slightly faster analysis
  (gsetq dtrt-indent-max-lines 2000)

  ;; always keep tab-width up-to-date
  (push '(t tab-width) dtrt-indent-hook-generic-mapping-list)

  ;; Enable dtrt-indent even in smie modes so that it can update `tab-width',
  ;; `standard-indent' and `evil-shift-width' there as well.
  (gsetq dtrt-indent-run-after-smie t)

  (define-advice dtrt-indent-mode (:around (orig-fn arg) fix-broken-smie-modes)
    "Some smie modes throw errors when trying to guess their indentation.
One example is `nim-mode'. This prevents them from leaving Emacs in a broken
state."
    (let ((dtrt-indent-run-after-smie dtrt-indent-run-after-smie))
      (cl-letf* ((old-smie-config-guess (symbol-function 'smie-config-guess))
                 (old-smie-config--guess
                  (symbol-function 'symbol-config--guess))
                 ((symbol-function 'symbol-config--guess)
                  (lambda (beg end)
                    (funcall old-smie-config--guess beg (min end 10000))))
                 ((symbol-function 'smie-config-guess)
                  (lambda ()
                    (condition-case e (funcall old-smie-config-guess)
                      (error (setq dtrt-indent-run-after-smie t)
                             (message "[WARNING] Indent detection: %s"
                                      (error-message-string e))
                             (message "")))))) ; warn silently
        (funcall orig-fn arg)))))

(use-package eacl)

(use-package edit-indirect
  :general
  (general-def leader-map
    :prefix "a"
    "e" #'edit-indirect-region))

(use-package elpa-mirror)

(use-package epm)

(use-package expand-region
  :general
  (general-nmap
    "C-SPC" #'er/expand-region)
  (general-vmap
    "+" #'er/expand-region
    "-" #'er/contract-region)
  (general-def
    "M-m" #'er/mark-symbol)
  :config
  (gsetq expand-region-fast-keys-enabled nil))

(use-package fcitx
  :when (executable-find "fcitx-remote")
  :defer 3
  :config
  (when (eq system-type 'gnu/linux)
    (gsetq fcitx-use-dbus t))

  (fcitx-aggressive-setup))

(use-package fish-completion
  :when (executable-find "fish")
  :ghook
  'eshell-mode-hook)

;; TODO `format-all' is being unmaintained, try `reformatter' or `apheleia'
;; see <https://github.com/lassik/emacs-format-all-the-code/issues/52>
(use-package format-all
  :general
  (general-def leader-map
    :prefix "a"
    "f" #'format-all-buffer)
  (general-def leader-map
    :prefix "t"
    "=" #'format-all-mode)
  :config
  (define-advice format-all-buffer (:before-until (&rest _) workaround)
    (cond ((derived-mode-p 'tex-mode 'latex-mode)
           (user-error "Don't format latex code because latexindent is broken"))
          ((and (derived-mode-p 'sh-mode)
                (equal sh-shell 'zsh))
           (user-error "Don't format zsh code with shfmt"))))

  (+set-mode-line-misc-info 'format-all-mode "=" t))

;; NOTE please customize `gcmh-high-cons-threshold'
(use-package gcmh
  :ghook
  'after-init-hook
  :config
  (general-add-hook 'focus-out-hook #'gcmh-idle-garbage-collect))

(use-package git-ps1-mode
  :ghook
  'after-init-hook
  :config
  (gsetq git-ps1-mode-lighter-text-format " Git:%s")

  ;; replace VC's git mode-line info, see <https://github.com/magit/magit/issues/2687> for reasons
  (setcar (cdr (assq 'vc-mode mode-line-format))
          '(:eval
            (if (string-match-p "Git" vc-mode)
                git-ps1-mode-lighter-text
              vc-mode))))

(use-package helm-make
  :general
  (general-def leader-map
    :prefix "a"
    "m" #'helm-make))

(use-package highlight-escape-sequences
  :ghook
  ('prog-mode-hook #'hes-mode))

(use-package highlight-numbers
  :ghook
  'prog-mode-hook)

(use-package highlight-parentheses
  :ghook
  'prog-mode-hook
  :config
  (gsetq hl-paren-colors '("#d5baff")   ; bg of `modus-theme-intense-magenta'
         hl-paren-attributes '((:weight bold :slant italic))))

(use-package hl-todo
  :ghook
  'prog-mode-hook
  :general
  (general-def leader-map
    :prefix "a"
    "t" #'hl-todo-occur)
  (general-mmap
    "[t" #'hl-todo-previous
    "]t" #'hl-todo-next))

(use-package imenu-list
  :general
  (general-def leader-map
    :prefix "a"
    "i" #'imenu-list-smart-toggle)
  :config
  (gsetq imenu-list-size 0.5)

  (define-advice imenu-list-smart-toggle (:before () adaptive-position)
    "Determine `imenu-list-position' according to the window width."
    (setq-local imenu-list-position (if (< (window-width) split-width-threshold)
                                        'below
                                      'right))))

(use-package lorem-ipsum)

(use-package macrostep
  :config
  (gsetq macrostep-expand-in-separate-buffer t))

(use-package paren-face
  :ghook
  ('after-init-hook #'global-paren-face-mode))

(use-package pdf-tools
  :magic ("%PDF" . pdf-view-mode)
  :init
  (with-eval-after-load 'tex
    (add-to-list 'TeX-view-program-selection '(output-pdf "PDF Tools"))
    (add-to-list 'TeX-view-program-selection '((output-pdf has-no-display-manager) "xdg-open"))

    (general-add-hook 'TeX-after-compilation-finished-functions #'TeX-revert-document-buffer)))

(use-package pinyinlib
  :config
  (define-advice pinyinlib-build-regexp-char (:filter-args (args) flypy)
    "Use \"小鹤双拼\" only."
    (progn
      (let ((flypy-alist '((?v . ?z)    ; v -> zh
                           (?i . ?c)    ; i -> ch
                           (?u . ?s)))  ; u -> sh
            (char (car args)))
        (setcar args (or (cdr (assq char flypy-alist))
                         char)))
      (setcar (last args) t)            ; only-chinese-p
      args)))

(use-package prescient
  :ghook
  ('after-init-hook #'prescient-persist-mode))

(use-package rainbow-mode
  :general
  (general-def leader-map
    :prefix "t"
    "r" #'rainbow-mode))

(use-package smart-jump
  :defer 3
  :general
  (general-def leader-map
    "," #'smart-jump-back
    "/" #'smart-jump-go
    "?" #'smart-jump-references)
  :config
  (gsetq smart-jump-bind-keys nil
         smart-jump-find-references-fallback-function #'xref-find-references)

  (smart-jump-setup-default-registers)

  (with-eval-after-load 'evil
    (general-add-hook '(xref-after-jump-hook dumb-jump-after-jump-hook) #'evil-set-jump)

    (define-advice smart-jump-back (:around (orig-func &rest args) fallback)
      "Fallback function when marker stack is empty."
      (condition-case nil
          (apply orig-func args)
        (error
         (evil-jump-backward)
         (user-error "Marker stack is empty, go to older position in jump list instead"))))))

(use-package tiny)

(use-package undo-tree
  :general
  (general-def leader-map
    :prefix "a"
    "u" #'undo-tree-visualize)
  :config
  (gsetq undo-tree-auto-save-history t)

  (defun +advice-undo-tree-inhibit-message (orig-func &rest args)
    (let ((inhibit-message t))
      (apply orig-func args)))
  (general-add-advice (list #'undo-tree-load-history
                            #'undo-tree-save-history)
                      :around #'+advice-undo-tree-inhibit-message))

(use-package wgrep
  :config
  (gsetq wgrep-auto-save-buffer t))

(use-package which-key
  :ghook
  'after-init-hook
  :general
  (general-def help-map
    "M" #'which-key-show-major-mode)
  :config
  (gsetq which-key-sort-order #'which-key-prefix-then-key-order
         which-key-sort-uppercase-first nil)

  ;; unbind `help-for-help', which conflicts with which-key's help command
  (general-def help-map
    "C-h" nil))

;; TODO keep an eye on `clipetty'
(use-package xclip
  :init
  (gsetq select-enable-clipboard nil)
  :general
  (general-def leader-map
    :prefix "t"
    "p" #'xclip-mode)
  :gfhook
  #'+xclip-mode-setup
  :config
  ;; enable `select-enable-clipboard' only if `xclip-mode' is enabled
  (defun +xclip-mode-setup ()
    (if xclip-mode
        (setq select-enable-clipboard t)
      (setq select-enable-clipboard nil)))

  (+set-mode-line-misc-info 'xclip-mode "+" t))

(use-package yasnippet
  :defer 1
  :init
  (gsetq yas-alias-to-yas/prefix-p nil)
  :config
  (let ((inhibit-message t))
    (yas-global-mode))

  (general-def help-map
    "y" #'yas-describe-tables)

  ;; never expand snippets in normal state
  (general-nmap yas-minor-mode-map
    [remap yas-expand] #'ignore))

(use-package yasnippet-snippets
  :after yasnippet)

;;* Allow access from emacsclient

(use-package server
  :unless (daemonp)
  :ghook
  'after-init-hook)

;;* Load customizations, if any

(let ((inhibit-message t))
  (load custom-file t))

;;; .emacs ends here
