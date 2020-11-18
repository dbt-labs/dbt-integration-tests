Feature: Test re-materializing models as different types

  Background: Project setup
    Given a seed "seed" with:
      """
      id,first_name,last_name,email,gender,ip_address
      1,Jack,Hunter,jhunter0@pbs.org,Male,59.80.20.168
      2,Kathryn,Walker,kwalker1@ezinearticles.com,Female,194.121.179.35
      3,Gerald,Ryan,gryan2@com.com,Male,11.3.212.243
      4,Bonnie,Spencer,bspencer3@ameblo.jp,Female,216.32.196.175
      5,Harold,Taylor,htaylor4@people.com.cn,Male,253.10.246.136
      """
    And a file named "packages.yml" with:
      """
      packages:
        - package: fishtown-analytics/dbt_utils
          version: 0.2.4
      """
    And a file named "dbt_project.yml" with:
      """
      name: test
      version: 1.0
      """

  Scenario Outline: Materialize as <first_materialization> (<first_file_format>) first, then <second_materialization> (<second_file_format>)

    Given a model "relation" with:
      """
      {{
          config(
              materialized='<first_materialization>',
              partition_by='id',
              file_format='<first_file_format>'
          )
      }}
      select * from {{ ref('seed') }}
      """
    And a file named "models/schema.yml" with:
      """
      version: 2

      models:
        - name: relation
          columns:
            - name: state
              tests:
                - dbt_utils.equality:
                    compare_model: ref('seed')
      """

    When I successfully run "dbt deps"
     And I successfully run "dbt seed"
     And I successfully run "dbt run"
     And I successfully run "dbt test"
     And I update model "relation" to:
      """
      {{
          config(
              materialized='<second_materialization>',
              partition_by='id',
              file_format='<second_file_format>'
          )
      }}

      select * from {{ ref('seed') }}
      """
     And I successfully run "dbt run"
     And I successfully run "dbt test"

  Examples:
    | first_materialization | second_materialization | first_file_format | second_file_format |
    | view                  | view                   | view              | view               |
    | view                  | table                  | view              | parquet            |
    | view                  | incremental            | view              | parquet            |
    | table                 | view                   | parquet           | view               |
    | table                 | view                   | delta             | view               |
    | table                 | table                  | parquet           | parquet            |
    | table                 | table                  | parquet           | delta              |
    | table                 | table                  | delta             | parquet            |
    | table                 | table                  | delta             | delta              |
    | table                 | incremental            | parquet           | parquet            |
    | table                 | incremental            | parquet           | parquet            |
    | incremental           | view                   | parquet           | view               |
    | incremental           | table                  | parquet           | parquet            |
    | incremental           | incremental            | parquet           | parquet            |
