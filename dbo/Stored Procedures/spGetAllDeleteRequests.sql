CREATE PROCEDURE [dbo].[spGetAllDeleteRequests] 
  @PageNumber int=-1,
  @RowCount int=-1,
  @Keyword varchar(max)='',
  @UserType varchar(max)='',
  @OrderBy varchar(200) = '',
  @SortType varchar(5)='asc',
  @UserGuid uniqueidentifier=null
 AS

 /*
exec [dbo].[spGetAllDeleteRequests]   @PageNumber=1,@RowCount=12,@Keyword='',@UserType='',@OrderBy='Latest',@SortType='desc',@UserGuid=null


 MODIFICATIONS        
 Date					Author				Description          
 -----------------------------------------------------------------------------
 18/04/2023			Ravali .D            Created
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


If(@SortType = '' or @SortType is null)
BEGIN
	SET @SortType = 'asc'
END
	SET @SQL+=
   ';WITH tblDeleteRequests(DeleteRequestGuid,RequestedForUserTypeId,RequestedForUserTypeName,RequestedForUserId,RequestedFor,RequestedBy,BranchName,Comments,IsAccepted,IsRequested,CreatedDt) as
	( 
	 SELECT 
	  dr.Guid as DeleteRequestGuid,
	  dr.UserTypeId as RequestedForUserTypeId,
	  CASE WHEN dr.UserTypeId = 5 THEN ''Patients'' ELSE ''Doctors'' END AS RequestedForUserTypeName,	  
	  dr.RequestedForUserId,
	  dr.RequestedFor,
	  dr.RequestedBy,
	  dr.BranchName,
	  dr.Comments,
	  dr.IsAccepted,
	  dr.IsRequested,
	  dr.CreatedDt
 FROM 
	[dbo].[DeleteRequests] dr WITH(NOLOCK,READUNCOMMITTED)
    LEFT JOIN
	[Doctor].[Doctor] dd ON dr.RequestedForUserId = dd.UserId
	INNER JOIN
	[dbo].[Users] du  ON dr.RequestedForUserId = du.UserId
 WHERE 
	 dr.IsDeleted=0 
	 AND
	 du.IsDeleted=0
	 AND
	 dr.IsRequested=1 '

  IF (@Keyword !=''  )
	BEGIN 
	SET @WhereClause+='and (RequestedBy LIKE ''%'+ @Keyword +'%'' or RequestedFor LIKE ''%'+ @Keyword +'%'' )'
	END
  IF (@UserType = 'Doctors')
    BEGIN
        SET @WhereClause += ' AND dr.UserTypeId = 3'
    END
  ELSE IF (@UserType = 'Patients')
    BEGIN
        SET @WhereClause += ' AND dr.UserTypeId = 5'
    END

  IF (@UserGuid is not null)
	BEGIN 
	SET @WhereClause+=' AND (CreatedByUserId LIKE ''%'+ @UserId +'%'')'
	END

  IF(@OrderBy='RequestedBy' )
  BEGIN
  SET @OrderByClause+=' order by RequestedBy '+ @SortType
  SET @FinalOrderBy +=' order by RequestedBy '+ @SortType
  END

  IF(@OrderBy='RequestedFor' )
  BEGIN
  SET @OrderByClause+=' order by RequestedFor '+ @SortType
  SET @FinalOrderBy +=' order by RequestedFor '+ @SortType
  END

 IF(@OrderBy is null or @OrderBy = '' or @OrderBy='Latest')
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

  SET @AdditionalQuery+=',(Select count(DISTINCT dr.Guid)	 	
		                    FROM 
	                         [dbo].[DeleteRequests] dr WITH(NOLOCK,READUNCOMMITTED)
                               LEFT JOIN
								[Doctor].[Doctor] dd ON dr.RequestedForUserId = dd.UserId
								INNER JOIN
								[dbo].[Users] du  ON dr.RequestedForUserId = du.UserId
							 WHERE 
								 dr.IsDeleted=0 
								 AND
								 du.IsDeleted=0
								 AND
								 dr.IsRequested=1 '
							 + @WhereClause+ ' ) as TotalCount '

SET @AdditionalQuery+=' from tblDeleteRequests tms'
 
  SET @Query+= @SQL + @WhereClause  + @OrderByClause + @OffsetClause+ ')' + @AdditionalQuery + @FinalOrderBy
	
  PRINT @Query

EXECUTE sp_executesql @Query

SET NOCOUNT OFF
END
GO

