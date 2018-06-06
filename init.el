(setq user-full-name "Andrew Beach"
      user-mail-address "andrew.o.beach@gmail.com")

(setq gc-cons-threshold 100000000)

;; ---- Set up packages ----

(require 'package)

(setq package-enable-at-startup nil
      use-package-always-ensure t)

(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/") t)

(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))


;; ---- Emacs initialization ----

(setq large-file-warning-threshold 100000000
      ring-bell-function 'ignore)

;; Set frame size to max on load
(add-hook 'after-init-hook '(lambda () (toggle-frame-maximized)))
(setq initial-buffer-choice (eshell))

;; General line numbering
(add-hook 'prog-mode-hook 'linum-mode) ;; number lines in all prog-mode descendants
(setq fill-column 80
      global-visual-line-mode t
      linum-format "%4d \u2502")

;; Better scrolling
(setq mouse-wheel-follow-mouse 't)
(setq mouse-wheel-scroll-amount '(1 ((shift) . 1)))
(use-package smooth-scrolling
  :init (setq smooth-scroll-margin 10))

(delete-selection-mode 1)

(winner-mode t) ;; undo/redo for window config

(setq enable-recursive-minibuffers t) ;; allow ex: swiper recursive minibuffer

(add-hook 'before-save-hook 'delete-trailing-whitespace)


;; ---- Key bindings ----

(setq mac-command-modifier 'super)
(setq ns-function-modifier 'hyper)

(global-set-key (kbd "C-c e") 'eshell)

(global-set-key (kbd "C-s") 'swiper)
(global-set-key (kbd "C-+") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)

(global-set-key (kbd "C-c u b") 'ido-switch-buffer)
(global-set-key (kbd "C-c u c") 'comment-region)
(global-set-key (kbd "C-c u C-c") 'uncomment-region)

(global-set-key (kbd "C-x g") 'magit-status)

(defun move-line-up ()
  "Move the line at point up."
  (interactive)
  (transpose-lines 1)
  (forward-line -2)
  (indent-according-to-mode))
(defun move-line-down ()
  "Move the line at point down."
  (interactive)
  (forward-line 1)
  (transpose-lines 1)
  (forward-line -1)
  (indent-according-to-mode))
(global-set-key (kbd "M-p") 'move-line-up)
(global-set-key (kbd "M-n") 'move-line-down)

(defun find-user-init-file ()
  "Edit the 'user-init-file' in another window."
  (interactive)
  (find-file user-init-file))
(global-set-key (kbd "C-c I") 'find-user-init-file)


;; ---- Aliases ----

(defalias 'list-buffers 'ibuffer)

;; -- Eshell --
(defalias 'ls "ls -a")
(defalias 'yes-or-no-p 'y-or-n-p)
(defalias 'ff 'find-file)
(defalias 'ffo 'find-file-other-window)

;; -- Git --
(defalias 'gst "git status")
(defalias 'gb "git branch")

;; -- M-x --
(defalias 'eb 'eval-buffer)


;; ---- Packages ----

;; -- Language-specific --

(use-package clojure-mode
	     :config
	     (add-hook 'clojure-mode-hook 'enable-paredit-mode)
	     (add-hook 'clojure-mode-hook 'turn-on-eldoc-mode)
	     (add-hook 'clojurescript-mode-hook 'enable-paredit-mode))

(use-package cider
	     :init (setq cider-repl-display-help-banner nil)
	     :config
	     (add-hook 'cider-mode-hook 'eldoc-mode)
	     (add-hook 'cider-repl-mode-hook 'subword-mode)
	     (add-hook 'cider-repl-mode-hook 'paredit-mode))

(setq css-indent-offset 2)

(use-package elm-mode
  :init (setq elm-indent-offset 2)
  :mode ("\\.elm$" . elm-mode))


(use-package haskell-mode
  :config
  (add-hook 'haskell-mode-hook 'interactive-haskell-mode)
  :init
  (setq haskell-process-args-ghci
        '("-ferror-spans" "-fshow-loaded-modules"))

  (setq haskell-process-args-cabal-repl
        '("--ghc-options=-ferror-spans -fshow-loaded-modules"))

  (setq haskell-process-args-stack-ghci
        '("--ghci-options=-ferror-spans -fshow-loaded-modules"
          "--no-build" "--no-load"))

  (setq haskell-process-args-cabal-new-repl
        '("--ghc-options=-ferror-spans -fshow-loaded-modules")))

(use-package js2-mode
  :mode (("\\.js$" . js2-mode))
  :interpreter ("node" . js2-mode)
  :config
  (add-hook 'js2-mode-hook (lambda () (setq js2-basic-offset 2))))

(use-package markdown-mode
  :commands (markdown-mode gfm-mode)
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :init (setq markdown-command "multimarkdown"))

(use-package ng2-mode)

(use-package purescript-mode
  :mode ("\\.purs$" . purescript-mode))

(use-package psci
  :config
  (add-hook 'purescript-mode-hook 'inferior-psci-mode))

(use-package psc-ide
  :config
  (setq psc-ide-debug t)
  (add-hook 'purescript-mode-hook
          (lambda ()
            (psc-ide-mode)
            (company-mode)
            (flycheck-mode)
            (turn-on-purescript-indentation)))
  (setq psc-ide-flycheck-ignored-error-codes
        '("ImplicitImport")))

; (use-package rjsx-mode
;   :config
;   (add-to-list 'auto-mode-alist '("components\\/.*\\.js\\" . rjsx-mode)))

(use-package typescript-mode
  :mode "\\.ts\\'"
  :config
  (setq typescript-indent-level 2)
  :bind
  (("C-<right>" . sp-slurp-hybrid-sexp)))

(defun setup-tide-mode ()
  (interactive)
  (tide-setup)
  (flycheck-mode +1)
  (setq flycheck-check-syntax-automatically '(save mode-enabled))
  (eldoc-mode +1)
  (tide-hl-identifier-mode +1)
  (company-mode +1))

(use-package tide
  :config
  (setq company-tooltip-align-annotations t)
  ;; (add-hook 'before-save-hook 'tide-format-before-save)
  (add-hook 'typescript-mode-hook #'setup-tide-mode))

(use-package ts-comint
  :config
  (add-hook 'typescript-mode-hook
            (lambda ()
              (local-set-key (kbd "C-x C-e") 'ts-send-last-sexp)
              (local-set-key (kbd "C-M-x") 'ts-send-last-sexp-and-go)
              (local-set-key (kbd "C-c b") 'ts-send-buffer)
              (local-set-key (kbd "C-c C-b") 'ts-send-buffer-and-go)
              (local-set-key (kbd "C-c l") 'ts-load-file-and-go))))

(use-package yaml-mode
  :mode "\\.yaml\\'")


;; -- General --

(use-package avy
  :config
  (setq avy-background t)
  :bind
  ("C-;" . avy-goto-word-1))

(use-package better-defaults)

;; text completion
(use-package company
	     :diminish company-mode
	     :config (global-company-mode))

(use-package counsel
             :bind
             (("M-x"     . counsel-M-x)
              ("<C-SPC>" . counsel-M-x)
              ("C-x C-f" . counsel-find-file)
              ("C-x C-r" . counsel-recentf)
              ("C-c f"   . counsel-git)
              ("C-c s"   . counsel-git-grep)
              ("C-c /"   . counsel-ag)
              ("C-c l"   . counsel-locate)))

(use-package exec-path-from-shell
  :config
  (when (memq window-system '(mac ns x))
    (exec-path-from-shell-initialize)))

;; syntax checking
(use-package flycheck)

(use-package idle-highlight-mode
  :diminish idle-highlight-mode
  :config
  (add-hook 'prog-mode-hook
            (lambda ()
              (idle-highlight-mode t))))

(use-package ivy
  :diminish (ivy-mode . "")
  :init (ivy-mode 1)
  :bind (:map ivy-mode-map
              ("C-'" . ivy-avy))
  :config
  (setq ivy-use-virtual-buffers t)
  (setq ivy-height 20)
  (setq ivy-count-format "(%d/%d) "))

(use-package magit
  :bind
  ("C-c C-g b" . magit-branch-popup)
  ("C-c C-g c" . magit-commit-popup))

(use-package neotree
  :config
  (setq-local linum-mode nil)
  (setq neo-autorefresh nil)
  ;; (setq neo-window-fixed-size f)
  (setq neo-window-width 30)
  (setq neo-smart-open t)
  (setq neo-window-position 'right)
  (global-set-key (kbd "C-c d") 'neotree-toggle))

(use-package paredit
  :diminish paredit-mode
  :config
  (add-hook 'emacs-lisp-mode-hook 'enable-paredit-mode)
  (add-hook 'lisp-mode-hook 'enable-paredit-mode)
  (add-hook 'lisp-interaction-mode-hook 'enable-paredit-mode)
  (setq cider-cljs-lein-repl
	"(do (require 'figwheel-sidecar.repl-api)
         (figwheel-sidecar.repl-api/start-figwheel!)
         (figwheel-sidecar.repl-api/cljs-repl))"))

(use-package projectile
  :diminish projectile-mode
  :config (projectile-global-mode))

(use-package rainbow-delimiters
  :config
  (add-hook 'prog-mode-hook 'rainbow-delimiters-mode))

(use-package repl-toggle
  :config
  (repl-toggle-mode)
  (setq rtog/mode-repl-alist
        '((purescript-mode . psci))))

(use-package swiper)

(use-package which-key
	     :diminish which-key-mode
	     :init (which-key-mode))

(use-package whitespace
  :commands (whitespace-mode)
  :config
  (setq whitespace-style '(face tabs spaces newline empty
                                trailing tab-mark newline-mark)))

(use-package whitespace-cleanup-mode
  :diminish whitespace-cleanup-mode
  :init (global-whitespace-cleanup-mode))


;; -- Appearance & Fonts --

(use-package color-theme-sanityinc-tomorrow
  :config
  (setf custom-safe-themes t)
  (color-theme-sanityinc-tomorrow-eighties))

(use-package powerline
  :config (progn
            (setq powerline-default-separator 'arrow-fade)
            (setq powerline-display-hud t)
            (setq powerline-display-buffer-size nil)
            (setq powerline-display-mule-info nil)
            (powerline-center-theme)))

(use-package spaceline
  :init (setq powerline-default-separate 'arrow-fade)
  :config
  (require 'spaceline-config)
  (spaceline-spacemacs-theme))

(set-face-attribute 'default nil
                    :family "Source Code Pro"
                    :height 170)
(set-face-attribute 'bold nil :family "Source Code Pro Bold"
                    :height 170)

(set-frame-parameter (selected-frame) 'alpha '(95 75))
(add-to-list 'default-frame-alist '(alpha 95 75))



;; ---- Auto-generated stuff below this line (don't touch!) ----

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes (quote (sanityinc-tomorrow-eighties)))
 '(eshell-output-filter-functions
   (quote
    (eshell-handle-control-codes eshell-handle-ansi-color eshell-watch-for-password-prompt)))
 '(eshell-scroll-to-bottom-on-output nil)
 '(package-selected-packages
   (quote
    (heml-spotify-plus yaml-mode rjsx-mode rjxs-mode smartparens ts-comint tide js2-mode elm-mode repl-toggle psci psc-ide purescript-mode exec-path-from-shell haskell-mode smooth-scrolling ng2-mode typescript-mode whitespace-cleanup-mode which-key use-package spaceline smex rainbow-delimiters projectile paredit neotree markdown-mode magit idle-highlight-mode highlight-parentheses counsel company color-theme-sanityinc-tomorrow cider better-defaults avy)))
 '(show-paren-mode t)
 '(tool-bar-mode nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :stipple nil :background "#2d2d2d" :foreground "#cccccc" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 120 :width normal :foundry "nil" :family "Source Code Pro"))))
 '(eshell-prompt ((t (:foreground "gray81" :weight bold)))))
