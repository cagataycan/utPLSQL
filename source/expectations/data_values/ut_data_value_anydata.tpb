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
    return l_result;
  end;

  overriding member function compare_implementation(a_other ut_data_value) return integer is
  begin
    return compare_implementation( a_other, null, null);
  end;

  member function compare_implementation(a_other ut_data_value, a_exclude_xpath varchar2, a_include_xpath varchar2) return integer is
    l_self_data  xmltype;
    l_other_data xmltype;
    l_other  ut_data_value_anydata;
    l_result integer;
    l_ancestors varchar2(20);
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
        if self is of (ut_data_value_object) then
          l_ancestors := '/*/';
        else
          l_ancestors := '/*/*/';
        end if;
        ut_expectation_processor.set_xml_nls_params();
        l_self_data := xmltype.createxml(self.data_value);
        l_other_data := xmltype.createxml(l_other.data_value);
        filter_by_xpaths(l_self_data, a_exclude_xpath, a_include_xpath);
        filter_by_xpaths(l_other_data, a_exclude_xpath, a_include_xpath);
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

  final member procedure init(self in out nocopy ut_data_value_anydata, a_value anydata, a_data_object_type varchar2) is
  begin
    self.data_value := a_value;
    self.data_type  := case when a_value is not null then lower(a_value.gettypename) else 'undefined' end;
    if data_value is not null then
      execute immediate '
        declare
          l_data '||self.data_value.gettypename()||';
          l_value anydata := :a_value;
          l_status integer;
        begin
          l_status := l_value.get'||a_data_object_type||'(l_data);
          :l_data_is_null := case when l_data is null then 1 else 0 end;
        end;' using in self.data_value, out self.data_value_is_null;
    end if;
  end;

  overriding member function is_null return boolean is
  begin
    return self.data_value is null or ut_utils.int_to_boolean(self.data_value_is_null);
  end;

  static function get_instance(a_data_value anydata) return ut_data_value_anydata is
    l_result    ut_data_value_anydata := ut_data_value_object(null);
    l_type      anytype;
    l_type_code integer;
  begin
    if a_data_value is not null then
      l_type_code := a_data_value.gettype(l_type);
      if l_type_code in (dbms_types.typecode_table, dbms_types.typecode_varray, dbms_types.typecode_namedcollection, dbms_types.typecode_object) then
        if l_type_code = dbms_types.typecode_object then
          l_result := ut_data_value_object(a_data_value);
        else
          l_result := ut_data_value_collection(a_data_value);
        end if;
      else
        raise_application_error(-20000, 'Data type '||a_data_value.gettypename||' in ANYDATA is not supported by utPLSQL');
      end if;
    end if;
    return l_result;
  end;

end;
/
