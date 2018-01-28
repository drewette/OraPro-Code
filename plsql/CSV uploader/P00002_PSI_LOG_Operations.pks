CREATE OR REPLACE PACKAGE KF_SYSTEM.P00002_PSI_LOG_Operations AS
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
-- Logging Interface provides a mechanism 
-- for logging messages toa table for later anlaysis by development.
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
-- 
-- $NoKeywords: $
-- 
-- **************************************************************

   c_package_name    varchar2(30) := 'P00002_PSI_LOG_OPERATIONS';

    PROCEDURE P_Log_Message
        (I_Category        IN     T00008_PSI_LOG_TABLE.CATEGORY%Type,
         I_Log_Level       IN     T00008_PSI_LOG_TABLE.LOG_LEVEL%Type,
         I_Message         IN     T00008_PSI_LOG_TABLE.MESSAGE%Type);

    PROCEDURE P_Log_Exception
        (I_Category        IN     T00008_PSI_LOG_TABLE.CATEGORY%Type,
         I_Log_Level       IN     T00008_PSI_LOG_TABLE.LOG_LEVEL%Type,
         I_Message         IN     T00008_PSI_LOG_TABLE.MESSAGE%Type);

    PROCEDURE P_Log_Call_Stack
        (I_Category        IN     T00008_PSI_LOG_TABLE.CATEGORY%Type,
         I_Log_Level       IN     T00008_PSI_LOG_TABLE.LOG_LEVEL%Type,
         I_Message         IN     T00008_PSI_LOG_TABLE.MESSAGE%Type);
         
   PROCEDURE purge_program_logs;
   
END P00002_PSI_LOG_Operations;
/