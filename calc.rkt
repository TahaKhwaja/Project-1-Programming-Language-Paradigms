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

(define (negate a) (- a))

(define (divide a b)
  (if (zero? b)
      (fail "Invalid expression")
      (quotient a b)))

(define (parse-number chars)
  (let-values ([(digits rest) (splitf-at chars digit?)])
    (list (string->number (list->string digits)) rest)))

(define (parse-history chars history)
  (let-values ([(digits rest) (splitf-at chars digit?)])
    (if (null? digits)
        (fail "Invalid expression")
        (let ([n (string->number (list->string digits))])
          (if (and (>= n 1) (<= n (length history)))
              (list (list-ref history (- n 1)) rest)
              (fail "Invalid expression"))))))

(define (parse-unary op chars history)
  (let ([operand (parse-expr chars history)])
    (list (op (first operand)) (second operand))))

(define (parse-binary op chars history)
  (let* ([left  (parse-expr chars history)]
         [right (parse-expr (second left) history)])
    (list (op (first left) (first right)) (second right))))

(define (parse-expr chars history)
  (let ([cs (skip-ws chars)])
    (if (null? cs)
        (fail "Invalid expression")
        (let ([c (car cs)] [rest (cdr cs)])
          (cond
            [(char=? c #\+) (parse-binary + rest history)]
            [(char=? c #\*) (parse-binary * rest history)]
            [(char=? c #\/) (parse-binary divide rest history)]
            [(char=? c #\-) (parse-unary negate rest history)]
            [(char=? c #\$) (parse-history rest history)]
            [(digit? c)     (parse-number cs)]
            [else           (fail "Invalid expression")])))))

(define (evaluate line history)
  (let ([result (parse-expr (string->list line) history)])
    (if (null? (skip-ws (second result)))
        (first result)
        (fail "Unexpected trailing characters"))))

(define (eval-loop history)
  (when prompt?
    (display "> ")
    (flush-output))
  (let ([line (read-line)])
    (cond
      [(eof-object? line) (void)]
      [(string=? line "quit") (void)]
      [else
       (let ([outcome
              (with-handlers ([string?   (lambda (msg) (cons 'error msg))]
                              [exn:fail? (lambda (e)   (cons 'error "Invalid expression"))])
                (cons 'ok (evaluate line (reverse history))))])
         (cond
           [(eq? (car outcome) 'ok)
            (let ([new-history (cons (cdr outcome) history)])
              (display (length new-history))
              (display ": ")
              (displayln (cdr outcome))
              (eval-loop new-history))]
           [else
            (display "Error: ")
            (displayln (cdr outcome))
            (eval-loop history)]))])))

(module+ main
  (eval-loop '()))