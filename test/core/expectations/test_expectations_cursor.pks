create or replace package test_expectations_cursor is

  --%suite(expectations - cursor)
  --%suitepath(utplsql.core.expectations.cursor)

  --%aftereach
  procedure cleanup_expectations;

  procedure setup_temp_table_test;
  procedure cleanup_temp_table_test;

  --%test(Compares data from cursor on temporary table)
  --%beforetest(setup_temp_table_test)
  --%aftertest(cleanup_temp_table_test)
  procedure with_temp_table;

  --%test(Gives success for identical data)
  procedure success_on_same_data;

  --%test(Gives success when both cursors are empty)
  procedure success_on_empty;

  --%test(Gives success when both cursors are null)
  procedure success_on_both_null;

  --%test(Gives success on to_be_null if cursor is null)
  procedure success_to_be_null;

  --%test(Gives succes on not_to_be_not_null if cursor is null)
  procedure success_not_to_be_not_null;

  --%test(Gives success on not_to_be_null if cursor is not null)
  procedure success_not_to_be_null;

  --%test(Gives success on to_be_not_null if cursor is not null)
  procedure success_to_be_not_null;

  --%test(Gives success on is_empty if cursor is empty)
  procedure success_is_empty;

  --%test(Gives success on is_not_empty if cursor is not empty)
  procedure success_is_not_empty;

  --%test(Gives failure on is_null if cursor is null)
  procedure failure_is_null;

  --%test(Gives failure on is_not_null if cursor is not null)
  procedure failure_is_not_null;

  --%test(Gives failure on is_empty if cursor is empty)
  procedure failure_is_empty;

  --%test(Gives failure on is_not_empty if cursor is not empty)
  procedure failure_is_not_empty;

  --%test(Gives failure when one cursor is empty and another is null)
  procedure fail_null_vs_empty;

  --%test(Gives failure when different data present in one of rows)
  procedure fail_on_difference;

  --%test(Gives failure when more rows exist in actual)
  procedure fail_on_expected_missing;

  --%test(Gives failure when more rows exist in expected)
  procedure fail_on_actual_missing;

  --%test(Gives failure when different column name is used in cursors)
  procedure fail_on_different_column_name;

  --%test(Gives failure when different column ordering is used in cursors)
  procedure fail_on_different_column_order;

  --%test(Gives failure when different row ordering is used in cursors)
  procedure fail_on_different_row_order;

  --%test(Compares time part of date when set_nls was used)
  procedure include_time_in_date_with_nls;

  --%test(Uses default NLS for date when set_nls was not used)
  procedure uses_default_nls_for_date;

  --%test(List of columns to exclude is case sensitive)
  procedure exclude_columns_as_list;

  --%test(Comma separated list of columns to exclude is case sensitive)
  procedure exclude_columns_as_csv;

  --%test(Exclude columns fails on invalid XPath)
  procedure exclude_columns_xpath_invalid;

  --%test(Exclude columns by XPath is case sensitive)
  procedure exclude_columns_xpath;

  --%test(Excludes existing columns when some of columns on exclude are not valid column names)
  procedure exclude_ignores_invalid_column;

  --%test(List of columns to include is case sensitive)
  procedure include_columns_as_list;

  --%test(Comma separated list of columns to include is case sensitive)
  procedure include_columns_as_csv;

  --%test(Include columns fails on invalid XPath)
  procedure include_columns_xpath_invalid;

  --%test(Include columns by XPath is case sensitive)
  procedure include_columns_xpath;

  --%test(Includes existing columns when some of columns on exclude are not valid column names)
  procedure include_ignores_invalid_column;

  --%test(Includes only columns that are not excluded using combination of CSV and XPath)
  procedure include_exclude_col_csv_xpath;

  --%test(Includes only columns that are not on exclude list)
  procedure include_exclude_columns_list;

  --%test(Reports data-diff on expectation failure)
  procedure data_diff_on_failure;

  procedure prepare_table;
  procedure cleanup_table;

  --%test(Compares cursor on table to cursor on plsql data)
  --%beforetest(prepare_table)
  --%aftertest(cleanup_table)
  procedure compares_sql_and_plsql_types;

    --%test(Closes the cursor after use)
  procedure closes_cursor_after_use;

  --%test(Closes the cursor after use when exception was raised)
  procedure closes_cursor_after_use_on_err;

  --%test(Reports exception when cursor raises exception)
  procedure reports_on_exception_in_cursor;

   --%test(Reports an exception when cursor is closed)
  procedure exception_when_closed_cursor;

  --%test(Compares cursors with more than 1000 rows)
  procedure compares_over_1000_rows;

end;
/
