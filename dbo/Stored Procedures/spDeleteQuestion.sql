
CREATE procedure [dbo].[spDeleteQuestion] 
  @QuestionGuid uniqueIdentifier

AS        
      
/*
 exec [dbo].[spDeleteQuestion]    @QuestionGuid='f946f451-9e83-4bdb-82aa-cc3690539e05'
 -------------------------------------------------------------              
	select * from [PastHistoryType].[Fields] where Guid='f946f451-9e83-4bdb-82aa-cc3690539e05'

 MODIFICATIONS        
 Date					Author				Description          
 -----------------------------------------------------------------------------
20/04/2023			   D.Ravali	           to delete Questions
 ------------------------------------------------------------------------------      
                Copyright 2023@YLIMS
*/        
BEGIN 

SET NOCOUNT ON

/*Declaration */


/*Main Query */ 
    UPDATE
	    [PastHistoryType].[Fields]
	SET
	     IsDeleted=1
	WHERE
	     Guid = @QuestionGuid


SET NOCOUNT OFF

END
