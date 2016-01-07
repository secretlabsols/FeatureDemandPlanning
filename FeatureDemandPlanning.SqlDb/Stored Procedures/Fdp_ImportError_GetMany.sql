﻿CREATE PROCEDURE [dbo].[Fdp_ImportError_GetMany]

	  @FdpImportQueueId		INT
	, @FdpImportExceptionTypeId INT				= NULL
	, @FilterMessage		NVARCHAR(50)	= NULL
	, @PageIndex			INT				= NULL
	, @PageSize				INT				= NULL
	, @SortIndex			INT				= 0
	, @SortDirection		VARCHAR(5)		= 'DESC'
	, @TotalPages			INT OUTPUT
	, @TotalRecords			INT OUTPUT
	, @TotalDisplayRecords  INT OUTPUT
	, @TotalImportedRecords INT OUTPUT
	, @TotalFailedRecords	INT OUTPUT
AS
	SET NOCOUNT ON;
	
	IF @PageIndex IS NULL 
		SET @PageIndex = 1;
	
	DECLARE @MinIndex AS INT;
	DECLARE @MaxIndex AS INT;
	DECLARE @PageRecords AS TABLE
	(
		  RowIndex INT IDENTITY(1,1)
		, FdpImportErrorId INT
		, LineNumber INT
	);
	INSERT INTO @PageRecords 
	(
		  E.FdpImportErrorId
		, E.LineNumber
	)
	SELECT
		  E.FdpImportErrorId
		, E.LineNumber
		
	FROM Fdp_ImportError_VW AS E
	WHERE
	E.FdpImportQueueId = @FdpImportQueueId
	AND
	E.IsExcluded = 0
	AND
	(@FdpImportExceptionTypeId IS NULL OR E.FdpImportErrorTypeId = @FdpImportExceptionTypeId)
	AND
	(ISNULL(@FilterMessage, '') = '' 
		OR E.ErrorMessage LIKE '%' + @FilterMessage + '%' 
		OR E.[Type] LIKE '%' + @FilterMessage + '%')
	--ORDER BY
	--	--CASE @SortDirection
	--	--	WHEN 'ASC' THEN
	--			CASE ISNULL(@SortIndex, 0)
	--				WHEN 0 THEN LineNumber
	--				WHEN 1 THEN 0
	--				WHEN 2 THEN 0
	--				WHEN 3 THEN 0
	--				ELSE LineNumber
	--			END,
	--			CASE ISNULL(@SortIndex, 0)
	--				WHEN 0 THEN ''
	--				WHEN 1 THEN [Type]
	--				WHEN 2 THEN ErrorMessage
	--				WHEN 3 THEN ''
	--				ELSE ''
	--			END,
	--			CASE ISNULL(@SortIndex, 0)
	--				WHEN 0 THEN 0
	--				WHEN 1 THEN 0
	--				WHEN 2 THEN 0
	--				WHEN 3 THEN ErrorOn
	--				ELSE ErrorOn
	--			END
		--END ASC,
		--CASE @SortDirection
		--	WHEN 'DESC' THEN
		--		CASE ISNULL(@SortIndex, 0)
		--			WHEN 0 THEN LineNumber
		--			WHEN 1 THEN [Type]
		--			WHEN 2 THEN ErrorMessage
		--			WHEN 3 THEN CONVERT(VARCHAR(20), ErrorOn, 20)
		--		END	
		--END DESC;
	
	SELECT @TotalRecords = COUNT(1) FROM @PageRecords;
	
	IF ISNULL(@PageSize, 0) = 0
		SET @PageSize = @TotalRecords;
	
	SET @TotalPages = CEILING(@TotalRecords / CAST(@PageSize AS DECIMAL));
	SET @MinIndex = ((@PageIndex - 1) * @PageSize) + 1;
	SET @MaxIndex = @MinIndex + (@PageSize - 1);
	
	SELECT @TotalDisplayRecords = COUNT(1) FROM @PageRecords WHERE RowIndex BETWEEN @MinIndex AND @MaxIndex;
	SET @TotalFailedRecords = 0; -- This is now handled by the summary stored proc
	SET @TotalImportedRecords = 0; -- This is now handled by the summary stored proc
	
	SELECT 
		  E.FdpImportErrorId
		, E.FdpImportId
		, E.FdpImportQueueId AS ImportQueueId
		, E.ProgrammeId
		, E.Gateway
		, E.DocumentId
		, E.FdpImportErrorId
		, RIGHT('0000000000' + CAST(E.LineNumber AS VARCHAR(10)), 10) AS LineNumber
		, E.FdpImportErrorTypeId
		, E.[Type] AS ErrorTypeDescription
		, E.ErrorMessage
		, E.ErrorOn 
		, E.IsExcluded
		, E.ImportMarket
		, E.ImportDerivativeCode
		, E.ImportDerivative
		, E.ImportTrim
		, E.ImportFeatureCode
		, E.ImportFeature
		
	FROM @PageRecords		AS P
	JOIN Fdp_ImportError_VW AS E	ON	P.FdpImportErrorId = E.FdpImportErrorId
									AND P.RowIndex BETWEEN @MinIndex AND @MaxIndex
	ORDER BY
	P.RowIndex;
	
