CREATE OR REPLACE PACKAGE BODY KF_SYSTEM.P00003_PSI_Par_Operations AS
-- Project:     "Kwik-Fit ROLF Project"
-- Component:   "PSI - ROLF Internals"
-- Module:      "Parameter Operations"  
-- **************************************************************
--
-- Copyright (C) 2010 Kwik-Fit GB Limited.
--
-- $Archive: $ 
-- $Workfile: $ 
-- $Revision: $ 
-- $Date: $ 
--
-- **************************************************************
--
-- Description:
-- ============
--
-- ROLF Internals. 
-- Parameter Operations
-- 
-- Revision History
-- ================
--
-- $Log: $ 
-- 
-- 1     19/02/10 Nicly Bell  Adapt from NDC Scripts
--
--
-- 
-- $NoKeywords: $
-- 
-- **************************************************************

    PROCEDURE P_Get_Parameter
        (I_Param_Name     IN     T00009_PSI_PARAMETER_TABLE.Param_Name%Type,
         O_Param_Value    OUT    T00009_PSI_PARAMETER_TABLE.Param_Value%Type) AS
--**************************************************************
--
-- PURPOSE:     Get a paraemter value
--
-- PARAMETERS:
--
-- IN:          I_Param_Name   
--                  Parameter name (upper case only)
--              
-- OUT:
--              O_Param_Value
--                  80 bytes value. NULL if not found
--
-- IN/OUT:      
--
-- SIDE EFFECTS:    None
--
--*************************************************************/
    PRAGMA AUTONOMOUS_TRANSACTION;
    V_LOG_SEQUENCE NUMBER;
    BEGIN
        BEGIN
            --
            -- Get Parameter
            --
            SELECT PARAM_Value INTO O_Param_Value
            FROM T00009_PSI_PARAMETER_TABLE
           WHERE PARAM_Name = I_Param_Name;

        EXCEPTION
        WHEN NO_DATA_FOUND THEN
            --
            -- Get the next log number
            --
            SELECT Log_Sequence_No.nextval
              INTO V_Log_Sequence
              FROM DUAL;
            --
            -- Report the missing paramenter
            --
            INSERT INTO T00008_PSI_LOG_TABLE LG
                    (LG.LOG_SEQUENCE, 
                     LG.CREATE_DATE,
                     LG.CATEGORY,
                     LG.LOG_LEVEL, 
                     LG.MESSAGE)
                VALUES
                    (V_Log_Sequence,
                     SYSDATE,
                     'W',
                     '0',
                     I_PARAM_NAME||' **** Parameter does not exist ****');
            COMMIT;
            --
            -- No Value found so return NULL
            --
            O_PARAM_VALUE := NULL;
        END;

    EXCEPTION
    WHEN OTHERS THEN
        P00002_PSI_LOG_Operations.P_LOG_EXCEPTION('X',0,'P001_PSI_Par_Operations.P_Get_Parameter: Unhandled exception');
        O_Param_Value := NULL;
    END;

         
END P00003_PSI_Par_Operations;
/