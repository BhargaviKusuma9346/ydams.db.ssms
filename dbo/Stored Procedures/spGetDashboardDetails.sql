CREATE procedure [dbo].[spGetDashboardDetails]   
  @UserGuid uniqueIdentifier=null
  
  
AS        
      
/*
 exec [dbo].[spGetDashboardDetails]     
   @UserGuid='a91f58c8-fb82-47e4-8b9b-cb036506c9d6'

 -------------------------------------------------------------              

 MODIFICATIONS        
 Date					Author				Description          
 -----------------------------------------------------------------------------
20/04/2023			   M.Chandrani	           to get Dashboard information
 ------------------------------------------------------------------------------      
                Copyright 2023@YLIMS
*/        
BEGIN 

SET NOCOUNT ON

DECLARE @TotalDoctors INT = 0;
DECLARE @TotalPatients INT = 0;
DECLARE @TotalCoordinators INT = 0;
DECLARE @TotalAppointments INT = 0;
DECLARE @TotalTodayAppointments INT = 0;

DECLARE @UserId INT
SELECT @UserId=UserId from [dbo].[Users] WITH(NOLOCK,READUNCOMMITTED) WHERE IsDeleted=0 and UserGuid=@UserGuid
print(@UserId);
DECLARE @CoordinatorId INT 
DECLARE @CoordinatorName varchar(200),@CoordinatorGuid uniqueidentifier
SELECT @CoordinatorId=id,@CoordinatorName=FirstName ,@CoordinatorGuid=Guid from [Coordinator].[Coordinator] WITH(NOLOCK,READUNCOMMITTED) WHERE IsDeleted=0 and UserId=@UserId
print(@CoordinatorId);
/**Main Query**/
/*Query to get specific coordinator details total count based on date and category*/
	SELECT
	    @CoordinatorGuid as CoordinatorGuid ,
	    @CoordinatorId as CoordinatorId,
		@CoordinatorName as CoordinatorName,
		CONVERT(DATE, pp.CreatedDt) AS Date, 
		'Patients' AS Category, 
		COUNT(DISTINCT pp.Guid) AS Count,
		(SELECT 
		      COUNT(DISTINCT pp.Guid) 
		 FROM 
			[dbo].[Users] du WITH(NOLOCK,READUNCOMMITTED)
			LEFT JOIN
			[Patient].[Patient] pp WITH(NOLOCK,READUNCOMMITTED)
			ON du.UserId=pp.UserId
			LEFT JOIN
			[Lookup].[City] lc WITH(NOLOCK,READUNCOMMITTED)
			ON pp.CityId = lc.Id and lc.IsDeleted=0
			LEFT JOIN
			[Lookup].[State] ls WITH(NOLOCK,READUNCOMMITTED)
			ON pp.StateId = ls.Id and ls.IsDeleted=0
			LEFT JOIN
			[Lookup].[AddressProofType] apt WITH(NOLOCK,READUNCOMMITTED)
			ON pp.AddressProofTypeId= apt.Id and apt.Isdeleted=0
			LEFT JOIN
			[Lookup].[IncomeGroup] ign WITH(NOLOCK,READUNCOMMITTED)
			ON pp.IncomeGroupId= ign.Id and ign.Isdeleted=0
			LEFT JOIN
			[Lookup].[Occupation] oo WITH(NOLOCK,READUNCOMMITTED)
			ON pp.OccupationId= oo.Id and oo.Isdeleted=0
			LEFT JOIN
			[Lookup].[RelationshipType] rt WITH(NOLOCK,READUNCOMMITTED)
			ON pp.RelationshipTypeId= rt.Id and rt.Isdeleted=0
			LEFT JOIN
			[Lookup].[Religion] rn WITH(NOLOCK,READUNCOMMITTED)
			ON pp.ReligionId= rn.Id AND rn.IsDeleted=0
			LEFT JOIN
			[Lookup].[Education] en WITH(NOLOCK,READUNCOMMITTED)
			ON pp.EducationId = en.Id AND en.IsDeleted=0
			LEFT JOIN
			[dbo].[Users] du1 WITH(NOLOCK,READUNCOMMITTED)
			ON du1.UserId=pp.ModifiedBy
			WHERE 
			pp.IsDeleted=0
			AND
			du.IsDeleted=0
 			AND 
			CreatedByUserId = @UserId) AS CategoryWiseCount
