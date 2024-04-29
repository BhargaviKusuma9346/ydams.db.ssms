CREATE PROCEDURE [Patient].[spSavePatientFamily]
	 @RelationGuid uniqueidentifier
    ,@Title varchar (200)
    ,@FirstName varchar(200)
	,@MiddleName varchar(200)=null
    ,@LastName varchar(200)
	,@CountryCode varchar(200)='+91'
	,@MobileNumber varchar(50)
	,@AlternateMobileNumber varchar(50)
	,@Email varchar(max)=null
    ,@Gender varchar(200)
    ,@DateOfBirth datetime
	,@AddressProofTypeGuid uniqueidentifier=null
	,@IdentificationNumber varchar(200)=null
	,@MaritalStatus varchar(200)=null
	,@OccupationGuid uniqueidentifier=null
    ,@ReligionGuid uniqueidentifier=null
    ,@IncomeGroupGuid uniqueidentifier=null
    ,@EducationGuid uniqueidentifier=null
    ,@BloodGroup varchar(200)=null
    ,@RelationshipTypeGuid uniqueidentifier=null
    ,@RelationName varchar(200)=null
    ,@MothersMaidenName varchar(200)=null
    ,@CityGuid uniqueidentifier
    ,@StateGuid uniqueidentifier
    ,@Address1 varchar(200)
	,@Address2 varchar(200)=NULL
	,@PatientPhotoUrl varchar(200)=NULL
	,@CreatedByUserGuid uniqueidentifier=null
	,@BranchGuid uniqueidentifier=null
 AS
 
/*
select * from [Patient].[Patient] where Guid='DF753665-CB54-4EAF-8BDC-52D9409F5DED'

exec [Patient].[spSavePatientFamily]
     @RelationGuid='093d7435-59d1-48bc-abdc-c553115a9306'
    ,@Title='Mrs'
    ,@FirstName='vijay'
    ,@MiddleName='son'
    ,@LastName='Jeo'
    ,@CountryCode='+91'
    ,@MobileNumber='1312321312'
    ,@AlternateMobileNumber='5431231313'
    ,@Email='vijay@gmail.com'
    ,@Gender='Male'
    ,@DateOfBirth='10-06-1999'
    ,@AddressProofTypeGuid='C4C59CE3-15E8-4082-9775-78C132358D82'
    ,@IdentificationNumber='36873829233398'
    ,@MaritalStatus='Single'
    ,@OccupationGuid=null
    ,@ReligionGuid='83908CA0-9338-452B-A519-5F660B3AFFED'
    ,@IncomeGroupGuid=null
    ,@EducationGuid='C29DCC76-87AE-41FC-A5C8-0C2CE2AADE82'
    ,@BloodGroup='B-'
    ,@RelationshipTypeGuid='BAE06A0C-65E8-47C3-B308-2C6E633ED351'
    ,@RelationName='Shankar'
    ,@MothersMaidenName='P'
    ,@CityGuid=null
    ,@StateGuid=null
    ,@Address1='5-37,Guntur'
    ,@Address2='Palnadu'
    ,@PatientPhotoUrl='abc.com'
    ,@CreatedByUserGuid='8b7ea0d2-92ca-4aac-931c-3f256da23e37'
	,@BranchGuid=null


 Date					Author				Description          
 -----------------------------------------------------------------------------
03/07/2023		Ravali.D	           created
11/07/2023      Chandrani.M            modified to add BranchGuid  
 ------------------------------------------------------------------------------      
                Copyright 2023@YodaLIMS
*/ 

BEGIN
SET NOCOUNT ON
/*Declaration */
DECLARE @AddressProofTypeId INT 
DECLARE @AddressProofType  varchar(max)
SELECT @AddressProofTypeId=id,@AddressProofType=AddressProofType from [Lookup].[AddressProofType] WITH(NOLOCK,READUNCOMMITTED) WHERE 	IsDeleted=0 and Guid=@AddressProofTypeGuid

DECLARE @OccupationId INT 
DECLARE @OccupationName  varchar(max)
SELECT @OccupationId=id,@OccupationName=OccupationName from [Lookup].[Occupation] WITH(NOLOCK,READUNCOMMITTED) WHERE 	IsDeleted=0 and Guid=@OccupationGuid

DECLARE @ReligionId INT 
DECLARE @ReligionName  varchar(max)
SELECT @ReligionId=id,@ReligionName=ReligionName from [Lookup].[Religion] WITH(NOLOCK,READUNCOMMITTED) WHERE 	IsDeleted=0 and Guid=@ReligionGuid

