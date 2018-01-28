BEGIN

kf_system.p00016_csv_upload.define_progress_as( :APP_SESSION
                                  , :APP_USER
                                  , 'FILE'
                                  , 'Uploading File'
                                  , 1
                                  , 0 );

END;


BEGIN

 :P1000_job_id := APEX_PLSQL_JOB.SUBMIT_PROCESS ( ' 

    BEGIN

    kf_system.p00016_csv_upload.run_upload( p_session => '||:APP_SESSION||'
                                , p_user => '''||:APP_USER||'''
                                , p_file_id => '||:P1000_ID||' 
                                , p_table_name => ''OPERATION_DATA.MAKE_MODEL_MASTER_STAGING''
                                , p_process_name => ''null;'');

    END; '
    , sysdate, 'RUNNING');                               

 :P1000_RUN := 1;

 :P1000_UPLOADING_FLAG := 1;

END;