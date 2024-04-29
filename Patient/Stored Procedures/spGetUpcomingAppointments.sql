CREATE PROCEDURE [Patient].[spGetUpcomingAppointments] 
  @PageNumber int=-1,
  @RowCount int=-1,
  @OrderBy varchar(200) = '',
  @SortType varchar(5)='asc',
  @PatientGuid uniqueIdentifier=null,
  @UserGuid uniqueIdentifier=null

 AS

 /*

exec [Patient].[spGetUpcomingAppointments] 
 @PageNumber=-1,
 @RowCount=-1,
 @OrderBy='AppointmentDate',
 @SortType='asc', 
 @PatientGuid=null, 
 @UserGuid='84407844-d3d7-4d75-ae83-a853d6a92985'

 select * from Patient.Appointment

 MODIFICATIONS        
 Date					Author				Description          
 -----------------------------------------------------------------------------
 18/04/2023			M Chandrani	           to get Upcoming Appointments
 ------------------------------------------------------------------------------      
                Copyright 2023@YodaLIMS
*/ 

BEGIN
SET NOCOUNT ON

/*Main Query */
DECLARE @Query nvarchar(max)=''
DECLARE @SQL nvarchar(max)=''
DECLARE @WhereClause nvarchar(max)=''
DECLARE @OrderByClause nvarchar(max)=''
DECLARE @OffsetClause nvarchar(max)=''
DECLARE @FinalOrderBy nvarchar(max)=''
DECLARE @AdditionalQuery nvarchar(max)

DECLARE @UserId varchar(100)
SELECT @UserId=UserId from dbo.Users where UserGuid=@UserGuid
print(@UserId)

If(@SortType = '' or @SortType is null)
BEGIN
	SET @SortType = 'asc'
