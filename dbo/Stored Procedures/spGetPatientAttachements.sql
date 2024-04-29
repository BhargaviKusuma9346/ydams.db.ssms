
CREATE PROCEDURE [dbo].[spGetPatientAttachements] 
  @PageNumber int=-1,
  @RowCount int=-1,
  @Keyword varchar(max)='',
  @OrderBy varchar(200) = '',
  @SortType varchar(5)='desc',
  @PatientGuid uniqueIdentifier=null

 AS

  /*
exec [dbo].[spGetPatientAttachements]  @PageNumber=1,@RowCount=5,@Keyword='',@OrderBy='',@SortType='asc',@PatientGuid='45e59f45-f82f-440e-9717-92a55ade86b4'

select * from patient.patient where Guid='3868F5C8-6F25-46C1-BB4F-8B62E17E814C'


select * from [mapping].[PatientAttachments]

 MODIFICATIONS        
 Date					Author				Description          
 -----------------------------------------------------------------------------
 18/04/2023			Nikhita	           Get all Patient Attachements
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

DECLARE @PatientId varchar(100)
SELECT @PatientId=Id from [Patient].[Patient] where Guid=@PatientGuid

PRINT (@PatientId)
If(@SortType = '' or @SortType is null)
BEGIN
	SET @SortType = 'asc'
END
	SET @SQL+=
   ';WITH tblPtAttachements(PatientGuid,AppointmentGuid,AttachmentGuid,AttachmentTitle,AttachmentUrl,IsDeleted,CreatedDt) as
	( 
	  SELECT 
			pp.Guid as PatientGuid,
			pa.Guid as AppointmentGuid,
			ppa.Guid as AttachmentGuid,
			ppa.AttachmentTitle,
			ppa.AttachmentUrl,
			ppa.IsDeleted,
			ppa.CreatedDt
		FROM
			[mapping].[PatientAttachments] ppa WITH(NOLOCK,READUNCOMMITTED)
			LEFT JOIN
			[Patient].[Appointment] pa WITH(NOLOCK,READUNCOMMITTED)
			ON pa.Id = ppa.AppointmentId AND pa.IsConfirmed=1
			INNER JOIN
			[Patient].[Patient] pp WITH(NOLOCK,READUNCOMMITTED)
			on pp.Id= ppa.PatientId 
		WHERE
		   ppa.IsDeleted=0    
			AND
		   pp.IsDeleted=0 '
   

 IF (@Keyword !=''  )
	BEGIN 
	SET @WhereClause+='and (AttachmentTitle LIKE ''%'+ @Keyword +'%'')'
	END

  IF (@PatientGuid is not null)
	BEGIN 
	SET @WhereClause+=' AND (ppa.PatientId LIKE ''%'+ @PatientId +'%'')'
	END

IF(@OrderBy='Attachment title ' )
  BEGIN
 SET @OrderByClause+=' order by AttachmentTitle '+ @SortType
  SET @FinalOrderBy +=' order by AttachmentTitle '+ @SortType
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

  SET @AdditionalQuery+=',(Select count(DISTINCT ppa.Guid)	 	
		                    FROM
								[mapping].[PatientAttachments] ppa WITH(NOLOCK,READUNCOMMITTED)
								LEFT JOIN
								[Patient].[Appointment] pa WITH(NOLOCK,READUNCOMMITTED)
								ON pa.Id = ppa.AppointmentId AND pa.IsConfirmed=1
								INNER JOIN
								[Patient].[Patient] pp WITH(NOLOCK,READUNCOMMITTED)
								on pp.Id= ppa.PatientId 
							WHERE
							   ppa.IsDeleted=0    
								AND
							   pp.IsDeleted=0 '
									
							 + @WhereClause+ ' ) as TotalCount '

SET @AdditionalQuery+=' from tblPtAttachements tpa'
 
if (@OrderBy != 'Doctor name')
begin
SET @Query+= @SQL + @WhereClause  + @OrderByClause + @OffsetClause+ ')' + @AdditionalQuery + @FinalOrderBy
end
else
begin
SET @Query+= @SQL + @WhereClause   + 'order by CreatedDt DESC ' + @OffsetClause+ ')' + @AdditionalQuery 
end
 PRINT @Query

EXECUTE sp_executesql @Query

SET NOCOUNT OFF
END