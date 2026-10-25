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

(define (parse-unary op chars)
  (let ([operand (parse-expr chars)])
    (list (op (first operand)) (second operand))))

(define (parse-binary op chars)
  (let* ([left  (parse-expr chars)]
         [right (parse-expr (second left))])
    (list (op (first left) (first right)) (second right))))

(define (parse-expr chars)
  (let ([cs (skip-ws chars)])
    (if (null? cs)
        (fail "Invalid expression")
        (let ([c (car cs)] [rest (cdr cs)])
          (cond
            [(char=? c #\+) (parse-binary + rest)]
            [(char=? c #\*) (parse-binary * rest)]
            [(char=? c #\/) (parse-binary divide rest)]
            [(char=? c #\-) (parse-unary negate rest)]
            [(digit? c)     (parse-number cs)]
            [else           (fail "Invalid expression")])))))

(define (evaluate line)
  (let ([result (parse-expr (string->list line))])
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
                (cons 'ok (evaluate line)))])
         (cond
           [(eq? (car outcome) 'ok)
            (displayln (cdr outcome))
            (eval-loop history)]
           [else
            (display "Error: ")
            (displayln (cdr outcome))
            (eval-loop history)]))])))

(module+ main
  (eval-loop '()))