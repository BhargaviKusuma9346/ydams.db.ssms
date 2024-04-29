
CREATE procedure [dbo].[spGetPastHistoryQuestions]   
      @PageNumber int=-1,
	  @RowCount int=-1,
	  @Keyword varchar(max)='',
	  @OrderBy varchar(200) = '',
	  @SortType varchar(5)='asc',
      @PastHistoryTypeGuid uniqueIdentifier=null ,
	  @QuestionGuid uniqueIdentifier=null 
AS         
      
/*
 exec [dbo].[spGetPastHistoryQuestions]  @PastHistoryTypeGuid='31AB9538-0917-4FEE-87A5-F3EF7024C7AD',@QuestionGuid=null
 -------------------------------------------------------------              

 MODIFICATIONS 
 
 Date					Author				Description          
 -----------------------------------------------------------------------------
20/04/2023			   M.Chandrani	           to get Patient Past History information
 ------------------------------------------------------------------------------      
                Copyright 2023@YLIMS
*/        
BEGIN 

SET NOCOUNT ON


DECLARE @Query nvarchar(max)=''
DECLARE @SQL nvarchar(max)=''
DECLARE @SeletClause nvarchar(max)=''
DECLARE @WhereClause nvarchar(max)=''
DECLARE @OrderByClause nvarchar(max)=''
DECLARE @FinalOrderBy nvarchar(max)=''
DECLARE @OffsetClause nvarchar(max)=''
DECLARE @AdditionalQuery nvarchar(max)

/*Main Query */
SET @Keyword = IIF(@Keyword is null, '', TRIM(@Keyword))

If(@SortType = '' or @SortType is null)
BEGIN
	SET @SortType = 'asc'
END
	SET @SQL+=
   ';WITH tblPastHistoryQuestions(QuestionGuid,PastHistoryTypeGuid,PastHistoryTypeName,Description,Question,QuestionType,QuestionTypeGuid,RowOrder,Units,Option1,Option2,Option3,Option4,Option5,Option6,Option7,Option8,Option9,Option10,SqlQuery,CreatedDt) as
	( 
	 SELECT 
	         pf.Guid as QuestionGuid
			,lph.Guid as PastHistoryTypeGuid
			,lph.PastHistoryFieldName as PastHistoryTypeName
			,lph.Description
			,pf.FieldName as Question
			,pf.FieldType as QuestionType
			,lpq.Guid as QuestionTypeGuid
			,pf.RowOrder
			,pf.Units
			,pf.Option1
			,pf.Option2
			,pf.Option3
			,pf.Option4
			,pf.Option5 
			,pf.Option6
			,pf.Option7
			,pf.Option8
			,pf.Option9
			,pf.Option10
			,pf.SqlQuery
			,pf.CreatedDt
	FROM
		[PastHistoryType].[Fields] pf WITH(NOLOCK,READUNCOMMITTED)
		INNER JOIN
		[Lookup].[PastHistoryType] lph WITH(NOLOCK,READUNCOMMITTED)
		ON pf.PastHistoryTypeId=lph.Id
		INNER JOIN
		[Lookup].[PastHistoryQuestionType]  lpq WITH(NOLOCK,READUNCOMMITTED)
		ON pf.FieldType=lpq.QuestionType
	WHERE
	   pf.IsDeleted=0
		AND
	   lph.IsDeleted=0
	   AND
	   lpq.IsDeleted=0 '

    IF (@PastHistoryTypeGuid is not null)
	BEGIN 
	SET @WhereClause+=' AND (lph.Guid LIKE ''%'+ CONVERT(varchar(36), @PastHistoryTypeGuid) +'%'')'
	END

	IF (@QuestionGuid is not null)
	BEGIN 
	SET @WhereClause+=' AND (pf.Guid LIKE ''%'+ CONVERT(varchar(36), @QuestionGuid) +'%'')'
	END

  IF (@Keyword !=''  )
	BEGIN 
	SET @WhereClause+='and (Question LIKE ''%'+ @Keyword +'%'' or PastHistoryName LIKE ''%'+ @Keyword +'%'')'
	END

  IF(@OrderBy='Question ' )
  BEGIN
  SET @OrderByClause+=' order by Question '+ @SortType
  SET @FinalOrderBy +=' order by Question '+ @SortType
  END

  IF(@OrderBy='PastHistoryTypeName ' )
  BEGIN
  SET @OrderByClause+=' order by PastHistoryTypeName '+ @SortType
  SET @FinalOrderBy +=' order by PastHistoryTypeName '+ @SortType
  END

  IF(@OrderBy='TestCategory' )
  BEGIN
  SET @OrderByClause+=' order by TestCategory '+ @SortType
  SET @FinalOrderBy +=' order by TestCategory '+ @SortType
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

  SET @AdditionalQuery+=',(SELECT count(distinct pf.guid)
							FROM
								[PastHistoryType].[Fields] pf WITH(NOLOCK,READUNCOMMITTED)
								INNER JOIN
								[Lookup].[PastHistoryType] lph WITH(NOLOCK,READUNCOMMITTED)
								ON pf.PastHistoryTypeId=lph.Id
								INNER JOIN
								[Lookup].[PastHistoryQuestionType]  lpq WITH(NOLOCK,READUNCOMMITTED)
								ON pf.FieldType=lpq.QuestionType
							WHERE
							   pf.IsDeleted=0
								AND
							   lph.IsDeleted=0
							   AND
							   lpq.IsDeleted=0 '
							 + @WhereClause+ ' ) as TotalCount '

SET @AdditionalQuery+=' from tblPastHistoryQuestions tbhs'
 
  SET @Query+= @SQL + @WhereClause  + @OrderByClause + @OffsetClause+ ')' + @AdditionalQuery + @FinalOrderBy
	
  PRINT @Query

EXECUTE sp_executesql @Query

SET NOCOUNT OFF

END
