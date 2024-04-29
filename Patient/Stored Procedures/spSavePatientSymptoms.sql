
CREATE PROCEDURE [Patient].[spSavePatientSymptoms]
	   @AppointmentGuid  uniqueidentifier=null
	  ,@PatientGuid uniqueidentifier=null
	  ,@SymptomName varchar(200)
	  ,@SeverityLevel varchar(200)
	  ,@Description varchar(200)

 AS
 
/*
select * from [mapping].[PatientSymptoms] order by 1 desc 
exec [Patient].[spSavePatientSymptoms]
      @AppointmentGuid = 'c8a007e2-1a6a-4c1e-955c-84ff3c072483',
	  @PatientGuid ='f71601f7-dc70-4f1f-8166-c8a487a77171',
      @SymptomName ='Chills/Night sweats',
	  @SeverityLevel='Moderate',
	  @Description='High'

select * from mapping.PatientSymptoms order by 1 desc

 Date					Author				Description          
 -----------------------------------------------------------------------------
27/04/2023			M Chandrani	           Save Patient symptoms related information
 ------------------------------------------------------------------------------      
                Copyright 2023@YodaLIMS
*/ 

BEGIN
SET NOCOUNT ON
/*Declaration */

DECLARE @AppointmentId INT,@PatientId INT,@Id INT

IF @AppointmentGuid IS NOT NULL
	BEGIN
	SELECT @AppointmentId=id,@PatientId=PatientId from [Patient].[Appointment] WITH(NOLOCK,READUNCOMMITTED) WHERE IsDeleted=0 and guid=@AppointmentGuid
	END
ELSE
    BEGIN
	SELECT @PatientId=Id from [Patient].[Patient] WITH(NOLOCK,READUNCOMMITTED) WHERE IsDeleted=0 and guid=@PatientGuid
	END

SELECT @Id=Id from [mapping].[PatientSymptoms] WITH(NOLOCK,READUNCOMMITTED) WHERE IsDeleted=0 and Symptoms=@SymptomName and AppointmentId=@AppointmentId


/*Main Query */

    
  MERGE [mapping].[PatientSymptoms] AS trg 
  Using (
          select
		          @Id as Id
                 ,@PatientId as PatientId
                 ,@AppointmentId as AppointmentId
                 ,@SymptomName as SymptomName
				 ,@SeverityLevel as SeverityLevel
				 ,@Description as Description

		     ) as src
		   ON  
		        trg.Id=@Id

		  WHEN MATCHED THEN
		  UPDATE 
		  SET		
			    SeverityLevel = src.SeverityLevel
			   ,Description = src.Description
		  WHEN NOT MATCHED THEN
		        INSERT
			         (  
					   PatientId
					  ,AppointmentId
					  ,Symptoms
					  ,SeverityLevel
					  ,Description
				     )
			   values(
					   @PatientId
					  ,@AppointmentId
					  ,@SymptomName
					  ,@SeverityLevel
					  ,@Description
			        );

SET NOCOUNT OFF
END




  



