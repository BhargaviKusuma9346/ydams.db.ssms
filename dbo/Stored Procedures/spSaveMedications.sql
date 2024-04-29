
CREATE PROCEDURE [dbo].[spSaveMedications]
	 @MedicationGuid  uniqueidentifier=null
	,@MedicationCode varchar(200)
    ,@MedicationName varchar(200)
	,@MedicationClass varchar(200)
	,@Dosage varchar(200)
	,@Type varchar(200)
	,@Manufacturer varchar(200)
	,@Usage varchar(200)
	,@UserGuid uniqueidentifier=null
 AS
 
/*
select * from [Lookup].[Medications] order by 1 desc

exec [dbo].[spSaveMedications]
     @MedicationGuid=null
	,@MedicationCode='CIP200'
    ,@MedicationName='Cipla'
	,@MedicationClass='Immunosuppressant'
	,@Dosage='250 mg'
	,@Type='Bristol-Myers Squibb'
	,@Manufacturer='Fasting required. Collect in SST tube'
	,@Usage='Organ transplantation'
	,@UserGuid='8B7EA0D2-92CA-4AAC-931C-3F256DA23E37'

 Date					Author				Description          
 -----------------------------------------------------------------------------
02/05/2023			M Chandrani	           Save Medications related information
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
SELECT @Id=id from [Lookup].[Medications] WITH(NOLOCK,READUNCOMMITTED) WHERE IsDeleted=0 and guid=@MedicationGuid

/*Main Query */ 
	
  MERGE [Lookup].[Medications] AS trg 
  Using (
          select
                  @Id as Id
                 ,@MedicationName as MedicationName
				 ,@MedicationClass as MedicationClass
				 ,@Dosage as Dosage
	             ,@Type as Type
	             ,@Manufacturer as Manufacturer 
				 ,@Usage as Usage
				 ,@ModifiedName as ModifiedName
				 ,@ModifiedDt as ModifiedDt
				 ,@ModifiedBy as ModifiedBy
		) as src
		   ON  
		         trg.Id=@Id

		  WHEN MATCHED THEN
		  UPDATE 
		  SET				        
                  MedicationName=src.MedicationName
				 ,MedicationClass = src.MedicationClass
				 ,Dosage = src.Dosage
	             ,Type= src.Type
	             ,Manufacturer  = src.Manufacturer
				 ,Usage=src.Usage
				 ,ModifiedName=@FirstName
				 ,ModifiedDt=getDate()
				 ,ModifiedBy=@CreatedByUserId

			WHEN NOT MATCHED THEN
		    INSERT
			     (  
		          MedicationCode
                 ,MedicationName
				 ,MedicationClass
				 ,Dosage
	             ,Type
	             ,Manufacturer
				 ,Usage
				 ,CreatedByUserId
				 ,CreatedByName
				  )
			values(
			      @MedicationCode
                 ,@MedicationName
				 ,@MedicationClass
				 ,@Dosage
				 ,@Type
	             ,@Manufacturer
				 ,@Usage
				 ,@CreatedByUserId
				 ,@FirstName
			);

SET NOCOUNT OFF
END




  



