
/*
	Simple implementation of transaction
*/

CREATE PROCEDURE [dbo].[Transaction_Simple]
AS  
BEGIN  

-- Your code here...

BEGIN TRANSACTION;
  
BEGIN TRY  

	-- Your code here...

	COMMIT TRANSACTION; -- Commit only if we are not nested  

	RETURN 0;  
  
END TRY  
BEGIN CATCH  
  
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;  
	
	THROW;

END CATCH  

END;