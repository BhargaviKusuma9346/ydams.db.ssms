CREATE PROCEDURE [Coordinator].[spGetAllCoordinators]
  @PageNumber int=-1,
  @RowCount int=-1,
  @Keyword varchar(max)='',
  @OrderBy varchar(200) = '',
  @SortType varchar(5)='asc'

 AS

 /*

exec [Coordinator].[spGetAllCoordinators] @PageNumber=-1,@RowCount=-1,@Keyword='',@OrderBy='',@SortType='desc'

select * from [Coordinator].[Coordinator] 


select * from [Lookup].[Branch] 

 MODIFICATIONS        
 Date					Author				Description          
 -----------------------------------------------------------------------------
 18/04/2023			M Chandrani	           Get all Details of Coordinators
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
   ';WITH tblCoordinators(CoordinatorGuid,UserId,UserGuid,UserName,FirstName,LastName,ContactNumber,AlternateNumber,EmailId,Gender,DateOfBirth,Branches,BranchGuid,BranchLatitude,BranchLongitude,WorkDays,WorkHours,PreferredContactTypeGuid,PreferredContactType,LanguagesGuid,Languages,CoordinatorPhotoURL,CreatedDt,DefaultBranch) as
	( 
	 SELECT 
     cc.Guid as CoordinatorGuid,
	 cc.UserId,
	 du.UserGuid,
	 du.UserName,
	 cc.FirstName,
	 cc.LastName,
	 cc.ContactNumber,
	 cc.AlternateNumber,
	 cc.EmailId,
	 cc.Gender,
     CONVERT(varchar, cc.DateOfBirth, 105) as DateOfBirth,
	 cc.Branches,
	 STUFF(
           COALESCE((
               SELECT '','' + CONVERT(VARCHAR(1000),Guid) 
               FROM lookup.Branch lb
               WHERE CHARINDEX('',''+ LTRIM(RTRIM(BranchName)) + '','', '',''+ LTRIM(RTRIM(cc.Branches)) + '','') > 0 
               FOR XML PATH('''')
     ), ''''), 1, 1, '''') AS BranchGuid,
	 STUFF(
           COALESCE((
               SELECT '','' + CONVERT(VARCHAR(1000),Latitude) 
               FROM lookup.Branch lb
               WHERE CHARINDEX('',''+ LTRIM(RTRIM(BranchName)) + '','', '',''+ LTRIM(RTRIM(cc.Branches)) + '','') > 0 
               FOR XML PATH('''')
     ), ''''), 1, 1, '''') AS BranchLatitude,
	 STUFF(
           COALESCE((
               SELECT '','' + CONVERT(VARCHAR(1000),Longitude) 
               FROM lookup.Branch lb
               WHERE CHARINDEX('',''+ LTRIM(RTRIM(BranchName)) + '','', '',''+ LTRIM(RTRIM(cc.Branches)) + '','') > 0 
               FOR XML PATH('''')
     ), ''''), 1, 1, '''') AS BranchLongitude,
	 cc.WorkDays,
	 cc.WorkHours,
	 STUFF(
           COALESCE((
               SELECT '','' + CONVERT(VARCHAR(1000),Guid) 
               FROM lookup.PreferredContactType lp
               WHERE CHARINDEX('',''+ LTRIM(RTRIM(PreferredContactType)) + '','', '',''+ LTRIM(RTRIM(cc.PreferredContactType)) + '','') > 0 
               FOR XML PATH('''')
     ), ''''), 1, 1, '''') AS PreferredContactTypeGuid,
	 cc.PreferredContactType,
	 STUFF(
           COALESCE((
               SELECT '','' + CONVERT(VARCHAR(1000),Guid) 
               FROM lookup.Languages ll
               WHERE CHARINDEX('',''+ LTRIM(RTRIM(Languages)) + '','', '',''+ LTRIM(RTRIM(cc.languages)) + '','') > 0 
               FOR XML PATH('''')
     ), ''''), 1, 1, '''') AS LanguageGuid,
	 cc.Languages,
	 cc.CoordinatorPhotoURL,
	 cc.CreatedDt,
   lb.BranchName AS DefaultBranch
    FROM 
        [Coordinator].[Coordinator] cc WITH(NOLOCK,READUNCOMMITTED)
    INNER JOIN
        [dbo].[Users] du WITH(NOLOCK,READUNCOMMITTED)
    ON du.UserId=cc.UserId
    LEFT JOIN
        [mapping].[CoordinatorBranches] mpc ON mpc.CoordinatorId = cc.Id AND (mpc.Isdeleted = 0 AND mpc.Isdefault = 1)
    LEFT JOIN
        [Lookup].[Branch] lb ON lb.Id = mpc.BranchId AND lb.Isdeleted = 0
    WHERE 
        (cc.IsDeleted = 0	
        AND
        du.IsDeleted = 0		
        ) '

   IF (@Keyword !=''  )
	BEGIN 
	SET @WhereClause+='and ( cc.FirstName LIKE ''%'+ @Keyword +'%'' or cc.Branches LIKE ''%'+ @Keyword +'%'' or cc.LastName LIKE ''%'+ @Keyword +'%'' or cc.EmailId LIKE ''%'+ @Keyword +'%'' or cc.ContactNumber LIKE ''%'+ @Keyword +'%'' or cc.AlternateNumber LIKE ''%'+ @Keyword +'%'' or CONCAT(TRIM(cc.FirstName), '' '', TRIM(cc.LastName)) LIKE ''%'+ @Keyword +'%'')'
	END
  IF(@OrderBy='First name ' )
  BEGIN
  SET @OrderByClause+=' order by cc.FirstName '+ @SortType
  SET @FinalOrderBy +=' order by FirstName '+ @SortType
  END

  IF(@OrderBy='Last name' )
  BEGIN
  SET @OrderByClause+=' order by cc.LastName '+ @SortType
  SET @FinalOrderBy +=' order by LastName '+ @SortType
  END	
	
  IF(@OrderBy is null or @OrderBy = '' or @OrderBy='Latest')
  BEGIN
  SET @OrderByClause+=' order by cc.CreatedDt '+ @SortType
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

  SET @AdditionalQuery+=',(Select count(DISTINCT cc.Guid )
                             from
                                 [Coordinator].[Coordinator] cc WITH(NOLOCK,READUNCOMMITTED)
									INNER JOIN
										[dbo].[Users] du WITH(NOLOCK,READUNCOMMITTED)
									ON du.UserId=cc.UserId
									LEFT JOIN
										[mapping].[CoordinatorBranches] mpc ON mpc.CoordinatorId = cc.Id AND mpc.Isdeleted = 0 AND mpc.Isdefault = 1
									LEFT JOIN
										[Lookup].[Branch] lb ON lb.Id = mpc.BranchId AND lb.Isdeleted = 0
									WHERE 
										(cc.IsDeleted = 0	
										AND
										du.IsDeleted = 0
										) '
							 + @WhereClause+ ' ) as TotalCount '

SET @AdditionalQuery+=' from tblCoordinators tcs'
 
  SET @Query+= @SQL + @WhereClause  + @OrderByClause + @OffsetClause+ ')' + @AdditionalQuery + @FinalOrderBy
	
  PRINT @Query

EXECUTE sp_executesql @Query


SET NOCOUNT OFF
END
GO

