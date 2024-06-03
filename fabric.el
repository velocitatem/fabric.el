;;; fabric.el --- A Spacemacs package integrates with Fabric AI to enhance workflows with pattern application and retrieval functions. -*- lexical-binding: t -*-

;; Author: Daniel Rosel
;; Maintainer: Daniel Rosel
;; Version: 0.1
;; Package-Requires: ()
;; Homepage: https://github.com/velocitatem/fabric.el
;; Keywords: ai fabric spacemacs emacs LLMs


;; This file is not part of GNU Emacs

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.


;;; Commentary:

;; A spacemacs package to use fabric https://github.com/danielmiessler/fabric
;; fabric is an open-source framework for augmenting humans using AI. It provides a modular framework for solving specific problems using a crowdsourced set of AI prompts that can be used anywhere.

;;; Code:

(provide 'fabric)


(defvar fabric-pattern-cache nil
  "Cache for storing fabric patterns.")

(defun fabric-get-patterns ()
  "Get the list of patterns from the fabric command, using a cache."
  (interactive)
  (if fabric-pattern-cache
      (progn
        (message "Using cached patterns")
        fabric-pattern-cache)
    (message "Getting patterns")
    (shell-command "/mnt/s/.local/bin/fabric --list" "*fabric-patterns*")
    (let ((patterns (with-current-buffer "*fabric-patterns*"
                      (split-string (buffer-string) "\n" t))))
      (kill-buffer "*fabric-patterns*")
      (setq fabric-pattern-cache patterns)
      patterns)))

(defun fabric-clear-pattern-cache ()
  "Clear the cache for fabric patterns."
  (interactive)
  (setq fabric-pattern-cache nil)
  (message "Fabric pattern cache cleared"))

(defun fabric-list-patterns ()
  "List the patterns from the fabric command"
  (interactive)
  (message "Getting patterns")
  (shell-command "/mnt/s/.local/bin/fabric --list" "*fabric-patterns*")
  (let ((patterns (with-current-buffer "*fabric-patterns*"
                    (split-string (buffer-string) "\n" t))))
    ;; show the buffer
    (pop-to-buffer "*fabric-patterns*")))


(define-derived-mode fabric-mode markdown-mode "Fabric"
  "Major mode for fabric output"
  ;; make it editable
  (read-only-mode -1)
  (markdown-mode))



(defun fabric-run-pattern-on-buffer (pattern)
  "Run the fabric command on the current buffer, shell command works like echo $STRING | fabric --pattern {pattern}' which returns the output of the command"
  ;; let the user select the pattern or run without a pattern optionally
  (interactive (list (completing-read "Pattern: "
                                      (append (fabric-get-patterns) '("NONE"))
                                      nil t)))

  ;; get the current buffer
  (message "Running fabric on buffer %s" (current-buffer))
  (message "Pattern: %s" pattern)
  (let ((buffer (current-buffer)))
    ;; get the buffer content
    (let ((content (buffer-string)))
      ;; run the command
      (message "Running fabric command")
      (message "Content: %s" content)
      ;; wrbite content to temp file and run fabric on it
      (let ((temp-file (make-temp-file "fabric" nil ".txt")))
        (message "Temp file: %s" temp-file)
        (write-region content nil temp-file)
        ;; check if pattern is nil
        (if (string= pattern "NONE")
            (shell-command (format "cat %s | /mnt/s/.local/bin/fabric -s &" temp-file) "*fabric-output*")
          (shell-command (format "cat %s | /mnt/s/.local/bin/fabric -s --pattern %s &" temp-file pattern) "*fabric-output*"))
        (delete-file temp-file)
        )
      )))


(defun fabric-run-pattern-on-region (pattern start end)
  "Run the fabric command on the current region, shell command works like echo $STRING | fabric --pattern {pattern}' which returns the output of the command"
  (interactive (list (completing-read "Pattern: " (append (fabric-get-patterns) '("NONE"))
                                     nil t)
                     (region-beginning)
                     (region-end)))
  ;; get the current buffer
  (message "Running fabric on region %s" (current-buffer))
  (message "Pattern: %s" pattern)
  (let ((buffer (current-buffer)))
    ;; get the buffer content
    (let ((content (buffer-substring start end)))
      ;; run the command
      (message "Running fabric command")
      (message "Content: %s" content)
      ;; write content to temp file and run fabric on it
      (let ((temp-file (make-temp-file "fabric" nil ".txt")))
        (message "Temp file: %s" temp-file)
        (write-region content nil temp-file)
        ;; check if pattern is nil
        (if (string= pattern "NONE")
            (shell-command (format "cat %s | /mnt/s/.local/bin/fabric -s &" temp-file ) "*fabric-output*")
          (shell-command (format "cat %s | /mnt/s/.local/bin/fabric -s --pattern %s &" temp-file pattern) "*fabric-output*")
          )
        (delete-file temp-file))
      )))

;; spacemacs keybinding

(spacemacs/set-leader-keys "aib" 'fabric-run-pattern-on-buffer)
(spacemacs/set-leader-keys "aiR" 'fabric-run-pattern-on-region)
(spacemacs/set-leader-keys "aiP" 'fabric-get-patterns)
;; suggest other keybindings

;;; fabric.el ends here
