CREATE PROCEDURE [Doctor].[spGetAllDoctors]
  @PageNumber int=-1,
  @RowCount int=-1,
  @Keyword varchar(max)='',
  @OrderBy varchar(200) = '',
  @SortType varchar(5)='asc'

 AS

 /*

exec [Doctor].[spGetAllDoctors]  @PageNumber=1,@RowCount=1000,@Keyword='Dh',@OrderBy='',@SortType='desc'

select * from [Doctor].[Doctor] where firstname like 'Dhawal' 

select * from [Lookup].[DrQualification] 

select * from [Lookup].[DrSpecialization]

 MODIFICATIONS        
 Date					Author				Description          
 -----------------------------------------------------------------------------
 18/04/2023			M Chandrani	           Get all Details of doctors
 ------------------------------------------------------------------------------      
                Copyright 2023@YodaLIMS
*/ 

BEGIN
SET NOCOUNT ON

/*Main Query */
DECLARE @Query nvarchar(max)=''
DECLARE @SQL nvarchar(max)=''
DECLARE @SeletClause nvarchar(max)=''
DECLARE @WhereClause nvarchar(max)=''
DECLARE @OrderByClause nvarchar(max)=''
DECLARE @FinalOrderBy nvarchar(max)=''
DECLARE @OffsetClause nvarchar(max)=''
DECLARE @AdditionalQuery nvarchar(max)

SET @Keyword = IIF(@Keyword is null, '', TRIM(@Keyword))

If(@SortType = '' or @SortType is null)
BEGIN
	SET @SortType = 'asc'
