CREATE PROCEDURE [Patient].[spGetAllPatients]
  @PageNumber int=-1,
  @RowCount int=-1,
  @Keyword varchar(max)='',
  @OrderBy varchar(200) = '',
  @SortType varchar(5)='asc',
  @CreatedByUserGuid uniqueIdentifier=null,
  @Phonenumber varchar(200)=null

 AS

 /*

exec [Patient].[spGetAllPatients] @PageNumber=1,@RowCount='',@Keyword='',@OrderBy='',@SortType='desc',@CreatedByUserGuid=null,@Phonenumber=null

select * from [Patient].[Patient] order by 1 desc

 MODIFICATIONS        
 Date					Author				Description          
 -----------------------------------------------------------------------------
 18/04/2023			M Chandrani	           Get all Details of Patients based on UserId
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

DECLARE @CreatedByUserId varchar(100)
SELECT @CreatedByUserId=UserId from dbo.Users where UserGuid=@CreatedByUserGuid

If(@SortType = '' or @SortType is null)
BEGIN
	SET @SortType = 'asc'
END
	SET @SQL+=
   ';WITH tblPatients(PatientId,PatientGuid,PatientUserId,PatientUserGuid,CreatedByUserId,CreatedByUserGuid,CreatedByUserTypeId,Title,FirstName,MiddleName,LastName,CountryCode,MobileNumber,AlternateMobileNumber,EmailId,Gender,DateOfBirth,AddressProofTypeGuid,AddressProofType,IdentificationNumber,MaritalStatus,OccupationGuid,OccupationName,ReligionGuid,ReligionName,IncomeGroupGuid,IncomeGroupName,EducationGuid,EducationName,BloodGroup,RelationshipTypeGuid,RelationshipType,RelationName,MothersMaidenName,CityGuid,CityName,StateGuid,StateName,Address1,Address2,PatientPhotoURL,BranchName,CoordinatorName,CreatedDt,LastConsultedDate,PatientName,ModifiedByUserGuid) as
	( 
	SELECT 
	 pp.Id as PatientId ,
	 pp.Guid as PatientGuid,
	 du.UserId as PatientUserId,
	 du.UserGuid as PatientUserGuid,
	 pp.CreatedByUserId,
	 (SELECT userguid from dbo.users where userid=CreatedByUserId) as CreatedByUserGuid,
	 (SELECT CASE du.UserTypeId
        WHEN ''1'' THEN ''Admin''
        WHEN ''2'' THEN ''Coordinator''
        WHEN ''3'' THEN ''Doctor''
        WHEN ''5'' THEN ''Patient''
     END AS UserTypeId 
	 FROM dbo.users du 
	 where du.UserId=pp.CreatedByUserId),
	 pp.Title, 
	 pp.FirstName,
	 pp.MiddleName,
	 pp.LastName,
	 du.CountryCode,
	 pp.MobileNumber,
	 pp.AlternativeMobileNumber as AlternateMobileNumber,
	 pp.Email as EmailId,
	 pp.Gender,
	 CONVERT(varchar, pp.DateOfBirth, 105) as DateOfBirth,
	 apt.Guid as AddressProofTypeGuid,
     pp.AddressProofType,
     pp.IdentificationNumber,
     pp.MaritalStatus,
	 oo.Guid as OccupationGuid,
     pp.OccupationName,
	 rn.Guid as ReligionGuid,
     pp.ReligionName,
	 ign.Guid as IncomeGroupGuid,
     pp.IncomeGroupName,
	 en.Guid as EducationGuid,
     pp.EducationName,
     pp.BloodGroup,
	 rt.Guid as RelationshipTypeGuid,
     pp.RelationshipType,
     pp.RelationName,
     pp.MothersMaidenName,
	 lc.Guid as CityGuid,
     pp.CityName,
	 ls.Guid as StateGuid,
     pp.StateName,
     pp.Address1,
     pp.Address2,
     pp.PatientPhotoURL,
	 pp.BranchName,
	(SELECT concat(FirstName,'' '',LastName) from dbo.users WHERE UserId=pp.CreatedByUserId)  AS CoordinatorName,
	 pp.CreatedDt,
	(SELECT AppointmentDate FROM [Patient].[Appointment] WHERE PatientId = pp.Id and ((IsPatientAttended=1 or IsCoordinatorAttended=1) and IsDoctorAttended=1) ORDER BY AppointmentDate DESC OFFSET 0 ROWS FETCH NEXT 1 ROWS ONLY),
    concat(pp.FirstName ,'' '', pp.LastName) as PatientName,
	du1.UserGuid
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
	du.IsDeleted=0'

  IF (@Keyword !=''  )
	BEGIN 
	SET @WhereClause+='and ( pp.FirstName LIKE ''%'+ @Keyword +'%'' or pp.MiddleName LIKE ''%'+ @Keyword +'%'' or pp.LastName LIKE ''%'+ @Keyword +'%'' or pp.Email LIKE ''%'+ @Keyword +'%'' or du.PhoneNumber LIKE ''%'+ @Keyword +'%'' or pp.AlternativeMobileNumber LIKE ''%'+ @Keyword +'%'' or CONCAT(TRIM(pp.FirstName), '' '', TRIM(pp.MiddleName),'' '', TRIM(pp.LastName)) LIKE ''%'+ @Keyword +'%'' or pp.BranchName LIKE ''%'+ @Keyword +'%'' or CONCAT(TRIM(pp.FirstName), '' '', TRIM(pp.LastName)) LIKE ''%'+ @Keyword +'%'' or (SELECT concat(FirstName,'' '',LastName) from dbo.users WHERE UserId=pp.CreatedByUserId) LIKE ''%'+ @Keyword +'%'')'
	END

  IF (@CreatedByUserGuid is not null)
	BEGIN 
	SET @WhereClause+=' AND (pp.CreatedByUserId LIKE ''%'+ @CreatedByUserId +'%'')'
	END

   IF (@Phonenumber is not null)
	BEGIN 
	SET @WhereClause+=' AND pp.MobileNumber = ''' + @Phonenumber + ''''
	END

  IF(@OrderBy='First name ' )
  BEGIN
  SET @OrderByClause+=' order by FirstName '+ @SortType
  SET @FinalOrderBy +=' order by FirstName '+ @SortType
  END

  IF(@OrderBy='LastName' )
  BEGIN
  SET @OrderByClause+=' order by LastName '+ @SortType
  SET @FinalOrderBy +=' order by LastName '+ @SortType
  END	

  IF(@OrderBy='MiddleName' )
  BEGIN
  SET @OrderByClause+=' order by MiddleName '+ @SortType
  SET @FinalOrderBy +=' order by MiddleName '+ @SortType
  END

  IF(@OrderBy='BranchName' )
  BEGIN
  SET @OrderByClause+=' order by BranchName '+ @SortType
  SET @FinalOrderBy +=' order by BranchName '+ @SortType
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
SET @AdditionalQuery += ',(SELECT ISNULL((SELECT TOP 1 IsRequested FROM dbo.DeleteRequests dr WITH (NOLOCK, READUNCOMMITTED) WHERE dr.RequestedFor LIKE ''%'' + tps.PatientName + ''%'' AND IsDeleted = 0), 0)) AS IsRequested'
SET @AdditionalQuery += ',(SELECT TOP 1 Comments FROM dbo.DeleteRequests dr WITH (NOLOCK, READUNCOMMITTED) WHERE dr.RequestedFor LIKE ''%'' + tps.PatientName + ''%'' AND IsDeleted = 0) AS Comments'
SET @AdditionalQuery += ',(SELECT TOP 1 CAST(CASE WHEN pp.RelationId IS NOT NULL THEN 1 ELSE 0 END AS BIT) AS IsRelation
FROM [Patient].[Patient] pp WITH (NOLOCK, READUNCOMMITTED)
WHERE pp.Id = tps.PatientId AND pp.IsDeleted = 0) AS IsRelation'
SET @AdditionalQuery+=',(Select count(DISTINCT pp.Guid ) FROM 	 
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
							du.IsDeleted=0 '
							 + @WhereClause+ ' ) as TotalCount '

SET @AdditionalQuery+=' from tblPatients tps'
 
  SET @Query+= @SQL + @WhereClause  + @OrderByClause + @OffsetClause+ ')' + @AdditionalQuery + @FinalOrderBy
	
  PRINT @Query

EXECUTE sp_executesql @Query


SET NOCOUNT OFF
END
GO

