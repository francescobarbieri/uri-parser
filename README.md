# Uri Parser

## Introduction

Surfing the Internet, but not only, requires skills to manipulate strings that represents Universal Resource Identifiers (URI). The purpose of this project is to create two libraries (Prolog and Lisp) that build structures that internally represents URIs starting from their representation as string.

## URI Syntax

```
URI     ::= URI1 | URI2
URI1    ::= scheme ':' [authority] [['/'] [path] ['?' query] ['#' fragment]]
URI2    ::= scheme ':' scheme-syntax

scheme      ::= <identifier>
authority   ::= '//' [userinfo '@'] host [':' port]
userinfo    ::= <identifier>
host        ::= <host-identifier> ['.' <host-identifier>]*
            | IP-address
port        ::= <digit>+
IP-address  ::= <NNN.NNN.NNN.NNN> (N is a digit)
path        ::= <identifier> ['/' <identifier>]* ['/']
query       ::= <chars without '#'>+
fragment    ::= <chars>+

<identifier>        ::= <chars without '/', '?', '#', '@' and ':'>+
<host-identifier>   ::= <chars without '.', '?', '#', '@' and ':'>+
<digit>             ::= '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9'

scheme-syntax       ::= <special-scheme - see below>
```

## Prolog

## Lisp
