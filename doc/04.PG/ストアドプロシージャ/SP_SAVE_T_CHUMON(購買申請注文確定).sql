
--DROP PROCEDURE SP_SAVE_T_CHUMON

CREATE PROCEDURE SP_SAVE_T_CHUMON
       @USER_ID     NVARCHAR(64)
      ,@SERIAL      NVARCHAR(50)
      ,@MODE        NVARCHAR(1)
      ,@SQL         NVARCHAR(max)
      ,@HATCHU_DATE NVARCHAR(10)
AS
--[���[�h] 0:�Ǎ� / 1:���F(�ۑ�) / ELSE:���[�N�e�[�u���폜
BEGIN

--�ϐ���`
    DECLARE @strSQL NVARCHAR(max)

    --�V�[�P���X
    DECLARE @SEQ AS INT

    --�Ώے���No.
    DECLARE @CHUMON_NO AS NVARCHAR(10)
    --�Ώۈ˗�No.
    DECLARE @IRAI_NO AS NVARCHAR(10)
    --�Ώۍw��No.
    DECLARE @KOBAI_NO AS NVARCHAR(10)
    --�Ώۍw��SEQ
    DECLARE @KOBAI_SEQ AS INT
    --�Ώێd����CD
    DECLARE @SHIIRE_CD AS NVARCHAR(10)

    --���F��
    DECLARE @SHONIN_DATE AS NVARCHAR(10)

    --�˗��e�[�u���ۑ��p�J�[�\��
    DECLARE IRAI_SAVE_CURSOR CURSOR
        FOR
     SELECT W_KOBAI_CHUMON_LIST.KOBAI_NO
           ,W_KOBAI_CHUMON_LIST.KOBAI_SEQ
       FROM W_KOBAI_CHUMON_LIST
      WHERE W_KOBAI_CHUMON_LIST.W_USER_ID          =  @USER_ID
        AND W_KOBAI_CHUMON_LIST.SELECT_FLG         =  'True'
        AND ISNULL(W_KOBAI_CHUMON_LIST.IRAI_NO,'') =  ''

    --�����e�[�u���ۑ��p�J�[�\��
    DECLARE CHUMON_SAVE_CURSOR CURSOR
        FOR
     SELECT W_KOBAI_CHUMON_LIST.SHIIRE_CD
       FROM W_KOBAI_CHUMON_LIST
      WHERE W_KOBAI_CHUMON_LIST.W_USER_ID            =  @USER_ID
        AND W_KOBAI_CHUMON_LIST.SELECT_FLG           =  'True'
        AND ISNULL(W_KOBAI_CHUMON_LIST.CHUMON_NO,'') =  ''
      GROUP BY
            W_KOBAI_CHUMON_LIST.SHIIRE_CD


--�Z�[�u�|�C���g����
    SAVE TRANSACTION SAVE1

BEGIN TRY

    --�Ǎ�����
    IF @MODE = 0
      BEGIN

        --���[�N�e�[�u���N���A
        DELETE
          FROM W_KOBAI_CHUMON_LIST
         WHERE W_KOBAI_CHUMON_LIST.W_USER_ID = @USER_ID

        --�Ǎ��f�[�^�����[�N�e�[�u���֊i�[
        SET @strSQL = 'INSERT INTO '
                    + '  W_KOBAI_CHUMON_LIST '
                    + 'SELECT   '''+ @USER_ID +''''
                    + '        ,'''+ @SERIAL  +''''
                    + '        ,ROW_NUMBER() OVER (ORDER BY IRAI_NO) '
                    + '        ,'  + @MODE
                    + '        ,TBL1.*'
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

        --���������Ώۍ폜(�����e�[�u��)
        DELETE
          FROM T_CHUMON
         WHERE EXISTS
               ( SELECT 1 
                   FROM W_KOBAI_CHUMON_LIST
                  WHERE W_KOBAI_CHUMON_LIST.W_USER_ID  = @USER_ID
                    AND W_KOBAI_CHUMON_LIST.SELECT_FLG = 'False'
                    AND W_KOBAI_CHUMON_LIST.IRAI_NO    = T_CHUMON.IRAI_NO )

        --�X�e�[�^�X�ύX����ۑ� 201801�ǉ�
       INSERT INTO
               T_KOBAI_STS_R
        SELECT
               TBL_A.KOBAI_NO
              ,TBL_A.KOBAI_SEQ
              ,CONVERT(VARCHAR(10),GETDATE(),111) + ' ' + CONVERT(VARCHAR(8),GETDATE(),114)
              ,TBL_A.KOBAI_STS
              ,2
              ,1
              ,TBL_A.DBS_CREATE_USER
              ,TBL_A.DBS_CREATE_DATE
              ,TBL_A.DBS_UPDATE_USER
              ,TBL_A.DBS_UPDATE_DATE
          FROM W_KOBAI_CHUMON_LIST AS TBL_A
                    LEFT JOIN T_KOBAI_B
                     ON TBL_A.KOBAI_NO   =  T_KOBAI_B.KOBAI_NO
                    AND TBL_A.KOBAI_SEQ  =  T_KOBAI_B.KOBAI_SEQ
                  WHERE TBL_A.W_USER_ID  =  @USER_ID
                    AND TBL_A.SELECT_FLG =  'False'
                    AND T_KOBAI_B.KOBAI_STS        NOT IN ( '1','2' )

       --���������X�e�[�^�X�X�V
        UPDATE T_KOBAI_B
           SET T_KOBAI_B.KOBAI_STS = 2
         WHERE EXISTS
               ( SELECT 1 
                   FROM W_KOBAI_CHUMON_LIST
                  WHERE W_KOBAI_CHUMON_LIST.W_USER_ID  =  @USER_ID
                    AND W_KOBAI_CHUMON_LIST.SELECT_FLG =  'False'
                    AND W_KOBAI_CHUMON_LIST.KOBAI_NO   =  T_KOBAI_B.KOBAI_NO
                    AND W_KOBAI_CHUMON_LIST.KOBAI_SEQ  =  T_KOBAI_B.KOBAI_SEQ
                    AND T_KOBAI_B.KOBAI_STS        NOT IN ( '1','2' ) )

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
              FROM W_KOBAI_CHUMON_LIST
             WHERE W_USER_ID = @USER_ID
               AND W_SERIAL  = @SERIAL
               AND KOBAI_NO  = '' + @KOBAI_NO + ''
               AND KOBAI_SEQ = @KOBAI_SEQ

            FETCH NEXT FROM IRAI_SAVE_CURSOR INTO @KOBAI_NO, @KOBAI_SEQ
        END


        --�����Ώےǉ�(�����e�[�u��)
        --�J�[�\���I�[�v��
        OPEN CHUMON_SAVE_CURSOR

        FETCH NEXT FROM CHUMON_SAVE_CURSOR INTO @SHIIRE_CD
        WHILE @@FETCH_STATUS = 0
        BEGIN

            --�V�[�P���X�擾
            SET @SEQ = NEXT VALUE FOR SEQ_CHUMON_NO

            --�˗�No.����
            SET @CHUMON_NO = ( SELECT CONCAT( 'C', RIGHT('00'+CAST(YEAR(GETDATE()) AS NVARCHAR) ,2) 
                                   ,'-' 
                                   ,RIGHT('00'+CAST(MONTH(GETDATE()) AS NVARCHAR) ,2)
                                   ,RIGHT('0000' + CAST(@SEQ AS NVARCHAR) ,4) ) )


            --�����e�[�u���ǉ�����
            INSERT INTO
                   T_CHUMON
            SELECT
                   @CHUMON_NO
                  ,ROW_NUMBER() OVER (ORDER BY W_ROW)
                  ,W_KOBAI_CHUMON_LIST.KOBAI_NO
                  ,W_KOBAI_CHUMON_LIST.KOBAI_SEQ
                  ,T_IRAI.IRAI_NO
                  ,@USER_ID
                  ,@HATCHU_DATE
                  ,'False'
                  ,1
                  ,W_KOBAI_CHUMON_LIST.DBS_UPDATE_USER
                  ,W_KOBAI_CHUMON_LIST.DBS_UPDATE_DATE
                  ,W_KOBAI_CHUMON_LIST.DBS_UPDATE_USER
                  ,W_KOBAI_CHUMON_LIST.DBS_UPDATE_DATE
              FROM W_KOBAI_CHUMON_LIST
              LEFT JOIN
                   T_IRAI
                ON T_IRAI.KOBAI_NO  = W_KOBAI_CHUMON_LIST.KOBAI_NO
               AND T_IRAI.KOBAI_SEQ = W_KOBAI_CHUMON_LIST.KOBAI_SEQ
             WHERE W_USER_ID = @USER_ID
               AND W_SERIAL  = @SERIAL
               AND SHIIRE_CD = '' + @SHIIRE_CD + ''
               AND SELECT_FLG           =  'True'
               AND ISNULL(CHUMON_NO,'') =  ''


            --�����σX�e�[�^�X�X�V
            UPDATE T_KOBAI_B
               SET T_KOBAI_B.KOBAI_STS = 3
              FROM T_KOBAI_B
             INNER JOIN
                   W_KOBAI_CHUMON_LIST
                ON W_KOBAI_CHUMON_LIST.KOBAI_NO   =  T_KOBAI_B.KOBAI_NO
               AND W_KOBAI_CHUMON_LIST.KOBAI_SEQ  =  T_KOBAI_B.KOBAI_SEQ
             WHERE W_KOBAI_CHUMON_LIST.W_USER_ID  =  @USER_ID
               AND W_KOBAI_CHUMON_LIST.W_SERIAL   =  @SERIAL
               AND W_KOBAI_CHUMON_LIST.SHIIRE_CD  =  '' + @SHIIRE_CD + ''
               AND W_KOBAI_CHUMON_LIST.SELECT_FLG =  'True'
               AND ISNULL(CHUMON_NO,'')           =  ''
               AND T_KOBAI_B.KOBAI_STS            IN ( '1','2' )


            --�X�e�[�^�X�ύX����ۑ�(�����m�蕪)
            INSERT INTO
                   T_KOBAI_STS_R
            SELECT
                   TBL_A.KOBAI_NO
                  ,TBL_A.KOBAI_SEQ
                  ,CONVERT(VARCHAR(10),GETDATE(),111) + ' ' + CONVERT(VARCHAR(8),GETDATE(),114)
                  ,TBL_B.AFTER_STS
                  ,3
                  ,1
                  ,TBL_A.DBS_CREATE_USER
                  ,TBL_A.DBS_CREATE_DATE
                  ,TBL_A.DBS_UPDATE_USER
                  ,TBL_A.DBS_UPDATE_DATE
              FROM W_KOBAI_CHUMON_LIST AS TBL_A
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
               AND TBL_A.SHIIRE_CD  =  '' + @SHIIRE_CD + ''
               AND TBL_B.AFTER_STS  IN ( '1','2' )

            FETCH NEXT FROM CHUMON_SAVE_CURSOR INTO @SHIIRE_CD
        END




        CLOSE IRAI_SAVE_CURSOR
        CLOSE CHUMON_SAVE_CURSOR


        --�������X�V
        UPDATE T_CHUMON
           SET T_CHUMON.HATCHU_DATE = @HATCHU_DATE
          FROM T_CHUMON
         WHERE T_CHUMON.CHUMON_NO IN
               ( SELECT TBL_2.CHUMON_NO
                   FROM W_KOBAI_CHUMON_LIST AS TBL_1
                   LEFT JOIN
                        T_CHUMON AS TBL_2
                     ON TBL_2.KOBAI_NO   = TBL_1.KOBAI_NO
                    AND TBL_2.KOBAI_SEQ  = TBL_1.KOBAI_SEQ
                  WHERE TBL_1.W_USER_ID  = @USER_ID
                    AND TBL_1.W_SERIAL   = @SERIAL
                    AND TBL_1.SELECT_FLG = 'True'
               )

        --�����m��C���t�H���[�V�������� 201801�ǉ�

          BEGIN
           EXEC SP_CREATE_INFO @USER_ID ,@SERIAL ,6
          END


     END

    --���[�N�e�[�u���폜����
    ELSE
     BEGIN
        --���[�N�e�[�u���N���A
        DELETE
          FROM W_KOBAI_CHUMON_LIST
         WHERE W_KOBAI_CHUMON_LIST.W_USER_ID = @USER_ID
     END

    DEALLOCATE IRAI_SAVE_CURSOR
    DEALLOCATE CHUMON_SAVE_CURSOR


END TRY


--��O����
BEGIN CATCH

    -- �g�����U�N�V���������[���o�b�N�i�L�����Z���j
    ROLLBACK TRANSACTION SAVE1

    --���[�N�e�[�u���N���A
    DELETE
      FROM W_KOBAI_CHUMON_LIST
     WHERE W_KOBAI_CHUMON_LIST.W_USER_ID = @USER_ID

    DEALLOCATE IRAI_SAVE_CURSOR
    DEALLOCATE CHUMON_SAVE_CURSOR

END CATCH

END

