create or replace type body ut_data_value_anydata as
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2017 utPLSQL Project

  Licensed under the Apache License, Version 2.0 (the "License"):
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
  */

  overriding member function is_null return boolean is
  begin
    return true;
  end;

  overriding member function to_string return varchar2 is
    l_result varchar2(32767);
    l_clob   clob;
  begin
    if self.is_null() then
      l_result := ut_utils.to_string( to_char(null) );
    else
      ut_expectation_processor.set_xml_nls_params();
      select xmlserialize(content xmltype(self.data_value) indent) into l_clob from dual;
      l_result := ut_utils.to_string( l_clob, null );
      ut_expectation_processor.reset_nls_params();
    end if;
    return self.format_multi_line( l_result );
  end;

  overriding member function compare_implementation(a_other ut_data_value) return integer is
    l_self_data  xmltype;
    l_other_data xmltype;
    l_other  ut_data_value_anydata;
    l_result integer;
    procedure filter_by_xpaths(a_xml in out nocopy xmltype, a_exclude varchar2, a_include varchar2) is
    begin
      if a_exclude is not null then
        select deletexml( a_xml, a_exclude ) into a_xml from dual;
      end if;
      if a_include is not null then
        select extract( a_xml, a_include ) into a_xml from dual;
      end if;
    end;
  begin
    if a_other is of (ut_data_value_anydata) then
      l_other := treat(a_other as ut_data_value_anydata);
      --needed for 11g xe as it fails on constructing XMLTYPE from null ANYDATA
      if not self.is_null() and not l_other.is_null() then
        ut_expectation_processor.set_xml_nls_params();
        l_self_data := xmltype.createxml(self.data_value);
        l_other_data := xmltype.createxml(l_other.data_value);
        --We use `order member function compare` to do data comparison.
        --Therefore, in the `ut_equals` matcher, comparison is done by simply checking
        --   `l_result := equal_with_nulls((self.expected = a_actual), a_actual)`
        --We cannot guarantee that we will always use `expected = actual ` and not `actual = expected`.
        --We should expect the same behaviour regardless of that is the order.
        -- This is why we need to coalesce `exclude_xpath` though at most one of them will always be populated
        filter_by_xpaths(l_self_data, coalesce(self.exclude_xpath, l_other.exclude_xpath), coalesce(self.include_xpath, l_other.include_xpath));
        filter_by_xpaths(l_other_data, coalesce(self.exclude_xpath, l_other.exclude_xpath), coalesce(self.include_xpath, l_other.include_xpath));
        ut_expectation_processor.reset_nls_params();
        if l_self_data is not null and l_other_data is not null then
          l_result := dbms_lob.compare( l_self_data.getclobval(), l_other_data.getclobval() );
        end if;
      end if;
    else
      raise value_error;
    end if;
    return l_result;
  end;

  final member procedure init(self in out nocopy ut_data_value_anydata, a_value anydata, a_self_type varchar2) is
  begin
    self.data_value := a_value;
    self.self_type  := a_self_type;
    self.data_type  := case when a_value is not null then lower(a_value.gettypename) else 'undefined' end;
  end;

  static function get_instance(a_data_value anydata, a_exclude varchar2 := null, a_include varchar2 := null) return ut_data_value_anydata is
    l_result    ut_data_value_anydata := ut_data_value_object(null);
    l_type      anytype;
    l_ancestors varchar2(20) := '/*/';
    l_type_code integer;
  begin
    if a_data_value is not null then
      l_type_code := a_data_value.gettype(l_type);
      if l_type_code in (dbms_types.typecode_table, dbms_types.typecode_varray, dbms_types.typecode_namedcollection, dbms_types.typecode_object) then
        if l_type_code = dbms_types.typecode_object then
          l_result := ut_data_value_object(a_data_value);
        else
          l_result := ut_data_value_collection(a_data_value);
          l_ancestors := '/*/*/';
        end if;
        l_result.exclude_xpath := ut_utils.to_xpath( a_exclude, l_ancestors );
        l_result.include_xpath := ut_utils.to_xpath( a_include, l_ancestors );
      else
        raise_application_error(-20000, 'Data type '||a_data_value.gettypename||' in ANYDATA is not supported by utPLSQL');
      end if;
    end if;
    return l_result;
  end;

  static function get_instance(a_data_value anydata, a_exclude ut_varchar2_list, a_include ut_varchar2_list) return ut_data_value_anydata is
    l_result    ut_data_value_anydata;
    l_exclude   varchar2(32767);
    l_include   varchar2(32767);
  begin
    l_exclude := substr(ut_utils.table_to_clob(a_exclude, ','), 1, 32767);
    l_include := substr(ut_utils.table_to_clob(a_include, ','), 1, 32767);
    l_result  := ut_data_value_anydata.get_instance(a_data_value, l_exclude, l_include );
    return l_result;
  end;

end;
/