FROM 
	[dbo].[Users] du WITH(NOLOCK,READUNCOMMITTED)
	LEFT JOIN
	[Patient].[Patient] pp WITH(NOLOCK,READUNCOMMITTED)
	ON du.UserId=pp.UserId
	LEFT JOIN
	[Lookup].[City] lc WITH(NOLOCK,READUNCOMMITTED)
	ON pp.CityId = lc.Id and lc.IsDeleted=0
	LEFT JOIN
	[Lookup].[State] ls WITH(NOLOCK,READUNCOMMITTED)
	ON pp.StateId = ls.Id and ls.IsDeleted=0
	LEFT JOIN
	[Lookup].[AddressProofType] apt WITH(NOLOCK,READUNCOMMITTED)
	ON pp.AddressProofTypeId= apt.Id and apt.Isdeleted=0
	LEFT JOIN
	[Lookup].[IncomeGroup] ign WITH(NOLOCK,READUNCOMMITTED)
	ON pp.IncomeGroupId= ign.Id and ign.Isdeleted=0
	LEFT JOIN
	[Lookup].[Occupation] oo WITH(NOLOCK,READUNCOMMITTED)
	ON pp.OccupationId= oo.Id and oo.Isdeleted=0
	LEFT JOIN
	[Lookup].[RelationshipType] rt WITH(NOLOCK,READUNCOMMITTED)
	ON pp.RelationshipTypeId= rt.Id and rt.Isdeleted=0
	LEFT JOIN
	[Lookup].[Religion] rn WITH(NOLOCK,READUNCOMMITTED)
	ON pp.ReligionId= rn.Id AND rn.IsDeleted=0
	LEFT JOIN
	[Lookup].[Education] en WITH(NOLOCK,READUNCOMMITTED)
	ON pp.EducationId = en.Id AND en.IsDeleted=0
	LEFT JOIN
	[dbo].[Users] du1 WITH(NOLOCK,READUNCOMMITTED)
	ON du1.UserId=pp.ModifiedBy
	WHERE 
	pp.IsDeleted=0
	AND
	du.IsDeleted=0
	AND 
	pp.CreatedByUserId = @UserId
GROUP BY 
		CONVERT(DATE, pp.CreatedDt)

UNION ALL

SELECT 
        @CoordinatorGuid as CoordinatorGuid ,
	    @CoordinatorId as CoordinatorId,
		@CoordinatorName as CoordinatorName,
		CONVERT(DATE, dd.CreatedDt) AS Date, 
		'Doctors' AS Category, 
		COUNT(DISTINCT dd.Guid) AS Count,
		(SELECT 
		    COUNT(DISTINCT dd.Guid) 
		 FROM 
			[Doctor].[Doctor] dd WITH(NOLOCK,READUNCOMMITTED)
			LEFT JOIN
			[Lookup].[City] lc WITH(NOLOCK,READUNCOMMITTED)
			ON dd.City = lc.CityName AND lc.IsDeleted=0
			LEFT JOIN
			[Lookup].[State] ls WITH(NOLOCK,READUNCOMMITTED)
			ON dd.State = ls.StateName AND ls.IsDeleted=0
			LEFT JOIN
			[Lookup].[State] lsr WITH(NOLOCK,READUNCOMMITTED)
			ON dd.StateOfRegistration=lsr.StateName
			LEFT JOIN
			[dbo].[Users] du WITH(NOLOCK,READUNCOMMITTED)
			ON du.UserId=dd.UserId
			 WHERE 
				dd.IsDeleted=0							
				AND
				du.IsDeleted=0) AS CategoryWiseCount
