## NAME

jp - command line tool for accessing JSON string using regex JSON Pointers

## SYNOPSIS

```bash
$ jp -hh

$ jp < example.json
{"Version":"1","server":[{...},{...},{...}]}

$ jp /server/0/password < example.json
s3cr3t
```

See EXAMPLES, below, for more!

## DESCRIPTION

Command line tool for accessing JSON string using regex JSON Pointers and
a an extra powerful eval option for filtering the data structure.

## USAGE

```
  Usage: $0 [OPTIONS] [POINTERS]
    Options:
      -A               Dereference JSON arrays into columns
      -C               No collection
      -E eval-string   Evaluate the Perl eval string
                       These functions and variables, in addition to standard Perl functions and variables, are:
         \$_            A Mojo::Collection of [JP OBJECTS]
         D             Dump an object to inspect it
         out           Print to stdout and include it in test inspection
         c             Create a new Mojo::Collection object
         f             Create a new Mojo::File object
         l             Create a new Mojo::URL object
         r             Alias to Mojo::Util::dumper
         traverse      Imported from Data::Traverse, if available
      -I exact-match   Compare the results exactly against the supplied text
      -M test-message  Specify a message in the test output
      -R regex         Compare the results against the supplied regex
      -S               Don't sort
      -T eval-string   Compare the results against the supplied Perl eval string
      -U               Remove undef
      -d delimiter     Delimiter to use in columnar output
      -h               Display this help, one more to include examples
      -i               Ignore case in regex JSON pointers
      -k tail-number   Display the bottom n results, n can be negative
      -n head-number   Display the top n results, n can be negative
      -p               Include the pointer in the columnar output
      -r regex-pointer A regex JSON pointer for selecting multiple targets
      -v               Increase verbosity
    
    Jp Objects:
      An object with pointer and value attributes. The primary method to use for this object when iterating a collection
      is the `jp` method which is used to further expand the JSON object by pointer. See the example commented
      "Filtering" for a very practical use case of the Jp object which allows further filtering the results of the regex
      pointer (-r) by iterating the \$_ Mojo::Collection of Jp objects with the use of the `grep` method and using a
      JSON Pointer with the `jp` method on each Jp object.
    Pointers:
      Any remaining non-flag arguments are considered JSON pointers and used to narrow the selection from the selected
      JSON string for columnar output.
```

## EXAMPLES

```
    (All examples read example.json from stdin, as shown by the first example)
    # Use a JSON pointer to get a value from the JSON data structure
    $ jp /server/0/password < example.json
    s3cr3t
    # Use a JSON pointer to get a value from the JSON data structure, defaults to /
    $ jp
    {"Version":"1","server":[{...},{...},{...}]}
    # Use a regex in the pointer to reduce the JSON data structure and return each result, one per line
    $ jp -n 1 -r '/server/\d+'
    {...}
    # Use a regex in the pointer to reduce the JSON data structure and include the pointer for all records found
    $ jp -n 1 -p -r '/server/\d+' /user /password
    /server/0  12345 s3cr3t
    # Filtering
    $ jp -Aip -n -1 -d: -E '$_->grep(sub{$_->jp("/isdefault")})' -r '/Server/\d' /user /password
    /server/1:54321:s3cr3t5
    # Treat the execution as a test
    $ jp -n 1 -E '$_->tap(sub{out $_->size})->tap(sub{out $_->size})' -r '/server/\d+' /user /password \
        -T '3\n3\n12345\ts3cr3t'
    ok: 'Test /user /password' is '3\n3\n12345\ts3cr3t'
    # A syntax error in the -E Perl eval is handled gracefully (final tap method is missing a closing ')')
    $ jp -v -n 1 -E '$_->tap(sub{out $_->size})->tap(sub{die 123}' -r '/server/\d+' /user /password 
    syntax error in -E eval
    # Don't sort by pointer, sort arbitrarily as specified in the -E Perl eval
    $ jp -v -S -U -p -r '/markers/\d' -E '$_->sort(sub{$a->jp("/location/0", "/position/0") <=> $b->jp("/location/0", "/position/0")})' /location /position <<EOF
    {"markers":[{"name":"Google","position":[40.741,-74.005]},{"name":"Microsoft","location":[40.756,-73.990]},{"name":"Tesla","location":[40.7411,-74.009]},{"name":"Amazon","location":[40.753,-74.001]}]}
```
