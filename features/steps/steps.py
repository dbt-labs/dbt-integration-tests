import behave4cmd0.command_steps

import dbt.main

from behave import given, when, then


@given(u'a seed "{name}" with')
def a_model_view_with_body(context, name):
    behave4cmd0.command_steps.step_a_file_named_filename_with(
        context, "data/{}.csv".format(name))


@given(u'a model "{name}" with')
def a_model_view_with_body(context, name):
    behave4cmd0.command_steps.step_a_file_named_filename_with(
        context, "models/{}.sql".format(name))


@when(u'I execute "{command}"')
def i_execute_command(context, command):
    dbt.main.main(command.split(' ')[1:])


@then(u'"{relation_one}" and "{relation_two}" should be equivalent')
def seed_and_view_should_be_equivalent(context, relation_one, relation_two):
    raise NotImplementedError(u'STEP: "{}" and "{}" should be equivalent',
        relation_one, relation_two)
