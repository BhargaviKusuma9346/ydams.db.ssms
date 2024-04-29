CREATE PROCEDURE [Patient].[spGetTodayAppointments] 
  @PageNumber int=-1,
  @RowCount int=-1,
  @OrderBy varchar(200) = '',
  @SortType varchar(5)='asc',
  @Keyword varchar(max)='',
  @PatientGuid uniqueIdentifier=null,
  @UserGuid uniqueIdentifier=null

 AS

 /*

exec [Patient].[spGetTodayAppointments] 
 @PageNumber=1,
 @RowCount=100,
 @OrderBy='DoctorName',
 @Keyword='',
 @SortType='desc', 
 @PatientGuid=null, 
 @UserGuid='C0C0B3D0-B106-499A-B5C0-F9746044B84A'

 select * from Patient.Appointment

 MODIFICATIONS        
 Date					Author				Description          
 -----------------------------------------------------------------------------
 18/04/2023			M Chandrani	           to get Todays Appointments
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
SET @Keyword = IIF(@Keyword is null, '', TRIM(@Keyword))
DECLARE @UserId varchar(100)
SELECT @UserId=UserId from dbo.Users where UserGuid=@UserGuid

If(@SortType = '' or @SortType is null)
BEGIN
	SET @SortType = 'asc'
END
	SET @SQL+=
   N';WITH tblAppStatus(DoctorGuid,DoctorName,DoctorId,DoctorProfileUrl,CoordinatorProfileUrl,PatientProfileUrl,SpecializationName,DoctorGender,AppointmentDuration,DoctorDateOfBirth,DoctorcontactNumber,DoctorEmailId,PatientGuid,PatientName,PatientId,PatientMobileNumber,PatientAlternateMobileNumber,PatientEmailId,PatientGender,PatientDateOfBirth,CoordinatorGuid,CoordinatorUserGuid,CoordinatorName,CoordinatorId,BranchGuid,BranchName,BranchAddress,BranchContactPerson,BranchContactPhone,BranchContactEmail,AppointmentGuid,AppointmentId,AppointmentDate,IsPatientAttended,IsDoctorAttended,IsCoordinatorAttended,AppointmentEndTime,Status,CreatedDt) as
	( 
	 SELECT 
	 dd.Guid as DoctorGuid,
	 CONCAT(dd.[FirstName],'' '',dd.[LastName]) as DoctorName,
	 dd.Id as DoctorId,
	 dd.ProfileUrl as DoctorProfileUrl,
	 cc.CoordinatorPhotoURL as CoordinatorProfileUrl,
	 pp.PatientPhotoURL as PatientProfileUrl,
	 dd.SpecializationName,
	 dd.Gender as DoctorGender,
	 dd.AppointmentDurationInMin as AppointmentDuration,
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
	 pa.IsDoctorAttended,
	 pa.IsCoordinatorAttended,
	 DATEADD(MINUTE, dd.AppointmentDurationInMin, pa.AppointmentDate) AS AppointmentEndTime,
	 status.Status,
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
	pp.IsDeleted=0
	AND
	dd.IsDeleted=0
	AND
	pa.IsConfirmed=1
	AND
	CAST(pa.AppointmentDate AS DATE) = CAST(GETDATE() AS DATE) '

	IF (@PatientGuid is not null)
	BEGIN 
	SET @WhereClause+=' AND (pp.Guid LIKE ''%'+ CAST(@PatientGuid AS nvarchar(200)) +'%'')'
	END

	IF (@UserGuid is not null)
	BEGIN 
	SET @WhereClause+=' AND (cc.UserId LIKE ''%'+ @UserId +'%'' or dd.UserId LIKE ''%'+ @UserId +'%'' or pp.UserId LIKE ''%'+ @UserId +'%'')'
	END
	IF (@Keyword !=''  )
    BEGIN 
    SET @WhereClause+='and ( dd.FirstName LIKE ''%'+ @Keyword +'%'' or dd.LastName LIKE ''%'+ @Keyword +'%'' or lb.branchname LIKE ''%'+ @Keyword +'%'' or CONCAT(TRIM(pp.FirstName), '' '', TRIM(pp.LastName)) LIKE ''%'+ @Keyword +'%'' or dd.SpecializationName LIKE ''%'+ @Keyword +'%'' or Status LIKE ''%'+ @Keyword +'%'' or CONCAT(TRIM(dd.FirstName), '' '', TRIM(dd.LastName)) LIKE ''%'+ @Keyword +'%'')'
    END
   IF(@OrderBy='Status ' )
  BEGIN
  SET @OrderByClause+=' order by Status '+ @SortType
  SET @FinalOrderBy+=' order by Status '+ @SortType
  END

  IF(@OrderBy='AppointmentDate ' )
  BEGIN
  SET @OrderByClause+=' order by AppointmentDate '+ @SortType
  SET @FinalOrderBy+=' order by AppointmentDate '+ @SortType
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
							pp.IsDeleted=0
							AND
							dd.IsDeleted=0
							AND 
							pa.IsConfirmed=1
	                        AND
							CAST(pa.AppointmentDate AS DATE) = CAST(GETDATE() AS DATE)'+ @WhereClause+ ' ) as TotalCount '

   SET @AdditionalQuery+=' from tblAppStatus taps'
 
   SET @Query+= @SQL + @WhereClause  + @OrderByClause + @OffsetClause +')' + @AdditionalQuery + @FinalOrderBy
	
   PRINT @Query

   EXECUTE sp_executesql @Query

 SET NOCOUNT OFF
END
GO

