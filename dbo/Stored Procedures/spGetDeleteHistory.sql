CREATE PROCEDURE [dbo].[spGetDeleteHistory]  
  @PageNumber int=-1,
  @RowCount int=-1,
  @Keyword varchar(max)='',
  @UserType varchar(max)='',
  @OrderBy varchar(200) = '',
  @SortType varchar(5)='asc'

 AS

 /*
exec [dbo].[spGetDeleteHistory] @PageNumber=-1,@RowCount=-1,@Keyword='',@OrderBy='DeletedOn',@SortType='desc',@UserType='Patients'

select * from dbo.deleterequests

 MODIFICATIONS        
 Date					Author				  Description          
 -----------------------------------------------------------------------------
 18/04/2023			M Chandrani	            Get Delete History
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
   ';WITH tblDeleteHistory(DeleteRequestGuid,RequestedFor,RequestedForUserType,RequestedBy,BranchName,CreatedDt,DeletedBy,DeletedOn) as
	( 
	 SELECT 
	  Guid as DeleteRequestGuid,
	  RequestedFor,
	  CASE 
	  WHEN UserTypeId = 5 THEN ''Patients'' 
	  WHEN UserTypeId = 2 THEN ''Coordinators'' 
	  ELSE ''Doctors'' END,
	  RequestedBy,
	  BranchName,
	  CreatedDt,
	  ModifiedName,
	  ModifiedDt as DeletedOn
 FROM 
	[dbo].[DeleteRequests] WITH(NOLOCK,READUNCOMMITTED)
 WHERE 
    Isdeleted=1 '

  IF (@Keyword !=''  )
	BEGIN 
	SET @WhereClause+='and (RequestedFor LIKE ''%'+ @Keyword +'%'' or RequestedBy LIKE ''%'+ @Keyword +'%'' or ModifiedBy LIKE ''%'+ @Keyword +'%'')'
	END

  IF (@UserType = 'Coordinators')
    BEGIN
        SET @WhereClause += ' AND UserTypeId = 2'
    END
 ELSE IF (@UserType = 'Doctors')
    BEGIN
        SET @WhereClause += ' AND UserTypeId = 3'
    END
 ELSE IF (@UserType = 'Patients')
    BEGIN
        SET @WhereClause += ' AND UserTypeId = 5'
    END

  IF(@OrderBy='RequestedFor ' )
  BEGIN
  SET @OrderByClause+=' order by RequestedFor '+ @SortType
  SET @FinalOrderBy +=' order by RequestedFor '+ @SortType
  END

  IF(@OrderBy='RequestedBy  ' )
  BEGIN
  SET @OrderByClause+=' order by RequestedBy  '+ @SortType
  SET @FinalOrderBy +=' order by RequestedBy  '+ @SortType
  END

  IF(@OrderBy='ModifiedBy  ' )
  BEGIN
  SET @OrderByClause+=' order by ModifiedBy  '+ @SortType
  SET @FinalOrderBy +=' order by ModifiedBy  '+ @SortType
  END

  IF(@OrderBy='DeletedOn  ' )
  BEGIN
  SET @OrderByClause+=' order by DeletedOn  '+ @SortType
  SET @FinalOrderBy +=' order by DeletedOn  '+ @SortType
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

  SET @AdditionalQuery+=',(Select count(DISTINCT Guid)	 	
		                    FROM 
	                          [dbo].[DeleteRequests] WITH(NOLOCK,READUNCOMMITTED)
							WHERE Isdeleted=1 '
							 + @WhereClause+ ' ) as TotalCount '

SET @AdditionalQuery+=' from tblDeleteHistory tdh'
 
  SET @Query+= @SQL + @WhereClause  + @OrderByClause + @OffsetClause+ ')' + @AdditionalQuery + @FinalOrderBy
	
  PRINT @Query

EXECUTE sp_executesql @Query


 SET NOCOUNT OFF
END
GO

