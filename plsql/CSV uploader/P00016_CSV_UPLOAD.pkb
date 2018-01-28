CREATE OR REPLACE PACKAGE BODY KF_SYSTEM.p00016_csv_upload
as
   /****************************************************************
   -- Project:     "CSV Uploads"
   -- Component:   "Utility Package"
   -- Module:      ""
   -- **************************************************************
   --
   -- Copyright (C) 2009 Kwik-Fit GB Limited.
   --               2010 Kwik-Fit GB Limited.
   --
   -- $Archive: / $
   -- $Workfile:  $
   -- $Revision:  $
   -- $Date:  $
   --
   -- **************************************************************
   --
   -- Description:
   -- ============
   -- 1. 23/10/2012   Eoghain Anderson  Created Package.
   -- 2, 10/7/2015    David Drewette - Line 746 added to handle null values in csv file, eg 1,,1,1,1,1 ie two commas together
   --3.  10/08/2015   David Drewette - Lopp added at line 747 to handle multiple nulls
   --
   --
   --
   -- Revision History
   -- ================
   --
   -- $Log:  $
   --
   --
   -- $NoKeywords: $
   --
   -- **************************************************************/



   procedure report_prog (p_session   in number,
                          p_user      in varchar2 default null)
   /**************************************************************
   PURPOSE: Reports the progress of a file upload by
            querying t00016_csv_progress, used by recursive Ajax call

       PARAMETERS:
       IN:  p_session - The Apex session


       SIDE EFFECTS: n/a
   *************************************************************/
   is
      l_process_name   constant varchar2 (32) := 'report_prog';

      l_data                    t00016_csv_progress%rowtype;
      l_return                  varchar2 (2000);
   begin
      select *
        into l_data
        from t00016_csv_progress
       where apex_session = p_session and curr = 1;

      --JS array formatted text with query result
      l_return :=
            '{ "stage" : "'
         || l_data.stage
         || '", "message" : "'
         || l_data.message
         || '", "complete" : "'
         || l_data.complete
         || '", "error" : "'
         || nvl (l_data.err, 0)
         || '", "error_message" : "'
         || l_data.errm
         || '"}';


      if l_data.stage = 'LOAD3' and l_data.complete = 1
      then
         p00002_psi_log_operations.p_log_message (
            'I',
            10,
            c_package_name || '.' || l_process_name || ': ' || 'End Progress');
         end_progress (p_session, p_user);
      end if;

      p00002_psi_log_operations.p_log_message (
         'I',
         99,
         c_package_name || '.' || l_process_name || ': ' || l_return);

      htp.p (l_return);
   exception
      when no_data_found
      then
         l_return :=
            '{ "stage" : "FILE", "message" : "Uploading File", "complete" : "0", "error" : "0", "error_message" : "No started"}';
         htp.p (l_return);
      when others
      then
         p00002_psi_log_operations.p_log_exception (
            'X',
            0,
            c_package_name || '.' || l_process_name || ': ' || sqlerrm);
         l_return :=
               '{ "stage" : "ERROR", "message" : "'
            || sqlerrm
            || '", "complete" : "0", "error" : "1", "error_message" : "'
            || sqlerrm
            || '"}';
         htp.p (l_return);
   end report_prog;



   procedure init_progress (p_session             in number,
                            p_user                in varchar2,
                            p_secondary_process   in varchar2 default null)
   /**************************************************************
   PURPOSE: Creates a set of records in t00016_csv_progress
            to allow updated to be called by repot_prog

       PARAMETERS:
       IN:  p_session - The Apex session id
            p_user - The Apex username


       SIDE EFFECTS: Commits under an autonomous transaction
   *************************************************************/
   is
      pragma autonomous_transaction;

      l_process_name   constant varchar2 (32) := 'init_progress';
   begin
      p00002_psi_log_operations.p_log_message (
         'I',
         10,
            c_package_name
         || '.'
         || l_process_name
         || ': '
         || 'Delete Progress Data');

      delete from t00016_csv_progress
            where apex_session = p_session;

      p00002_psi_log_operations.p_log_message (
         'I',
         10,
            c_package_name
         || '.'
         || l_process_name
         || ': '
         || 'Insert Progress Data');

      insert into t00016_csv_progress (id,
                                       apex_session,
                                       username,
                                       stage,
                                       message,
                                       complete,
                                       seq)
           values (null,
                   p_session,
                   p_user,
                   'FILE',
                   'Uploading File',
                   0,
                   1);

      insert into t00016_csv_progress (id,
                                       apex_session,
                                       username,
                                       stage,
                                       message,
                                       complete,
                                       seq)
           values (null,
                   p_session,
                   p_user,
                   'ANALYSE',
                   'Analysing File',
                   0,
                   2);

      insert into t00016_csv_progress (id,
                                       apex_session,
                                       username,
                                       stage,
                                       message,
                                       complete,
                                       seq)
           values (null,
                   p_session,
                   p_user,
                   'LOAD1',
                   'Uploading Lines',
                   0,
                   3);

      if p_secondary_process is not null
      then
         insert into t00016_csv_progress (id,
                                          apex_session,
                                          username,
                                          stage,
                                          message,
                                          complete,
                                          seq)
              values (null,
                      p_session,
                      p_user,
                      'LOAD2',
                      p_secondary_process,
                      0,
                      4);
      end if;

      insert into t00016_csv_progress (id,
                                       apex_session,
                                       username,
                                       stage,
                                       message,
                                       complete,
                                       seq)
           values (null,
                   p_session,
                   p_user,
                   'LOAD3',
                   'Completed!',
                   0,
                   5);

      commit;

      p00002_psi_log_operations.p_log_message (
         'I',
         10,
         c_package_name || '.' || l_process_name || ': ' || 'Completed');
   exception
      when others
      then
         p00002_psi_log_operations.p_log_exception (
            'X',
            0,
            c_package_name || '.' || l_process_name || ': ' || sqlerrm);
         raise;
   end init_progress;



   procedure end_progress (p_session in number, p_user in varchar2)
   /**************************************************************
   PURPOSE: Ends progress by deleting progress records from t00016_csv_progress

       PARAMETERS:
       IN:  p_session - The Apex session id
            p_user - The Apex username


       SIDE EFFECTS: Commits under an autonomous transaction
   *************************************************************/
   is
      pragma autonomous_transaction;

      l_process_name   constant varchar2 (32) := 'end_progress';
   begin
      p00002_psi_log_operations.p_log_message (
         'I',
         10,
            c_package_name
         || '.'
         || l_process_name
         || ': '
         || 'Delete Progress Data');


      delete from t00016_csv_progress
            where apex_session = p_session;

      commit;

      p00002_psi_log_operations.p_log_message (
         'I',
         10,
         c_package_name || '.' || l_process_name || ': ' || 'Completed');
   exception
      when others
      then
         p00002_psi_log_operations.p_log_exception (
            'X',
            0,
            c_package_name || '.' || l_process_name || ': ' || sqlerrm);
         raise;
   end end_progress;



   procedure define_progress_as (p_session    in number,
                                 p_user       in varchar2,
                                 p_stage      in varchar2,
                                 p_message    in varchar2,
                                 p_complete   in number,
                                 p_curr       in number,
                                 p_err        in number default 0,
                                 p_errm       in varchar2 default null)
   /**************************************************************
   PURPOSE: Sets the progress records in t00016_csv_progress

       PARAMETERS:
       IN:  p_session - The Apex session id
            p_user - The Apex username
            p_stage - The Sage of the progress as defined in t00016_csv_progress
            p_message - The current message
            p_complete - Complete flag (0 or 1)
            p_curr - Flag set to define this process as current (1 or null)
            p_err - Flag set if an error has occured (1 or null)
            p_errm - Error message if relevant


       SIDE EFFECTS: Commits under an autonomous transaction
   *************************************************************/
   is
      pragma autonomous_transaction;

      l_process_name   constant varchar2 (32) := 'define_progress_as';
      v_clean_string            varchar2 (4000);
   begin
      p00002_psi_log_operations.p_log_message (
         'I',
         10,
            c_package_name
         || '.'
         || l_process_name
         || ': '
         || p_session
         || ', '
         || p_user
         || ', '
         || p_stage
         || ', '
         || p_message
         || ', '
         || p_complete
         || ', '
         || p_curr
         || ', '
         || p_err
         || ', '
         || p_errm);

      v_clean_string := replace (p_errm, '"'); /*Double quotes in error message will escape return JSON string so must be removed*/
      v_clean_string := replace (v_clean_string, '''');
      v_clean_string := replace (v_clean_string, chr (10), '<br/>');

      update t00016_csv_progress
         set stage = p_stage,
             message = replace (p_message, '"') /*Double quotes in message will escape return JSON string so must be removed*/
                                               ,
             complete = p_complete,
             curr = p_curr,
             err = p_err,
             errm = v_clean_string
       where apex_session = p_session and stage = p_stage;

      commit;
   --   p00002_psi_log_operations.p_log_message( 'I', 10, c_package_name || '.' || l_process_name || ': ' || 'Completed' );

   exception
      when others
      then
         p00002_psi_log_operations.p_log_exception (
            'X',
            0,
            c_package_name || '.' || l_process_name || ': ' || sqlerrm);
         raise;
   end define_progress_as;



   procedure run_upload (p_session          in number,
                         p_user             in varchar2,
                         p_file_id          in number,
                         p_table_name       in varchar2,
                         p_predefine_cols      varchar2 default null,
                         p_procedure_spec   in varchar2 default null,
                         p_process_name     in varchar2 default null,
                         p_delimeter        in varchar2 default ',',
                         p_append_cols      in number default 0,
                         p_prepend_cols     in number default 0)
   /**************************************************************
   PURPOSE: Single run point for parsing text file and loading table

       PARAMETERS:
       IN:  p_session - The Apex session id
            p_user - The Apex username
            p_file_id - The id from t00016t_csv_files
            p_table_name - name of table to spool data into
            p_predefine_cols -- predefine the values of any columns by column seq e.g. '2:1,4:testing' will set columns to and 4 with 1 and "testing" respectively
            p_procedure_spec -- the spec of a secondary process procedure
            p_process_name - the name of a secondary process if p_procedure spec is populated
            p_delimeter - row delimeter
            p_append_cols - append blank cols to end of each row. Use with p_predefine_col to add additional data to uploaded file
            p_prepend_cols - prepend blank cols to front of each row. Use with p_predefine_col to add additional data to uploaded file

       SIDE EFFECTS: n/a
   *************************************************************/
   is
      l_process_name   constant varchar2 (32) := 'run_upload';

      l_blob                    blob;
      l_clob                    clob;
      l_filename                varchar2 (1000);
      l_what                    varchar2 (1000) := chr (13);
   begin
      p00002_psi_log_operations.p_log_message (
         'I',
         10,
         c_package_name || '.' || l_process_name || ': ' || 'Set Progress');
      define_progress_as (p_session,
                          p_user,
                          'ANALYSE',
                          'Analysing File',
                          0,
                          1);

      p00002_psi_log_operations.p_log_message (
         'I',
         10,
            c_package_name
         || '.'
         || l_process_name
         || ': '
         || 'Fetch File from t00016_csv_files');

      select file_blob, filename
        into l_blob, l_filename
        from t00016_csv_files
       where id = p_file_id; -- and app_id = g_app_id;


      p00002_psi_log_operations.p_log_message (
         'I',
         10,
            c_package_name
         || '.'
         || l_process_name
         || ': '
         || 'Convert Blob to Clob');
      l_clob := blob_to_clob (l_blob);

      p00002_psi_log_operations.p_log_message (
         'I',
         10,
         c_package_name || '.' || l_process_name || ': ' || 'Count lines');
      g_cnt := count_lines (l_clob);

      if g_cnt > g_max_rows
      then
         raise too_many_rows;
      end if;

      p00002_psi_log_operations.p_log_message (
         'I',
         10,
         c_package_name || '.' || l_process_name || ': ' || 'Set Progress');
      define_progress_as (p_session,
                          p_user,
                          'ANALYSE',
                          'Analysing File',
                          1,
                          0);

      p00002_psi_log_operations.p_log_message (
         'I',
         10,
         c_package_name || '.' || l_process_name || ': ' || 'Load Lines');
      load_lines (l_clob,
                  l_filename,
                  p_user,
                  p_session,
                  p_table_name,
                  p_predefine_cols,
                  p_delimeter,
                  p_append_cols,
                  p_prepend_cols);

      if p_procedure_spec is not null
      then
         p00002_psi_log_operations.p_log_message (
            'I',
            10,
               c_package_name
            || '.'
            || l_process_name
            || ': '
            || 'Secondary Process');
         secondary_process (p_procedure_spec,
                            p_user,
                            p_session,
                            p_process_name);
      end if;

      p00002_psi_log_operations.p_log_message (
         'I',
         10,
         c_package_name || '.' || l_process_name || ': ' || 'Complete Load');
      complete_load (p_user, p_session);
   exception
      when too_many_rows
      then
         p00002_psi_log_operations.p_log_exception (
            'X',
            0,
               c_package_name
            || '.'
            || l_process_name
            || ': Input file has too many rows '
            || g_cnt);
         define_progress_as (p_session,
                             p_user,
                             'ANALYSE',
                             'Analysing File',
                             1,
                             1,
                             1,
                             ' Too Many Rows Maximum ' || g_max_rows);
         raise;
      when others
      then
         p00002_psi_log_operations.p_log_exception (
            'X',
            0,
            c_package_name || '.' || l_process_name || ': ' || sqlerrm);
         raise;
   end run_upload;



   function blob_to_clob (p_blob in blob)
      return clob
   /**************************************************************
    PURPOSE: Convert txt file to clob for parsing

        PARAMETERS:

        IN:  p_blob - File to be converted

        SIDE EFFECTS: n/a
   *************************************************************/
   is
      l_process_name   constant varchar2 (32) := 'blob_to_clob';

      l_clob                    clob;
      l_varchar                 varchar2 (32767);
      l_start                   pls_integer := 1;
      l_buffer                  pls_integer := 4000;
   begin
      dbms_lob.createtemporary (l_clob, true);

      for i in 1 .. ceil (dbms_lob.getlength (p_blob) / l_buffer)
      loop
         l_varchar :=
            utl_raw.cast_to_varchar2 (
               dbms_lob.substr (p_blob, l_buffer, l_start));
         dbms_lob.writeappend (l_clob, length (l_varchar), l_varchar);
         l_start := l_start + l_buffer;
      end loop;

      p00002_psi_log_operations.p_log_message (
         'I',
         10,
         c_package_name || '.' || l_process_name || ': ' || 'Completed');
      return l_clob;
   exception
      when others
      then
         p00002_psi_log_operations.p_log_exception (
            'X',
            0,
            c_package_name || '.' || l_process_name || ': ' || sqlerrm);
         raise;
   end blob_to_clob;



   function count_lines (p_clob in clob)
      return number
   /**************************************************************
   PURPOSE: Counts the lines in the file

       PARAMETERS:
       IN:  p_clob - The clob to be parsed


       SIDE EFFECTS: n/a
   *************************************************************/

   is
      l_process_name   constant varchar2 (32) := 'count_lines';

      l_offset                  pls_integer := 1;
      l_segment                 varchar2 (32767);
      l_buffer                  pls_integer := 32767;
      l_search                  varchar2 (10) := chr (13);

      l_count                   number := 0;
   begin
      --Loop while offset is less than the filesize
      while l_offset < dbms_lob.getlength (p_clob)
      loop
         --segment the clob by the new line feeds ( chr(13) ) and incement a counter for each
         l_segment := dbms_lob.substr (p_clob, l_buffer, l_offset);
         l_count :=
              l_count
            + (length (l_segment) - length (replace (l_segment, l_search)));
         l_offset := l_offset + l_buffer;
      end loop;

      p00002_psi_log_operations.p_log_message (
         'I',
         10,
            c_package_name
         || '.'
         || l_process_name
         || ': '
         || 'Lines - '
         || l_count);
      return l_count;
   exception
      when others
      then
         p00002_psi_log_operations.p_log_exception (
            'X',
            0,
            c_package_name || '.' || l_process_name || ': ' || sqlerrm);
         raise;
   end count_lines;



   procedure load_lines (p_clob             in clob,
                         p_filename         in varchar2,
                         p_user             in varchar2,
                         p_session          in number,
                         p_table_name       in varchar2,
                         p_predefine_cols   in varchar2 default null,
                         p_delimeter        in varchar2 default ',',
                         p_append_cols      in number default 0,
                         p_prepend_cols     in number default 0)
   /**************************************************************
   PURPOSE: Parses clob an loads each valid line into table

       PARAMETERS:
       IN:  p_clob - The clob to be parsed
            p_filename - The filename
            p_user - The Apex username
            p_session - The Apex session ID
            p_table_name - Name of the destination table
            p_predefine_cols -- predefine the values of any columns by column seq e.g. '2:1,4:testing' will set columns to and 4 with 1 and "testing" respectively
            p_delimeter - row delimeter
            p_append_cols - append blank cols to end of each row. Use with p_predefine_col to add additional data to uploaded file
            p_prepend_cols - prepend blank cols to front of each row. Use with p_predefine_col to add additional data to uploaded file

       SIDE EFFECTS: e.g. COMMIT Executed
   *************************************************************/
   is
      l_process_name   constant varchar2 (32) := 'load_lines';

      l_clob                    clob := p_clob;
      l_offset                  pls_integer := 1;
      l_line                    varchar2 (32767);
      l_buffer                  pls_integer;
      l_search                  varchar2 (10) := chr (13);
      l_uploaded_date           date := sysdate;
      l_id                      number;
      l_count                   pls_integer := 0;
      l_line_arr                apex_application_global.vc_arr2;
      l_values                  varchar2 (32767);
      l_val                     varchar2 (32767);
      l_appended_cols           varchar2 (1000) := '';
      l_prepended_cols          varchar2 (1000) := '';
      l_dml                     varchar2 (32767);
      l_line_data               varchar2 (1);
   begin
      --save point for rollback on error
      savepoint start_file_load;

      for i in 1 .. p_append_cols
      loop
         l_appended_cols := l_appended_cols || p_delimeter;
      end loop;

      for i in 1 .. p_prepend_cols
      loop
         l_prepended_cols := l_prepended_cols || p_delimeter;
      end loop;

      define_progress_as (p_session,
                          p_user,
                          'LOAD1',
                          'Uploading Line 0 of ' || g_cnt,
                          0,
                          1);

      while l_offset < dbms_lob.getlength (p_clob)
      loop
         l_count := l_count + 1;

         select s00016_csv_progress_seq.nextval into l_id from dual;

         --Failsafe to prevent infinite loop.
         --This can be removed
         if l_count > g_max_rows
         then
            l_offset := dbms_lob.getlength (p_clob) + 1;
         end if;

         if mod (l_count, 50) = 0
         then
            define_progress_as (
               p_session,
               p_user,
               'LOAD1',
               'Uploading Line ' || l_count || ' of ' || g_cnt,
               0,
               1);
         end if;

         l_buffer :=
              dbms_lob.instr (l_clob,
                              l_search,
                              l_offset,
                              1)
            - l_offset;

         l_line :=
               l_prepended_cols
            || replace (
                  replace (dbms_lob.substr (l_clob, l_buffer, l_offset),
                           chr (10)),
                  '''')
            || l_appended_cols;


         -- this code handles null values in the uploaded csv file. DDrewette 10-07-2015
         -- do this 50 times to catch apll possible nulls
         for i in 1 .. 50
         loop
            l_line := replace (l_line, ',,', ',#NULL#,');
         end loop;


         l_line_arr := apex_util.string_to_table (l_line, p_delimeter);

         l_values := ' values (';
         l_line_data := 'N';

         for arr_idx in l_line_arr.first () .. l_line_arr.last ()
         loop
            if l_line_arr (arr_idx) is not null
            then
               l_values :=
                     l_values
                  || ''''
                  || nvl (get_override_val (p_predefine_cols, arr_idx),
                          l_line_arr (arr_idx))
                  || ''''
                  || p_delimeter;
               l_line_data := 'Y';
            end if;
         end loop;

         l_values := rtrim (l_values, p_delimeter) || ')';

         -- replace #NULL# with null - DDrewette 10-07-2015
         l_values := replace (l_values, '#NULL#', '');

         l_offset := l_offset + l_buffer + 1;

         if l_line_data = 'Y'
         then
            l_dml :=
                  'INSERT INTO '
               || p_table_name
               || replace (l_values, p_delimeter, ',');

            --           p00002_psi_log_operations.p_log_message( 'I', 10, c_package_name || '.' || l_process_name || ': ' || l_dml );

            execute immediate l_dml;
         end if;
      end loop;

      commit;

      define_progress_as (p_session,
                          p_user,
                          'LOAD1',
                          'Uploading Line ' || g_cnt || ' of ' || g_cnt,
                          0,
                          1);

      --Not ideal but less complicated than the alternative.
      --Used to create a pause to allow the ajax call to correctly report the final upload progress line before the progress skips to the next stage.
      dbms_lock.sleep (1);

      define_progress_as (p_session,
                          p_user,
                          'LOAD1',
                          'Uploading Line ' || g_cnt || ' of ' || g_cnt,
                          1,
                          0);
   exception
      when others
      then
         p00002_psi_log_operations.p_log_exception (
            'X',
            0,
            c_package_name || '.' || l_process_name || ': ' || sqlerrm);


         define_progress_as (
            p_session,
            p_user,
            'LOAD1',
            'There was a problem with line ' || l_count || '!',
            1,
            1,
            1,
            sqlerrm);


         dbms_lock.sleep (1);
         end_progress (p_session, p_user);

         rollback to start_file_load;
   end load_lines;



   procedure secondary_process (p_procedure_spec   in varchar2,
                                p_user             in varchar2,
                                p_session          in varchar2,
                                p_process_name     in varchar2)
   is
      l_process_name   varchar2 (100) := 'secondary_process';
   begin
      p00002_psi_log_operations.p_log_message (
         'I',
         10,
         c_package_name || '.' || l_process_name || ': ' || 'Started');

      define_progress_as (p_session,
                          p_user,
                          'LOAD2',
                          p_process_name,
                          0,
                          1);

      execute immediate
            'BEGIN  '
         || p_procedure_spec
         || '; EXCEPTION WHEN OTHERS THEN RAISE; END;';

      dbms_lock.sleep (1);

      define_progress_as (p_session,
                          p_user,
                          'LOAD2',
                          p_process_name,
                          1,
                          0);


      p00002_psi_log_operations.p_log_message (
         'I',
         10,
         c_package_name || '.' || l_process_name || ': ' || 'Completed');
   exception
      when others
      then
         p00002_psi_log_operations.p_log_exception (
            'X',
            0,
            c_package_name || '.' || l_process_name || ': ' || sqlerrm);


         define_progress_as (p_session,
                             p_user,
                             'LOAD2',
                             'There was a problem! ',
                             1,
                             1,
                             1,
                             sqlerrm);


         dbms_lock.sleep (1);
         end_progress (p_session, p_user);
         raise;
   end;

   procedure complete_load (p_user in varchar2, p_session in varchar2)
   is
      l_process_name   varchar2 (100) := 'complete_load';
   begin
      p00002_psi_log_operations.p_log_message (
         'I',
         10,
         c_package_name || '.' || l_process_name || ': ' || 'Started');

      define_progress_as (p_session,
                          p_user,
                          'LOAD3',
                          'Completed!',
                          1,
                          1);

      p00002_psi_log_operations.p_log_message (
         'I',
         10,
         c_package_name || '.' || l_process_name || ': ' || 'Completed');
   end;



   procedure get_report (p_session   in varchar2 default null,
                         p_user      in varchar2 default null)
   is
      l_return   varchar2 (32767) := '';
      l_row      varchar2 (32767);


      cursor getData
      is
           select    '
          <div>
           <div id = '''
                  || lower (stage)
                  || '_prog'' class=''prog1''>'
                  || message
                  || '</div>
           <div id = '''
                  || lower (stage)
                  || '_img'' class=''prog2''>
           </div>
           <div id = '''
                  || lower (stage)
                  || '_errm'' class=''prog2''>
           </div>
          </div>'
                     as msg
             from t00016_csv_progress
            where apex_session = p_session
         order by seq;

      r_data     getData%rowtype;
   begin
      l_return := l_return || '<table>';


      for r_data in getData
      loop
         l_row := '<tr><td>' || r_data.msg || '</td></tr>';
         l_return := l_return || l_row;
      end loop;


      l_return := l_return || '</table>';


      l_return :=
            '{ "table_data" : "'
         || replace (replace (l_return, chr (10)), chr (13))
         || '" }';

      htp.prn (l_return);
   end;



   function get_override_val (p_string   in varchar2 default null,
                              p_search   in varchar2 default null)
      return varchar2
   is
      l_return   varchar2 (100);

      l_arr      apex_application_global.vc_arr2;
      l_set      apex_application_global.vc_arr2;
   begin
      if p_string is not null
      then
         l_arr := apex_util.string_to_table (p_string, ',');

         for i in l_arr.first .. l_arr.last
         loop
            l_set := apex_util.string_to_table (l_arr (i), ':');

            if l_set (1) = p_search
            then
               l_return := l_set (2);
            end if;
         end loop;
      end if;

      return (l_return);
   end;



   procedure example_secondary_process_1 (p_wait in number default 10)
   is
   begin
      dbms_lock.sleep (p_wait);
   end;



   procedure example_secondary_process_2 (p_table_name   in varchar2,
                                          p_session      in number,
                                          p_user         in varchar2)
   is
   begin
      execute immediate
            '
 
  DECLARE
  
   l_count NUMBER;
 
  BEGIN
  
   SELECT COUNT(*)
   INTO l_count
   FROM '
         || p_table_name
         || ';
 
   FOR i IN 1..l_count LOOP
  
    p00016_csv_upload.define_progress_as ('
         || p_session
         || ' ,'''
         || p_user
         || ''',''LOAD2'',''Doing some business logic on line '' || i ,0,1);
  
   END LOOP;   

  END;
  
  
  ';
   end;



   procedure PROCESS_LOADED_DATA (p_table_name   in varchar2,
                                  p_session      in number,
                                  p_group_id     in varchar2)
   is
   begin
      --  STOCK.P27_CARS_PRICING.PROCESS_LOADED_DATA(p_table_name, p_group_id, p_session);
      null;
   end;
end p00016_csv_upload;
/