FROM 
    [Doctor].[Doctor] dd WITH(NOLOCK,READUNCOMMITTED)
	LEFT JOIN
	[Lookup].[City] lc WITH(NOLOCK,READUNCOMMITTED)
	ON dd.City = lc.CityName AND lc.IsDeleted=0
	LEFT JOIN
	[Lookup].[State] ls WITH(NOLOCK,READUNCOMMITTED)
	ON dd.State = ls.StateName AND ls.IsDeleted=0
	LEFT JOIN
	[Lookup].[State] lsr WITH(NOLOCK,READUNCOMMITTED)
	ON dd.StateOfRegistration=lsr.StateName
	LEFT JOIN
	[dbo].[Users] du WITH(NOLOCK,READUNCOMMITTED)
	ON du.UserId=dd.UserId
WHERE 
	dd.IsDeleted=0							
	AND
	du.IsDeleted=0
GROUP BY 
		CONVERT(DATE, dd.CreatedDt)

UNION ALL

	SELECT 
	    @CoordinatorGuid as CoordinatorGuid ,
	    @CoordinatorId as CoordinatorId,
		@CoordinatorName as CoordinatorName,
		CONVERT(DATE, pa.appointmentdate) AS Date, 
		'TodayAppointments' AS Category, 
		COUNT(DISTINCT pa.Id) AS Count,
		(SELECT 
		     COUNT(DISTINCT pa.id) 
		 FROM 
		     [Patient].[appointment] pa WITH(NOLOCK,READUNCOMMITTED)
			 INNER JOIN
			 [Coordinator].[Coordinator] cc WITH(NOLOCK,READUNCOMMITTED)
			 ON pa.CoordinatorId = cc.Id
			 INNER JOIN
			 [Patient].[Patient] pp WITH(NOLOCK,READUNCOMMITTED)
			 ON pp.Id= pa.PatientId 
			 INNER JOIN
			 [Doctor].[Doctor] dd WITH(NOLOCK,READUNCOMMITTED)
			 ON dd.Id= pa.DoctorId 
			 WHERE 
			 pa.IsConfirmed = 1 
			 AND 
			 pp.IsDeleted=0
			 AND
			 dd.IsDeleted=0
			 AND
			 cc.IsDeleted = 0 
			 AND
			 pa.coordinatorid = @CoordinatorId 
			 AND 
			 CAST(pa.appointmentdate AS DATE) = CAST(GETDATE() AS DATE)
		) AS CategoryWiseCount
	FROM 
		[Patient].[appointment] pa WITH(NOLOCK,READUNCOMMITTED)
			 INNER JOIN
			 [Coordinator].[Coordinator] cc WITH(NOLOCK,READUNCOMMITTED)
			 ON pa.CoordinatorId = cc.Id
			 INNER JOIN
			 [Patient].[Patient] pp WITH(NOLOCK,READUNCOMMITTED)
			 ON pp.Id= pa.PatientId 
			 INNER JOIN
			 [Doctor].[Doctor] dd WITH(NOLOCK,READUNCOMMITTED)
			 ON dd.Id= pa.DoctorId 
			 WHERE 
			 pa.IsConfirmed = 1 
			 AND 
			 pp.IsDeleted=0
			 AND
			 dd.IsDeleted=0
			 AND
			 cc.IsDeleted = 0 
			 AND
			 pa.coordinatorid = @CoordinatorId 
			 AND 
			 CAST(pa.appointmentdate AS DATE) = CAST(GETDATE() AS DATE)
	GROUP BY 
		CONVERT(DATE, pa.appointmentdate)

