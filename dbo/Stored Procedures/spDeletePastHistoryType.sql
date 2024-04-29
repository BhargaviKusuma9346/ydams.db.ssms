
CREATE PROCEDURE [dbo].[spDeletePastHistoryType]
	 @PastHistoryTypeGuid  uniqueidentifier=null
 AS
 
/*
select * from [Lookup].[PastHistoryType] order by 1 desc

exec [dbo].[spDeletePastHistoryType]
     @PastHistoryTypeGuid= null

 Date					Author				Description          
 -----------------------------------------------------------------------------
 20/06/2023			M Chandrani	           Delete Past History type related information
 ------------------------------------------------------------------------------      
                Copyright 2023@YodaLIMS
*/ 

BEGIN
SET NOCOUNT ON

/*Main Query */ 
	
UPDATE
    [Lookup].[PastHistoryType]
SET 
    IsDeleted=1
WHERE
    guid=@PastHistoryTypeGuid

SET NOCOUNT OFF
END




  



