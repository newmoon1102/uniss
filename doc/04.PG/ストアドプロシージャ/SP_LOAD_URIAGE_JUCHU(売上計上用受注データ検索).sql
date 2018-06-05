
--DROP PROCEDURE SP_LOAD_URIAGE_JUCHU

CREATE PROCEDURE SP_LOAD_URIAGE_JUCHU
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
          FROM W_URIAGE_JUCHU
         WHERE W_URIAGE_JUCHU.W_USER_ID = @USER_ID

        --�Ǎ��f�[�^�����[�N�e�[�u���֊i�[
        SET @strSQL = 'INSERT INTO '
                    + '  W_URIAGE_JUCHU '
                    + 'SELECT   '''+ @USER_ID +''''
                    + '        ,'''+ @SERIAL  +''''
                    + '        ,ROW_NUMBER() OVER (ORDER BY JURI_NO) '
                    + '        ,'  + @MODE
                    + '        ,''False''' 
                    + '        ,JUCHU_KBN_MEI '
                    + '        ,STS_MEI '
                    + '        ,BUN_HAN_KBN_MEI '
                    + '        ,JURI_NO '
                    + '        ,KENMEI '
                    + '        ,SEIKYU_CD '
                    + '        ,SEIKYU_MEI '
                    + '        ,NYURYOKUSHA_MEI '
                    + '        ,EIGYO_TANTO_MEI '
                    + '        ,NYURYOKU_DATETIME '
                    + '        ,NOHIN_DATE '
                    + '        ,EDA_KENSU '
                    + '        ,SHOHIN_KENSU '
                    + '        ,MITSU_NO '
                    + '        ,URIAGE_NO_S '
                    + '        ,HASSO_CD '
                    + '        ,JUCHU_KBN '
                    + '        ,STS '
                    + '        ,BUN_HAN_KBN '
                    + '        ,NYURYOKUSHA_CD '
                    + '        ,EIGYO_TANTO_CD '
                    + '        ,URI_MIKEIJO_FLG '
                    + '        ,FREEWD '
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
          FROM W_URIAGE_JUCHU
         WHERE W_URIAGE_JUCHU.W_USER_ID = @USER_ID

     END

END TRY


 --��O����
BEGIN CATCH

    -- �g�����U�N�V���������[���o�b�N�i�L�����Z���j
    ROLLBACK TRANSACTION SAVE1

    --���[�N�e�[�u���N���A
    DELETE
      FROM W_URIAGE_JUCHU
     WHERE W_URIAGE_JUCHU.W_USER_ID = @USER_ID

END CATCH

END

