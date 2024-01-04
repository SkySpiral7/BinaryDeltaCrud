# Binary Delta CRUD
A [red lang](https://www.red-lang.org/p/about.html) implementation of my [Binary Delta CRUD specification](docs/spec.md).

## Running the app
The only thing currently accessable (outside of a red library) is using the cli to apply a delta:
`red cli.red applyDelta beforeStreamFile deltaStreamFile afterStreamFile`
more documentation will be added later.

## Running the tests
Run `scripts/runAllTests.sh` to run all the tests. It expects `scripts/red` to be pointed at a [red binary](https://www.red-lang.org/p/download.html)
(not included in this repo).

## Compatibility
Project was tested with red-02jan24-b34f787db (interpreted only).
