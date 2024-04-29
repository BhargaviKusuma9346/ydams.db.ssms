CREATE procedure [Patient].[spGetPatientCaseSheet]  
     @AppointmentGuid uniqueIdentifier=null
  
AS        
      
/*
 exec [Patient].[spGetPatientCaseSheet] @AppointmentGuid='73e73e38-08ca-4fa4-a65b-b380886b115a'

 select * from patient.appointment where Guid='aef2c100-0332-49b1-828c-36d8e6e71bd1' 
 -------------------------------------------------------------              

 MODIFICATIONS        
 Date					Author				Description          
 -----------------------------------------------------------------------------
20/04/2023			   M.Chandrani	           to get Patient appointment related information
 ------------------------------------------------------------------------------      
                Copyright 2023@YLIMS
*/        
BEGIN 

SET NOCOUNT ON

/*Declaration */
DECLARE @PatientId INT,@AppointmentId INT  
SELECT @PatientId=PatientId,@AppointmentId=Id from [Patient].[Appointment] WITH(NOLOCK,READUNCOMMITTED) WHERE IsDeleted=0 and guid=@AppointmentGuid

/** Main Query **/

/* Patient Symptoms */
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
   pp.IsDeleted=0
    AND
   lp.IsDeleted=0
    AND
   pa.Guid=@AppointmentGuid


/* Patient Doctor Prescribed Investigations */
SELECT 
    dd.Guid AS DoctorGuid,
	dd.Id as DoctorId,
	pp.Guid as PatientGuid,
	pp.Id as PatientId,
	pa.Guid as AppointmentGuid,
	pa.Id as AppointmentId,
    l.InvestigationName AS Investigations
FROM
    [mapping].[PatientInvestigations] mp WITH(NOLOCK,READUNCOMMITTED)
	INNER JOIN
	[Patient].[Appointment] pa WITH(NOLOCK,READUNCOMMITTED)
	ON pa.Id = mp.AppointmentId
	INNER JOIN
    [Patient].[Patient] pp WITH(NOLOCK,READUNCOMMITTED)
	on pp.Id= mp.PatientId 
	INNER JOIN
    [Doctor].[Doctor] dd WITH(NOLOCK,READUNCOMMITTED)
	on dd.Id= mp.DoctorId 
	CROSS APPLY (
		SELECT value AS InvestigationName
		FROM STRING_SPLIT(mp.Investigations, ';')
	) AS l
WHERE
   pa.IsConfirmed=1
	AND
   mp.IsDeleted=0
    AND
   dd.IsDeleted=0
    AND
   pp.IsDeleted=0
    AND
   pa.Guid=@AppointmentGuid;


/* Patient Doctor Prescribed Medications */
SELECT 
    dd.Guid AS DoctorGuid,
	dd.Id as DoctorId,
	pp.Guid as PatientGuid,
	pm.Guid as PatientMedicationGuid,
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

/* Patient Vitals */
SELECT 
    pp.Guid as PatientGuid,
    pp.Id as PatientId,
    pp.Title,
    CONCAT(pp.[FirstName],' ',pp.[MiddleName],' ',pp.[LastName]) as PatientName,
    mpv.VitalName,
    mpv.VitalValue,
    mpv.LastUpdatedTime
FROM
    [Patient].[Patient] pp WITH(NOLOCK, READUNCOMMITTED)
left  JOIN
    [mapping].[PatientVitals] mpv WITH(NOLOCK, READUNCOMMITTED) ON mpv.PatientId = pp.Id  AND mpv.IsDeleted = 0
WHERE
    pp.IsDeleted = 0
	AND
    mpv.AppointmentId=@AppointmentId

/* Patient Physical Examinations*/
SELECT 
	pp.Guid as PatientGuid,
	pa.Guid as AppointmentGuid,
	lp.Guid as PhysicalExaminationGuid,
	pps.PhysicalExaminationName
FROM
    [mapping].[PatientPhysicalExaminations] pps WITH(NOLOCK,READUNCOMMITTED)
	INNER JOIN
	[Patient].[Appointment] pa WITH(NOLOCK,READUNCOMMITTED)
	ON pa.Id = pps.AppointmentId
	INNER JOIN
    [Patient].[Patient] pp WITH(NOLOCK,READUNCOMMITTED)
	on pp.Id= pps.PatientId 
	INNER JOIN
	[Lookup].[PhysicalExamination] lp WITH(NOLOCK,READUNCOMMITTED)
	on lp.PhysicalExaminationName= pps.PhysicalExaminationName
