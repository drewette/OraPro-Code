--Export all APEX apps
--ONLY RUN THIS IN DEV!!!

--dashboard
cd c:\git\FLASK_DASHBOARD\build\bespoke-flaskdashboard\apex\
@auto_export.sql;

--config
cd c:\git\FLASK_CONFIGURATION\build\bespoke-flask-configurator\apex\
@auto_export.sql;

--transit
cd c:\git\FLASK_TRANSIT\build\bespoke-flask-drstif\apex\
@auto_export.sql;

--planning
cd c:\git\FLASK_PLANNING\build\bespoke-flask-planning\apex\
@auto_export.sql;

--non-flask


--non-conformance
cd c:\git\FLASK_NON_CONFORMANCE_REPORTS\build\bespoke-non-conformance-reports\apex\
@auto_export.sql;

--Notifications
cd c:\git\NOTIFICATIONS\build\apex\
@auto_export.sql;

--INA
cd c:\git\INA\build\bespoke-independent-nuclear-assurance\apex\
@auto_export.sql;

--Laydowns
cd c:\git\LAYDOWNS\build\bespoke-laydowns\apex\
@auto_export.sql;

--SOER
cd c:\git\SOER\build\apex\
@auto_export.sql;

--Thermocouples
cd c:\git\TC\build\bespoke-thermocouples\apex\
@auto_export.sql;

--Fuel Stringer disassembly
cd c:\git\FUEL_STRINGER_DISASSEMBLY\bespoke-fuel-stringer-disassembly\apex\
@auto_export.sql;

--MIRS
cd c:\git\MIRS\bespoke-mirs\apex\
@auto_export.sql;



