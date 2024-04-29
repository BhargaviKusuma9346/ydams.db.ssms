CREATE PROCEDURE [Patient].[spSavePatientMedications]
     @PatientMedicationGuid uniqueIdentifier=null 
    ,@AppointmentGuid uniqueIdentifier=null 
	,@MedicationName varchar(500)=null 
	,@NoOfDays int
	,@Strength varchar(200)=null
	,@StartDate datetime=null
	,@EndDate datetime = null
	,@WhenToTake varchar(200) = null
	,@Frequency varchar(200) =null
	,@Notes varchar(1000)=null

 AS

/*

 MODIFICATIONS

 select * from mapping.PatientMedications order by 1 desc

 select * from lookup.Medications

 exec [Patient].[spSavePatientMedications]
             @PatientMedicationGuid='4e78b526-9fd5-45e5-936e-f73857c4f78b'
            ,@AppointmentGuid='122e5015-0ea1-430f-a9e5-4e01034d7fcb'
			,@MedicationName='qwedwqadwrdfwesfdew'
			,@NoOfDays=5
	        ,@Strength=''
	        ,@StartDate=''
	        ,@EndDate=''
	        ,@WhenToTake=''
	        ,@Frequency='0-1-0'
	        ,@Notes='fdfdf'
			
 Date					Author				Description          
 -----------------------------------------------------------------------------
 07/04/2023			M Chandrani	           Additions of Medications For Patients
 ------------------------------------------------------------------------------      
                Copyright 2023@YodaLIMS
*/ 

BEGIN
SET NOCOUNT ON
/*Declaration */

DECLARE @AppointmentId INT,@DoctorId INT,@PatientId INT  
SELECT @AppointmentId=id,@DoctorId=DoctorId,@PatientId=PatientId from [Patient].[Appointment] WITH(NOLOCK,READUNCOMMITTED) WHERE IsDeleted=0 and guid=@AppointmentGuid

DECLARE @Id INT
SELECT @Id=id from [mapping].[PatientMedications] WITH(NOLOCK,READUNCOMMITTED) WHERE IsDeleted=0 and Guid=@PatientMedicationGuid



/*Main Query */

  MERGE [mapping].[PatientMedications] AS trg 
  Using(
        select
             @Id as Id
            ,@AppointmentId as AppointmentId
			,@DoctorId as DoctorId
			,@PatientId as PatientId
			,@MedicationName as MedicationName
			,@NoOfDays as NoOfDays
			,@Strength as Strength
			,@StartDate as StartDate
	        ,@EndDate as EndDate
	        ,@WhenToTake as WhenToTake
	        ,@Frequency as Frequency
	        ,@Notes as Notes
		  ) as src
		  ON  
		    trg.Id =@Id 

	WHEN MATCHED THEN
		 UPDATE 
		   SET		    
			  NoOfDays=src.NoOfDays
			 ,Strength=src.Strength
			 ,StartDate=src.StartDate
	         ,EndDate=src.EndDate
	         ,WhenToTake=src.WhenToTake
	         ,Frequency=src.Frequency
	         ,Notes=src.Notes
			 ,MedicationName=src.MedicationName
	 WHEN NOT MATCHED THEN
		insert(
		    AppointmentId
		    ,PatientId
			,DoctorId
			,MedicationName
			,NoOfDays
			,Strength
			,StartDate
			,EndDate
			,WhenToTake
			,Frequency
			,Notes
		  )
		   values( 
		      @AppointmentId
			 ,@PatientId
			 ,@DoctorId
			 ,@MedicationName
			 ,@NoOfDays
			 ,@Strength
			 ,@StartDate
			 ,@EndDate
			 ,@WhenToTake
			 ,@Frequency
			 ,@Notes
		);

SET NOCOUNT OFF
END
GO

