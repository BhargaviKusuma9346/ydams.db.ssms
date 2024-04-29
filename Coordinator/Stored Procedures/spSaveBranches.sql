CREATE PROCEDURE [Coordinator].[spSaveBranches]
	 @BranchGuid  uniqueidentifier=null
    ,@BranchName varchar(200)
    ,@Address varchar(200)
	,@City varchar(200)
	,@State varchar(200)
	,@Latitude varchar(max)=NULL
	,@Longitude varchar(max)=NULL
	,@ContactPerson varchar(200)
	,@ContactPhone varchar(200)
	,@ContactEmail varchar(200)
 AS
 
/*
select * from [Lookup].[Branch] order by 1 desc

exec [Coordinator].[spSaveBranches] 
     @BranchGuid = null
    ,@BranchName = 'Yoda Diagnotics'
    ,@Address = 'Medak'
	,@City = 'Medak'
	,@State='Telangana'
	,@Latitude = '17.437462'
	,@Longitude = '78.448288'
	,@ContactPerson='abc'
	,@ContactPhone='1234567890'
	,@ContactEmail='abc@gmail.com'
     

 Date					Author				Description          
 -----------------------------------------------------------------------------
02/05/2023			M Chandrani	           Save Coordinator Branch related information
 ------------------------------------------------------------------------------      
                Copyright 2023@YodaLIMS
*/ 

BEGIN
SET NOCOUNT ON
/*Declaration */

DECLARE @mylocation varchar(200) = iif(@Longitude is not null and @Latitude is not null or @Longitude='','POINT(' + CAST( @Longitude AS VARCHAR(20)) + ' ' + CAST(@Latitude AS VARCHAR(20)) + ')','POINT(0 0)') ;
DECLARE @BranchLocation geography = geography::STPointFromText(@mylocation, 4326);

DECLARE @Id INT,@OldBranchName varchar(200)
SELECT @Id=id,@OldBranchName=BranchName from [Lookup].[Branch] WITH(NOLOCK,READUNCOMMITTED) WHERE IsDeleted=0 AND Guid=@BranchGuid

/*Main Query */ 
	
  MERGE [Lookup].[Branch] AS trg 
  Using (
          select
                  @Id as Id
                 ,@BranchName as BranchName
                 ,@Address as Address
				 ,@City as City
				 ,@State as State
	             ,@Latitude as Latitude
	             ,@Longitude as Longitude
	             ,@ContactPerson as ContactPerson
	             ,@ContactPhone as ContactPhone
	             ,@ContactEmail as ContactEmail            
		) as src
		   ON  
		        trg.Id =@Id

		  WHEN MATCHED THEN
		  UPDATE 
		  SET		
		          BranchName=src.BranchName
				 ,Address= src.Address
				 ,City = src.City
				 ,State = src.State
	             ,Latitude = src.Latitude
	             ,Longitude = src.Longitude
				 ,ContactName = src.ContactPerson 
	             ,ContactPhone =src.ContactPhone
				 ,ContactEmail = src.ContactEmail
				 ,location_cords = @BranchLocation

			WHEN NOT MATCHED THEN
		    INSERT
			     (  
		          BranchName
				 ,Address
				 ,City
				 ,State
	             ,Latitude
				 ,Longitude
				 ,ContactName
	             ,ContactPhone
				 ,ContactEmail
				 ,location_cords
				  )
			values(
			      @BranchName
                 ,@Address
				 ,@City
				 ,@State
				 ,@Latitude
	             ,@Longitude
				 ,@ContactPerson
				 ,@ContactPhone
				 ,@ContactEmail
				 ,@BranchLocation
			);

If @BranchGuid is not null 
Begin
UPDATE Coordinator.Coordinator
SET branches = REPLACE(branches, @OldBranchName, @BranchName)
End


SET NOCOUNT OFF
END
GO