WHERE
   pps.IsDeleted=0
    AND
   pp.IsDeleted=0
    AND
   lp.IsDeleted=0
    AND
   pa.Guid=@AppointmentGuid   

/* Patient Attachments*/
SELECT 
	pp.Guid as PatientGuid,
	pa.Guid as AppointmentGuid,
	ppa.Guid as AttachmentGuid,
	ppa.AttachmentTitle,
	ppa.AttachmentUrl
FROM
    [mapping].[PatientAttachments] ppa WITH(NOLOCK,READUNCOMMITTED)
	LEFT JOIN
	[Patient].[Appointment] pa WITH(NOLOCK,READUNCOMMITTED)
	ON pa.Id = ppa.AppointmentId
	INNER JOIN
    [Patient].[Patient] pp WITH(NOLOCK,READUNCOMMITTED)
	on pp.Id= ppa.PatientId 
WHERE
   ppa.IsDeleted=0
    AND
   pp.IsDeleted=0
    AND
   pa.Guid=@AppointmentGuid 

 /* Appointment details*/
SELECT
     pp.Id as PatientId,
     pp.Guid as PatientGuid,
	 pp.MobileNumber as PatientMobileNumber,
	 pp.AlternativeMobileNumber as PatientAlternateMobileNumber,
	 pp.Email as PatientEmailId,
	 pp.Gender as PatientGender,
	 pp.PatientPhotoURL as ProfileUrl,
	 CONVERT(varchar, pp.DateOfBirth, 105) as DateOfBirth,
	 CONCAT(pp.[FirstName],' ',pp.[MiddleName],' ',pp.[LastName]) as PatientName,
	 pp.BloodGroup,
	 dd.Id as DoctorId,
	 dd.Guid as DoctorGuid,
	 CONVERT(varchar, dd.DateOfBirth, 105) as DoctorDateOfBirth,
	 dd.QualificationName,
	 dd.SpecializationName,
	 dd.RegistrationNumber,
	 dd.gender as DoctorGender,
	 dd.contactNumber as DoctorMobile,
	 dd.EmailId as DoctorEmail,
	 CONVERT(varchar, dd.PracticeStartDate, 105) as PracticeStartDate,
	 CONCAT(dd.[FirstName],' ',dd.[LastName]) as DoctorName,
	 dd.SignUrl,
	 cc.Guid as CoordinatorGuid,
	 cc.ContactNumber as CoordinatorPhone,
	 (SELECT UserGuid from dbo.users where userid=cc.UserId) as CoordinatorUserGuid,
	 CONCAT(cc.[FirstName],' ',cc.[LastName]) as CoordinatorName,
	 pa.Id as AppointmentId,
	 pa.Guid as AppointmentGuid,
	 pa.AppointmentDate,
	 pa.AppointmentName,
	 pa.Description as AppointmentDescription, 
	 pa.VideoUrl,
	 pa.AppointmentDuration,
	 CONCAT(lb.[BranchName],',',lb.[Address]) AS BranchAddress,
	 lb.BranchName,
	 pa.IsConfirmed,
	 status.Status,
	 (SELECT Guid from [Patient].[Appointment] where Id=pa.PreviousAppointmentId) as PreviousAppointmentGuid,
	 (SELECT AppointmentDate 
	    FROM [Patient].[Appointment] 
		WHERE 
		PatientId = pp.Id AND AppointmentDate <= CONVERT(DATETIME, SWITCHOFFSET(GETUTCDATE(), '+05:30'))
		ORDER BY AppointmentDate DESC 
		OFFSET 0 ROWS FETCH NEXT 1 ROWS ONLY) AS LastConsultedDate	 
