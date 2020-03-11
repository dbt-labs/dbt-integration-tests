Feature: Test pre- and post-run hooks

  Background: Project setup
    Given a seed "on_run_hook" with:
      """
      state
      creating_table
      """
    And a seed "frozen_expected" with:
      """
      state
      creating_table
      start
      seed_completed
      end
      start
      """
    And a seed "unfrozen_expected" with:
      """
      state
      creating_table
      start
      seed_completed
      end
      start
      model_completed
      end
      """
    And a file named "packages.yml" with:
      """
      packages:
        - git: https://github.com/fishtown-analytics/dbt-utils.git
      """
    And a macro file "macros" with:
      """
      {% macro custom_run_hook(state) %}

        insert into {{ target.schema }}.on_run_hook (state)
        values ('{{ state }}')

      {% endmacro %}

      {% macro custom_seed_hook() %}

        insert into {{ target.schema }}.on_run_hook (state)
        values ('seed_completed')

      {% endmacro %}

      {% macro custom_model_hook() %}

        insert into {{ target.schema }}.on_run_hook (state)
        values ('model_completed')

      {% endmacro %}
      """
    And a file named "dbt_project.yml" with:
      """
      name: test
      version: 1.0

      on-run-start:
       - "{{ custom_run_hook('start') }}"
      on-run-end:
       - "{{ custom_run_hook('end') }}"
      models:
       test:
        post-hook:
         - "{{ custom_model_hook() }}"
      seeds:
       test:
        post-hook:
         - "{{ custom_seed_hook() }}"
      """

  Scenario: Make sure rows are added to on_run_hook table

    Given a model "frozen" with:
      """
      {{config(materialized='table')}}
      select * from {{target.schema}}.on_run_hook
      """
    And a model "unfrozen" with:
      """
      {{config(materialized='view')}}
      select * from {{target.schema}}.on_run_hook
      """
    And a file named "models/schema.yml" with:
      """
      version: 2

      models:
        - name: unfrozen
          columns:
            - name: state
              tests:
                - dbt_utils.equality:
                    compare_model: ref('unfrozen_expected')
        - name: frozen
          columns:
            - name: state
              tests:
                - dbt_utils.equality:
                    compare_model: ref('frozen_expected')
      """

    When I successfully run "dbt deps"
     And I successfully run "dbt seed"
     And I successfully run "dbt run"
     And I successfully run "dbt --debug test"
