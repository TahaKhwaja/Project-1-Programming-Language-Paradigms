#lang racket

(define prompt?
  (let [(args (current-command-line-arguments))]
    (cond
      [(= (vector-length args) 0) #t]
      [(string=? (vector-ref args 0) "-b") #f]
      [(string=? (vector-ref args 0) "--batch") #f]
      [else #t])))

(define (fail msg) (raise msg))
(define (digit? c) (and (char>=? c #\0) (char<=? c #\9)))
(define (skip-ws chars) (dropf chars char-whitespace?))

(define (parse-number chars)
  (let-values ([(digits rest) (splitf-at chars digit?)])
    (list (string->number (list->string digits)) rest)))

(define (eval-loop history)
  (when prompt?
    (display "> ")
    (flush-output))
  (let ([line (read-line)])
    (cond
      [(eof-object? line) (void)]
      [(string=? line "quit") (void)]
      [else (displayln line)
            (eval-loop history)])))

(module+ main
  (eval-loop '()))