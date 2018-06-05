--DROP PROCEDURE SP_LOAD_URIAGE_RENDO

CREATE PROCEDURE SP_LOAD_URIAGE_RENDO
       @USER_ID  NVARCHAR(64)
      ,@SERIAL   NVARCHAR(50)
      ,@MODE     NVARCHAR(1)
      ,@SQL      NVARCHAR(max)
AS
--[���[�h] 0:�Ǎ� / 1:���[�N�e�[�u���폜
BEGIN

--�ϐ���`
    DECLARE @strSQL NVARCHAR(max)

--�Z�[�u�|�C���g����
    SAVE TRANSACTION SAVE1

BEGIN TRY

    --�Ǎ�����
    IF @MODE = 0
      BEGIN

        --���[�N�e�[�u���N���A
        DELETE
          FROM W_URIAGE_RENDO
         WHERE W_URIAGE_RENDO.W_USER_ID = @USER_ID

        --�Ǎ��f�[�^�����[�N�e�[�u���֊i�[
        SET @strSQL = 'INSERT INTO '
                    + '  W_URIAGE_RENDO '
                    + 'SELECT   '''+ @USER_ID +''''
                    + '        ,'''+ @SERIAL  +''''
                    + '        ,ROW_NUMBER() OVER (ORDER BY URIAGE_NO ASC) '
                    + '        ,'  + @MODE
                    + '        ,''FALSE''' 
                    + '        ,TBL1.*'
                    + '        ,1 '
                    + '        ,'''+ @USER_ID +''''
                    + '        ,''DT'' + ' + 'CONVERT(VARCHAR(24),GETDATE(),120) '
                    + '        , '''+ @USER_ID +''''
                    + '        ,''DT'' + ' + 'CONVERT(VARCHAR(24),GETDATE(),120) '
                    + '  FROM' + '(' + @SQL + ') TBL1'  
        EXEC(@strSQL)        
      END

    --���[�N�e�[�u���폜����
    ELSE IF @MODE = 1
     BEGIN

        --���[�N�e�[�u���N���A
        DELETE
          FROM W_URIAGE_RENDO
         WHERE W_URIAGE_RENDO.W_USER_ID = @USER_ID

     END

END TRY


--��O����
BEGIN CATCH

    --�g�����U�N�V���������[���o�b�N�i�L�����Z���j
    ROLLBACK TRANSACTION SAVE1

    --���[�N�e�[�u���N���A
    DELETE
      FROM W_URIAGE_RENDO
     WHERE W_URIAGE_RENDO.W_USER_ID = @USER_ID

END CATCH

END
