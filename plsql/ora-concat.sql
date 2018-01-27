FUNCTION ora_concat(col in varchar2,
delimiter in varchar2,
)
RETURN clob
is
l_result clob;
begin
for r in (
SELECT '<li>'||substr(fact,1,200)||'...</li><br />' facts
FROM facts
WHERE observations_id = p_id)
loop
l_result := l_result || r.facts;
end loop;
return l_result;
end;
/