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

### Special Scheme

Here we define some special syntaxes to take into consideration. The syntax is specified for each desired pattern. Note that the "normal" syntax must be used whenever the scheme is not among those recognized as special: `mailto`, `news`, `tel`, `fax` and `zos`.

#### Scheme 'mailto'

In this case only the `userinfo` and `host` fields of the structure must be filled.

```
scheme-syntax   ::= [userinfo ['@' host]]
```

#### Scheme 'news'

In this case only the `host` field must be filled.

```
scheme-syntax   ::= [host]
```

#### Scheme 'tel' and 'fax'

For the sake of simplicity, no checks on the consistency of the identifier associated with userinfo were considered, apart from compliance with the specific syntactic rules.

```
scheme-syntax   ::= [userinfo]
```

#### Scheme 'zos'

The zos scheme describes the names of data-sets on IBM mainframes. In this case the special syntax is a variation of the production of `URI1`, with the `path` field having a different structure which is checked differently. The other fields (`userinfo`, `host`, `port`, `query`, `fragment`) are to be recognized normally as in the production of `URI1`.

```
path        ::= <id44> ['(' <id8> ')']
id44        ::= (<alphanum> | '.')+
id8         ::= (<alphanum>)+
alphanum    ::= <alphabetic characters and digits>
```

The length of `id44` is at most 44 and that of `id8` is at most 8. Furthermore, `id44` and `id8` must start with an alphabetic character; `id44` cannot end with a '.'

#### Notes

Many fields are optional. `Port` has '80' by default and must be rendered as a number.
Starting from the given grammar, an URI can therefore be divided into the following components:

1. Scheme
2. Userinfo
3. Host
4. Port
5. Path
6. Query
7. Fragment

Note that the grammar admits URIs containing only the scheme (and the default `port` '80')

## Prolog

There is a `uri_parse/2` predicate in prolog:

```Prolog
uri_parse(URIString, URI).
```

which is true if URIString can be unbundled into the compound term:

```Prolog
URI = uri(Scheme, Userinfo, Host, Port, Path, Query, Fragment).
```

The `uri_display/1` and `uri_display/2` predicates have also been implemented which print a URI in text format and on file respectively.  
Some examples:

```Prolog
uri_parse("http://facebook.com", URI).
URI = uri(http, [], 'facebook.com', 80, [], [], [])
```

```Prolog
uri_parse("sftp://anon@facebook.com/foo/uri.pl", URI).
URI = uri(sftp, anon, 'facebook.com', 80, 'foo/uri.pl', [], [])
```

The program is also able to correctly answer queries in which the terms are partially instantiated, such as:

```Prolog
uri_parse("http://facebook.com", uri(https, _, _, _, _, _, _)).
false
```

```Prolog
uri_parse("http://facebook.com", uri(_, _, Host, _, _, _, _)).
Host = 'facebook.com'
```

## Lisp

In Common Lisp a `uri-parse` function has been implemented which receives a string as input and returns a "structure" with at least the 7 fields mentioned above. This structure is represented with a `defstruct`.  
Furthermore, specific functions have been implemented to access the various components of the structure, in particular they are:

```
uri-parse:          string → uri-structure
uri-scheme:         uri-structure → string
uri-userinfo:       uri-structure → string
uri-host:           uri-structure → string
uri-port:           uri-structure → integer
uri-path:           uri-structure → string
uri-query:          uri-structure → string
uri-fragment:       uri-structure → string
uri-display:        uri-structure &optional stream → T
```

Examples:

```Lisp
(defparameter uri (uri-parse "http://facebook.com"))
URI
```

```Lisp
(uri-scheme uri))
"http"
```

```Lisp
(uri-host disco))
"facebook.com"
```

```Lisp
(uri-query disco))
NIL
```

```Lisp
(uri-display disco))
Scheme:     "http"
Userinfo:   NIL
Host:       "facebook.com"
Port:       80
Path:       NIL
Query:      NIL
Fragment:   NIL
```
