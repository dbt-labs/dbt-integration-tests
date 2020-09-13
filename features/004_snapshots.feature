Feature: Test direct copying of source tables

  Background: Project setup
    Given a seed "seed" with:
      """
      id,first_name,last_name,email,gender,ip_address,updated_at
      1,Jack,Hunter,jhunter0@pbs.org,Male,59.80.20.168,2000-01-01 13:00:00
      2,Kathryn,Walker,kwalker1@ezinearticles.com,Female,194.121.179.35,2000-01-01 13:00:00
      3,Gerald,Ryan,gryan2@com.com,Male,11.3.212.243,2000-01-01 13:00:00
      4,Bonnie,Spencer,bspencer3@ameblo.jp,Female,216.32.196.175,2000-01-01 13:00:00
      5,Harold,Taylor,htaylor4@people.com.cn,Male,253.10.246.136,2000-01-01 13:00:00
      """
    And a file named "packages.yml" with:
      """
      packages:
        - git: https://github.com/fishtown-analytics/dbt-utils.git
      """
    And a macro file "macros" with:
      """
      {% macro update_seed(id, ip_address, updated_at) %}
        {% set sql %}
          update {{ target.schema }}.seed
          set ip_address = '{{ip_address}}',
          updated_at = '{{updated_at}}'
          where id = {{id}}
        {% endset %}
        
        {% do run_query(sql) %}
      {% endmacro %}
      """
    And a file named "dbt_project.yml" with:
      """
      name: test
      version: 1.0

      test-paths: ["tests"]
      """

  Scenario Outline: Test snapshot strategy='<strategy>'

    Given a snapshot "snapshot_relation_<strategy>" with:
      """
      {% snapshot snapshot_relation_<strategy> %}
        {%- if '<strategy>' == 'timestamp' -%}
        {{config(
            target_schema=target.schema,
            strategy='timestamp',
            unique_key='id',
            updated_at='updated_at'
          )
        }}
        {%- endif -%}
        {%- if '<strategy>' == 'check' -%}
        {{config(
            target_schema=target.schema,
            strategy='check',
            unique_key='id',
            check_cols='all'
          )
        }}
        {%- endif -%}
        select * from {{ ref('seed') }}
      {% endsnapshot %}
      """
      And a file named "snapshots/schema.yml" with:
      """
      version: 2

      snapshots:
        - name: snapshot_relation_<strategy>
          columns:
            - name: id
              tests:
                - relationships:
                    to: ref('seed')
                    field: id
                - dbt_utils.unique_where:
                    where: "dbt_valid_to is null"
            - name: dbt_scd_id
              tests:
                - unique
                - not_null
            - name: dbt_updated_at
              tests:
                - not_null
            - name: dbt_valid_from
              tests:
                - not_null
            - name: dbt_valid_to
              tests:
                - dbt_utils.at_least_one
      """
      And a file named "tests/test_snapshot_relation.sql" with:
      """
      with snapshot_minus_seed as (
        select id, first_name, email, gender, ip_address, updated_at
        from {{ ref('snapshot_relation_<strategy>') }}
        where dbt_valid_to is null
        except 
        select id, first_name, email, gender, ip_address, updated_at
        from {{ ref('seed') }}
      ),
      seed_minus_snapshot as (
        select id, first_name, email, gender, ip_address, updated_at
        from {{ ref('seed') }}
        except
        select id, first_name, email, gender, ip_address, updated_at
        from {{ ref('snapshot_relation_<strategy>') }}
        where dbt_valid_to is null 
      ),
      unioned as (
          select * from snapshot_minus_seed
          union all
          select * from seed_minus_snapshot
      )
      select * from unioned
      """

    When I successfully run "dbt deps"
     And I successfully run "dbt seed"
     And I successfully run "dbt snapshot"
     And I successfully run "dbt run-operation update_seed --args '{id: 1, ip_address: 255.255.255.255, updated_at: 2001-01-01 15:00:00}'"
     And I successfully run "dbt snapshot"
     And I successfully run "dbt test"

  Examples:
    | strategy  |
    | timestamp |
    | check     |