DECLARE @IncomeGroupId INT 
DECLARE @IncomeGroupName  varchar(max)
SELECT @IncomeGroupId=id,@IncomeGroupName=IncomeGroupName from [Lookup].[IncomeGroup] WITH(NOLOCK,READUNCOMMITTED) WHERE 	IsDeleted=0 and Guid=@IncomeGroupGuid

DECLARE @EducationId INT 
DECLARE @EducationName  varchar(max)
SELECT @EducationId=id,@EducationName=EducationName from [Lookup].[Education] WITH(NOLOCK,READUNCOMMITTED) WHERE 	IsDeleted=0 and Guid=@EducationGuid

DECLARE @RelationshipTypeId INT 
DECLARE @RelationshipType  varchar(max)
SELECT @RelationshipTypeId=id,@RelationshipType=RelationshipType from [Lookup].[RelationshipType] WITH(NOLOCK,READUNCOMMITTED) WHERE 	IsDeleted=0 and Guid=@RelationshipTypeGuid

DECLARE @CityId INT 
DECLARE @CityName  varchar(max)
SELECT @CityId=id,@CityName=CityName from [Lookup].[City] WITH(NOLOCK,READUNCOMMITTED) WHERE 	IsDeleted=0 and Guid=@CityGuid

DECLARE @StateId INT 
DECLARE @StateName  varchar(max)
SELECT @StateId=id,@StateName=StateName from [Lookup].[State] WITH(NOLOCK,READUNCOMMITTED) WHERE 	IsDeleted=0 and Guid=@StateGuid

DECLARE @BranchName varchar(200)
SELECT @BranchName=BranchName from [Lookup].[Branch] WITH(NOLOCK,READUNCOMMITTED) WHERE IsDeleted=0 and guid=@BranchGuid

DECLARE @UserId INT
SELECT @UserId=UserId from dbo.Users where PhoneNumber=@MobileNumber

DECLARE @ModifiedName varchar(100)
DECLARE @ModifiedDt datetime
DECLARE @ModifiedBy INT

DECLARE @CreatedByUserId INT,@CreatedByFirstName varchar(100)
SELECT @CreatedByUserId=UserId,@CreatedByFirstName=FirstName from dbo.Users where UserGuid=@CreatedByUserGuid

DECLARE @RelationId INT
SELECT @RelationId= Id from [Patient].[Patient] where Guid=@RelationGuid

DECLARE @Id INT 

/*Main Query */
			
INSERT into [Patient].[Patient]
			     (
				  UserId
		         ,Title 
                 ,FirstName 
	             ,MiddleName
                 ,LastName
	             ,Email
				 ,CountryCode
				 ,MobileNumber
				 ,AlternativeMobileNumber
                 ,Gender
                 ,DateOfBirth
	             ,AddressProofType
	             ,AddressProofTypeId
	             ,IdentificationNumber
	             ,MaritalStatus
	             ,OccupationName
	             ,OccupationId
                 ,ReligionName
                 ,ReligionId
                 ,IncomeGroupName
                 ,IncomeGroupId
	             ,EducationName
                 ,EducationId
                 ,BloodGroup
                 ,RelationshipType
                 ,RelationshipTypeId
                 ,RelationName
                 ,MothersMaidenName
                 ,CityName
                 ,CityId
                 ,StateName
                 ,StateId
                 ,Address1
	             ,Address2
	             ,PatientPhotoUrl
				 ,CreatedByUserId
				 ,CreatedByName
				 ,BranchName
				  )
			values(
			      @UserId
			     ,@Title 
                 ,@FirstName 
	             ,@MiddleName
                 ,@LastName
	             ,@Email
				 ,@CountryCode
				 ,@MobileNumber
				 ,@AlternateMobileNumber
                 ,@Gender
                 ,@DateOfBirth
	             ,@AddressProofType
	             ,@AddressProofTypeId
	             ,@IdentificationNumber
	             ,@MaritalStatus
	             ,@OccupationName
	             ,@OccupationId
                 ,@ReligionName
                 ,@ReligionId
                 ,@IncomeGroupName
                 ,@IncomeGroupId
	             ,@EducationName
                 ,@EducationId
                 ,@BloodGroup
                 ,@RelationshipType
                 ,@RelationshipTypeId
                 ,@RelationName
                 ,@MothersMaidenName
                 ,@CityName
                 ,@CityId
                 ,@StateName
                 ,@StateId
                 ,@Address1
	             ,@Address2
	             ,@PatientPhotoUrl
				 ,@CreatedByUserId
				 ,@CreatedByFirstName
				 ,@BranchName
			)

			SELECT @Id=SCOPE_IDENTITY()

update [Patient].[Patient] set RelationId=@RelationId where Id=@Id


SET NOCOUNT OFF
END
GO

