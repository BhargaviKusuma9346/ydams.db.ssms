CREATE procedure [Patient].[spGetPatientMedications]  
          @AppointmentGuid uniqueIdentifier
  
AS        
      
/*
 exec [Patient].[spGetPatientMedications]  
         @AppointmentGuid='FC6D6681-4C71-44C7-B33C-90C820EFBBED'
 -------------------------------------------------------------              

 MODIFICATIONS        
 Date					Author				Description          
 -----------------------------------------------------------------------------
20/04/2023			   M.Chandrani	           to get Patient Medication information
 ------------------------------------------------------------------------------      
                Copyright 2023@YLIMS
*/        
BEGIN 

SET NOCOUNT ON

SELECT 
    dd.Guid AS DoctorGuid,
	dd.Id as DoctorId,
	pp.Guid as PatientGuid,
	pp.Id as PatientId,
	pa.Guid as AppointmentGuid,
	pa.Id as AppointmentId,
	pm.MedicationName,
	pm.NoOfDays,
	pm.Strength,
	pm.StartDate,
	pm.EndDate,
	pm.WhenToTake,
	pm.Frequency,
	pm.Notes
FROM
    [mapping].[PatientMedications] pm WITH(NOLOCK,READUNCOMMITTED)
	INNER JOIN
	[Patient].[Appointment] pa WITH(NOLOCK,READUNCOMMITTED)
	ON pa.Id = pm.AppointmentId
	INNER JOIN
    [Patient].[Patient] pp WITH(NOLOCK,READUNCOMMITTED)
	on pp.Id= pm.PatientId 
	INNER JOIN
    [Doctor].[Doctor] dd WITH(NOLOCK,READUNCOMMITTED)
	on dd.Id= pm.DoctorId 
WHERE
   pa.IsConfirmed=1
	AND
   pm.IsDeleted=0
    AND
   pa.Guid=@AppointmentGuid
   
SET NOCOUNT OFF

END
GO

