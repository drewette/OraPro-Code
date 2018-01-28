CREATE OR REPLACE PACKAGE BODY KF_SYSTEM.P00002_PSI_LOG_Operations as
-- Project:     "Kwik-Fit ROLF project"
-- Component:   "Common Internals"
-- Module:      "Logging Operations"  
-- **************************************************************
--
-- Copyright (C) 2010 Kwik-Fit GB Limited.
--
-- $Archive:$ 
-- $Workfile:$ 
-- $Revision: $ 
-- $Date:$ 
--
-- **************************************************************
--
-- Description:
-- ============
--
-- POM SOM Internals.
-- Logging Interface provides a mechanism 
-- for logging messages to a table for later anlaysis by development.
-- Note that only messages up till the DEBUG_LEVEL will be reported.
-- Level 0 messages are always reported.
--
-- Revision History
-- ================
--
-- $Log$ 
--
-- 1     19/02/2010 Nicky Bell  Adapt from NDC Scripts
--
-- 
-- $NoKeywords: $
-- 
-- **************************************************************

    procedure P_Log_Message
        (I_Category        in     T00008_PSI_LOG_TABLE.category%type,
         I_Log_Level       in     T00008_PSI_LOG_TABLE.LOG_LEVEL%type,
         I_Message         in     T00008_PSI_LOG_TABLE.MESSAGE%type) as
--**************************************************************
--
-- PURPOSE:     Log message if Log_Level <= DEBUG_LEVEL 
--
-- PARAMETERS:
--
-- IN:          I_Category   
--                  E - Error
--                  F - Fatal Error
--                  W - Warning
--                  I - Information
--                  X - Unhandled Exception
-- 
--              I_Log_Level   
--                  Level to log at (0 = Always)
--                  Otherwise <= DEBUG_LEVEL
-- 
--              I_Message 
--                   Message TO Log          
-- 
-- OUT:
-- 
-- IN/OUT:                     
--
-- SIDE EFFECTS:    Autonomous transaction to store message 
--
--
--*************************************************************/

    pragma AUTONOMOUS_TRANSACTION;     

    V_Log_Sequence     NUMBER;
    V_Debug_Level      VARCHAR2(80);  -- As comes from get_parameter 
    
    begin
        P00003_PSI_Par_Operations.P_GET_PARAMETER('DEBUG_LEVEL',V_Debug_Level);

        if I_Log_Level <= TO_NUMBER(NVL(V_Debug_Level,0)) then
            -- Get next seqeunce for log
            select Log_Sequence_No.nextval
            into V_Log_Sequence
            from DUAL;

            -- Add entry
            insert into T00008_PSI_LOG_TABLE LG
            (LG.LOG_SEQUENCE, LG.CREATE_DATE,
             LG.category, LG.LOG_LEVEL, 
             LG.MESSAGE)
            values
            (V_Log_Sequence, SYSDATE,
              I_Category, I_Log_Level,
              I_Message);
              
             -- autonomous commit 
             commit;
         end if;
    exception
    when OTHERS then
       rollback;          
    end; -- P_Log_Message

    procedure P_Log_Exception
        (I_Category        in     T00008_PSI_LOG_TABLE.category%type,
         I_Log_Level       in     T00008_PSI_LOG_TABLE.LOG_LEVEL%type,
         I_Message         in     T00008_PSI_LOG_TABLE.MESSAGE%type) as
