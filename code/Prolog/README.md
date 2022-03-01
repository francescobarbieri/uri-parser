# Prolog Uri Parser

## How parsing happens

The parsing takes place first through a logical part (in fact an automaton) which checks the presence or absence of the components of the uri, saving the results obtained in special variables, called `Boolean-ComponentName`. These variables can have a value of 1 or 0 based on the presence or absence of the component in question.

The `Boolean-ComponentName` variables are then called within the predicates that must act on conditions.

For example the `split_query / 6` predicate when `BooleanQuery` is equal to 1 splits the list where there is the query identifier (the '?' character), otherwise it will do nothing and set `query` equal to an empty list.

In order, the parser does the following given an uri:

1. Check for ':'
2. If present, split the list using ':' char, otherwise the uri is not valid (see the grammar)
3. The presence of the `authority` is identified
4. A possible special scheme is identified
5. If special-schemes are present, specific predicates are called for parsing these syntaxes, otherwise skip to the next step
6. We start to parse the list from the bottom, check for the presence of `fragment`
7. Similarly, you check for `query`
8. `Query` and `fragment` are split if present, and saved in variables
9. If present it parses the `authority`, dividing it, thus isolating the `path` and the `authority`
10. We check the presence of `port` and `userinfo` in the `authority`
11. `Port` and `host` are split if present. As a result, `userinfo` is also obtained and saved in a variable
12. Lists are transformed into atoms for output.
