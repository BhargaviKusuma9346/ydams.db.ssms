
CREATE PROCEDURE [dbo].[spSavePastHistoryType]
	 @PastHistoryTypeGuid  uniqueidentifier=null
    ,@PastHistoryFieldName varchar(200)
	,@Description varchar(200)
 AS
 
/*
select * from [Lookup].[PastHistoryType] order by 1 desc

exec [dbo].[spSavePastHistoryType]
     @PastHistoryTypeGuid= null
    ,@PastHistoryFieldName='Eyes infection'
	,@Description='Eyes infection'

 Date					Author				Description          
 -----------------------------------------------------------------------------
 20/06/2023			M Chandrani	           Save Past History type related information
 ------------------------------------------------------------------------------      
                Copyright 2023@YodaLIMS
*/ 

BEGIN
SET NOCOUNT ON
/*Declaration */

DECLARE @PastHistoryFieldGuid nvarchar(max)
DECLARE @Id INT 
SELECT @Id=id from [Lookup].[PastHistoryType] WITH(NOLOCK,READUNCOMMITTED) WHERE IsDeleted=0 and guid=@PastHistoryTypeGuid

/*Main Query */ 
	
  MERGE [Lookup].[PastHistoryType] AS trg 
  Using (
          select
                  @Id as Id
                 ,@PastHistoryFieldName as PastHistoryFieldName
	             ,@Description as Description
		) as src
		   ON  
		         (trg.PastHistoryFieldName=@PastHistoryFieldName or trg.Id=@Id)

		  WHEN MATCHED THEN
		  UPDATE 
		  SET				        
                  PastHistoryFieldName=src.PastHistoryFieldName,
				  Description=src.Description

			WHEN NOT MATCHED THEN
		    INSERT
			     (  
		           PastHistoryFieldName,
				   Description
				  )
			values(
			        @PastHistoryFieldName,
				    @Description
			      );


DECLARE @PastHistoryFieldId INT 
 SET @PastHistoryFieldId=SCOPE_IDENTITY()

 SELECT @PastHistoryFieldGuid =  Guid  from   [Lookup].[PastHistoryType] where IsDeleted=0

 SELECT  @PastHistoryFieldGuid as PastHistoryFieldGuid


SET NOCOUNT OFF
END




  