FROM
    [Patient].[Appointment] pa WITH(NOLOCK,READUNCOMMITTED)
	INNER JOIN
    [Patient].[Patient] pp WITH(NOLOCK,READUNCOMMITTED)
	ON pa.PatientId = pp.Id
	INNER JOIN
    [doctor].[doctor] dd WITH(NOLOCK,READUNCOMMITTED)
	on dd.Id= pa.DoctorId 
	LEFT JOIN
    [Coordinator].[Coordinator] cc WITH(NOLOCK,READUNCOMMITTED)
	on cc.Id= pa.CoordinatorId 
	LEFT JOIN
    [Lookup].[Branch] lb WITH(NOLOCK,READUNCOMMITTED)
	on pa.BranchId=lb.Id 
	CROSS APPLY		
	(
	  SELECT
		CASE
			WHEN pa.IsDeleted = 1 THEN 'Cancelled'
			WHEN (pa.IsDeleted = 0 AND ((pa.IsCoordinatorAttended = 1 OR pa.IsPatientAttended=1) AND pa.IsDoctorAttended = 1)) THEN 'Completed'
			WHEN (pa.IsDeleted = 0 AND ((pa.IsCoordinatorAttended = 0 AND pa.IsPatientAttended=0) AND pa.IsDoctorAttended = 0) AND pa.AppointmentDate >= CONVERT(DATETIME, SWITCHOFFSET(GETUTCDATE(), '+05:30')) AND pa.IsRescheduled = 0) THEN 'Upcoming'
			WHEN (pa.IsDeleted = 0 AND ((pa.IsCoordinatorAttended = 0 OR pa.IsPatientAttended=0) OR pa.IsDoctorAttended = 0) AND pa.AppointmentDate <= CONVERT(DATETIME, SWITCHOFFSET(GETUTCDATE(), '+05:30'))) THEN 'Not Attended'
			WHEN (pa.IsRescheduled = 1 AND pa.AppointmentDate >= CONVERT(DATETIME, SWITCHOFFSET(GETUTCDATE(), '+05:30'))) THEN 'Rescheduled'
		END AS Status
	) status
 WHERE 
	pp.IsDeleted=0
	AND
	dd.IsDeleted=0
	AND
	pa.IsConfirmed=1
	AND
	pa.Guid=@AppointmentGuid

	/* Patient Diagnosis */
SELECT 
	pa.Guid as AppointmentGuid,
	mds.Guid as DiagnosisGuid,
	mds.Diagnosis,
	mds.DiagnosisType,
	ld.Guid as DiagnosisGroupGuid,
	mds.DiagnosisGroup,
	mds.DiseaseType,
	mds.Comments
FROM
    [mapping].[PatientDiagnosis] mds WITH(NOLOCK,READUNCOMMITTED)
	INNER JOIN
	[Patient].[Appointment] pa WITH(NOLOCK,READUNCOMMITTED)
	ON pa.Id = mds.AppointmentId
	INNER JOIN
	[Lookup].[DiagnosisGroup] ld WITH(NOLOCK,READUNCOMMITTED)
	on ld.DiagnosisGroup=mds.DiagnosisGroup
WHERE
   mds.IsDeleted=0
    AND
   pa.IsConfirmed=1
    AND
   ld.IsDeleted=0
    AND
   pa.Guid=@AppointmentGuid

	/* Patient Advice */
SELECT 
	pa.Guid as AppointmentGuid,
	pac.Advice 
FROM
    [mapping].[PatientAdvice] pac WITH(NOLOCK,READUNCOMMITTED)
	INNER JOIN
	[Patient].[Appointment] pa WITH(NOLOCK,READUNCOMMITTED)
	ON pa.Id = pac.AppointmentId
WHERE
   pa.IsConfirmed=1
    AND
   pac.IsDeleted=0
    AND
   pa.Guid=@AppointmentGuid

/* Patient Review Details */
SELECT 
	pa.Guid as AppointmentGuid,
	pa.NextReviewDate,
	CONCAT(dd.[FirstName],' ',dd.[LastName]) as DoctorName,
	dd.Guid as DoctorGuid,
	dd.SignUrl
FROM
	[Patient].[Appointment] pa WITH(NOLOCK,READUNCOMMITTED)
	INNER JOIN
    [doctor].[doctor] dd WITH(NOLOCK,READUNCOMMITTED)
	on pa.ReviewDoctorId= dd.Id 
WHERE
   pa.IsConfirmed=1
    AND
   dd.IsDeleted=0
    AND
   pa.Guid=@AppointmentGuid

SET NOCOUNT OFF
END
GO

