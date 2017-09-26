; Tools generally useful for testing / debugging GHOST

(define-public (ghost-debug-mode)
  (cog-logger-set-level! ghost-logger "debug")
  (cog-logger-set-stdout! ghost-logger #t))

(define-public (test-ghost TXT)
  "Try to find (and execute) the matching rules given an input TXT."
  (define sent (car (nlp-parse TXT)))
  (State ghost-anchor sent)
  (map (lambda (r) (cog-evaluate! (gdar r)))
       (cog-outgoing-set (chat-find-rules sent)))
  *unspecified*)

(define-public (ghost-show-lemmas)
  "Show the lemmas stored."
  (display lemma-alist)
  (newline))

(define-public (ghost-show-vars)
  "Show the groundings of variables stored."
  (format #t "=== User Variables\n~a\n" uvars))

(define-public (ghost-get-curr-sent)
  "Get the SentenceNode that is being processed currently."
  (define sent (cog-chase-link 'StateLink 'SentenceNode ghost-anchor))
  (if (null? sent) '() (car sent)))

(define-public (ghost-currently-processing)
  "Get the sentence that is currently being processed."
  (car (filter (lambda (e) (equal? ghost-word-seq (gar e)))
               (cog-get-pred (ghost-get-curr-sent) 'PredicateNode))))

(define-public (ghost-get-relex-outputs)
  "Get the RelEx outputs generated for the current sentence."
  (parse-get-relex-outputs (car (sentence-get-parses (ghost-get-curr-sent)))))

(define*-public (ghost-show-relation #:optional (SENT (ghost-get-curr-sent)))
  "Get a subset of the RelEx outputs of a sentence that GHOST cares.
   SENT is a SentenceNode, if not given, it will be the current input."
  (define parses (sentence-get-parses SENT))
  (define relex-outputs (append-map parse-get-relex-outputs parses))
  (filter
    (lambda (r)
      (define type (cog-type r))
      (or (equal? 'ParseLink type)
          (equal? 'WordInstanceLink type)
          (equal? 'ReferenceLink type)
          (equal? 'LemmaLink type)))
    relex-outputs))
