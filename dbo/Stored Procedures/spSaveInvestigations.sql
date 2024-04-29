
CREATE PROCEDURE [dbo].[spSaveInvestigations]
	 @InvestigationGuid  uniqueidentifier=null
	,@TestCode varchar(200)
    ,@TestName varchar(200)
	,@TestCategory varchar(200)
	,@SpecimenType varchar(200)
	,@SpecimenVolume varchar(200)
	,@Instructions varchar(500)
	,@UserGuid uniqueidentifier=null
 AS
 
/*
select * from [Lookup].[Investigations] order by 1 desc

exec [dbo].[spSaveInvestigations]
     @InvestigationGuid=null
	,@TestCode=''
    ,@TestName='Test'
	,@TestCategory='Regular'
	,@SpecimenType='Serum'
	,@SpecimenVolume='2 mL'
	,@Instructions='abc'
	,@UserGuid='8B7EA0D2-92CA-4AAC-931C-3F256DA23E37'



 Date					Author				Description          
 -----------------------------------------------------------------------------
02/05/2023			M Chandrani	           Save Investigations related information
 ------------------------------------------------------------------------------      
                Copyright 2023@YodaLIMS
*/ 

BEGIN
SET NOCOUNT ON
/*Declaration */

DECLARE @ModifiedName varchar(100)
DECLARE @ModifiedDt datetime
DECLARE @ModifiedBy INT

DECLARE @CreatedByUserId INT,@FirstName varchar(100)
SELECT @CreatedByUserId=UserId,@FirstName=FirstName from dbo.Users where UserGuid=@UserGuid

DECLARE @Id INT 
SELECT @Id=id from [Lookup].[Investigations] WITH(NOLOCK,READUNCOMMITTED) WHERE IsDeleted=0 and guid=@InvestigationGuid

/*Main Query */ 
	
  MERGE [Lookup].[Investigations] AS trg 
  Using (
          select
                  @Id as Id
                 ,@TestName as TestName
				 ,@TestCategory as TestCategory 
				 ,@SpecimenType as SpecimenType
	             ,@SpecimenVolume as SpecimenVolume
	             ,@Instructions as Instructions  
				 ,@ModifiedName as ModifiedName
				 ,@ModifiedDt as ModifiedDt
				 ,@ModifiedBy as ModifiedBy
		) as src
		   ON  
		        trg.Id=@Id

		  WHEN MATCHED THEN
		  UPDATE 
		  SET				        
                  TestName=src.TestName
				 ,TestCategory = src.TestCategory
				 ,SpecimenType = src.SpecimenType 
	             ,SpecimenVolume = src.SpecimenVolume
	             ,Instructions  = src.Instructions
				 ,ModifiedName=@FirstName
				 ,ModifiedDt=getDate()
				 ,ModifiedBy=@CreatedByUserId

			WHEN NOT MATCHED THEN
		    INSERT
			     (  
		          TestCode
                 ,TestName
				 ,TestCategory
				 ,SpecimenType
	             ,SpecimenVolume
	             ,Instructions
				 ,CreatedByUserId
				 ,CreatedByName
				  )
			values(
			      @TestCode 
                 ,@TestName
				 ,@TestCategory
				 ,@SpecimenType
				 ,@SpecimenVolume
	             ,@Instructions
				 ,@CreatedByUserId
				 ,@FirstName
			);

SET NOCOUNT OFF
END




  



