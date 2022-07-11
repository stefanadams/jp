## NAME

jp - command line tool for accessing JSON string using regex JSON Pointers

## SYNOPSIS

```bash
$ jp -hh

$ jp < example.json
{"Version":"1","artifactory":[{...},{...},{...}]}

$ jp /artifactory/0/password < example.json
s3cr3t
```

## DESCRIPTION

Command line tool for accessing JSON string using regex JSON Pointers and
a an extra powerful eval option for filtering the data structure.

