
CREATE procedure [Patient].[spDeletePatientVitals] 
  @PatientGuid uniqueIdentifier,
  @VitalGuid uniqueidentifier
  
AS        
      
/*
 exec [Patient].[spDeletePatientVitals]  @PatientGuid='381F2AC9-2112-49DA-B9A7-B3E1F726E28B',@VitalGuid='69056CD9-C277-48D2-897C-BE5AD9908EBF'
 -------------------------------------------------------------              
	select * from [mapping].[PatientVitals] where IsDeleted=1

 MODIFICATIONS        
 Date					Author				Description          
 -----------------------------------------------------------------------------
20/04/2023			   M.Chandrani	           to delete Patient Vitals
 ------------------------------------------------------------------------------      
                Copyright 2023@YLIMS
*/        
BEGIN 

SET NOCOUNT ON

    UPDATE
	     mapping.PatientVitals
	SET
	     IsDeleted=1
	WHERE
	     PatientId IN (Select Id from Patient.Patient WHERE Guid=@PatientGuid)
	AND
	     VitalId IN (Select Id from Lookup.Vital WHERE Guid=@VitalGuid)


SET NOCOUNT OFF

END
