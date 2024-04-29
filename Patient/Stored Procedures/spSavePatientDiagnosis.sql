
CREATE PROCEDURE [Patient].[spSavePatientDiagnosis]
	   @AppointmentGuid  uniqueidentifier=null
	  ,@Diagnosis varchar(200)
	  ,@DiagnosisType varchar(200)=null
	  ,@DiagnosisGroupGuid uniqueidentifier=null
	  ,@DiseaseType varchar(200)=null
	  ,@Comments varchar(200)=null

 AS
 
/*
select * from [mapping].[PatientDiagnosis] order by 1 desc 
exec [Patient].[spSavePatientDiagnosis]
       @AppointmentGuid='CB1F789A-BA4D-4DBF-AD75-0145AF5F9152'
	  ,@Diagnosis='Backpain'
	  ,@DiagnosisType='Provisional'
	  ,@DiagnosisGroupGuid='96B28728-058E-40B4-B890-C2508746DFCA'
	  ,@DiseaseType='Non-Communicable'
	  ,@Comments='abc'

select * from mapping.PatientDiagnosis order by 1 desc

 Date					Author				Description          
 -----------------------------------------------------------------------------
27/04/2023			M Chandrani	           Save PatientDiagnosis related information
 ------------------------------------------------------------------------------      
                Copyright 2023@YodaLIMS
*/ 

BEGIN
SET NOCOUNT ON
/*Declaration */

DECLARE @AppointmentId INT,@Id INT

SELECT @AppointmentId=id from [Patient].[Appointment] WITH(NOLOCK,READUNCOMMITTED) WHERE IsDeleted=0 and guid=@AppointmentGuid

DECLARE @DiagnosisGroup varchar(200)
SELECT @DiagnosisGroup=DiagnosisGroup from [Lookup].[DiagnosisGroup] WITH(NOLOCK,READUNCOMMITTED) WHERE IsDeleted=0 and Guid=@DiagnosisGroupGuid

SELECT @Id=Id from [mapping].[PatientDiagnosis] WITH(NOLOCK,READUNCOMMITTED) WHERE IsDeleted=0 and Diagnosis=@Diagnosis and AppointmentId=@AppointmentId


/*Main Query */

    
  MERGE [mapping].[PatientDiagnosis] AS trg 
  Using (
          select
		          @Id as Id
                 ,@AppointmentId as AppointmentId
                 ,@Diagnosis as Diagnosis
			     ,@DiagnosisType as DiagnosisType
			     ,@DiagnosisGroup as DiagnosisGroup
			     ,@DiseaseType as DiseaseType
			     ,@Comments as Comments

		     ) as src
		   ON  
		        trg.Id=@Id

		  WHEN MATCHED THEN
		  UPDATE 
		  SET	
		          DiagnosisType=src.DiagnosisType
			     ,DiagnosisGroup=COALESCE(src.DiagnosisGroup, 'General')
			     ,DiseaseType=src.DiseaseType
			     ,Comments=src.Comments
			    
		  WHEN NOT MATCHED THEN
		        INSERT
			         (  
					   AppointmentId
                      ,Diagnosis
			          ,DiagnosisType
			          ,DiagnosisGroup
			          ,DiseaseType
			          ,Comments
				     )
			   values(
					   @AppointmentId
                      ,@Diagnosis
			          ,@DiagnosisType
					  ,COALESCE(@DiagnosisGroup, 'General')
			          ,@DiseaseType
			          ,@Comments
			        );

SET NOCOUNT OFF
END




  



