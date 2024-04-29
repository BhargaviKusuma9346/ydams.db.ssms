
CREATE PROCEDURE [Patient].[spSavePatientPhysicalExaminations]
	   @AppointmentGuid  uniqueidentifier=null
	  ,@PatientGuid uniqueidentifier=null
	  ,@PhysicalExaminationName varchar(200)
 AS
 
/*
select * from [mapping].[PatientPhysicalExaminations]
exec [Patient].[spSavePatientPhysicalExaminations]
      @AppointmentGuid = '4B59F148-6726-440D-84B3-B593B41AC972',
      @PhysicalExaminationName ='Cyanosis'

 Date					Author				Description          
 -----------------------------------------------------------------------------
27/04/2023			M Chandrani	           Save Patient PhysicalExamination related information
 ------------------------------------------------------------------------------      
                Copyright 2023@YodaLIMS
*/ 

BEGIN
SET NOCOUNT ON
/*Declaration */

DECLARE @AppointmentId INT, @PatientId INT,@Id INT

IF @AppointmentGuid IS NOT NULL
	BEGIN
		SELECT @AppointmentId = id, @PatientId = PatientId FROM [Patient].[Appointment] WITH (NOLOCK, READUNCOMMITTED) WHERE IsDeleted = 0 AND guid = @AppointmentGuid
	END
ELSE
	BEGIN
		SELECT @PatientId = Id FROM [Patient].[Patient] WITH (NOLOCK, READUNCOMMITTED)WHERE IsDeleted = 0 AND guid = @PatientGuid
	END

SELECT @Id=Id from [mapping].[PatientPhysicalExaminations] WITH(NOLOCK,READUNCOMMITTED) WHERE IsDeleted=0 and AppointmentId=@AppointmentId and PhysicalExaminationName=@PhysicalExaminationName

/*Main Query */

    
  MERGE [mapping].[PatientPhysicalExaminations] AS trg 
  Using (
          select
                  @PatientId as PatientId
                 ,@AppointmentId as AppointmentId
                 ,@PhysicalExaminationName as PhysicalExaminationName

		     ) as src
		   ON  
		         trg.Id=@Id

		  WHEN MATCHED THEN
		  UPDATE 
		  SET	
		        trg.AppointmentId = ISNULL(trg.AppointmentId, src.AppointmentId),
				IsDeleted = CASE WHEN IsDeleted = 0 THEN 1 ELSE 0 END
		  WHEN NOT MATCHED THEN
		        INSERT
			         (  
					   PatientId
					  ,AppointmentId
					  ,PhysicalExaminationName
				     )
			   values(
					   @PatientId
					  ,@AppointmentId
					  ,@PhysicalExaminationName
			        );

SET NOCOUNT OFF
END




  



