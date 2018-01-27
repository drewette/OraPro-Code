FUNCTION close_account(
p_clientUserId IN VARCHAR2,
p_affiliateId IN VARCHAR2,
p_password IN VARCHAR2,
p_reason IN VARCHAR2)
RETURN VARCHAR2
IS
v_xml XMLType;
v_url VARCHAR2(200);
v_pieces utl_http.html_pieces;
v_data CLOB;

-- pipelined values from type
v_ErrorNumber NUMBER;
v_ErrorMessage VARCHAR2(4000);
--============================

BEGIN

utl_http.set_wallet(
nowtv2.pkg_system_parameters.get_param(p_param_name => 'WALLET_PATH'),
nowtv2.pkg_system_parameters.get_param(p_param_name => 'WALLET_PASSWORD'));

v_url := (
nowtv2.pkg_system_parameters.get_param(p_param_name => 'MPP_CLOSE_ACCOUNT_WEB_SERVICE') ||
'affiliateId=' || p_affiliateId || chr(38) ||
'password=' || utl_url.escape(p_password, TRUE) || chr(38) ||
'clientUserId=' || p_clientUserId || chr(38) ||
'reason=' || utl_url.escape(p_reason, TRUE)
);

v_pieces := utl_http.request_pieces(v_url);
FOR i IN 1 .. v_pieces.COUNT
LOOP
v_data := v_data || v_pieces(i);
END LOOP;

v_xml := XMLType(v_data);

for r in (

SELECT
*
FROM
XMLTable( XMLNamespaces(
DEFAULT 'https://secure1.mppglobal.com/interface/ipaydeveloperV17/ipaydeveloper.asmx',
'http://schemas.xmlsoap.org/soap/envelope/' AS "soap",
'http://www.w3.org/2001/XMLSchema-instance' AS "xsi",
'http://www.w3.org/2001/XMLSchema' AS "xsd"
),
'/CloseAccountResult'
PASSING v_xml
COLUMNS
ErrorNumber NUMBER PATH 'ErrorNumber',
ErrorMessage VARCHAR2(4000) PATH 'ErrorMessage'
) )

loop
v_ErrorNumber := r.ErrorNumber;
v_ErrorMessage := r.ErrorMessage;
end loop;

if v_ErrorNumber in (1002,1005,1006,1009,1063,1081)
then
pkg_error_log.write_error(
p_errorcode => v_ErrorNumber,
p_errormessage => v_ErrorMessage,
p_source => SQLCODE,
p_error_datetime => sysdate);

return v_ErrorNumber || ' - ' || v_ErrorMessage;

end if;

exception when others
then
pkg_error_log.write_error(
p_errorcode => v_ErrorNumber,
p_errormessage => v_ErrorMessage,
p_source => SQLCODE,
p_error_datetime => sysdate);

end;

END;