
CREATE procedure [Patient].[spGetPatientSymptoms]  
     @AppointmentGuid uniqueIdentifier
  
AS        
      
/*
 exec [Patient].[spGetPatientSymptoms] @AppointmentGuid='4B59F148-6726-440D-84B3-B593B41AC972'

 select * from lookup.Symptom
 -------------------------------------------------------------              

 MODIFICATIONS        
 Date					Author				Description          
 -----------------------------------------------------------------------------
20/04/2023			   M.Chandrani	           to get Patient Symptoms information
 ------------------------------------------------------------------------------      
                Copyright 2023@YLIMS
*/        
BEGIN 

SET NOCOUNT ON

SELECT 
	pp.Guid as PatientGuid,
	pa.Guid as AppointmentGuid,
	lp.Guid as SymptomGuid,
	ms.Symptoms,
	ms.SeverityLevel,
	ms.Description
FROM
    [mapping].[PatientSymptoms] ms WITH(NOLOCK,READUNCOMMITTED)
	INNER JOIN
	[Patient].[Appointment] pa WITH(NOLOCK,READUNCOMMITTED)
	ON pa.Id = ms.AppointmentId
	INNER JOIN
    [Patient].[Patient] pp WITH(NOLOCK,READUNCOMMITTED)
	on pp.Id= ms.PatientId 
	INNER JOIN
	[Lookup].[Symptom] lp WITH(NOLOCK,READUNCOMMITTED)
	on lp.SymptomName=ms.Symptoms
WHERE
   ms.IsDeleted=0
    AND
   pa.IsDeleted=0
    AND
   pp.IsDeleted=0
    AND
   lp.IsDeleted=0
    AND
   pa.Guid=@AppointmentGuid
   
SET NOCOUNT OFF

END