END
	SET @SQL+=
   N';WITH tblDoctors(DoctorId,DoctorGuid,UserId,UserGuid,UserName,FirstName,LastName,Gender,DateOfBirth,ProfileURL,SignUrl,QualificationGuid,QualificationName,SpecializationGuid,SpecializationName,LanguagesGuid,Languages,ContactNumber,EmailId,CityGuid,City,StateGuid,State,Pincode,Address,RegistrationNumber,StateOfRegistrationGuid,StateOfRegistration,YearOfRegistration,RegistrationDate,RegistrationValidity,AlternateNumber,PracticeStartDate,ConsultationFee,Status,CreatedDt,DoctorName) as
	( 
	SELECT 
	 dd.Id as DoctorId,
	 dd.Guid as DoctorGuid,
	 dd.UserId,
	 du.UserGuid,
	 du.UserName,
	 dd.FirstName,
	 dd.LastName,
	 dd.Gender,
     CONVERT(varchar, dd.DateOfBirth, 105) as DateOfBirth,
	 dd.ProfileURL,
	 dd.SignUrl,
	 STUFF(
           COALESCE((
               SELECT '','' + CONVERT(VARCHAR(1000),Guid) 
               FROM lookup.DrQualification dq
               WHERE CHARINDEX('',''+ LTRIM(RTRIM(QualificationName)) + '','', '',''+ LTRIM(RTRIM(dd.QualificationName)) + '','') > 0 
               FOR XML PATH('''')
     ), ''''), 1, 1, '''') AS QualificationGuid,
	 dd.QualificationName,
	 STUFF(
           COALESCE((
               SELECT '','' + CONVERT(VARCHAR(1000),Guid) 
               FROM lookup.DrSpecialization ds
               WHERE CHARINDEX('',''+ LTRIM(RTRIM(SpecializationName)) + '','', '',''+ LTRIM(RTRIM(dd.SpecializationName)) + '','') > 0 
               FOR XML PATH('''')
     ), ''''), 1, 1, '''') AS SpecializationGuid,
	 dd.SpecializationName,
	 STUFF(
           COALESCE((
               SELECT '','' + CONVERT(VARCHAR(1000),Guid) 
               FROM lookup.Languages ll
               WHERE CHARINDEX('',''+ LTRIM(RTRIM(Languages)) + '','', '',''+ LTRIM(RTRIM(dd.languages)) + '','') > 0 
               FOR XML PATH('''')
     ), ''''), 1, 1, '''') AS LanguagesGuid,
	 dd.Languages,
	 dd.ContactNumber,
	 dd.EmailId,
	 lc.Guid as CityGuid,
	 dd.City,
	 ls.Guid as StateGuid,
	 dd.State,
	 dd.Pincode,
	 dd.Address,
	 dd.RegistrationNumber,
	 lsr.Guid as StateOfRegistrationGuid,
	 dd.StateOfRegistration,
	 dd.YearOfRegistration,
	 CONVERT(varchar, dd.RegistrationDate, 105) as RegistrationDate,
	 CONVERT(varchar, dd.RegistrationValidity, 105) as RegistrationValidity,
	 dd.AlternateNumber,
	 CONVERT(varchar, dd.PracticeStartDate, 105) as PracticeStartDate,
	 dd.ConsultationFee,
	 status.Status,
	 dd.CreatedDt,
	 concat( dd.FirstName ,'' '',  dd.LastName) as DoctorName
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
	CROSS APPLY
	(
		SELECT 
			CASE 
				WHEN (dd.IsAvailable=1)  THEN ''Online''
				WHEN (dd.IsAvailable=0) THEN ''Offline''
			END AS Status
	) status
	LEFT JOIN
	[dbo].[Users] du WITH(NOLOCK,READUNCOMMITTED)
	ON du.UserId=dd.UserId
 WHERE 
	dd.IsDeleted=0
	AND 
	du.IsDeleted=0'

  IF (@Keyword !=''  )
	BEGIN 
	SET @WhereClause+=' and ( dd.FirstName LIKE ''%'+ @Keyword +'%'' or dd.LastName LIKE ''%'+ @Keyword +'%'' or dd.EmailId LIKE ''%'+ @Keyword +'%'' or dd.ContactNumber LIKE ''%'+ @Keyword +'%'' or dd.AlternateNumber LIKE ''%'+ @Keyword +'%'' or CONCAT(TRIM(dd.FirstName), '' '', TRIM(dd.LastName)) LIKE ''%'+ @Keyword +'%'' or  dd.SpecializationName LIKE ''%'+ @Keyword +'%'' or dd.Languages LIKE ''%'+ @Keyword +'%'' or  dd.QualificationName LIKE ''%'+ @Keyword +'%''  or  dd.Address LIKE ''%'+ @Keyword +'%''  or  dd.City LIKE ''%'+ @Keyword +'%''  or  dd.State LIKE ''%'+ @Keyword +'%'' or Status LIKE ''%'+ @Keyword +'%'')' 
	END

  IF(@OrderBy='First name ' )
  BEGIN
  SET @OrderByClause+=' order by dd.FirstName '+ @SortType
  SET @FinalOrderBy +=' order by FirstName '+ @SortType
  END

  IF(@OrderBy='Last name' )
  BEGIN
  SET @OrderByClause+=' order by dd.LastName '+ @SortType	
  SET @FinalOrderBy +=' order by LastName '+ @SortType
  END	

  IF(@OrderBy='Qualification name' )
  BEGIN
  SET @OrderByClause+=' order by ld.QualificationName '+ @SortType
  SET @FinalOrderBy +=' order by QualificationName '+ @SortType
  END

  IF(@OrderBy='Specialization name' )
  BEGIN
  SET @OrderByClause+=' order by dd.SpecializationName '+ @SortType
  SET @FinalOrderBy +=' order by SpecializationName  '+ @SortType
  END
	
  IF(@OrderBy is null or @OrderBy = '' or @OrderBy='Latest')
  BEGIN
  SET @OrderByClause+=' order by dd.CreatedDt '+ @SortType
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
  SET @AdditionalQuery += ',(SELECT ISNULL((SELECT TOP 1 IsRequested FROM dbo.DeleteRequests dr WITH (NOLOCK, READUNCOMMITTED) WHERE dr.RequestedFor LIKE ''%'' + tds.DoctorName + ''%'' AND IsDeleted = 0), 0)) AS IsRequested'
  SET @AdditionalQuery += ',(SELECT TOP 1 Comments FROM dbo.DeleteRequests dr WITH (NOLOCK, READUNCOMMITTED) WHERE dr.RequestedFor LIKE ''%'' + tds.DoctorName + ''%'' AND IsDeleted = 0) AS Comments'
 -- OnlineCount Subquery
  SET @AdditionalQuery +=
    ', (SELECT 
            COUNT(DISTINCT CASE WHEN dd.IsAvailable = 1 THEN dd.UserId END) 
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
			CROSS APPLY
			(
				SELECT 
					CASE 
						WHEN (dd.IsAvailable=1)  THEN ''Online''
						WHEN (dd.IsAvailable=0) THEN ''Offline''
					END AS Status
			) status
			LEFT JOIN
			[dbo].[Users] du WITH(NOLOCK,READUNCOMMITTED)
			ON du.UserId=dd.UserId
		 WHERE 
			dd.IsDeleted=0
			AND 
			du.IsDeleted=0 ' 
    + @WhereClause + ' ) AS OnlineCount';

-- OfflineCount Subquery
   SET @AdditionalQuery +=
    ', (SELECT 
            COUNT(DISTINCT CASE WHEN dd.IsAvailable = 0 THEN dd.UserId END) 
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
			CROSS APPLY
			(
				SELECT 
					CASE 
						WHEN (dd.IsAvailable=1)  THEN ''Online''
						WHEN (dd.IsAvailable=0) THEN ''Offline''
					END AS Status
			) status
			LEFT JOIN
			[dbo].[Users] du WITH(NOLOCK,READUNCOMMITTED)
			ON du.UserId=dd.UserId
		 WHERE 
			dd.IsDeleted=0
			AND 
			du.IsDeleted=0 ' 
    + @WhereClause + ' ) AS OfflineCount';

   -- TotalCount Subquery
    SET @AdditionalQuery +=
    ', (SELECT 
            COUNT(DISTINCT dd.UserId) 
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
		CROSS APPLY
		(
			SELECT 
				CASE 
					WHEN (dd.IsAvailable=1)  THEN ''Online''
					WHEN (dd.IsAvailable=0) THEN ''Offline''
				END AS Status
		) status
		LEFT JOIN
		[dbo].[Users] du WITH(NOLOCK,READUNCOMMITTED)
		ON du.UserId=dd.UserId
	 WHERE 
		dd.IsDeleted=0
		AND 
		du.IsDeleted=0 ' 
    + @WhereClause + ' ) AS TotalCount';


SET @AdditionalQuery+=' from tblDoctors tds'
 
  SET @Query+= @SQL + @WhereClause  + @OrderByClause + @OffsetClause+ ')' + @AdditionalQuery + @FinalOrderBy
	
  PRINT @Query

EXECUTE sp_executesql @Query


SET NOCOUNT OFF
END
GO