UNION ALL

	SELECT 
	    @CoordinatorGuid as CoordinatorGuid ,
	    @CoordinatorId as CoordinatorId,
		@CoordinatorName as CoordinatorName,
		CONVERT(DATE, pa.appointmentdate) AS Date, 
		'Appointments' AS Category, 
		COUNT(DISTINCT pa.id) AS Count,
		(SELECT 
		     COUNT(DISTINCT pa.id) 
		 FROM 
		     [Patient].[appointment] pa WITH(NOLOCK,READUNCOMMITTED)
			 INNER JOIN
			 [Coordinator].[Coordinator] cc WITH(NOLOCK,READUNCOMMITTED)
			 ON pa.CoordinatorId = cc.Id
			 INNER JOIN
			 [Patient].[Patient] pp WITH(NOLOCK,READUNCOMMITTED)
			 ON pp.Id= pa.PatientId 
			 INNER JOIN
			 [Doctor].[Doctor] dd WITH(NOLOCK,READUNCOMMITTED)
			 ON dd.Id= pa.DoctorId 
			 WHERE 
			 pa.IsConfirmed = 1 
			 AND 
			 pp.IsDeleted=0
			 AND
			 dd.IsDeleted=0
			 AND
			 cc.IsDeleted = 0 
			 AND
			 pa.coordinatorid = @CoordinatorId 			 
		) AS CategoryWiseCount
	FROM 
		[Patient].[appointment] pa WITH(NOLOCK,READUNCOMMITTED)
			 INNER JOIN
			 [Coordinator].[Coordinator] cc WITH(NOLOCK,READUNCOMMITTED)
			 ON pa.CoordinatorId = cc.Id
			 INNER JOIN
			 [Patient].[Patient] pp WITH(NOLOCK,READUNCOMMITTED)
			 ON pp.Id= pa.PatientId 
			 INNER JOIN
			 [Doctor].[Doctor] dd WITH(NOLOCK,READUNCOMMITTED)
			 ON dd.Id= pa.DoctorId 
			 WHERE 
			 pa.IsConfirmed = 1 
			 AND 
			 pp.IsDeleted=0
			 AND
			 dd.IsDeleted=0
			 AND
			 cc.IsDeleted = 0 
			 AND
			 pa.coordinatorid = @CoordinatorId 
	GROUP BY 
		CONVERT(DATE, pa.appointmentdate)

/*Query to get all total count based on date and category*/
SELECT 
    CONVERT(DATE, pp.CreatedDt) AS Date, 
    'Patients' AS Category, 
    COUNT(DISTINCT pp.Guid) AS Count,
    (SELECT 
	    COUNT(DISTINCT pp.Guid) 
	 FROM 
		[dbo].[Users] du WITH(NOLOCK,READUNCOMMITTED)
		LEFT JOIN
		[Patient].[Patient] pp WITH(NOLOCK,READUNCOMMITTED)
		ON du.UserId=pp.UserId
		LEFT JOIN
		[Lookup].[City] lc WITH(NOLOCK,READUNCOMMITTED)
		ON pp.CityId = lc.Id and lc.IsDeleted=0
		LEFT JOIN
		[Lookup].[State] ls WITH(NOLOCK,READUNCOMMITTED)
		ON pp.StateId = ls.Id and ls.IsDeleted=0
		LEFT JOIN
		[Lookup].[AddressProofType] apt WITH(NOLOCK,READUNCOMMITTED)
		ON pp.AddressProofTypeId= apt.Id and apt.Isdeleted=0
		LEFT JOIN
		[Lookup].[IncomeGroup] ign WITH(NOLOCK,READUNCOMMITTED)
		ON pp.IncomeGroupId= ign.Id and ign.Isdeleted=0
		LEFT JOIN
		[Lookup].[Occupation] oo WITH(NOLOCK,READUNCOMMITTED)
		ON pp.OccupationId= oo.Id and oo.Isdeleted=0
		LEFT JOIN
		[Lookup].[RelationshipType] rt WITH(NOLOCK,READUNCOMMITTED)
		ON pp.RelationshipTypeId= rt.Id and rt.Isdeleted=0
		LEFT JOIN
		[Lookup].[Religion] rn WITH(NOLOCK,READUNCOMMITTED)
		ON pp.ReligionId= rn.Id AND rn.IsDeleted=0
		LEFT JOIN
		[Lookup].[Education] en WITH(NOLOCK,READUNCOMMITTED)
		ON pp.EducationId = en.Id AND en.IsDeleted=0
		LEFT JOIN
		[dbo].[Users] du1 WITH(NOLOCK,READUNCOMMITTED)
		ON du1.UserId=pp.ModifiedBy
   WHERE 
		pp.IsDeleted=0
		AND
		du.IsDeleted=0) AS CategoryWiseCount				
