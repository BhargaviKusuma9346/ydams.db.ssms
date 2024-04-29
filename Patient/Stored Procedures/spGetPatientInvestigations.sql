
CREATE procedure [Patient].[spGetPatientInvestigations]  
          @PageNumber int=-1,
		  @RowCount int=-1,
		  @Keyword varchar(max)='',
		  @OrderBy varchar(200) = '',
		  @SortType varchar(5)='asc',
          @PatientGuid uniqueIdentifier=null
  
AS        
      
/*
 exec [Patient].[spGetPatientInvestigations]
          @PageNumber =1,
		  @RowCount =5,
		  @Keyword  ='',
		  @OrderBy = 'Doctor name',
		  @SortType ='asc',
          @PatientGuid='8e3204fe-af10-40bc-a429-cb2e2cf97ce4'
 -------------------------------------------------------------              

 MODIFICATIONS        
 Date					Author				Description          
 -----------------------------------------------------------------------------
20/04/2023			   M.Chandrani	           to get Patient Investigations information
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
   ';WITH tblPatientInvestigations(DoctorGuid,DoctorName,CoordinatorGuid,CoordinatorName,PatientGuid,PatientName,AppointmentGuid,AppointmentDate,Investigations,Status,CreatedDt) as
	( 
		SELECT 
			dd.Guid AS DoctorGuid,
			CONCAT(dd.[FirstName],'' '',dd.[LastName]) as DoctorName,
			cc.Guid as CoordinatorGuid,
			CONCAT(cc.[FirstName],'' '',cc.[LastName]) as CoordinatorName,
			pp.Guid as PatientGuid,
			CONCAT(pp.[FirstName],'' '',pp.[MiddleName],'' '',pp.[LastName]) as PatientName,
			pa.Guid as AppointmentGuid,
			pa.AppointmentDate,
			mp.Investigations,
			mp.Status,
			mp.CreatedDt as CreatedDt
		FROM
			[mapping].[PatientInvestigations] mp WITH(NOLOCK,READUNCOMMITTED)
			LEFT JOIN
			[Patient].[Appointment] pa WITH(NOLOCK,READUNCOMMITTED)
			ON pa.Id = mp.AppointmentId
			INNER JOIN
			[Patient].[Patient] pp WITH(NOLOCK,READUNCOMMITTED)
			on pp.Id= mp.PatientId 
			INNER JOIN
			[Doctor].[Doctor] dd WITH(NOLOCK,READUNCOMMITTED)
			on dd.Id= mp.DoctorId 
			LEFT JOIN
			[Coordinator].[Coordinator] cc WITH(NOLOCK,READUNCOMMITTED)
			on cc.Id= pa.CoordinatorId
		WHERE
		   pa.IsConfirmed=1
			AND
		   mp.IsDeleted=0
			AND
		   dd.IsDeleted=0
			AND
		   pp.IsDeleted=0  '

IF (@Keyword !=''  )
	BEGIN 
	SET @WhereClause+='and (mp.Status LIKE ''%'+ @Keyword +'%'' or CONCAT(dd.[FirstName],'' '',dd.[LastName]) LIKE ''%'+ @Keyword +'%'' or mp.Investigations LIKE ''%'+ @Keyword +'%'')'
	END

    IF (@PatientGuid is not null)
	BEGIN 
	SET @WhereClause+=' AND (pp.Guid LIKE ''%'+ CONVERT(varchar(36), @PatientGuid) +'%'')'
	END

  

  IF(@OrderBy='Appointment date ' )
  BEGIN
  SET @OrderByClause+=' order by AppointmentDate '+ @SortType
  SET @FinalOrderBy +=' order by AppointmentDate '+ @SortType
  END

  IF(@OrderBy='Doctor name ' )
  BEGIN
  SET @OrderByClause+=' order by DoctorName '+ @SortType
  SET @FinalOrderBy +=' order by DoctorName '+ @SortType
  END

  IF(@OrderBy='Coordinator name' )
  BEGIN
  SET @OrderByClause+=' order by CoordinatorName '+ @SortType
  SET @FinalOrderBy +=' order by CoordinatorName '+ @SortType
  END

  IF(@OrderBy='Status' )
  BEGIN
  SET @OrderByClause+=' order by Status '+ @SortType
  SET @FinalOrderBy +=' order by Status '+ @SortType
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

  SET @AdditionalQuery+=',(SELECT count(distinct mp.guid)
							FROM
			[mapping].[PatientInvestigations] mp WITH(NOLOCK,READUNCOMMITTED)
			INNER JOIN
			[Patient].[Appointment] pa WITH(NOLOCK,READUNCOMMITTED)
			ON pa.Id = mp.AppointmentId
			INNER JOIN
			[Patient].[Patient] pp WITH(NOLOCK,READUNCOMMITTED)
			on pp.Id= mp.PatientId 
			INNER JOIN
			[Doctor].[Doctor] dd WITH(NOLOCK,READUNCOMMITTED)
			on dd.Id= mp.DoctorId 
			LEFT JOIN
			[Coordinator].[Coordinator] cc WITH(NOLOCK,READUNCOMMITTED)
			on cc.Id= pa.CoordinatorId
		WHERE
		   pa.IsConfirmed=1
			AND
		   mp.IsDeleted=0
			AND
		   dd.IsDeleted=0
			AND
		   pp.IsDeleted=0 '
		 + @WhereClause+ ' ) as TotalCount '

SET @AdditionalQuery+=' from tblPatientInvestigations tbs'
 
  SET @Query+= @SQL + @WhereClause  + @OrderByClause + @OffsetClause+ ')' + @AdditionalQuery + @FinalOrderBy
	
  PRINT @Query

EXECUTE sp_executesql @Query

SET NOCOUNT OFF

END
