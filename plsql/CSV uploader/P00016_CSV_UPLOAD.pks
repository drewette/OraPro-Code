CREATE OR REPLACE PACKAGE KF_SYSTEM.p00016_csv_upload 
AS
/****************************************************************
-- Project:     ""
-- Component:   "" 
-- Module:      ""  
-- **************************************************************
--
-- Copyright (C) 2009 Kwik-Fit GB Limited.
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
-- 1. 10/09/2012   Eoghain Anderson  Created Package.  
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


    c_package_name  CONSTANT VARCHAR2(30) := 'p00016_csv_upload';
    g_cnt NUMBER := 0;
    g_max_rows NUMBER := 100000;
    g_app_id NUMBER := v('APP_ID');
    
    --Rowtype to hold row in txt file for insert into the parts group and location detail tablesc (used in load_lines)
   -- rt_parts_data t27_parts_group_detail%ROWTYPE;    
   -- rt_location_data t27_location_group_detail%ROWTYPE;  
    
    --Reports the progress of a file upload by querying detail table, used by recursive Ajax call
    PROCEDURE report_prog( p_session IN NUMBER, p_user IN VARCHAR2 DEFAULT NULL );
    
       
    --Creates a set of records in tables to allow updated to be called by repot_prog
    PROCEDURE init_progress( p_session IN NUMBER, p_user IN VARCHAR2, p_secondary_process IN VARCHAR2 DEFAULT NULL ) ;
    
    
    --Ends progress by deleting progress records from autodata_progress
    PROCEDURE end_progress( p_session IN NUMBER, p_user IN VARCHAR2 );
    
    
    --Sets the progress records in progress table
    PROCEDURE define_progress_as( p_session IN NUMBER, p_user IN VARCHAR2, p_stage IN VARCHAR2, p_message IN VARCHAR2, p_complete IN NUMBER, p_curr IN NUMBER,  p_err IN NUMBER DEFAULT 0, p_errm IN VARCHAR2 DEFAULT null );  
    
    
    --Single run point for parsing text file and loading details table
    PROCEDURE run_upload( p_session IN NUMBER, p_user IN VARCHAR2, p_file_id IN NUMBER, p_table_name IN VARCHAR2, p_predefine_cols VARCHAR2 DEFAULT NULL, p_procedure_spec IN VARCHAR2 DEFAULT NULL, p_process_name IN VARCHAR2 DEFAULT NULL, p_delimeter IN VARCHAR2 DEFAULT ',', p_append_cols IN NUMBER DEFAULT 0, p_prepend_cols IN NUMBER DEFAULT 0 );
    
    
    --Convert txt file to clob for parsing
    FUNCTION blob_to_clob( p_blob IN BLOB ) RETURN clob;
    
    
    --Counts the lines in the file
    FUNCTION count_lines( p_clob IN CLOB ) RETURN NUMBER;
    
    
    --Parses clob an loads each valid line into details table
    PROCEDURE load_lines (p_clob IN CLOB, p_filename IN VARCHAR2, p_user IN VARCHAR2, p_session IN NUMBER, p_table_name IN VARCHAR2, p_predefine_cols IN VARCHAR2 DEFAULT NULL, p_delimeter IN VARCHAR2 DEFAULT ',', p_append_cols IN NUMBER DEFAULT 0, p_prepend_cols IN NUMBER DEFAULT 0);
    
    PROCEDURE secondary_process( p_procedure_spec IN VARCHAR2, p_user IN VARCHAR2, p_session IN VARCHAR2, p_process_name IN VARCHAR2 );
    
    PROCEDURE complete_load( p_user IN VARCHAR2, p_session IN VARCHAR2 );
    
    PROCEDURE get_report( p_session IN VARCHAR2 DEFAULT NULL, p_user IN VARCHAR2 DEFAULT NULL );
    
    
    FUNCTION get_override_val( p_string IN VARCHAR2 DEFAULT NULL, p_search IN VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2;
    
    PROCEDURE example_secondary_process_1(p_wait IN NUMBER default 10);
    PROCEDURE example_secondary_process_2(p_table_name IN VARCHAR2, p_session IN NUMBER, p_user IN VARCHAR2);
    PROCEDURE PROCESS_LOADED_DATA(p_table_name IN VARCHAR2, p_session IN NUMBER, p_group_id IN VARCHAR2);
       

END p00016_csv_upload;
/