FROM 
	[dbo].[Users] du WITH(NOLOCK,READUNCOMMITTED)
	LEFT JOIN
	[Patient].[Patient] pp WITH(NOLOCK,READUNCOMMITTED)
	ON du.UserId=pp.UserId
	LEFT JOIN
	[Lookup].[City] lc WITH(NOLOCK,READUNCOMMITTED)
	ON pp.CityId = lc.Id and lc.IsDeleted=0
	LEFT JOIN
	[Lookup].[State] ls WITH(NOLOCK,READUNCOMMITTED)
	ON pp.StateId = ls.Id and ls.IsDeleted=0
	LEFT JOIN
	[Lookup].[AddressProofType] apt WITH(NOLOCK,READUNCOMMITTED)
	ON pp.AddressProofTypeId= apt.Id and apt.Isdeleted=0
	LEFT JOIN
	[Lookup].[IncomeGroup] ign WITH(NOLOCK,READUNCOMMITTED)
	ON pp.IncomeGroupId= ign.Id and ign.Isdeleted=0
	LEFT JOIN
	[Lookup].[Occupation] oo WITH(NOLOCK,READUNCOMMITTED)
	ON pp.OccupationId= oo.Id and oo.Isdeleted=0
	LEFT JOIN
	[Lookup].[RelationshipType] rt WITH(NOLOCK,READUNCOMMITTED)
	ON pp.RelationshipTypeId= rt.Id and rt.Isdeleted=0
	LEFT JOIN
	[Lookup].[Religion] rn WITH(NOLOCK,READUNCOMMITTED)
	ON pp.ReligionId= rn.Id AND rn.IsDeleted=0
	LEFT JOIN
	[Lookup].[Education] en WITH(NOLOCK,READUNCOMMITTED)
	ON pp.EducationId = en.Id AND en.IsDeleted=0
	LEFT JOIN
	[dbo].[Users] du1 WITH(NOLOCK,READUNCOMMITTED)
	ON du1.UserId=pp.ModifiedBy
	WHERE 
	pp.IsDeleted=0
	AND
	du.IsDeleted=0
GROUP BY 
    CONVERT(DATE, pp.CreatedDt)

UNION ALL

SELECT 
		CONVERT(DATE, dd.CreatedDt) AS Date, 
		'Doctors' AS Category, 
		COUNT(DISTINCT dd.Guid) AS Count,
		(SELECT 
		    COUNT(DISTINCT dd.Guid) 
		 FROM 
			[Doctor].[Doctor] dd WITH(NOLOCK,READUNCOMMITTED)
			LEFT JOIN
			[Lookup].[City] lc WITH(NOLOCK,READUNCOMMITTED)
			ON dd.City = lc.CityName AND lc.IsDeleted=0
			LEFT JOIN
			[Lookup].[State] ls WITH(NOLOCK,READUNCOMMITTED)
			ON dd.State = ls.StateName AND ls.IsDeleted=0
			LEFT JOIN
			[Lookup].[State] lsr WITH(NOLOCK,READUNCOMMITTED)
			ON dd.StateOfRegistration=lsr.StateName
			LEFT JOIN
			[dbo].[Users] du WITH(NOLOCK,READUNCOMMITTED)
			ON du.UserId=dd.UserId
			 WHERE 
				dd.IsDeleted=0							
				AND
				du.IsDeleted=0) AS CategoryWiseCount
		 FROM 
			[Doctor].[Doctor] dd WITH(NOLOCK,READUNCOMMITTED)
			LEFT JOIN
			[Lookup].[City] lc WITH(NOLOCK,READUNCOMMITTED)
			ON dd.City = lc.CityName AND lc.IsDeleted=0
			LEFT JOIN
			[Lookup].[State] ls WITH(NOLOCK,READUNCOMMITTED)
			ON dd.State = ls.StateName AND ls.IsDeleted=0
			LEFT JOIN
			[Lookup].[State] lsr WITH(NOLOCK,READUNCOMMITTED)
			ON dd.StateOfRegistration=lsr.StateName
			LEFT JOIN
			[dbo].[Users] du WITH(NOLOCK,READUNCOMMITTED)
			ON du.UserId=dd.UserId
			 WHERE 
				dd.IsDeleted=0							
				AND
				du.IsDeleted=0
	GROUP BY 
		CONVERT(DATE, dd.CreatedDt)
