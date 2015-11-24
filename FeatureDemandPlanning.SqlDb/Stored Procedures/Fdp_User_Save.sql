﻿CREATE PROCEDURE [dbo].[Fdp_User_Save]
	  @CDSId		NVARCHAR(16)
	, @FullName		NVARCHAR(50)
	, @IsAdmin		BIT = 0
	, @CreatorCDSID NVARCHAR(16)
AS
	SET NOCOUNT ON;
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM Fdp_User WHERE CDSId = @CDSId)
		INSERT INTO Fdp_User
		(
			  CDSId
			, FullName
			, IsAdmin
			, CreatedBy
		)
		VALUES
		(
			  @CDSId
			, @FullName
			, @IsAdmin
			, @CreatorCDSID
		)
	
	EXEC Fdp_User_Get @CDSId = @CDSId;