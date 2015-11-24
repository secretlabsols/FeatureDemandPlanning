﻿CREATE TABLE [dbo].[Fdp_VolumeDataItem] (
    [FdpVolumeDataItemId] INT IDENTITY (1, 1) NOT NULL,
    [FdpVolumeHeaderId]   INT NOT NULL,
    [IsManuallyEntered]   BIT CONSTRAINT [DF_Fdp_VolumeDataItem_IsManuallyEntered] DEFAULT ((1)) NOT NULL,
    [MarketId]            INT NOT NULL,
    [MarketGroupId]       INT NULL,
    [ModelId]             INT NOT NULL,
    [TrimId]              INT NOT NULL,
    [EngineId]            INT NOT NULL,
    [FeatureId]           INT NOT NULL,
    [FeaturePackId]       INT NULL,
    [Volume]              INT CONSTRAINT [DF_Fdp_VolumeDataItem_Volume] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Fdp_VolumeDataItem] PRIMARY KEY CLUSTERED ([FdpVolumeDataItemId] ASC),
    CONSTRAINT [FK_Fdp_VolumeDataItem_Fdp_VolumeHeader] FOREIGN KEY ([FdpVolumeHeaderId]) REFERENCES [dbo].[Fdp_VolumeHeader] ([FdpVolumeHeaderId]),
    CONSTRAINT [FK_Fdp_VolumeDataItem_OXO_Feature_Ext] FOREIGN KEY ([FeatureId]) REFERENCES [dbo].[OXO_Feature_Ext] ([Id]),
    CONSTRAINT [FK_Fdp_VolumeDataItem_OXO_Master_Market] FOREIGN KEY ([MarketId]) REFERENCES [dbo].[OXO_Master_Market] ([Id]),
    CONSTRAINT [FK_Fdp_VolumeDataItem_OXO_Programme_Model] FOREIGN KEY ([ModelId]) REFERENCES [dbo].[OXO_Programme_Model] ([Id]),
    CONSTRAINT [FK_Fdp_VolumeDataItem_OXO_Programme_Pack] FOREIGN KEY ([FeaturePackId]) REFERENCES [dbo].[OXO_Programme_Pack] ([Id])
);




GO
CREATE NONCLUSTERED INDEX [IX_NC_Fdp_VolumeDataItem_FdpVolumeHeaderId]
    ON [dbo].[Fdp_VolumeDataItem]([FdpVolumeHeaderId] ASC)
    INCLUDE([MarketId], [TrimId], [EngineId], [FeatureId], [Volume]);




GO
CREATE NONCLUSTERED INDEX [IX_NC_Fdp_VolumeDataItem_MarketId]
    ON [dbo].[Fdp_VolumeDataItem]([MarketId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_NC_Fdp_VolumeDataItem_TrimId]
    ON [dbo].[Fdp_VolumeDataItem]([TrimId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_NC_Fdp_VolumeDataItem_FeatureId]
    ON [dbo].[Fdp_VolumeDataItem]([FeatureId] ASC);
