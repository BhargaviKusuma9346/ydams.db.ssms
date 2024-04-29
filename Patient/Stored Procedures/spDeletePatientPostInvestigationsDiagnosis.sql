CREATE PROCEDURE [Patient].[spDeletePatientPostInvestigationsDiagnosis]
@DiagnosisGuid  uniqueidentifier	
AS
/*
 exec [Patient].[spDeletePatientPostInvestigationsDiagnosis]   
      @DiagnosisGuid = '9B3AAE52-E256-4236-8B8E-FEFF5D4B78E1'
 -------------------------------------------------------------              
	select * from [mapping].[PatientDiagnosis] order by 1 desc

 MODIFICATIONS        
 Date					Author				Description          
 -----------------------------------------------------------------------------
05/09/2023			   Kiran Palaparthi	           To Delete Patient Post Investigation Details
 ------------------------------------------------------------------------------      
                Copyright 2023@YLIMS
*/        
BEGIN
	/*Declaration */
DECLARE @DiagnosisId INT
SELECT @DiagnosisId=id from [mapping].[PatientDiagnosis] WITH(NOLOCK,READUNCOMMITTED) WHERE IsDeleted=0 and guid=@DiagnosisGuid
print @DiagnosisId

/*Main Query */
UPDATE
	[mapping].[PatientDiagnosis]
SET
	IsDeleted=1
WHERE
	 Id = @DiagnosisId
SET NOCOUNT OFF

select
Diagnosis from [mapping].[PatientDiagnosis] where guid=@DiagnosisGuid
END
GO

