USE [profiles_100810]
GO
/****** Object:  StoredProcedure [dbo].[usp_LoadDataFromCLS]    Script Date: 08/18/2010 16:14:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_LoadDataFromCLS]	

AS
BEGIN
	SET NOCOUNT ON;	

	DECLARE @ErrMsg nvarchar(4000), @ErrSeverity int
	DECLARE @date DATETIME,@auditid UNIQUEIDENTIFIER, @rows int
	SELECT @date=GETDATE() 
												
	-- Start Transaction. Log load failures, roll back transaction on error.
	BEGIN TRY
		BEGIN TRAN				 
			TRUNCATE TABLE _person
			TRUNCATE TABLE _person_affiliations
			TRUNCATE TABLE _person_filter_flags

			INSERT _person select * from cls.dbo.vw_person
			INSERT _person_affiliations select * from cls.dbo.vw_person_affiliations
			INSERT _person_affiliations select * from cls.dbo.vw_person_secondary_affiliations
			INSERT _person_filter_flags select * from cls.dbo.vw_person_filter_flags

		COMMIT
	END TRY
	BEGIN CATCH
			--Check success
			IF @@TRANCOUNT > 0  ROLLBACK

			-- Raise an error with the details of the exception
			SELECT @ErrMsg = '[usp_LoadDataFromCLS] Failed with : ' + ERROR_MESSAGE(),
						 @ErrSeverity = ERROR_SEVERITY()

			RAISERROR(@ErrMsg, @ErrSeverity, 1)
	END CATCH	
				
	END
