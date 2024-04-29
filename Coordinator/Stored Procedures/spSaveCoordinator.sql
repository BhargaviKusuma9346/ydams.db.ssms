CREATE PROCEDURE [Coordinator].[spSaveCoordinator]  
     @CoordinatorGuid  uniqueidentifier=null
    ,@FirstName varchar(200)
    ,@LastName varchar(200)
	,@MobileNumber varchar(50)
	,@AlternateMobileNumber varchar(50)
	,@Email varchar(max)
    ,@Gender varchar(200)
    ,@DateOfBirth datetime = null
	,@BranchesUDT [Coordinator].[BranchesUDT] READONLY
	,@DefaultBranchGuid uniqueidentifier=null
	,@WorkDays int
	,@WorkHours int
    ,@LanguagesUDT [dbo].[LanguagesUDT] READONLY
	,@PreferredContactTypeUDT [dbo].[PreferredContactTypeUDT] READONLY
	,@CoordinatorPhotoURL varchar(200)
	,@UserName varchar(max)
 AS
 
/*
select * from [Coordinator].[Coordinator] order by 1 desc
select * from [mapping].[CoordinatorLanguages] order by 1 desc
select * from [mapping].[CoordinatorPreferredContactType] order by 1 desc
select * from [mapping].[CoordinatorBranches] order by 1 desc

DECLARE @LanguagesUDT [dbo].[LanguagesUDT]
DECLARE @PreferredContactTypeUDT [dbo].[PreferredContactTypeUDT]
DECLARE @BranchesUDT [Coordinator].[BranchesUDT]

insert into @LanguagesUDT values('71411894-0019-4f87-970e-451407e92003')
insert into @PreferredContactTypeUDT values('1fb0533e-2d28-4bf0-a8ac-c8d1aa106edd')
insert into @BranchesUDT values('77098657-7ed5-40f7-990e-2fd87fd5cb8e','0'),('de4e0b88-1555-41cf-994c-d3120d449780','0'),('6a49d7b3-a2ed-40ff-9e64-82824f746b53','0')

exec [Coordinator].[spSaveCoordinator]  
     @CoordinatorGuid='9d94ce6b-329a-42ac-8f3b-982c68bd0e74'
    ,@FirstName='Nikhitha'
    ,@LastName='Mandaa'
	,@MobileNumber='9876543215'
	,@AlternateMobileNumber='9876543215'
	,@Email='nikhitha123@gmail.com'
    ,@Gender='female'
    ,@DateOfBirth='2000-9-19'
	,@BranchesUDT = @BranchesUDT
	,@DefaultBranchGuid = '6a49d7b3-a2ed-40ff-9e64-82824f746b53'
	,@WorkDays=6
	,@WorkHours=51
	,@LanguagesUDT = @LanguagesUDT 
	,@PreferredContactTypeUDT = @PreferredContactTypeUDT
	,@CoordinatorPhotoURL='https://hiremeus.s3.amazonaws.com/users/profile/imagesgirl.cood.png'
	,@UserName='nikhitha123@gmail.com'

 Date					Author				Description          
 -----------------------------------------------------------------------------
24/04/2023			M Chandrani	           Save Coordinator related information
 ------------------------------------------------------------------------------      
                Copyright 2023@YodaLIMS
*/ 

BEGIN
SET NOCOUNT ON
/*Declaration */

DECLARE @BranchName varchar(max)
DECLARE @OutputId TABLE (CoordinatorId INT); 

DECLARE @Branch TABLE(BranchId int,Branch varchar(max),IsDeleted bit)
        insert into @Branch
		SELECT  
		     lb.Id as BranchId,
             lb.BranchName as Branch,
			 budt.IsDeleted
        FROM	          
	        [Lookup].[Branch] lb WITH(NOLOCK,READUNCOMMITTED)
			 inner join @BranchesUDT budt
	         on 
	         lb.Guid=budt.BranchGuid 
        WHERE 
	       lb.IsDeleted=0 

	       SELECT @BranchName= STRING_AGG(Branch,',') FROM @Branch where IsDeleted=0


DECLARE @LanguageNames varchar(max)

DECLARE @Languages TABLE(Languages varchar(max))
        insert into @Languages
		SELECT  
             ll.Languages as Languages
        FROM	          
	        [Lookup].[Languages] ll WITH(NOLOCK,READUNCOMMITTED)
			 inner join @LanguagesUDT ludt
	         on 
	         ll.Guid=ludt.LanguageGuid 
        WHERE 
	       ll.IsDeleted=0 

		SELECT @LanguageNames= STRING_AGG(Languages,',') FROM @Languages

DECLARE @PreferredContactTypeName varchar(max)
DECLARE @PreferredContactType TABLE(PreferredContactType varchar(max))
        insert into @PreferredContactType
		SELECT  
             lp.PreferredContactType as PreferredContactType
        FROM	          
	        [Lookup].[PreferredContactType] lp WITH(NOLOCK,READUNCOMMITTED)
			 inner join @PreferredContactTypeUDT pudt
	         on 
	         lp.Guid=pudt.PreferredContactTypeGuid 
        WHERE 
	       lp.IsDeleted=0 

	       SELECT @PreferredContactTypeName= STRING_AGG(PreferredContactType,',') FROM @PreferredContactType



DECLARE @Id INT 
SELECT @Id=id from [Coordinator].[Coordinator] WITH(NOLOCK,READUNCOMMITTED) WHERE 	IsDeleted=0 and guid=@CoordinatorGuid
print @Id

