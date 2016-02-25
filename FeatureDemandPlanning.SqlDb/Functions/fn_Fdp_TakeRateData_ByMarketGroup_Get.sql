﻿CREATE FUNCTION [dbo].[fn_Fdp_TakeRateData_ByMarketGroup_Get]
(
	@FdpVolumeHeaderId	INT
  , @MarketGroupId		INT
  , @ModelIds			NVARCHAR(MAX)
)
RETURNS 
@VolumeData TABLE 
(
	  FeatureId				INT NULL
	, FdpFeatureId			INT NULL
	, FeaturePackId			INT NULL
	, ModelId				INT NULL
	, FdpModelId			INT NULL
	, Volume				INT NULL
	, PercentageTakeRate	DECIMAL(5,4) NULL
)
AS
BEGIN
	DECLARE @Models AS TABLE
	(	
		  ModelId			INT
		, StringIdentifier	NVARCHAR(10)
		, IsFdpModel		BIT
	);
	INSERT INTO @Models 
	(
		  ModelId
		, StringIdentifier
		, IsFdpModel
	)
	SELECT 
		  ModelId
		, StringIdentifier
		, IsFdpModel
	FROM 
	dbo.fn_Fdp_SplitModelIds(@ModelIds);
	
	INSERT INTO @VolumeData
	(
		  FeatureId
		, FdpFeatureId
		, FeaturePackId
		, ModelId
		, FdpModelId
		, Volume
		, PercentageTakeRate
	)
	SELECT 
		  F.FeatureId
		, F.FdpFeatureId
		, F.FeaturePackId
		, M.ModelId
		, NULL
		, SUM(ISNULL(D.Volume, 0))			AS Volume
		, MAX(ISNULL(D.PercentageTakeRate, 0))	AS PercentageTakeRate	
    FROM 
	Fdp_VolumeHeader_VW		AS H
	CROSS APPLY @Models		AS M
	JOIN OXO_Programme_MarketGroupMarket_VW AS MK ON H.ProgrammeId = MK.Programme_Id
	JOIN Fdp_Feature_VW		AS F	ON	H.ProgrammeId		= F.ProgrammeId
									AND	H.Gateway			= F.Gateway
    LEFT JOIN Fdp_VolumeDataItem_VW	AS D ON H.FdpVolumeHeaderId = D.FdpVolumeHeaderId
		    							AND MK.Market_Id = D.MarketId
										AND M.ModelId = D.ModelId
										AND 
										(
											F.FeatureId = D.FeatureId
											OR
											F.FdpFeatureId = D.FdpFeatureId
										)
	WHERE 
	H.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	M.IsFdpModel = 0
	AND
	(F.FeatureId IS NOT NULL OR F.FdpFeatureId IS NOT NULL)
	AND
	(@MarketGroupId IS NULL OR MK.Market_Group_Id = @MarketGroupId)
	GROUP BY
	  M.ModelId
	, F.FeatureId
	, F.FdpFeatureId
	, F.FeaturePackId
	
	UNION

	SELECT 
		  NULL
		, NULL
		, F.FeaturePackId
		, M.ModelId
		, NULL
		, SUM(ISNULL(D.Volume, 0))			AS Volume
		, MAX(ISNULL(D.PercentageTakeRate, 0))	AS PercentageTakeRate	
    FROM 
	Fdp_VolumeHeader_VW		AS H
	CROSS APPLY @Models		AS M
	JOIN OXO_Programme_MarketGroupMarket_VW AS MK ON H.ProgrammeId = MK.Programme_Id
	JOIN Fdp_Feature_VW		AS F	ON	H.ProgrammeId		= F.ProgrammeId
									AND	H.Gateway			= F.Gateway
    LEFT JOIN Fdp_VolumeDataItem_VW	AS D ON H.FdpVolumeHeaderId = D.FdpVolumeHeaderId
		    							AND MK.Market_Id = D.MarketId
										AND M.ModelId = D.ModelId
										AND 
										(
											F.FeatureId = D.FeatureId
											OR
											F.FdpFeatureId = D.FdpFeatureId
										)
	WHERE 
	H.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	M.IsFdpModel = 0
	AND
	F.FeatureId IS NULL 
	AND 
	F.FdpFeatureId IS NULL
	AND
	F.FeaturePackId IS NOT NULL
	AND
	(@MarketGroupId IS NULL OR MK.Market_Group_Id = @MarketGroupId)
	GROUP BY
	  M.ModelId
	, F.FeaturePackId

	UNION
	
		SELECT 
		  F.FeatureId
		, F.FdpFeatureId
		, F.FeaturePackId
		, NULL
		, M.ModelId
		, SUM(ISNULL(D.Volume, 0))			AS Volume
		, MAX(ISNULL(D.PercentageTakeRate, 0))	AS PercentageTakeRate	
    FROM 
	Fdp_VolumeHeader_VW		AS H
	CROSS APPLY @Models		AS M
	JOIN OXO_Programme_MarketGroupMarket_VW AS MK ON H.ProgrammeId = MK.Programme_Id
	JOIN Fdp_Feature_VW		AS F	ON	H.ProgrammeId		= F.ProgrammeId
									AND	H.Gateway			= F.Gateway
    LEFT JOIN Fdp_VolumeDataItem_VW	AS D ON H.FdpVolumeHeaderId = D.FdpVolumeHeaderId
		    							AND MK.Market_Id = D.MarketId
										AND M.ModelId = D.FdpModelId
										AND 
										(
											F.FeatureId = D.FeatureId
											OR
											F.FdpFeatureId = D.FdpFeatureId
										)
	WHERE 
	H.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	M.IsFdpModel = 1
	AND
	(F.FeatureId IS NOT NULL OR F.FdpFeatureId IS NOT NULL)
	AND
	(@MarketGroupId IS NULL OR MK.Market_Group_Id = @MarketGroupId)
	GROUP BY
	  M.ModelId
	, F.FeatureId
	, F.FdpFeatureId
	, F.FeaturePackId
	
	RETURN; 
END