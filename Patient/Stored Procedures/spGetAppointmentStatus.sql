CREATE PROCEDURE [Patient].[spGetAppointmentStatus] 
  @PageNumber int=-1,
  @RowCount int=-1,
  @Keyword varchar(max)='',
  @OrderBy varchar(200) = '',
  @SortType varchar(5)='asc',
  @UserGuid uniqueIdentifier=null,
  @DoctorGuid uniqueIdentifier=null,
  @PatientGuid uniqueIdentifier=null,
  @CoordinatorGuid uniqueIdentifier=null,
  @Status varchar(200)=''

 AS

 /*


exec [Patient].[spGetAppointmentStatus]  
 @PageNumber=-1,
 @RowCount=-1,
 @Keyword='',
 @OrderBy='',
 @SortType='desc', 
 @DoctorGuid=null,
 @PatientGuid=null,
 @CoordinatorGuid=null,
 @UserGuid=null,
 @Status=''

 select * from Patient.Appointment order by 1 desc


 MODIFICATIONS        
 Date					Author				Description          
 -----------------------------------------------------------------------------
 18/04/2023			M Chandrani	           to get Appointment Categories
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
SET @Keyword = IIF(@Keyword is null, '', TRIM(@Keyword))

If(@SortType = '' or @SortType is null)
BEGIN
	SET @SortType = 'asc'
END
	SET @SQL+=
   N';WITH tblAppStatus(PatientGuid,PatientName,PatientId,DoctorProfileUrl,CoordinatorProfileUrl,BloodGroup,PatientProfileUrl,PatientMobileNumber,PatientAlternateMobileNumber,PatientEmailId,PatientGender,PatientDateOfBirth,DoctorGuid,DoctorName,DoctorId,SpecializationName,DoctorGender,DoctorDateOfBirth,DoctorcontactNumber,DoctorEmailId,AppointmentGuid,AppointmentId,CoordinatorGuid,CoordinatorUserGuid,CoordinatorName,CoordinatorId,CoordinatorContactNumber,CoordinatorAlternateNumber,CoordinatorEmailId,BranchGuid,BranchName,BranchAddress,BranchContactPerson,BranchContactPhone,BranchContactEmail,AppointmentName,Description,IsPatientAttended,IsCoordinatorAttended,IsDoctorAttended,IsRescheduled,AppointmentDate,VideoUrl,AppointmentDuration,AppointmentEndTime,PreviousAppointmentId,NextReviewDate,Status,LastConsultedDate,LastDoctorGuid,LastDoctorName,CreatedDt) as
	( 
	 SELECT 
	 pp.Guid as PatientGuid,
	 CONCAT(pp.[FirstName],'' '',pp.[MiddleName],'' '',pp.[LastName]) as PatientName,
	 pp.Id as PatientId,
	 dd.ProfileUrl as DoctorProfileUrl,
	 cc.CoordinatorPhotoURL as CoordinatorProfileUrl,
	 pp.BloodGroup,
	 pp.PatientPhotoURL as PatientProfileUrl,
	 pp.MobileNumber as PatientMobileNumber,
	 pp.AlternativeMobileNumber as PatientAlternateMobileNumber,
	 pp.Email as PatientEmailId,
	 pp.Gender as PatientGender,
	 CONVERT(varchar, pp.DateOfBirth, 105) as PatientDateOfBirth,
	 dd.Guid as DoctorGuid,
	 CONCAT(dd.[FirstName],'' '',dd.[LastName]) as DoctorName,
	 dd.Id as DoctorId,
	 dd.SpecializationName,
	 dd.Gender as DoctorGender,
     CONVERT(varchar, dd.DateOfBirth, 105) as DoctorDateOfBirth,
	 dd.ContactNumber as DoctorcontactNumber,
	 dd.EmailId as DoctorEmailId,
     pa.Guid as AppointmentGuid,
	 pa.Id as AppointmentId,
     cc.Guid as CoordinatorGuid,
	 (SELECT UserGuid from dbo.users where userid=cc.UserId) as CoordinatorUserGuid,
	 CONCAT(cc.[FirstName],'' '',cc.[LastName]) as CoordinatorName,	
	 cc.Id as CoordinatorId,
	 cc.ContactNumber as CoordinatorContactNumber,
	 cc.AlternateNumber as CoordinatorAlternateNumber,
	 cc.EmailId as CoordinatorEmailId,
	 lb.Guid as BranchGuid,
	 lb.BranchName,
	 lb.Address as BranchAddress,
	 lb.ContactName as BranchContactPerson,
	 lb.ContactEmail as BranchContactEmail,
	 lb.ContactPhone as BranchContactPhone,
	 pa.AppointmentName,
	 pa.Description,
	 CASE WHEN pa.IsPatientAttended = 1 THEN ''true'' ELSE ''false'' END AS IsPatientAttended ,
	 CASE WHEN pa.IsCoordinatorAttended = 1 THEN ''true'' ELSE ''false'' END AS IsCoordinatorAttended,
	 CASE WHEN pa.IsDoctorAttended = 1 THEN ''true'' ELSE ''false'' END AS IsDoctorAttended,
	 CASE WHEN pa.IsRescheduled = 1 THEN ''true'' ELSE ''false'' END AS IsRescheduled,
	 pa.AppointmentDate,
	 pa.VideoUrl,
	 pa.AppointmentDuration,
	 DATEADD(MINUTE, dd.AppointmentDurationInMin, pa.AppointmentDate) AS AppointmentEndTime,
	 pa.PreviousAppointmentId,
	 pa.NextReviewDate,
	 status.Status,
     (SELECT AppointmentDate 
	    FROM [Patient].[Appointment] 
		WHERE 
		PatientId = pp.Id AND AppointmentDate <= CONVERT(DATETIME, SWITCHOFFSET(GETUTCDATE(), ''+05:30'')) 
		ORDER BY AppointmentDate DESC 
		OFFSET 0 ROWS FETCH NEXT 1 ROWS ONLY) AS LastConsultedDate,
	 (SELECT dd.Guid as LastDoctorGuid 
		FROM [Patient].[Appointment] pa
		inner join
		doctor.doctor dd
		on dd.Id=pa.DoctorId
		WHERE PatientId = pp.Id 
		AND AppointmentDate <= CONVERT(DATETIME, SWITCHOFFSET(GETUTCDATE(), ''+05:30''))
		ORDER BY AppointmentDate DESC OFFSET 0 ROWS FETCH NEXT 1 ROWS ONLY),
	 (SELECT CONCAT(dd.[FirstName],'' '',dd.[LastName]) as LastDoctorName 
		FROM [Patient].[Appointment] pa
		inner join
		doctor.doctor dd
		on dd.Id=pa.DoctorId
		WHERE PatientId = pp.Id 
		AND AppointmentDate <= CONVERT(DATETIME, SWITCHOFFSET(GETUTCDATE(), ''+05:30'')) 
		ORDER BY AppointmentDate DESC OFFSET 0 ROWS FETCH NEXT 1 ROWS ONLY),
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
            WHEN (pa.IsConfirmed=1 AND (DATEADD(MINUTE, dd.AppointmentDurationInMin, pa.AppointmentDate) >= CONVERT(DATETIME, SWITCHOFFSET(GETUTCDATE(), ''+05:30''))) AND pa.IsRescheduled = 0) THEN ''Upcoming''		
			WHEN (pa.IsConfirmed=1 AND ((pa.IsCoordinatorAttended = 0 OR pa.IsPatientAttended=0) OR pa.IsDoctorAttended = 0) AND pa.AppointmentDate <= CONVERT(DATETIME, SWITCHOFFSET(GETUTCDATE(), ''+05:30''))) THEN ''Not Attended''
			WHEN (pa.IsRescheduled = 1 AND pa.AppointmentDate >= CONVERT(DATETIME, SWITCHOFFSET(GETUTCDATE(), ''+05:30''))) THEN ''Rescheduled''
		END AS Status
	) status	
 WHERE 
	(pp.IsDeleted=0
	AND
	dd.IsDeleted=0
	AND
	pa.IsConfirmed=1) '

	IF (@PatientGuid IS NOT NULL)
	BEGIN 
		SET @WhereClause += ' AND pp.Guid LIKE ''%' + CONVERT(varchar(36), @PatientGuid) + '%'''
	END

	IF (@DoctorGuid IS NOT NULL)
	BEGIN 
		SET @WhereClause += ' AND dd.Guid LIKE ''%' + CONVERT(varchar(36), @DoctorGuid) + '%'''
	END

	IF (@CoordinatorGuid IS NOT NULL)
	BEGIN 
		SET @WhereClause += ' AND cc.Guid LIKE ''%' + CONVERT(varchar(36), @CoordinatorGuid) + '%'''
	END

	IF (@UserGuid IS NOT NULL)
	BEGIN 
		SET @WhereClause += ' AND (cc.UserId = '''+ @UserId +''' or dd.UserId = '''+ @UserId +''' or pp.UserId = '''+ @UserId +''')'
	END

	IF (@Keyword!='')
	BEGIN 
	SET @WhereClause+=' AND (Status =''' + @Keyword+''' or CONCAT(TRIM(pp.FirstName), '' '', TRIM(pp.LastName)) LIKE ''%'+ @Keyword +'%'' or CONCAT(TRIM(dd.FirstName), '' '', TRIM(dd.LastName)) LIKE ''%'+ @Keyword +'%'' or dd.FirstName LIKE ''%'+ @Keyword +'%'' or dd.LastName LIKE ''%'+ @Keyword +'%'' or lb.BranchName LIKE ''%'+ @Keyword +'%'' or pp.Email LIKE ''%'+ @Keyword +'%'' or pp.MobileNumber LIKE ''%'+ @Keyword +'%'' or pp.AlternativeMobileNumber LIKE ''%'+ @Keyword +'%'' or CONCAT(TRIM(pp.FirstName), '' '', TRIM(pp.MiddleName),'' '', TRIM(pp.LastName)) LIKE ''%'+ @Keyword +'%'' or pp.FirstName LIKE ''%'+ @Keyword +'%'' or pp.MiddleName LIKE ''%'+ @Keyword +'%'' or pp.LastName LIKE ''%'+ @Keyword +'%'' or lb.BranchName LIKE ''%'+ @Keyword +'%'')'
	END

 IF(@OrderBy='Status ' )
  BEGIN
  SET @OrderByClause+=' order by Status '+ @SortType
  SET @FinalOrderBy+=' order by Status '+ @SortType
  END

 IF(@OrderBy='First name ' )
  BEGIN
  SET @OrderByClause+=' order by PatientName '+ @SortType
  SET @FinalOrderBy+=' order by PatientName '+ @SortType
  END
	
  IF(@OrderBy is null or @OrderBy = '')
  BEGIN
  SET @OrderByClause+=' order by AppointmentDate '+ @SortType
  SET @FinalOrderBy +=' order by AppointmentDate '+ @SortType
  END
  
   IF(@OrderBy='LastDoctorName' )
  BEGIN
  SET @OrderByClause+=' order by LastDoctorName '+ @SortType
  SET @FinalOrderBy+=' order by LastDoctorName '+ @SortType
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
										WHEN (pa.IsConfirmed=1 AND (DATEADD(MINUTE, dd.AppointmentDurationInMin, pa.AppointmentDate) >= CONVERT(DATETIME, SWITCHOFFSET(GETUTCDATE(), ''+05:30''))) AND pa.IsRescheduled = 0) THEN ''Upcoming''		
										WHEN (pa.IsConfirmed=1 AND ((pa.IsCoordinatorAttended = 0 OR pa.IsPatientAttended=0) OR pa.IsDoctorAttended = 0) AND pa.AppointmentDate <= CONVERT(DATETIME, SWITCHOFFSET(GETUTCDATE(), ''+05:30''))) THEN ''Not Attended''
										WHEN (pa.IsRescheduled = 1 AND pa.AppointmentDate >= CONVERT(DATETIME, SWITCHOFFSET(GETUTCDATE(), ''+05:30''))) THEN ''Rescheduled''
									END AS Status
								) status
						WHERE 
							pp.IsDeleted=0
							AND
							dd.IsDeleted=0 
							AND
							pa.IsConfirmed=1'+ @WhereClause+ ' ) as TotalCount '

   SET @AdditionalQuery+=' from tblAppStatus taps'
 
   SET @Query+= @SQL + @WhereClause  + @OrderByClause + @OffsetClause +')' + @AdditionalQuery + @FinalOrderBy
	
   PRINT @Query

   EXECUTE sp_executesql @Query

 SET NOCOUNT OFF
END
GO

