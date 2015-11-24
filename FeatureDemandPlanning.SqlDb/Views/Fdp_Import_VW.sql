﻿CREATE VIEW [dbo].[Fdp_Import_VW] AS

	SELECT 
		  Q.FdpImportQueueId
		, IH.FdpImportId
		, Q.CreatedBy
		, Q.CreatedOn
		, I.LineNumber										AS ImportLineNumber  
		, I.[NSC or Importer Description (Vista Market)]	AS ImportMarket
		, I.[Country Description]							AS ImportCountry
		, I.[Derivative Code]								AS ImportDerivativeCode
		, I.[Trim Pack Description]							AS ImportTrim
		, I.[Bff Feature Code]								AS ImportFeatureCode
		, I.[Feature Description]							AS ImportFeature
		, I.[Count of Specific Order No]					AS ImportVolume
		, SFT.FdpSpecialFeatureTypeId						AS SpecialFeatureCodeTypeId
		, UPPER(SFT.SpecialFeatureType)						AS SpecialFeatureCodeType
		, SFT.[Description]									AS SpecialFeatureCodeDescription
		, P.Id												AS ProgrammeId
		, P.VehicleMake
		, P.VehicleName
		, P.VehicleAKA
		, P.ModelYear										AS ModelYear
		, IH.Gateway										AS Gateway
		, MMAP.Market_Id									AS MarketId
		, MMAP.Market_Name									AS Market
		, MMAP.Market_Group_Id								AS MarketGroupId
		, MMAP.Market_Group_Name							AS MarketGroup
		, M.Id												AS ModelId
		, M.BMC												AS BMC
		, B.Id												AS BodyId
		, B.Shape											AS BodyShape
		, B.Doors											AS BodyDoors
		, B.Wheelbase										AS BodyWheelbase
		, T.Id												AS TrimId
		, T.Name											AS TrimName
		, T.[Level]											AS TrimLevel
		, T.DPCK											AS DPCK
		, E.Id												AS EngineId
		, E.Size											AS EngineSize
		, E.Fuel_Type										AS EngineFuelType
		, E.Cylinder										AS EngineCylinder
		, ISNULL(E.Turbo, '')								AS EngineTurbo
		, E.[Power]											AS EnginePower
		, ISNULL(E.Electrification, '')						AS EngineElectrification
		, TM.Id												AS TransmissionId
		, TM.[Type]											AS TransmissionType
		, TM.Drivetrain										AS TransmissionDrivetrain
		, FE.Id												AS FeatureId
		, FE.Feat_Code										AS FeatureCode
		, FE.[Description]									AS FeatureDescription
		, FB.Brand_Desc										AS MarketingFeatureDescription
		, FG.Id												AS FeatureGroupId
		, FG.Group_Name										AS FeatureGroup
		, ISNULL(FG.Sub_Group_Name, '')						AS FeatureSubGroup
		, FP.Id												AS FeaturePackId
		, ISNULL(FP.Pack_Name, '')							AS FeaturePack
		, CAST(	CASE 
					WHEN MMAP.Market_Id IS NULL AND SF.FdpSpecialFeatureId IS NULL
					THEN 1 
					ELSE 0
				END AS BIT)									AS IsMarketMissing
		, CAST( CASE 
					WHEN DER.ProgrammeId IS NULL AND SF.FdpSpecialFeatureId IS NULL
					THEN 1 
					ELSE 0
				END AS BIT)									AS IsDerivativeMissing
		, CAST( CASE 
					WHEN T.Id IS NULL AND SF.FdpSpecialFeatureId IS NULL
					THEN 1 
					ELSE 0
				END AS BIT)									AS IsTrimMissing
		, CAST( CASE
					WHEN FE.Id IS NULL AND SF.FdpSpecialFeatureId IS NULL
					THEN 1
					ELSE 0
				END AS BIT)									AS IsFeatureMissing
		, CAST( CASE
					WHEN CUR.FdpVolumeDataItemId IS NULL
					THEN 0
					ELSE 1
				END AS BIT)									AS IsExistingData
		, CAST( CASE
					WHEN SF.FdpSpecialFeatureId IS NOT NULL
					THEN 1
					ELSE 0
				END AS BIT)									AS IsSpecialFeatureCode
		
	FROM Fdp_Import							AS IH
	JOIN Fdp_ImportData						AS I		ON	IH.FdpImportId				= I.FdpImportId
	JOIN Fdp_ImportQueue					AS Q		ON	IH.FdpImportQueueId			= Q.FdpImportQueueId
	JOIN OXO_Programme_VW					AS P		ON	IH.ProgrammeId				= P.Id
	
	-- Mapping of market details
	
	LEFT JOIN Fdp_MarketMapping_VW			AS MMAP		ON	
														(
															I.[Country Description]     = MMAP.Market_Name
															OR
															I.[NSC or Importer Description (Vista Market)] = MMAP.Market_Name
														)
														AND IH.ProgrammeId				= MMAP.ProgrammeId
														AND IH.Gateway					= MMAP.Gateway
	
	-- Mapping of derivative details
	
	LEFT JOIN Fdp_DerivativeMapping_VW		AS DMAP		ON	LTRIM(RTRIM(I.[Derivative Code]))			= DMAP.ImportDerivativeCode
														AND IH.ProgrammeId				= DMAP.ProgrammeId
														AND IH.Gateway					= DMAP.Gateway
	LEFT JOIN OXO_Programme_Body			AS B		ON	DMAP.BodyId					= B.Id												
	LEFT JOIN OXO_Programme_Engine			AS E		ON	DMAP.EngineId				= E.Id												
	LEFT JOIN OXO_Programme_Transmission	AS TM		ON	DMAP.TransmissionId			= TM.Id
														
	-- Mapping of trim details	
																										
	LEFT JOIN Fdp_TrimMapping_VW			AS TMAP		ON	I.[Trim Pack Description]	= TMAP.ImportTrim
														AND IH.ProgrammeId				= TMAP.ProgrammeId
														AND IH.Gateway					= TMAP.Gateway
	LEFT JOIN OXO_Programme_Trim			AS T		ON	TMAP.TrimId					= T.Id
																
	-- Mapping of features		
													
	LEFT JOIN Fdp_FeatureMapping_VW			AS FMAP		ON	I.[Bff Feature Code]		= FMAP.ImportFeatureCode
														AND IH.ProgrammeId				= FMAP.ProgrammeId
														AND IH.Gateway					= FMAP.Gateway
	LEFT JOIN Fdp_SpecialFeature			AS SF		ON	I.[Bff Feature Code]		= SF.FeatureCode
														AND IH.ProgrammeId				= SF.ProgrammeId
														AND IH.Gateway					= SF.Gateway
														AND SF.IsActive					= 1
	LEFT JOIN Fdp_SpecialFeatureType		AS SFT		ON	SF.FdpSpecialFeatureTypeId	= SFT.FdpSpecialFeatureTypeId
	LEFT JOIN OXO_Feature_Ext				AS FE		ON	FMAP.FeatureId				= FE.Id
	LEFT JOIN OXO_Feature_Brand_Desc		AS FB		ON	FE.Feat_Code				= FB.Feat_Code
														AND P.VehicleMake				= FB.Brand
	LEFT JOIN OXO_Feature_Group				AS FG		ON	FE.OXO_Grp					= FG.Id
	LEFT JOIN OXO_Pack_Feature_Link			AS FL		ON	P.Id						= FL.Programme_Id
														AND FE.Id						= FL.Feature_Id
	LEFT JOIN OXO_Programme_Pack			AS FP		ON	FL.Pack_Id					= FP.Id
														
	-- The combination of body, engine, transmission and trim gives us the model
	LEFT JOIN OXO_Programme_Model			AS M		ON	P.Id						= M.Programme_Id
														AND B.Id						= M.Body_Id
														AND E.Id						= M.Engine_Id
														AND TM.Id						= M.Transmission_Id
														AND T.Id						= M.Trim_Id
	-- The combination of body, engine and transmission gives us the derivative
	LEFT JOIN Fdp_Derivative_VW				AS DER		ON	IH.ProgrammeId				= DER.ProgrammeId
														AND B.Id						= DER.BodyId
														AND E.Id						= DER.EngineId
														AND TM.Id						= DER.TransmissionId
	
	LEFT JOIN Fdp_VolumeHeader				AS CUR1		ON	P.Id						= CUR1.ProgrammeId
														AND IH.Gateway					= CUR1.Gateway
	LEFT JOIN Fdp_VolumeDataItem			AS CUR		ON	CUR1.FdpVolumeHeaderId		= CUR.FdpVolumeHeaderId
														AND MMAP.Market_Id				= CUR.MarketId
														AND M.Id						= CUR.ModelId
														AND T.Id						= CUR.TrimId
														AND	FE.Id						= CUR.FeatureId
														AND CAST(I.[Count of Specific Order No] AS INT)
																						= CUR.Volume



