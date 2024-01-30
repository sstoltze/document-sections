;;; document-sections.el --- Work with document sections  -*- lexical-binding:t -*-

;; Author: Sarah Stoltze <sstoltze@gmail.com>
;; Version: 1.0
;; Keywords: convenience, files, hypermedia
;; URL: https://github.com/sstoltze/document-sections
;; Package-Requires: ((emacs "24.4"))

;;; Commentary:

;;; Code:

(defgroup document-sections nil
  "Document section support for Emacs."
  :group 'convenience
  :link '(url-link "https://github.com/sstoltze/document-sections"))

(defcustom document-sections-regex-pattern
  (rx (or "// // //"
          "# # #"
          ";;;"))
  "The regexes used to determine document section headers."
  :type 'regexp)

(defun document-sections--build-match (string pos)
  "Build a cons cell representing the current match in STRING at POS.
Returns a name for the section and a line number for the section."
  (let* ((line-number (line-number-at-pos pos))
        (name (let ((section-name (string-trim (match-string 1 string))))
                (if (string-empty-p section-name) (format "Line %s" line-number) section-name))))
    (cons name line-number)))

(defun document-sections--re-seq (regexp string)
  "Get a list of all REGEXP matches in STRING."
  (save-match-data
    (let ((pos 0)
          matches)
      (while (string-match regexp string pos)
        (setq pos (match-end 0))
        (push (document-sections--build-match string pos) matches))
      matches)))

(defun document-sections--list-sections (&optional buffer-name pattern)
  "Find the document sections in BUFFER-NAME, using the regex pattern PATTERN."
  (let* ((base-buffer (or buffer-name
                          (buffer-base-buffer)
                          (buffer-name)))
         (regex-pattern (or pattern document-sections-regex-pattern))
         (regex (rx line-start
                    (*? whitespace)
                    (regex regex-pattern)
                    (group (*? anything))
                    line-end)))
    (with-current-buffer base-buffer
      (save-excursion
        (save-restriction
          (widen)
          (goto-char (point-min))
          (reverse (document-sections--re-seq regex (buffer-substring-no-properties (point-min) (point-max)))))))))

;;;###autoload
(defun document-sections-find-section ()
  "Prompt to visit the projects that related-file knows about."
  (interactive)
  (let* ((sections (document-sections--list-sections nil))
         (chosen-section (completing-read "Document sections: " sections nil nil)))
    (when chosen-section
      (let ((forward-lines (1- (cdr (assoc-string chosen-section sections)))))
        (widen)
        (goto-char (point-min))
        (forward-line forward-lines)))))

(provide 'document-sections)
;;; document-sections.el ends here
