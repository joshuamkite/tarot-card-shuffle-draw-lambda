# Testing the Tarot Draw Lambda Function

This document describes how to run tests locally for the Lambda function.

## Running Tests

### Basic Test Run

```bash
cd draw
CLOUDFRONT_URL="https://test.cloudfront.net" go test
```

### Verbose Output

To see detailed test output:

```bash
cd draw
CLOUDFRONT_URL="https://test.cloudfront.net" go test -v
```

### With Coverage Report

To generate a coverage report:

```bash
cd draw
CLOUDFRONT_URL="https://test.cloudfront.net" go test -cover -coverprofile=coverage.out
go tool cover -html=coverage.out -o coverage.html
```

Then open `coverage.html` in your browser to view the detailed coverage report.

### Quick Coverage Summary

```bash
cd draw
CLOUDFRONT_URL="https://test.cloudfront.net" go test -cover
```

## Test Coverage

The test suite includes:

- **OPTIONS request handling** - Tests CORS preflight requests
- **Invalid method handling** - Tests rejection of non-POST requests
- **Invalid JSON handling** - Tests malformed request bodies
- **Missing parameters** - Tests validation of required fields
- **Invalid deck options** - Tests validation of deck configuration
- **Valid requests** - Tests successful card draws with:
  - Major Arcana only
  - Full Deck
  - Upright and reversed cards
  - Default number of cards
  - Edge cases (requesting more cards than available)
- **Deck generation** - Tests deck building logic
- **Shuffle function** - Tests card shuffling

## Example Output

```
=== RUN   TestDrawHandler_OPTIONS
--- PASS: TestDrawHandler_OPTIONS (0.00s)
=== RUN   TestDrawHandler_InvalidMethod
--- PASS: TestDrawHandler_InvalidMethod (0.00s)
...
PASS
ok      draw    0.408s
```

## Troubleshooting

If tests fail, check:

1. You're in the `draw` directory
2. The `CLOUDFRONT_URL` environment variable is set
3. Go dependencies are installed: `go mod download`
