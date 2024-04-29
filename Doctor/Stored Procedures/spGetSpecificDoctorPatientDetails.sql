CREATE  PROCEDURE [Doctor].[spGetSpecificDoctorPatientDetails]
  @PageNumber int=-1,
  @RowCount int=-1,
  @Keyword varchar(max)='',
  @OrderBy varchar(200) = '',
  @SortType varchar(5)='asc',
  @UserGuid uniqueIdentifier=null

 AS

 /*

exec [Doctor].[spGetSpecificDoctorPatientDetails] @PageNumber=1,@RowCount=10,@Keyword='',@OrderBy='',@SortType='desc',@UserGuid='f5b9078b-9aac-4021-ab12-b6364f1dcbd1'

select * from [Patient].[Patient] where mobileNumber='8675424355'

 MODIFICATIONS        
 Date					Author				Description          
 -----------------------------------------------------------------------------
 18/04/2023			Ravali D	           Created
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

DECLARE @UserId varchar(100)
SELECT @UserId=UserId from dbo.Users where UserGuid=@UserGuid

DECLARE @DoctorId varchar(max)
SELECT @DoctorId =Id from  Doctor.Doctor where UserId=@UserId

print @DoctorId


If(@SortType = '' or @SortType is null)
BEGIN
	SET @SortType = 'asc'
END
	SET @SQL+=
   ';WITH tblPatients(PatientId,PatientGuid,PatientUserId,PatientUserGuid,Title,FirstName,MiddleName,LastName,CountryCode,MobileNumber,AlternateMobileNumber,EmailId,Gender,DateOfBirth,AddressProofTypeGuid,AddressProofType,IdentificationNumber,MaritalStatus,OccupationGuid,OccupationName,ReligionGuid,ReligionName,IncomeGroupGuid,IncomeGroupName,EducationGuid,EducationName,BloodGroup,RelationshipTypeGuid,RelationshipType,RelationName,MothersMaidenName,CityGuid,CityName,StateGuid,StateName,Address1,Address2,PatientPhotoURL,CreatedByUserId,BranchName,CoordinatorName,CreatedDt,LastConsultedDate,PatientName,ModifiedBy,ModifiedDt) as
	( 
	SELECT distinct 
	 pp.Id as PatientId ,
	 pp.Guid as PatientGuid,
	 pp.UserId as PatientUserId,
	 du.UserGuid as PatientUserGuid,
	 pp.Title, 
	 pp.FirstName,
	 pp.MiddleName,
	 pp.LastName,
	 pp.CountryCode,
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
	 pp.CreatedByUserId,
	 pp.BranchName,
	(SELECT concat(FirstName,'' '',LastName) from dbo.users WHERE UserId=pp.CreatedByUserId)  AS CoordinatorName,
	 pp.CreatedDt,
	(SELECT AppointmentDate FROM [Patient].[Appointment] WHERE PatientId = pp.Id AND AppointmentDate <= CONVERT(DATETIME, SWITCHOFFSET(GETUTCDATE(), ''+05:30'')) ORDER BY AppointmentDate DESC OFFSET 0 ROWS FETCH NEXT 1 ROWS ONLY),
    concat(pp.FirstName ,'' '', pp.LastName) as PatientName,
	pp.ModifiedBy,
	pp.ModifiedDt
	FROM
	[Patient].[Patient] pp WITH(NOLOCK,READUNCOMMITTED)
	left join 
    [Patient].[Appointment] PA WITH(NOLOCK,READUNCOMMITTED)
	on PA.PatientId=pp.Id 	AND PA.IsConfirmed=1
    INNER JOIN
	[Lookup].[City] lc WITH(NOLOCK,READUNCOMMITTED)
	ON pp.CityId = lc.Id 
	INNER JOIN
	[Lookup].[State] ls WITH(NOLOCK,READUNCOMMITTED)
	ON pp.StateId = ls.Id
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
	INNER JOIN
	[dbo].[Users] du WITH(NOLOCK,READUNCOMMITTED)
	ON du.UserId=pp.UserId
  WHERE 
	pp.IsDeleted=0
	AND
	lc.IsDeleted=0
	AND 
	ls.IsDeleted=0
	AND
	du.IsDeleted=0'

  IF (@Keyword !=''  )
	BEGIN 
	SET @WhereClause+='and ( pp.FirstName LIKE ''%'+ @Keyword +'%'' or pp.MiddleName LIKE ''%'+ @Keyword +'%'' or pp.LastName LIKE ''%'+ @Keyword +'%'' or pp.Email LIKE ''%'+ @Keyword +'%'' or pp.MobileNumber LIKE ''%'+ @Keyword +'%'' or pp.AlternativeMobileNumber LIKE ''%'+ @Keyword +'%'' or CONCAT(TRIM(pp.FirstName), '' '', TRIM(pp.MiddleName),'' '', TRIM(pp.LastName)) LIKE ''%'+ @Keyword +'%'' or pp.BranchName LIKE ''%'+ @Keyword +'%'' or CONCAT(TRIM(pp.FirstName), '' '', TRIM(pp.LastName)) LIKE ''%'+ @Keyword +'%'')'
	END

  IF (@UserGuid is not null)
	BEGIN 
	SET @WhereClause+=' AND (pp.CreatedByUserId LIKE ''%'+ @UserId +'%'' or pp.ModifiedBy LIKE ''%'+ @UserId +'%'' or pa.DoctorId LIKE ''%'+ @DoctorId +'%'')'
	END


  IF(@OrderBy='First name ' )
  BEGIN
  SET @OrderByClause+=' order by FirstName '+ @SortType
  SET @FinalOrderBy +=' order by FirstName '+ @SortType
  END

  IF(@OrderBy='Last name' )
  BEGIN
  SET @OrderByClause+=' order by LastName '+ @SortType
  SET @FinalOrderBy +=' order by LastName '+ @SortType
  END	

  IF(@OrderBy='Middle name' )
  BEGIN
  SET @OrderByClause+=' order by MiddleName '+ @SortType
  SET @FinalOrderBy +=' order by MiddleName '+ @SortType
  END

  IF(@OrderBy='Branch name' )
  BEGIN
  SET @OrderByClause+=' order by BranchName '+ @SortType
  SET @FinalOrderBy +=' order by BranchName '+ @SortType
  END
	
 IF (@OrderBy = 'CreatedDt')
    BEGIN
        SET @OrderByClause += ' ORDER BY CreatedDt ' + @SortType
        SET @FinalOrderBy += ' ORDER BY CreatedDt DESC '
    END
    ELSE
    BEGIN
        SET @OrderByClause += ' ORDER BY ModifiedDt ' + @SortType
        SET @FinalOrderBy += ' ORDER BY ModifiedDt DESC '
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
SET @AdditionalQuery+=',(Select count(distinct pp.Id)	 	
		                   FROM 
							[Patient].[Patient] pp WITH(NOLOCK,READUNCOMMITTED)
	                        left join 
                            [Patient].[Appointment] PA WITH(NOLOCK,READUNCOMMITTED)
	                        on PA.PatientId=pp.Id 	AND PA.IsConfirmed=1
                            INNER JOIN
	                        [Lookup].[City] lc WITH(NOLOCK,READUNCOMMITTED)
	                        ON pp.CityId = lc.Id 
	                        INNER JOIN
	                        [Lookup].[State] ls WITH(NOLOCK,READUNCOMMITTED)
	                        ON pp.StateId = ls.Id
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
	                        INNER JOIN
	                        [dbo].[Users] du WITH(NOLOCK,READUNCOMMITTED)
	                        ON du.UserId=pp.UserId
                   WHERE 
	                     pp.IsDeleted=0
						 AND
						 lc.IsDeleted=0
						 AND 
						 ls.IsDeleted=0
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

