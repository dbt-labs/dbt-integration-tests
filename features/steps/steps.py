import behave4cmd0.command_steps

import dbt.main

from behave import given, when, then


@given(u'a seed "{name}" with')
def a_seed_with_body(context, name):
    behave4cmd0.command_steps.step_a_file_named_filename_with(
        context,
        "data/{}.csv".format(name)
    )


@given(u'a model "{name}" with')
def a_model_with_body(context, name):
    behave4cmd0.command_steps.step_a_file_named_filename_with(
        context,
        "models/{}.sql".format(name)
    )


@given(u'a macro file "{name}" with')
def a_macro_file_with_body(context, name):
    behave4cmd0.command_steps.step_a_file_named_filename_with(
        context,
        "macros/{}.sql".format(name)
    )


@when(u'I successfully run "{command}"')
@when(u'I successfully run `{command}`')
def step_i_successfully_execute_command(context, command):
    command += " --profile {}".format(
        context.config.userdata.get('profile_name')
    )
    behave4cmd0.command_steps.step_i_run_command(context, command)
    behave4cmd0.command_steps.step_it_should_pass(context)


@when(u'I update model "{name}" to')
def update_model_with_body(context, name):
    behave4cmd0.command_steps.step_a_file_named_filename_with(
        context,
        "models/{}.sql".format(name)
    )


@then(u'"{relation_one}" and "{relation_two}" should be equivalent')
def seed_and_view_should_be_equivalent(context, relation_one, relation_two):
    raise NotImplementedError(
        u'STEP: "{}" and "{}" should be equivalent',
        relation_one,
        relation_two
    )
