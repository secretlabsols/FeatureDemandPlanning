﻿CREATE PROCEDURE [dbo].[Fdp_MarketGroup_GetMany]
  @DocumentId int,	
  @CDSId NVARCHAR(16)
AS
	SET NOCOUNT ON;
	
	DECLARE @ProgrammeId AS INT;
	
	SELECT TOP 1 @ProgrammeId = Programme_Id
	FROM OXO_Doc 
	WHERE Id = @DocumentId;
	
		WITH models AS
		(
			SELECT COUNT(Distinct OD.Model_Id) VariantCount,  
				   OD.Market_Group_Id
			FROM OXO_Item_Data_MBM OD WITH(NOLOCK)
			INNER JOIN OXO_Programme_Model V WITH(NOLOCK)
			ON V.Id = OD.Model_Id
			AND V.Active = 1 
			AND V.Programme_Id = @ProgrammeId
			WHERE 
			OD.OXO_Doc_Id = @DocumentId
			AND OD.OXO_Code = 'Y'
			AND OD.Active = 1
			GROUP BY OD.Market_Group_Id
		), marketGroups AS
		(
			SELECT Distinct 'Programme' AS Type,
			Market_Group_Id  AS Id,
			Programme_Id AS ProgrammeId,
			Market_Group_Name AS GroupName,
			Display_Order
			FROM OXO_Programme_MarketGroupMarket_VW
			WHERE Programme_Id = @ProgrammeId
		)		
		SELECT G.Type, G.Id, G.ProgrammeId, G.GroupName, G.Display_Order, ISNULL(M.VariantCount,0) AS VariantCount
		FROM marketGroups G
		LEFT OUTER JOIN models M
		ON G.Id = M.Market_Group_Id
		ORDER BY Display_Order;
	    		    
		
			WITH models AS
			(
				SELECT COUNT(Distinct OD.Model_Id) VariantCount,  
					   OD.Market_Id
				FROM OXO_Item_Data_MBM OD WITH(NOLOCK)
				INNER JOIN OXO_Programme_Model V WITH(NOLOCK)
				ON V.Id = OD.Model_Id
				AND V.Active = 1 
				AND V.Programme_Id = @ProgrammeId
				WHERE OD.OXO_Doc_Id = @DocumentId
				AND OD.OXO_Code = 'Y'
				AND OD.Active = 1
				GROUP BY OD.Market_Id
			)
			, AvailableMarkets AS
			(
				SELECT U.FdpUserId, M.MarketId
				FROM
				Fdp_User AS U
				JOIN Fdp_UserMarketMapping AS M ON U.FdpUserId = M.FdpUserId
												AND M.IsActive = 1
				WHERE
				U.CDSId = @CDSId
				GROUP BY
				U.FdpUserId, M.MarketId
			)
			, markets AS
			(
				SELECT Distinct 
					M.Market_Id AS Id,
					M.Market_Name AS Name,
					M.WHD AS WHD,
					M.PAR AS PAR_X,
					M.PAR AS PAR_L,
					M.Market_Group_Id AS ParentId,
					M.SubRegion AS SubRegion,
					M.SubRegionOrder
				FROM OXO_Programme_MarketGroupMarket_VW AS M WITH(NOLOCK)
				JOIN AvailableMarkets AS SEC ON M.Market_Id = SEC.MarketId
				WHERE Programme_Id = @ProgrammeId
			)
			SELECT MK.Id, MK.Name, MK.WHD AS WHD,
				   MK.PAR_X, MK.PAR_L, MK.ParentId,
				   MK.SubRegion, MK.SubRegionOrder,
				   ISNULL(M.VariantCount,0) AS VariantCount  
			FROM markets MK
			LEFT OUTER JOIN models M
			ON MK.Id = M.Market_Id
			ORDER BY ParentId, SubRegionOrder, SubRegion, Name;