--**************************************************************
--
-- PURPOSE:     Log message with exception if Log_Level <= DEBUG_LEVEL 
--              Log related exception information as well 
-- PARAMETERS:
--
-- IN:          I_Category   
--                  E - Error
--                  F - Fatal Error
--                  W - Warning
--                  I - Information
--                  X - Unhandled Exception
-- 
--              I_Log_Level   
--                  Level to log at (0 = Always)
--                  Otherwise <= DEBUG_LEVEL
-- 
--              I_Message 
--                   Message TO Log          
-- 
-- OUT:
-- 
-- IN/OUT:                     
--
-- SIDE EFFECTS:    Autonomous transaction to store message 
--
--
--*************************************************************/

    pragma AUTONOMOUS_TRANSACTION;     

    V_Log_Sequence     NUMBER;
    V_Debug_Level      VARCHAR2(80);  -- As comes from get_parameter 
    V_Error_Stack      VARCHAR2(2001); -- Error stack
    V_Call_Stack       VARCHAR2(2001); -- Call stack
    V_SQLCODE          NUMBER;          -- Code
    V_SQLERRM          VARCHAR2(255);  -- Error message
      
    begin
        P00003_PSI_Par_Operations.P_GET_PARAMETER('DEBUG_LEVEL',V_Debug_Level);


        if I_Log_Level <= TO_NUMBER(NVL(V_Debug_Level,0)) then
            -- Get next seqeunce for log
            select Log_Sequence_No.nextval
            into V_Log_Sequence
            from DUAL;
           
            -- Add entry
            insert into T00008_PSI_LOG_TABLE LG
            (LG.LOG_SEQUENCE, LG.CREATE_DATE,
             LG.category, LG.LOG_LEVEL, 
             LG.MESSAGE)
            values
            (V_Log_Sequence, SYSDATE,
              I_Category, I_Log_Level,
              I_Message);
              
             -- autonomous commit 
             commit;
             
             -- Now log related exception information
             V_Error_Stack := DBMS_UTILITY.FORMAT_ERROR_STACK;
             V_Call_Stack := DBMS_UTILITY.FORMAT_CALL_STACK;
             V_SQLERRM    := sqlerrm;
             V_SQLCODE := sqlcode;
             
            -- Add entry
            insert into T00007_PSI_EXC_TABLE LE
            (LE.LOG_SEQUENCE, 
             LE.EXCEPTION_NUMBER, LE.EXCEPTION_MESSAGE,
             LE.EXCEPTION_STACK, LE.CALL_STACK)
            values
            (V_Log_Sequence,
             V_SQLCODE, V_SQLERRM,
             V_Error_Stack, V_Call_Stack);
              
             -- autonomous commit 
             commit;
             
              
         end if;
    exception
    when OTHERS then
       rollback;
       V_SQLERRM    := sqlerrm;
       V_SQLCODE := sqlcode;
       P_Log_Message('E', 0, 'EX: ' ||  V_SQLCODE || ' EM: ' || V_SQLERRM);  
       commit;         

    end; -- P_Log_Exception

    procedure P_Log_Call_Stack
        (I_Category        in     T00008_PSI_LOG_TABLE.category%type,
         I_Log_Level       in     T00008_PSI_LOG_TABLE.LOG_LEVEL%type,
         I_Message         in     T00008_PSI_LOG_TABLE.MESSAGE%type) as
