# esbmc-solidity-action

Github action for security verification of solidity contracts using ESBMC-solidity

# usage

> It is strongly recommended to have a fundamental understanding of ESBMC-solidity before using this action. [Learn more](https://ssvlab.github.io/lucasccordeiro/papers/icse2022.pdf)

- Create a `es.yml` file to select .sol files and the functions to be verified. You can find the schema [here]().

Basic `es.yml`

```yml
files:
  - filepath: test.sol
    functions: 
      - test_two
      - test_one
  - filepath: test2.sol
    functions: 
      - test_three
```

- Add github action

```yml
name: Build and Push Docker Image

on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main

jobs:
  run-esbmc-solidity:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v2
      - name: ESBMC Solidity Github Action
        uses: alanpjohn/esbmc-solidity-action@v1.0.0-alpha
```