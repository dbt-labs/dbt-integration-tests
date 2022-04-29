# dbt-integration-tests

> :warning: **THIS SUITE IS NO LONGER THE RECOMMENDED WAY TO TEST ADAPTERS.**
If you are building and testing a new dbt adapter, please read instead: ["Testing a new adapter"](https://docs.getdbt.com/docs/contributing/testing-a-new-adapter)

## Installation

Clone this repository, then run `pip install -r requirements.txt`. Make sure that this project is installed into the same Python environment as the adapter and dbt code that you want to test.

## Usage

To invoke, use:

```bash
bin/run-with-profile <profile-name> <other-options>
```

So, for example, to run the tests on a profile named `postgres`:

```bash
bin/run-with-profile postgres
```

To run a specific test:

```bash
bin/run-with-profile postgres features/001_basic_materializations.feature
```
