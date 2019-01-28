# dbt-integration-tests

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