END
	SET @SQL+=
   N';WITH tblAppStatus(DoctorGuid,DoctorName,DoctorProfileUrl,PracticeStartDate,CoordinatorProfileUrl,PatientProfileUrl,DoctorId,SpecializationName,DoctorGender,DoctorDateOfBirth,DoctorcontactNumber,DoctorEmailId,PatientGuid,PatientName,PatientId,PatientMobileNumber,PatientAlternateMobileNumber,PatientEmailId,PatientGender,PatientDateOfBirth,CoordinatorGuid,CoordinatorUserGuid,CoordinatorName,CoordinatorId,BranchGuid,BranchName,BranchAddress,BranchContactPerson,BranchContactPhone,BranchContactEmail,AppointmentGuid,AppointmentId,AppointmentDate,IsPatientAttended,IsCoordinatorAttended,IsDoctorAttended,AppointmentEndTime,Status,AppointmentDuration,CreatedDt) as
	( 
	 SELECT 
	 dd.Guid as DoctorGuid,
	 CONCAT(dd.[FirstName],'' '',dd.[LastName]) as DoctorName,
	 dd.ProfileUrl as DoctorProfileUrl,
	 CONVERT(varchar, dd.PracticeStartDate, 105) as PracticeStartDate,
	 cc.CoordinatorPhotoURL as CoordinatorProfileUrl,
	 pp.PatientPhotoURL as PatientProfileUrl,
	 dd.Id as DoctorId,
	 dd.SpecializationName,
	 dd.Gender as DoctorGender,
     CONVERT(varchar, dd.DateOfBirth, 105) as DoctorDateOfBirth,
	 dd.ContactNumber as DoctorcontactNumber,
	 dd.EmailId as DoctorEmailId,
	 pp.Guid as PatientGuid,
	 CONCAT(pp.[FirstName],'' '',pp.[MiddleName],'' '',pp.[LastName]) as PatientName,
	 pp.Id as PatientId,
	 pp.MobileNumber as PatientMobileNumber,
	 pp.AlternativeMobileNumber as PatientAlternateMobileNumber,
	 pp.Email as PatientEmailId,
	 pp.Gender as PatientGender,
	 CONVERT(varchar, pp.DateOfBirth, 105) as PatientDateOfBirth, 
	 cc.Guid as CoordinatorGuid,
	 (Select UserGuid from dbo.users where UserId=cc.UserId) as CoordinatorUserGuid,
	 CONCAT(cc.[FirstName],'' '',cc.[LastName]) as CoordinatorName,	
	 cc.Id as CoordinatorId,
	 lb.Guid as BranchGuid,
	 lb.BranchName,
	 lb.Address as BranchAddress,
	 lb.ContactName as BranchContactPerson,
	 lb.ContactEmail as BranchContactEmail,
	 lb.ContactPhone as BranchContactPhone,
     pa.Guid as AppointmentGuid,
	 pa.Id as AppointmentId,
	 pa.AppointmentDate,
	 pa.IsPatientAttended,
	 pa.IsCoordinatorAttended,
	 pa.IsDoctorAttended,
	 DATEADD(MINUTE, dd.AppointmentDurationInMin, pa.AppointmentDate) AS AppointmentEndTime,
	 status.Status,
	 dd.AppointmentDurationinMin as AppointmentDuration,
	 pa.CreatedDt
 FROM
	[Patient].[Appointment] pa WITH(NOLOCK,READUNCOMMITTED)
	LEFT JOIN
    [Coordinator].[Coordinator] cc WITH(NOLOCK,READUNCOMMITTED)
	ON pa.CoordinatorId = cc.Id
	LEFT JOIN
	[Lookup].[Branch] lb WITH(NOLOCK,READUNCOMMITTED)
	ON pa.BranchId=lb.Id
	INNER JOIN
    [Patient].[Patient] pp WITH(NOLOCK,READUNCOMMITTED)
	on pa.PatientId = pp.Id
	INNER JOIN
    [Doctor].[Doctor] dd WITH(NOLOCK,READUNCOMMITTED)
	on pa.DoctorId = dd.Id
	CROSS APPLY		
	(
	  SELECT
		CASE
			WHEN pa.IsDeleted = 1 THEN ''Cancelled''
			WHEN (pa.IsConfirmed=1 AND ((pa.IsCoordinatorAttended = 1 OR pa.IsPatientAttended=1) AND pa.IsDoctorAttended = 1)) THEN ''Completed''
            WHEN (pa.IsConfirmed=1 AND DATEADD(MINUTE, dd.AppointmentDurationInMin, pa.AppointmentDate) >= CONVERT(DATETIME, SWITCHOFFSET(GETUTCDATE(), ''+05:30'')) AND pa.IsRescheduled = 0) THEN ''Upcoming''		
			WHEN (pa.IsConfirmed=1 AND ((pa.IsCoordinatorAttended = 0 OR pa.IsPatientAttended=0) OR pa.IsDoctorAttended = 0) AND pa.AppointmentDate <= CONVERT(DATETIME, SWITCHOFFSET(GETUTCDATE(), ''+05:30''))) THEN ''Not Attended''
			WHEN (pa.IsRescheduled = 1 AND pa.AppointmentDate >= CONVERT(DATETIME, SWITCHOFFSET(GETUTCDATE(), ''+05:30''))) THEN ''Rescheduled''
		END AS Status
	) status	
 WHERE 
	(pp.IsDeleted=0
	AND
	dd.IsDeleted=0
	AND
	(status=''Upcoming'' 
	OR status=''Rescheduled'')
	AND
	pa.IsConfirmed=1) '

	IF (@PatientGuid is not null)
	BEGIN 
	SET @WhereClause+=' AND (pp.Guid LIKE ''%'+ CAST(@PatientGuid AS nvarchar(200)) +'%'')'
	END

	IF (@UserGuid is not null)
	BEGIN 
	SET @WhereClause+=' AND (cc.UserId LIKE ''%'+ @UserId +'%'' or dd.UserId LIKE ''%'+ @UserId +'%'' or pp.UserId LIKE ''%'+ @UserId +'%'')'
	END

  IF(@OrderBy='AppointmentDate ' )
  BEGIN
  SET @OrderByClause+=' order by AppointmentDate '+ @SortType
  SET @FinalOrderBy+=' order by AppointmentDate '+ @SortType
  END
	
    IF(@OrderBy='Status ' )
  BEGIN
  SET @OrderByClause+=' order by Status '+ @SortType
  SET @FinalOrderBy+=' order by Status '+ @SortType
  END
	
  IF(@OrderBy='Doctor name ' )
  BEGIN
  SET @OrderByClause+=' order by DoctorName '+ @SortType
  SET @FinalOrderBy+=' order by DoctorName '+ @SortType
  END

  IF(@OrderBy='Branch name ' )
  BEGIN
  SET @OrderByClause+=' order by BranchName '+ @SortType
  SET @FinalOrderBy+=' order by BranchName '+ @SortType
  END

  IF(@OrderBy='Specialization name ' )
  BEGIN
  SET @OrderByClause+=' order by SpecializationName '+ @SortType
  SET @FinalOrderBy+=' order by SpecializationName '+ @SortType
  END

  IF(@OrderBy is null or @OrderBy = '')
  BEGIN
  SET @OrderByClause+=' order by CreatedDt '+ @SortType
  SET @FinalOrderBy +=' order by CreatedDt DESC '
  END  

   IF (@PageNumber=-1 or @RowCount='')
  BEGIN
     SET @OffsetClause =' OFFSET 0 ROWS'
  END

  IF (@PageNumber !=-1 and @RowCount!='')
  BEGIN

		SET @OffsetClause =' OFFSET '+ (CAST( (@PageNumber-1)*(@RowCount) AS nvarchar(200))) +' ROWS 
		FETCH NEXT '+ (CAST(@RowCount AS nvarchar(200))) +' ROWS ONLY ' 
  END

  SET @AdditionalQuery=' SELECT * '

  SET @AdditionalQuery+=',(Select count(pa.Guid)	 	
		                    FROM						
							[Patient].[Appointment] pa WITH(NOLOCK,READUNCOMMITTED)
							LEFT JOIN
							[Coordinator].[Coordinator] cc WITH(NOLOCK,READUNCOMMITTED)
							ON pa.CoordinatorId = cc.Id
							LEFT JOIN
							[Lookup].[Branch] lb WITH(NOLOCK,READUNCOMMITTED)
							ON pa.BranchId=lb.Id
							INNER JOIN
							[Patient].[Patient] pp WITH(NOLOCK,READUNCOMMITTED)
							on pp.Id= pa.PatientId 
							INNER JOIN
							[Doctor].[Doctor] dd WITH(NOLOCK,READUNCOMMITTED)
							on dd.Id= pa.DoctorId 
							CROSS APPLY		
							(
							  SELECT
								CASE
									WHEN pa.IsDeleted = 1 THEN ''Cancelled''
									WHEN (pa.IsConfirmed=1 AND ((pa.IsCoordinatorAttended = 1 OR pa.IsPatientAttended=1) AND pa.IsDoctorAttended = 1)) THEN ''Completed''
                                    WHEN (pa.IsConfirmed=1 AND DATEADD(MINUTE, dd.AppointmentDurationInMin, pa.AppointmentDate) >= CONVERT(DATETIME, SWITCHOFFSET(GETUTCDATE(), ''+05:30'')) AND pa.IsRescheduled = 0) THEN ''Upcoming''		
									WHEN (pa.IsConfirmed=1 AND ((pa.IsCoordinatorAttended = 0 OR pa.IsPatientAttended=0) OR pa.IsDoctorAttended = 0) AND pa.AppointmentDate <= CONVERT(DATETIME, SWITCHOFFSET(GETUTCDATE(), ''+05:30''))) THEN ''Not Attended''
									WHEN (pa.IsRescheduled = 1 AND pa.AppointmentDate >= CONVERT(DATETIME, SWITCHOFFSET(GETUTCDATE(), ''+05:30''))) THEN ''Rescheduled''
								END AS Status
							) status
						 WHERE 
							pp.IsDeleted=0
							AND
							dd.IsDeleted=0
							AND 
							(status=''Upcoming'' OR status=''Rescheduled'') AND pa.IsConfirmed=1'+ @WhereClause+ ' ) as TotalCount '

   SET @AdditionalQuery+=' from tblAppStatus taps'
 
   SET @Query+= @SQL + @WhereClause  + @OrderByClause + @OffsetClause +')' + @AdditionalQuery + @FinalOrderBy
	
   PRINT @Query

   EXECUTE sp_executesql @Query

 SET NOCOUNT OFF
END
GO

