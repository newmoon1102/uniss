
--DROP PROCEDURE SP_SAVE_T_IRAI

CREATE PROCEDURE SP_SAVE_T_IRAI
       @USER_ID  NVARCHAR(64)
      ,@SERIAL   NVARCHAR(50)
      ,@MODE     NVARCHAR(1)
      ,@SQL      NVARCHAR(max)
AS
--[���[�h] 0:�Ǎ� / 1:���F(�ۑ�) / ELSE:���[�N�e�[�u���폜
BEGIN

--�ϐ���`
    DECLARE @strSQL NVARCHAR(max)

    --�V�[�P���X
    DECLARE @SEQ AS INT

    --�Ώۈ˗�No.
    DECLARE @IRAI_NO AS NVARCHAR(10)
    --�Ώۍw��No.
    DECLARE @KOBAI_NO AS NVARCHAR(10)
    --�Ώۍw��SEQ
    DECLARE @KOBAI_SEQ AS INT

    --���F��
    DECLARE @SHONIN_DATE AS NVARCHAR(10)

    --�ۑ��p�J�[�\��
    DECLARE IRAI_SAVE_CURSOR CURSOR
        FOR
     SELECT W_KOBAI_SHONIN_LIST.KOBAI_NO
           ,W_KOBAI_SHONIN_LIST.KOBAI_SEQ
       FROM W_KOBAI_SHONIN_LIST
      WHERE W_KOBAI_SHONIN_LIST.W_USER_ID          = @USER_ID
        AND W_KOBAI_SHONIN_LIST.SELECT_FLG         = 'True'
        AND ISNULL(W_KOBAI_SHONIN_LIST.IRAI_NO,'') = ''


--�Z�[�u�|�C���g����
    SAVE TRANSACTION SAVE1

BEGIN TRY

    --�Ǎ�����
    IF @MODE = 0
      BEGIN

        --���[�N�e�[�u���N���A
        DELETE
          FROM W_KOBAI_SHONIN_LIST
         WHERE W_KOBAI_SHONIN_LIST.W_USER_ID = @USER_ID

        --�Ǎ��f�[�^�����[�N�e�[�u���֊i�[
        SET @strSQL = 'INSERT INTO '
                    + '  W_KOBAI_SHONIN_LIST '
                    + 'SELECT   '''+ @USER_ID +''''
                    + '        ,'''+ @SERIAL  +''''
                    + '        ,ROW_NUMBER() OVER (ORDER BY KOBAI_NO, KOBAI_SEQ) '
                    + '        ,'  + @MODE
                    + '        ,SHONIN_FLG '
                    + '        ,GYO_MOJI '
                    + '        ,WARNING '
                    + '        ,KOBAI_KBN_MEI'
                    + '        ,KOBAI_STS_MEI'
                    + '        ,SHINSEISHA_MEI'
                    + '        ,SHINSEI_DATETIME'
                    + '        ,KOBAIHIN_CD'
                    + '        ,KOBAIHIN_MEI'
                    + '        ,TANKA'
                    + '        ,IRISU'
                    + '        ,IRISU_TANI'
                    + '        ,SURYO'
                    + '        ,BARA_TANI'
                    + '        ,SOSU'
                    + '        ,TOTAL'
                    + '        ,NOKI'
                    + '        ,UKEIRE_DATE'
                    + '        ,KENSHU_DATE'
                    + '        ,HOKAN_BASHO_KBN_MEI'
                    + '        ,SHIIRE_CD'
                    + '        ,SHIIRE_MEI'
                    + '        ,MAKER_CD'
                    + '        ,MAKER_MEI'
                    + '        ,YOSAN_CD'
                    + '        ,JURI_NO'
                    + '        ,BIKO'
                    + '        ,KOBAI_NO'
                    + '        ,IRAI_NO'
                    + '        ,KOBAI_KBN'
                    + '        ,KOBAI_STS'
                    + '        ,SHINSEISHA_CD'
                    + '        ,FREEWD'
                    + '        ,KOBAI_SEQ'
                    + '        ,1 '
                    + '        ,'''+ @USER_ID +''''
                    + '        ,''DT'' + ' + 'CONVERT(VARCHAR(24),GETDATE(),120) '
                    + '        , '''+ @USER_ID +''''
                    + '        ,''DT'' + ' + 'CONVERT(VARCHAR(24),GETDATE(),120) '
                     + '  FROM' + '(' + @SQL + ') TBL1'  
        EXEC(@strSQL)
      END

    --���F�m�菈��
    ELSE IF @MODE = 1
     BEGIN

        --���F���Z�b�g
        SET @SHONIN_DATE = CONVERT(VARCHAR(10), GETDATE(),111) 

        --���F�����Ώۍ폜(�˗��e�[�u��)
        DELETE
          FROM T_IRAI
         WHERE EXISTS
               ( SELECT 1
                   FROM W_KOBAI_SHONIN_LIST
                  WHERE W_KOBAI_SHONIN_LIST.W_USER_ID  = @USER_ID
                    AND W_KOBAI_SHONIN_LIST.SELECT_FLG = 'False'
                    AND W_KOBAI_SHONIN_LIST.IRAI_NO    = T_IRAI.IRAI_NO )

        --���F�����Ώۍ폜(�����e�[�u��)
        DELETE
          FROM T_CHUMON
         WHERE EXISTS
               ( SELECT 1 
                   FROM W_KOBAI_SHONIN_LIST
                  WHERE W_KOBAI_SHONIN_LIST.W_USER_ID  = @USER_ID
                    AND W_KOBAI_SHONIN_LIST.SELECT_FLG = 'False'
                    AND W_KOBAI_SHONIN_LIST.IRAI_NO    = T_CHUMON.IRAI_NO )

        --���F�����X�e�[�^�X�X�V
        UPDATE T_KOBAI_B
           SET T_KOBAI_B.KOBAI_STS = 1
         WHERE EXISTS
               ( SELECT 1 
                   FROM W_KOBAI_SHONIN_LIST
                  WHERE W_KOBAI_SHONIN_LIST.W_USER_ID  = @USER_ID
                    AND W_KOBAI_SHONIN_LIST.SELECT_FLG = 'False'
                    AND W_KOBAI_SHONIN_LIST.KOBAI_NO   = T_KOBAI_B.KOBAI_NO
                    AND W_KOBAI_SHONIN_LIST.KOBAI_SEQ  = T_KOBAI_B.KOBAI_SEQ )

        --�X�e�[�^�X�ύX����ۑ�(���F������)
        INSERT INTO
               T_KOBAI_STS_R
        SELECT
               TBL_A.KOBAI_NO
              ,TBL_A.KOBAI_SEQ
              ,CONVERT(VARCHAR(10),GETDATE(),111) + ' ' + CONVERT(VARCHAR(8),GETDATE(),114)
              ,TBL_B.AFTER_STS
              ,1
              ,1
              ,TBL_A.DBS_CREATE_USER
              ,TBL_A.DBS_CREATE_DATE
              ,TBL_A.DBS_UPDATE_USER
              ,TBL_A.DBS_UPDATE_DATE
          FROM W_KOBAI_SHONIN_LIST AS TBL_A
              ,(SELECT TBL_1.KOBAI_NO
                      ,TBL_1.KOBAI_SEQ
                      ,TBL_1.MOD_DATE_TIME
                      ,TBL_1.AFTER_STS
                  FROM T_KOBAI_STS_R AS TBL_1
                 WHERE TBL_1.MOD_DATE_TIME = ( SELECT MAX(TBL_2.MOD_DATE_TIME)
                                                 FROM T_KOBAI_STS_R AS TBL_2
                                                WHERE TBL_2.KOBAI_NO  = TBL_1.KOBAI_NO
                                                  AND TBL_2.KOBAI_SEQ = TBL_1.KOBAI_SEQ )
               ) AS TBL_B
         WHERE TBL_A.W_USER_ID  =  @USER_ID
           AND TBL_A.W_SERIAL   =  @SERIAL
           AND TBL_A.SELECT_FLG =  'False'
           AND TBL_A.KOBAI_NO   =  TBL_B.KOBAI_NO
           AND TBL_A.KOBAI_SEQ  =  TBL_B.KOBAI_SEQ
           AND TBL_B.AFTER_STS  <> 1

        --���F�Ώےǉ�(�˗��e�[�u��)
        --�J�[�\���I�[�v��
        OPEN IRAI_SAVE_CURSOR

        FETCH NEXT FROM IRAI_SAVE_CURSOR INTO @KOBAI_NO, @KOBAI_SEQ
        WHILE @@FETCH_STATUS = 0
        BEGIN

            --�V�[�P���X�擾
            SET @SEQ = NEXT VALUE FOR SEQ_IRAI_NO

            --�˗�No.����
            SET @IRAI_NO = ( SELECT CONCAT( 'I', RIGHT('00'+CAST(YEAR(GETDATE()) AS NVARCHAR) ,2) 
                                      ,'-' 
                                      ,RIGHT('00'+CAST(MONTH(GETDATE()) AS NVARCHAR) ,2)
                                      ,RIGHT('0000' + CAST(@SEQ AS NVARCHAR) ,4) ) )

            --�˗��e�[�u���ǉ�����
            INSERT INTO
                   T_IRAI
            SELECT @IRAI_NO
                  ,KOBAI_NO
                  ,KOBAI_SEQ
                  ,@USER_ID
                  ,@SHONIN_DATE
                  ,1
                  ,DBS_UPDATE_USER
                  ,DBS_UPDATE_DATE
                  ,DBS_UPDATE_USER
                  ,DBS_UPDATE_DATE
              FROM W_KOBAI_SHONIN_LIST
             WHERE W_USER_ID = @USER_ID
               AND W_SERIAL  = @SERIAL
               AND KOBAI_NO  = '' + @KOBAI_NO + ''
               AND KOBAI_SEQ = @KOBAI_SEQ

            --���F�σX�e�[�^�X�X�V
            UPDATE T_KOBAI_B
               SET T_KOBAI_B.KOBAI_STS = 2
             WHERE T_KOBAI_B.KOBAI_NO  =  '' +  @KOBAI_NO + ''
               AND T_KOBAI_B.KOBAI_SEQ = @KOBAI_SEQ
               AND T_KOBAI_B.KOBAI_STS < 2

            --�X�e�[�^�X�ύX����ۑ�(���F��)
            INSERT INTO
                   T_KOBAI_STS_R
            SELECT
                   TBL_A.KOBAI_NO
                  ,TBL_A.KOBAI_SEQ
                  ,CONVERT(VARCHAR(10),GETDATE(),111) + ' ' + CONVERT(VARCHAR(8),GETDATE(),114)
                  ,TBL_B.AFTER_STS
                  ,2
                  ,1
                  ,TBL_A.DBS_CREATE_USER
                  ,TBL_A.DBS_CREATE_DATE
                  ,TBL_A.DBS_UPDATE_USER
                  ,TBL_A.DBS_UPDATE_DATE
              FROM W_KOBAI_SHONIN_LIST AS TBL_A
                  ,(SELECT TBL_1.KOBAI_NO
                          ,TBL_1.KOBAI_SEQ
                          ,TBL_1.MOD_DATE_TIME
                          ,TBL_1.AFTER_STS
                      FROM T_KOBAI_STS_R AS TBL_1
                     WHERE TBL_1.MOD_DATE_TIME = ( SELECT MAX(TBL_2.MOD_DATE_TIME)
                                                     FROM T_KOBAI_STS_R AS TBL_2
                                                    WHERE TBL_2.KOBAI_NO  = TBL_1.KOBAI_NO
                                                      AND TBL_2.KOBAI_SEQ = TBL_1.KOBAI_SEQ )
                   ) AS TBL_B
             WHERE TBL_A.W_USER_ID  =  @USER_ID
               AND TBL_A.W_SERIAL   =  @SERIAL
               AND TBL_A.SELECT_FLG =  'True'
               AND TBL_A.KOBAI_NO   =  TBL_B.KOBAI_NO
               AND TBL_A.KOBAI_SEQ  =  TBL_B.KOBAI_SEQ
               AND TBL_A.KOBAI_NO   =   '' +  @KOBAI_NO + ''
               AND TBL_A.KOBAI_SEQ  =  @KOBAI_SEQ
               AND TBL_B.AFTER_STS  <  2

            FETCH NEXT FROM IRAI_SAVE_CURSOR INTO @KOBAI_NO, @KOBAI_SEQ
        END

        CLOSE IRAI_SAVE_CURSOR

        --���[�N�e�[�u���N���A
        DELETE
          FROM W_KOBAI_SHONIN_LIST
         WHERE W_KOBAI_SHONIN_LIST.W_USER_ID = @USER_ID

     END

    --���[�N�e�[�u���폜����
    ELSE
     BEGIN
        --���[�N�e�[�u���N���A
        DELETE
          FROM W_KOBAI_SHONIN_LIST
         WHERE W_KOBAI_SHONIN_LIST.W_USER_ID = @USER_ID
     END

    DEALLOCATE IRAI_SAVE_CURSOR

END TRY


 --��O����
BEGIN CATCH

    -- �g�����U�N�V���������[���o�b�N�i�L�����Z���j
    ROLLBACK TRANSACTION SAVE1

    --���[�N�e�[�u���N���A
    DELETE
      FROM W_KOBAI_SHONIN_LIST
     WHERE W_KOBAI_SHONIN_LIST.W_USER_ID = @USER_ID

    DEALLOCATE IRAI_SAVE_CURSOR

END CATCH

END

