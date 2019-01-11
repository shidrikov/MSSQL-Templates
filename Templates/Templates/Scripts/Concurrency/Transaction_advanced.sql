
/*
	Advanced implementation of transaction in stored procedure
*/

CREATE PROCEDURE [dbo].[Transaction_Advanced]
	@Debug BIT = 0
AS
BEGIN

SET NOCOUNT ON;

IF @Debug = 1 PRINT CONCAT(SYSDATETIME(), ' Start [dbo].[Transaction_Advanced]')


/* Your code here... */


IF @Debug = 1 PRINT CONCAT(SYSDATETIME(), ' Start transaction') --Start transaction, being careful to check if we are nested
DECLARE @TranCount INT;
SET @TranCount = @@TRANCOUNT;
IF @TranCount > 0 SAVE TRANSACTION MyTran;
ELSE BEGIN TRANSACTION;
  
BEGIN TRY
	
	IF @Debug = 1 PRINT CONCAT(SYSDATETIME(), ' Start TRY block') 


	/* Your code here... */


	IF @Debug = 1 PRINT CONCAT(SYSDATETIME(), ' Commit only if not nested')
	IF @TranCount = 0 COMMIT TRANSACTION; -- Commit only if we are not nested

	IF @Debug = 1 PRINT CONCAT(SYSDATETIME(), ' End [dbo].[Transaction_Advanced]')
	RETURN 0;
  
END TRY
BEGIN CATCH
    
	SET NOCOUNT OFF;
  
    -- Get error info  
    DECLARE  
        @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE(),
        @ErrorSeverity INT = ERROR_SEVERITY(),
        @ErrorState INT = ERROR_STATE(),
        @ErrorNumber INT = ERROR_NUMBER(),
        @ErrorLine INT = ERROR_LINE(),
        @ErrorProcedure NVARCHAR(126) = ERROR_PROCEDURE();
  
    SET @ErrorMessage = CONCAT(@ErrorMessage, N', @ErrorNumber = ', @ErrorNumber, N', @ErrorProcedure = "', @ErrorProcedure, N'", line ', @ErrorLine);


	/* We can insert a custom log entry here... */


    IF @TranCount = 0 ROLLBACK TRANSACTION;
    ELSE IF XACT_STATE() <> -1 ROLLBACK TRANSACTION MyTran;
  
    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    IF @Debug = 1 PRINT CONCAT(SYSDATETIME(), ' End [dbo].[Transaction_Advanced]')
    RETURN 1;

END CATCH

SET NOCOUNT OFF;

END;