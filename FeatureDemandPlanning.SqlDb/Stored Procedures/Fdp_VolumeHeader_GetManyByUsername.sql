﻿CREATE PROCEDURE [dbo].[Fdp_VolumeHeader_GetManyByUsername]
	  @TakeRateId			INT				= NULL
	, @FdpTakeRateStatusId	INT				= NULL
	, @VehicleName			NVARCHAR(1000)	= NULL
	, @ModelYear			NVARCHAR(100)	= NULL
	, @Gateway				NVARCHAR(50)	= NULL
	, @FilterMessage		NVARCHAR(50)	= NULL
	-- TODO - Implement permissions over which take rate files can be viewed
	, @CDSId				NVARCHAR(16)	= NULL
	, @PageIndex			INT				= NULL
	, @PageSize				INT				= NULL
	, @SortIndex			INT				= 0
	, @SortDirection		VARCHAR(5)		= 'DESC'
	, @TotalPages			INT OUTPUT
	, @TotalRecords			INT OUTPUT
	, @TotalDisplayRecords  INT OUTPUT
AS
	SET NOCOUNT ON;
	
	IF @PageIndex IS NULL 
		SET @PageIndex = 1;
	
	DECLARE @MinIndex AS INT;
	DECLARE @MaxIndex AS INT;
	DECLARE @PageRecords AS TABLE
	(
		  RowIndex	INT IDENTITY(1,1)
		, TakeRateId INT
	);
	INSERT INTO @PageRecords 
	(
		TakeRateId
	)
	SELECT V.FdpVolumeHeaderId
	FROM Fdp_VolumeHeader		AS V
	JOIN Fdp_OxoDoc				AS D	ON V.FdpVolumeHeaderId	= D.FdpVolumeHeaderId
	JOIN OXO_Programme_VW		AS P	ON V.ProgrammeId		= P.Id
	WHERE
	(ISNULL(@FilterMessage, '') = '' 
		OR P.VehicleName LIKE '%' + @FilterMessage + '%'
		OR P.VehicleAKA LIKE '%' + @FilterMessage + '%'
		OR P.ModelYear LIKE '%' + @FilterMessage + '%')
	AND
	(@TakeRateId IS NULL OR V.FdpVolumeHeaderId = @TakeRateId)
	AND
	(@FdpTakeRateStatusId IS NULL OR V.FdpTakeRateStatusId = @FdpTakeRateStatusId)
	ORDER BY	
		CASE @SortDirection
		WHEN 'ASC' THEN
			CASE ISNULL(@SortIndex, 0)
				-- First sort looks a little odd, as it's a different type to the rest of the dynamic sort
				-- columns, we get a conversion error. The padding is so sorting a number as a string will
				-- work correctly
				WHEN 0 THEN RIGHT('000000' + CAST(V.FdpVolumeHeaderId AS NVARCHAR(10)), 6)
				WHEN 1 THEN V.CreatedBy
				WHEN 2 THEN P.VehicleName
				WHEN 3 THEN P.VehicleAKA
				WHEN 4 THEN P.ModelYear
				WHEN 5 THEN V.Gateway
			END
		END ASC,
		CASE @SortDirection
		WHEN 'DESC' THEN
			CASE ISNULL(@SortIndex, 0)
				WHEN 0 THEN RIGHT('000000' + CAST(V.FdpVolumeHeaderId AS NVARCHAR(10)), 6)
				WHEN 1 THEN V.CreatedBy
				WHEN 2 THEN P.VehicleName
				WHEN 3 THEN P.VehicleAKA
				WHEN 4 THEN P.ModelYear
				WHEN 5 THEN V.Gateway
			END	
		END DESC
	
	SELECT @TotalRecords = COUNT(1) FROM @PageRecords;

	IF ISNULL(@PageSize, 0) = 0
		SET @PageSize = @TotalRecords;
	
	SET @TotalPages = CEILING(@TotalRecords / CAST(@PageSize AS DECIMAL));
	SET @MinIndex = ((@PageIndex - 1) * @PageSize) + 1;
	SET @MaxIndex = @MinIndex + (@PageSize - 1);
	
	SELECT @TotalDisplayRecords = COUNT(1) FROM @PageRecords WHERE RowIndex BETWEEN @MinIndex AND @MaxIndex;

	SELECT DISTINCT
		  V.FdpVolumeHeaderId	AS TakeRateId
		, V.CreatedOn
		, V.CreatedBy
		, V.UpdatedOn
		, V.UpdatedBy
		, O.Id AS OxoDocId
		, P.VehicleName + 
			' '  + P.VehicleAKA +
			' '  + P.ModelYear +
			' '  + O.Gateway +
			' v' + CAST(O.Version_Id AS NVARCHAR(10)) +
			' '  + O.[Status]
			AS OxoDocument
		, S.FdpTakeRateStatusId
		, S.[Status]
		, S.[Description] AS StatusDescription
		
	FROM @PageRecords			AS PA
	JOIN Fdp_VolumeHeader		AS V	ON	PA.TakeRateId			= V.FdpVolumeHeaderId
										AND PA.RowIndex BETWEEN @MinIndex AND @MaxIndex
	JOIN Fdp_TakeRateStatus		AS S	ON	V.FdpTakeRateStatusId	= S.FdpTakeRateStatusId
	JOIN Fdp_OxoDoc				AS D	ON	V.FdpVolumeHeaderId		= D.FdpVolumeHeaderId
	JOIN OXO_Doc				AS O	ON	D.OXODocId				= O.Id
	JOIN OXO_Programme_VW		AS P	ON	V.ProgrammeId			= P.Id
	LEFT JOIN Fdp_Import		AS I1	ON	V.FdpImportId			= I1.FdpImportId
	LEFT JOIN Fdp_ImportQueue_VW	AS I	ON	I1.FdpImportQueueId		= I.FdpImportQueueId