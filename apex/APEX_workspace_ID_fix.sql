declare
  v_workspace_id NUMBER;
begin
  select workspace_id into v_workspace_id
  from apex_workspaces where workspace = 'CIW_APPS';
  apex_application_install.set_workspace_id (v_workspace_id);
  apex_util.set_security_group_id
    (p_security_group_id => apex_application_install.get_workspace_id);
  apex_application_install.set_schema('APX_FLASK_CONFIGURATION');
  apex_application_install.set_application_id(1530);
  apex_application_install.generate_offset;
  apex_application_install.set_application_alias('FLASK_CONFIGURATION');
end;
 /