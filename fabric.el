;; A spacemacs package to use fabric https://github.com/danielmiessler/fabric
;;  fabric is an open-source framework for augmenting humans using AI. It provides a modular framework for solving specific problems using a crowdsourced set of AI prompts that can be used anywhere.


(defun fabric-get-patterns ()
  "Get the list of patterns from the fabric command"
  (interactive)
  (message "Getting patterns")
  (shell-command "/mnt/s/.local/bin/fabric --list" "*fabric-patterns*")
  (let ((patterns (with-current-buffer "*fabric-patterns*"
                    (split-string (buffer-string) "\n" t))))
    (kill-buffer "*fabric-patterns*")
    patterns))

(defun fabric-list-patterns ()
  "List the patterns from the fabric command"
  (interactive)
  (message "Getting patterns")
  (shell-command "/mnt/s/.local/bin/fabric --list" "*fabric-patterns*")
  (let ((patterns (with-current-buffer "*fabric-patterns*"
                    (split-string (buffer-string) "\n" t))))
    ;; show the buffer
    (pop-to-buffer "*fabric-patterns*")))


(defun fabric-run-pattern-on-buffer (pattern)
  "Run the fabric command on the current buffer, shell command works like echo $STRING | fabric --pattern {pattern}' which returns the output of the command"
  ;; let the user select the pattern
  (interactive (list (completing-read "Pattern: " (fabric-get-patterns))))

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
        (shell-command (format "cat %s | /mnt/s/.local/bin/fabric -s --pattern %s &" temp-file pattern) "*fabric-output*")
        (delete-file temp-file))
      )))

(defun fabric-run-pattern-on-region (pattern start end)
  "Run the fabric command on the current region, shell command works like echo $STRING | fabric --pattern {pattern}' which returns the output of the command"
  (interactive (list (completing-read "Pattern: " (fabric-get-patterns)
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
        (shell-command (format "cat %s | /mnt/s/.local/bin/fabric --pattern %s &" temp-file pattern) "*fabric-output*")
        (delete-file temp-file))
      )))


;; spacemacs keybinding

(spacemacs/set-leader-keys "aib" 'fabric-run-pattern-on-buffer)
(spacemacs/set-leader-keys "aiR" 'fabric-run-pattern-on-region)
(spacemacs/set-leader-keys "aiP" 'fabric-get-patterns)
