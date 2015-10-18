﻿CREATE TABLE [dbo].[OXO_IMP_Feature] (
    [Id]                INT             IDENTITY (1, 1) NOT NULL,
    [Feat_Code]         NVARCHAR (10)   NOT NULL,
    [EFG_Code]          NVARCHAR (10)   NULL,
    [OXO_Grp]           INT             NULL,
    [Config_Grp]        INT             NULL,
    [OA_Code]           NVARCHAR (10)   NULL,
    [Description]       NVARCHAR (100)  NULL,
    [Long_Desc]         NVARCHAR (4000) NULL,
    [Legal_Comment]     NVARCHAR (4000) NULL,
    [Priorty_X351_L462] NVARCHAR (10)   NULL,
    [In_LR_Coding]      INT             NULL,
    [In_Jag_Coding]     INT             NULL,
    [WERS_Code]         NVARCHAR (10)   NULL,
    [On_Relevant_Map]   NVARCHAR (10)   NULL,
    [LR_Verified_By]    NVARCHAR (50)   NULL,
    [Jag_Verified_By]   NVARCHAR (50)   NULL,
    [Grp_Verified_By]   NVARCHAR (50)   NULL,
    [JLR_Code_On_MFDL]  NVARCHAR (50)   NULL,
    [OA_Code_On_MFDL]   NVARCHAR (50)   NULL,
    [VISTA_Visibility]  NVARCHAR (50)   NULL,
    [Status]            BIT             NULL,
    [Created_By]        NVARCHAR (8)    NULL,
    [Created_On]        DATETIME        NULL,
    [Updated_By]        NVARCHAR (8)    NULL,
    [Last_Updated]      DATETIME        NULL,
    CONSTRAINT [PK_OXO_IMP_Feature] PRIMARY KEY CLUSTERED ([Id] ASC)
);

