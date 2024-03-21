;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Eve Bradt"
      user-mail-address "evelyn.bradt@bradt.dev")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
(setq doom-font (font-spec :family "Hack Nerd Font" :size 15))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-nord)
(setq shell-file-name (executable-find "bash"))

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-id-link-to-org-use-id t)
(setq org-directory "~/repos/org/")

(add-to-list 'auth-sources "~/.authinfo")

(setq plantuml-default-exec-mode 'jar)

(after! org-roam
  (set-company-backend! 'org-mode `company-capf)
  (setq org-roam-directory (concat org-directory "notes/"))
  (setq deft-directory org-roam-directory)
  (setq deft-recursive t)
  (setq org-roam-graph-viewer "qutebrowser")
  (setq org-roam-capture-templates
	'(
	  ("d" "default" plain (function org-roam--capture-get-point)
           "%?"
           :file-name "%<%Y%m%d%H%M%S>-${slug}"
           :head "#+title: ${title}\n#+created: %U\n"
           :unnarrowed t)
	  )
	)

  (setq org-roam-capture-ref-templates
	`(
	  ("r" "ref" plain (function org-roam--capture-get-point)
	   "%?"
	   :file-name "refs/${slug}"
	   :head "#+title: ${title}\n#+roam_key: ${ref}\n#+created: %U\n"
	   :unnarrowed t)
	  )
	)
  (setq org-roam-dailies-capture-templates
	'(
	  ("d" "default" plain (function org-roam--capture-get-point)
           "* %?"
           :file-name "daily/%<%Y-%m-%d>"
           :head "#+title: %<%Y-%m-%d>\n#+created: %U\n"
           )
	  ("j" "journal" plain (function org-roam--capture-get-point)
           "* %?"
           :file-name "daily/%<%Y-%m-%d>"
           :head "#+title: %<%Y-%m-%d>\n#+created: %U\n"
	   :olp ("Journal")
           )
	  ("i" "idea" plain (function org-roam--capture-get-point)
           "* %?"
           :file-name "daily/%<%Y-%m-%d>"
           :head "#+title: %<%Y-%m-%d>\n#+created: %U\n"
	   :olp ("Idea")
           )
	  ))

  (map! :leader
	(:when (modulep! :lang org +roam)
	  (:mode org-mode
	   :prefix ("r" . "roam")
	   :desc "Switch to buffer" "b" #'org-roam-switch-to-buffer
	   :desc "Org Roam Capture" "c" #'org-roam-capture
           :desc "Find file" "f" #'org-roam-find-file
           :desc "Show graph" "g" #'org-roam-graph
           :desc "Insert" "i" #'org-roam-insert
           :desc "Insert (skipping org-capture)" "I" #'org-roam-insert-immediate
           :desc "Org roam" "m" #'org-roam
           :desc "Add tag" "t" #'org-roam-tag-add
           :desc "Remove Tag" "T" #'org-roam-tag-delete
           :desc "Add alias" "a" #'org-roam-alias-add
           :desc "Remove alias" "A" #'org-roam-alias-delete
           (:prefix ("d" . "by date")
            :desc "Find previous note" "b" #'org-roam-dailies-find-previous-note
            :desc "Find date"          "d" #'org-roam-dailies-find-date
            :desc "Find next note"     "f" #'org-roam-dailies-find-next-note
            :desc "Find tomorrow"      "m" #'org-roam-dailies-find-tomorrow
            :desc "Capture today"      "n" #'org-roam-dailies-capture-today
            :desc "Find today"         "t" #'org-roam-dailies-find-today
            :desc "Capture Date"       "v" #'org-roam-dailies-capture-date
            :desc "Find yesterday"     "y" #'org-roam-dailies-find-yesterday
            :desc "Find directory"     "." #'org-roam-dailies-find-directory
	    )
	   )
	  )
	)
  )

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)
(setq tramp-terminal-type "dumb")

(setq org-re-reveal-root "./reveal.js" )

;; Use the Personal Installation of Language server
(setq lsp-julia-package-dir nil)

(use-package! highlight-indent-guides
  :commands highlight-indent-guides-mode
  :hook (prog-mode . highlight-indent-guides-mode)
  :config
  (setq highlight-indent-guides-method 'character
        highlight-indent-guides-character ?\⇨
        highlight-indent-guides-delay 0.1
        highlight-indent-guides-responsive 'top
        highlight-indent-guides-auto-enabled nil))

(setq c-default-style "bsd"
      c-basic-offset 4
      indent-tabs-mode t
      tab-width 4)
(add-hook! c++-mode `(add-to-list 'c-offsets-alist '(inlamda . 0)))
(add-to-list 'auto-mode-alist '("\\.ipp\\'" . c++-mode))
(add-to-list 'auto-mode-alist '("\\.ixx\\'" . c++-mode))



(add-hook! julia-mode
  (eglot-jl-init))

(add-to-list 'auto-mode-alist '("\\.gdb\\'" . gdb-script-mode))
(after! forge
  (add-to-list 'forge-alist '("gitlab.blueorigin.com" "gitlab.blueorigin.com/api/v4" "gitlab.blueorigin.com" forge-gitlab-repository))
  )

(after! counsel
  (add-to-list 'counsel-compile-build-directories ".")
  (add-to-list 'counsel-compile-build-directories "build-local")
  (add-to-list 'counsel-compile-build-directories ".build-local")
  )

;; (set-eglot-client! 'cc-mode '("clangd" "-j=3" "--clang-tidy"))
(after! eglot
  (set-eglot-client! 'c++-mode '("clangd"))
  (setq eglot-connect-timeout 30))

(after!  lsp-clangd
  (setq lsp-clients-clangd-args
        '("-j=3"
          "--background-index"
          "--clang-tidy"
	  "--enable-config"
	  "--completion-style=detailed"
	  )))
(after! ccls
  (setq ccls-initialization-options '(:index (:comments 2) :completion (:detailedLabel t)))
  (set-lsp-priority! 'ccls 2)) ; optional as ccls is the default in Doom

(after! magit
  (setopt magit-prefer-remote-upstream 't)
  (setopt magit-clone-set-remote.pushDefault 'ask)
  (setopt magit-branch-prefer-remote-upstream '("main" "master" "maint"))
  (setopt magit-branch-adjust-remote-upstream-alist '(("main" . "\\`ebradt/")))
  )

;; (after! lsp
;;   (setq lsp-lens-enable 'f)
;;   )

;; (setq lsp-log-io t)
;; (setq lsp-enable-folding t)
;; (setq lsp-folding-range-limit 100)
(put 'projectile-project-name 'safe-local-variable #'stringp)
(setq-hook! 'python-mode-hook
  +format-with-lsp nil)

(use-package! py-snippets
  :config
  (py-snippets-initialize))

(use-package! direnv
  :after lsp
  :config
  (add-hook 'prog-mode-hook #'direnv--maybe-update-environment)
  )
;; (use-package! counsel
;;   :defer t
;;   :init
;;   (define-key!
;;     [remap projectile-compile-project] #'projectile-compile-project))
;;(defun org-summary-todo (n-done n-not-done)
;;  "Switch entry to DONE when all subentries are done, to TODO otherwise."
;;  (let (org-log-done org-log-states)   ; turn off logging
;;    (org-todo (if (= n-not-done 0) "DONE" "TODO"))))
;;
;;(add-hook 'org-after-todo-statistics-hook 'org-summary-todo)

;;(use-package  )

;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c g k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c g d') to jump to their definition and see how
;; they are implemented.
;;