--**************************************************************
--
-- PURPOSE:     Log message with call stack if Log_Level <= DEBUG_LEVEL 
--              Log related call stack information as well 
-- PARAMETERS:
--
-- IN:          I_Category   
--                  E - Error
--                  F - Fatal Error
--                  W - Warning
--                  I - Information
--                  X - Unhandled Exception
-- 
--              I_Log_Level   
--                  Level to log at (0 = Always)
--                  Otherwise <= DEBUG_LEVEL
-- 
--              I_Message 
--                   Message TO Log          
-- 
-- OUT:
-- 
-- IN/OUT:                     
--
-- SIDE EFFECTS:    Autonomous transaction to store message 
--
--
--*************************************************************/

    pragma AUTONOMOUS_TRANSACTION;     

    V_Log_Sequence     NUMBER;
    V_Debug_Level      VARCHAR2(80);  -- As comes from get_parameter 
    V_Error_Stack      VARCHAR2(2001); -- Error stack
    V_Call_Stack       VARCHAR2(2001); -- Call stack
    V_SQLCODE          NUMBER;          -- Code
    V_SQLERRM          VARCHAR2(255);  -- Error message
      
    begin
        P00003_PSI_Par_Operations.P_GET_PARAMETER('DEBUG_LEVEL',V_Debug_Level);

        if I_Log_Level <= TO_NUMBER(NVL(V_Debug_Level,0)) then
            -- Get next seqeunce for log
            select Log_Sequence_No.nextval
            into V_Log_Sequence
            from DUAL;

            -- Add entry
            insert into T00008_PSI_LOG_TABLE LG
            (LG.LOG_SEQUENCE, LG.CREATE_DATE,
             LG.category, LG.LOG_LEVEL, 
             LG.MESSAGE)
            values
            (V_Log_Sequence, SYSDATE,
              I_Category, I_Log_Level,
              I_Message);
              
             -- autonomous commit 
             commit;
             
             -- Now log related call stack information
             V_Error_Stack := null;
             V_Call_Stack := DBMS_UTILITY.FORMAT_CALL_STACK;
             V_SQLERRM    := 'P_Log_Call_Stack';
             V_SQLCODE := 0;
             
            -- Add entry
            insert into T00007_PSI_EXC_TABLE LE
            (LE.LOG_SEQUENCE, 
             LE.EXCEPTION_NUMBER, LE.EXCEPTION_MESSAGE,
             LE.EXCEPTION_STACK, LE.CALL_STACK)
            values
            (V_Log_Sequence,
             V_SQLCODE, V_SQLERRM,
             V_Error_Stack, V_Call_Stack);
              
             -- autonomous commit 
             commit;
             
              
         end if;
    exception
    when OTHERS then
       rollback;
       V_SQLERRM    := sqlerrm;
       V_SQLCODE := sqlcode;
       P_Log_Message('E', 0, 'Callback'); 
       commit;          
    end; -- P_Log_Call_Stack

   procedure purge_program_logs
   /**************************************************************
   Purpose: Purge the tables t00007_psi_exc_table,t00008_psi_log_table
   according to the parameter KEEP_LOG_DATA_DAYS 
   **************************************************************/
   as
      V_PROCESS_NAME VARCHAR2(30) := 'PURGE_PROGRAM_LOGS';
      V_DAYS_TO_KEEP NUMBER(3) := 31; -- if the parameter does not exist then default to 31 days
      V_DELETED_MSG  NUMBER := 0;
      V_log_sequence T00008_PSI_LOG_TABLE.log_sequence%type := 0;
   begin
      p00003_psi_par_operations.p_get_parameter('KEEP_LOG_DATA_DAYS',V_DAYS_TO_KEEP);
      v_days_to_keep := nvl(v_days_to_keep,31); -- if the parameter does not exist then default to 31 days
      p00002_psi_log_operations.p_log_message('I','10',C_PACKAGE_NAME||'.'||V_PROCESS_NAME||' Purging to sysdate-'||V_DAYS_TO_KEEP||' days.');                     

      select max(log_sequence) 
        into v_log_sequence
        from T00008_PSI_LOG_TABLE
       where create_date < sysdate-V_DAYS_TO_KEEP;
 
      delete from T00007_PSI_EXC_TABLE where log_sequence <= v_log_sequence;
      v_deleted_msg := sql%rowcount;               
      p00002_psi_log_operations.p_log_message('I','10',C_PACKAGE_NAME||'.'||V_PROCESS_NAME||' Deleted '||v_deleted_msg||' log exceptions.');                     

      delete from T00008_PSI_LOG_TABLE where log_sequence <= v_log_sequence;
      v_deleted_msg := sql%rowcount;               
      p00002_psi_log_operations.p_log_message('I','10',C_PACKAGE_NAME||'.'||V_PROCESS_NAME||' Deleted '||v_deleted_msg||' log messages.');                     
   end;


end P00002_PSI_LOG_Operations;
/