UNION ALL

SELECT 
    CONVERT(DATE, cc.CreatedDt) AS Date, 
    'Coordinators' AS Category, 
    COUNT(DISTINCT cc.UserId) AS Count,
    (SELECT 
	       COUNT(DISTINCT cc.UserId) 
	 FROM 
	       [Coordinator].[Coordinator] cc WITH(NOLOCK,READUNCOMMITTED)		   
		   INNER JOIN 
		   [dbo].[Users] du WITH(NOLOCK,READUNCOMMITTED)
		   ON 
		   du.UserId=cc.UserId
		   WHERE cc.IsDeleted = 0 
		   and 
		   du.Isdeleted=0) AS CategoryWiseCount
FROM 
    [Coordinator].[Coordinator] cc WITH(NOLOCK,READUNCOMMITTED)
	INNER JOIN 
    [dbo].[Users] du WITH(NOLOCK,READUNCOMMITTED)
	ON 
	du.UserId=cc.UserId
	WHERE 
	cc.IsDeleted = 0 
	and 
	du.Isdeleted=0 
GROUP BY 
    CONVERT(DATE, cc.CreatedDt)

UNION ALL

SELECT 
    CONVERT(DATE, AppointmentDate) AS Date, 
    'Appointments' AS Category, 
    COUNT(DISTINCT Id) AS Count,
    (SELECT 
	   COUNT(DISTINCT Id)
	FROM 
	   [Patient].[appointment] 
	WHERE 
       Isdeleted = 0
	   AND
	   IsConfirmed=1) AS CategoryWiseCount
FROM 
    [Patient].[appointment] WITH(NOLOCK,READUNCOMMITTED)
WHERE 
    Isdeleted = 0
	AND
	IsConfirmed=1
GROUP BY 
    CONVERT(DATE, AppointmentDate)

/*Query to get Recuuring and new patient count details based on date*/
SELECT
    CAST(p.CreatedDt AS DATE) AS Date,
	COUNT(CASE WHEN a.AppointmentCount <= 1 THEN p.ID END) AS NewPatientCount,
    COUNT(CASE WHEN a.AppointmentCount > 1 THEN p.ID END) AS RecurringPatientCount
FROM
    patient.patient p WITH(NOLOCK,READUNCOMMITTED)
    LEFT JOIN (
        SELECT
           pp.ID,
           COUNT(a.ID) AS AppointmentCount
           FROM
            patient.patient pp WITH(NOLOCK,READUNCOMMITTED)
           LEFT JOIN patient.appointment a WITH(NOLOCK,READUNCOMMITTED)
		   ON 
		    pp.ID = a.PatientID AND a.isConfirmed=1
		   INNER JOIN
	      [dbo].[Users] du WITH(NOLOCK,READUNCOMMITTED)
	      ON
	      du.UserId=pp.UserId
         GROUP BY
            pp.ID
    ) a ON p.ID = a.ID AND p.isdeleted = 0
	INNER JOIN
	[dbo].[Users] du WITH(NOLOCK,READUNCOMMITTED)
	ON
	du.UserId=p.UserId
WHERE
    p.Isdeleted = 0
	and
	du.IsDeleted=0
GROUP BY
    CAST(p.CreatedDt AS DATE);


SET NOCOUNT OFF

END
GO