DECLARE @DefaultBranchId INT 
SELECT @DefaultBranchId=id from [Lookup].[Branch] WITH(NOLOCK,READUNCOMMITTED) WHERE IsDeleted=0 and guid=@DefaultBranchGuid
print(@DefaultBranchId)

DECLARE @UserId INT
SELECT @UserId=UserId from [dbo].[Users] with(nolock,readuncommitted) WHERE UserName=@UserName and IsDeleted=0

/*Main Query */
			
  MERGE [Coordinator].[Coordinator] AS trg 
  Using (
          select
                  @UserId AS UserId
                 ,@FirstName as  FirstName
                 ,@LastName as LastName
	             ,@MobileNumber as MobileNumber
	             ,@AlternateMobileNumber as AlternateMobileNumber
	             ,@Email as Email
                 ,@Gender as Gender
                 ,@DateOfBirth as DateOfBirth
				 ,@BranchName as Branches
				 ,@WorkDays as WorkDays
				 ,@WorkHours as WorkHours
                 ,@PreferredContactTypeName as PreferredContactType
	             ,@LanguageNames as Languages
				 ,@CoordinatorPhotoURL as CoordinatorPhotoURL
 
		     ) as src
		   ON  
		        trg.UserId =@UserId 

		  WHEN MATCHED THEN
		  UPDATE 
		  SET				       
                  FirstName =src.FirstName
                 ,LastName =src.LastName
	             ,ContactNumber =src. MobileNumber
	             ,AlternateNumber =src.AlternateMobileNumber
	             ,EmailId =src.Email
                 ,Gender =src.Gender
                 ,DateOfBirth =src.DateOfBirth
				 ,Branches = src.Branches
				 ,WorkDays=src.WorkDays
				 ,WorkHours=src.WorkHours
				 ,PreferredContactType=src.PreferredContactType
				 ,Languages=src.Languages
				 ,CoordinatorPhotoURL=src.CoordinatorPhotoURL

			WHEN NOT MATCHED THEN
		    INSERT
			     ( 
				  UserId
                 ,FirstName 
                 ,LastName
	             ,ContactNumber
	             ,AlternateNumber
	             ,EmailId
                 ,Gender
                 ,DateOfBirth
				 ,Branches
				 ,WorkDays
				 ,WorkHours
				 ,PreferredContactType
				 ,Languages
				 ,CoordinatorPhotoURL
				  )
			values(
			      @UserId 
                 ,@FirstName 
                 ,@LastName
	             ,@MobileNumber
	             ,@AlternateMobileNumber
	             ,@Email
                 ,@Gender
                 ,@DateOfBirth
				 ,@BranchName
				 ,@WorkDays
				 ,@WorkHours
				 ,@PreferredContactTypeName
				 ,@LanguageNames
				 ,@CoordinatorPhotoURL
			)
			OUTPUT INSERTED.Id INTO @OutputId;

 DECLARE @CoordinatorId INT
 SET @CoordinatorId=(SELECT CoordinatorId FROM @OutputId)
 print @CoordinatorId

 If Exists(select * from [mapping].[CoordinatorLanguages] with(nolock,readuncommitted) where CoordinatorId = @Id and IsDeleted=0)

  BEGIN
	print(@Id)
	 UPDATE 
       [mapping].[CoordinatorLanguages]
	 SET 
	    Languages= @LanguageNames		
	 WHERE
	    CoordinatorId =@Id
  END
 ELSE
     INSERT INTO 
	    [mapping].[CoordinatorLanguages]
	    (
		  [CoordinatorId],
          [Languages]

	    )
        VALUES
	    (
		  @CoordinatorId,
		  @LanguageNames
	     )

If Exists(select * from [mapping].[CoordinatorPreferredContactType] with(nolock,readuncommitted) where CoordinatorId = @Id and IsDeleted=0) 
  BEGIN    
	 UPDATE 
       [mapping].[CoordinatorPreferredContactType]
	 SET 
	    PreferredContactType= @PreferredContactTypeName		
	 WHERE
	    CoordinatorId =@Id
  END

 ELSE

     INSERT INTO 
	    [mapping].[CoordinatorPreferredContactType]
	    (
		  [CoordinatorId],
          [PreferredContactType]

	    )
        VALUES
	    (
		  @CoordinatorId,
		  @PreferredContactTypeName
	     )

BEGIN
   UPDATE [dbo].[Users] 
   SET 
      PhoneNumber=@MobileNumber,
	  FirstName=@FirstName,
	  LastName=@LastName
   Where 
      UserId=@UserId
END

BEGIN      
   UPDATE [mapping].[CoordinatorBranches] 
   SET IsDefault=0 
   WHERE CoordinatorId=@Id and IsDefault=0

   MERGE INTO [mapping].[CoordinatorBranches] AS target
	 USING (
			SELECT
				@Id AS Id,
				b.BranchId AS BranchId,
				CASE WHEN b.BranchId = @DefaultBranchId THEN 1 ELSE 0 END AS IsDefault,
				b.IsDeleted
			FROM
				@Branch b
		) AS source ON target.CoordinatorId = source.Id AND target.BranchId = source.BranchId and target.IsDeleted=0
		WHEN MATCHED THEN
			UPDATE SET
				target.IsDefault = source.IsDefault,
				target.IsDeleted = source.IsDeleted
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (CoordinatorId, BranchId, IsDefault)
			VALUES (CASE WHEN @Id IS NULL THEN @CoordinatorId ELSE @Id END, source.BranchId, source.IsDefault);

END

SET NOCOUNT OFF
END
GO

