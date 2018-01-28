CREATE OR REPLACE PACKAGE KF_SYSTEM.P00003_PSI_Par_Operations  AS
-- Project:     "Kwik-Fit rolf"
-- Component:   "PSI - POM/SOM Internals"
-- Module:      "Parameter Operations"  
-- **************************************************************
--
-- Copyright (C) 2008 Kwik-Fit GB Limited.
--
-- $Archive: /NDC/Packages/P001_PSI_PAR_OPERATIONS.PKS $ 
-- $Workfile: P001_PSI_PAR_OPERATIONS.PKS $ 
-- $Revision: 1 $ 
-- $Date: 27/03/08 12:30 $ 
--
-- **************************************************************
--
-- Description:
-- ============
--
-- POM SOM Internals. 
-- Parameter operations
--
-- Revision History
-- ================
--
-- $Log: /NDC/Packages/P001_PSI_PAR_OPERATIONS.PKS $ 
-- 
-- 1     27/03/08 12:30 Jim Cooper
--
-- 2     11/03/10 TE. Added p_get_param_no_log for calls from 
--                the log and exception packages, otherwise you
--                end up in an escalating loop. 
-- 
-- $NoKeywords: $
-- 
-- **************************************************************

    PROCEDURE P_Get_Parameter
        (I_Param_Name     IN       T00009_PSI_PARAMETER_TABLE.Param_Name%Type,
         O_Param_Value    OUT    T00009_PSI_PARAMETER_TABLE.Param_Value%Type);

END P00003_PSI_Par_Operations;
/