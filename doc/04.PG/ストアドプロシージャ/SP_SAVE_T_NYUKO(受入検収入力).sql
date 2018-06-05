--DROP PROCEDURE SP_SAVE_T_NYUKO

CREATE PROCEDURE SP_SAVE_T_NYUKO
       @USER_ID  NVARCHAR(64)
      ,@SERIAL   NVARCHAR(50)
      ,@MODE     INT
      ,@REF_NO   NVARCHAR(10)
      ,@SURYO    INT
AS
--�ۑ��������s
BEGIN
    --�߂�l�p�e�[�u���ϐ�
    DECLARE @TBL TABLE (
      RESULT_NYUKO_NO NVARCHAR(10)
     ,RESULT_CD int NOT NULL
     ,RESULT_MESSAGE NVARCHAR(max)
    )

    --�V�[�P���X
    DECLARE @NYUKO_SEQ AS INT
    DECLARE @ZAIKO_SEQ AS INT
    --�Ώۓ���No.
    DECLARE @NYUKO_NO AS NVARCHAR(10)
    --�Ώۍ݌�No.
    DECLARE @ZAIKO_NO AS NVARCHAR(10)
    --�Ώۍw��No.
    DECLARE @KOBAI_NO AS NVARCHAR(10)
    --�Ώۍw��SEQ
    DECLARE @KOBAI_SEQ AS INT
    --�Ώۈ˗�No.
    DECLARE @IRAI_NO AS NVARCHAR(10)
    --�Ώۍw���X�e�[�^�X
    DECLARE @KOBAI_STS AS NVARCHAR(9)
    --���ɐ����v
    DECLARE @NYUKO_TOTAL AS NUMERIC(7,2)
    --������
    DECLARE @CHUMON_SURYO AS NUMERIC(7,2)
    --�w���敪CD
    DECLARE @KOBAI_KBN AS NVARCHAR(9)

    --�Z�[�u�|�C���g����
    SAVE TRANSACTION SAVE1

BEGIN TRY

    --�V�K�o�^����
    IF @MODE = 1
      BEGIN

        --�V�[�P���X�擾
        SET @NYUKO_SEQ = NEXT VALUE FOR SEQ_NYUSHUKKO_NO
        --����No.����
        SET @NYUKO_NO = ( SELECT CONCAT( 'N', RIGHT('00'+CAST(YEAR(GETDATE()) AS NVARCHAR) ,2) 
                                ,'-' 
                                ,RIGHT('00' + CAST(MONTH(GETDATE()) AS NVARCHAR) ,2)
                                ,RIGHT('0000' + CAST(@NYUKO_SEQ AS NVARCHAR) ,4) ) )

        --�V�[�P���X�擾
        SET @ZAIKO_SEQ = NEXT VALUE FOR SEQ_ZAIKO_NO
        --�݌�No.����
        SET @ZAIKO_NO = ( SELECT CONCAT( 'Z', RIGHT('00'+CAST(YEAR(GETDATE()) AS NVARCHAR) ,2) 
                                ,'-' 
                                ,RIGHT('00' + CAST(MONTH(GETDATE()) AS NVARCHAR) ,2)
                                ,RIGHT('0000' + CAST(@ZAIKO_SEQ AS NVARCHAR) ,4) ) )

        --�w���\��No.��SEQ�擾
        SELECT @KOBAI_NO  = V_KOBAI_LIST.KOBAI_NO
              ,@KOBAI_SEQ = V_KOBAI_LIST.KOBAI_SEQ
              ,@KOBAI_KBN = V_KOBAI_LIST.KOBAI_KBN
          FROM W_UKEIRE_KENSHU_INPUT
          LEFT JOIN
               V_KOBAI_LIST
            ON V_KOBAI_LIST.IRAI_NO = W_UKEIRE_KENSHU_INPUT.IRAI_NO
         WHERE W_UKEIRE_KENSHU_INPUT.W_USER_ID = @USER_ID
           AND W_UKEIRE_KENSHU_INPUT.W_SERIAL  = @SERIAL
           AND W_UKEIRE_KENSHU_INPUT.W_ROW     = 1


        --�V�K�ۑ�(���[�N�e�[�u�����w�b�_�e�[�u��)
        INSERT INTO
               T_NYUSHUKKO
                 SELECT @NYUKO_NO           --NYUSHUKKO_NO
                       ,@ZAIKO_NO           --ZAIKO_NO
                       ,1                   --NYUSHUKKO_KBN
                       ,NYURYOKUSHA_CD      --NYURYOKUSHA_CD
                       ,IRAI_NO             --IRAI_NO
                       ,JURI_NO             --JURI_NO
                       ,HOKAN_BASHO_KBN     --HOKAN_BASHO_KBN
                       ,UKEIRE_DATE         --UKEIRE_DATE
                       ,KENSHU_DATE         --KENSHU_DATE
                       ,NYUKO_SURYO         --NYUKO_SURYO
                       ,NULL                --SHUKKO_DATE
                       ,NULL                --SHUKKO_SURYO
                       ,NULL                --SHUKKO_JIYU
                       ,1
                       ,DBS_CREATE_USER
                       ,DBS_CREATE_DATE
                       ,DBS_UPDATE_USER
                       ,DBS_UPDATE_DATE
                   FROM W_UKEIRE_KENSHU_INPUT
                  WHERE W_USER_ID = @USER_ID
                    AND W_SERIAL  = @SERIAL
                    AND W_ROW     = 1


        --�������X�V
        UPDATE T_NYUSHUKKO
           SET T_NYUSHUKKO.KENSHU_DATE = TBL_A.KENSHU_DATE
          FROM T_NYUSHUKKO
         INNER JOIN
               T_NYUSHUKKO AS TBL_A
            ON TBL_A.NYUSHUKKO_NO = @NYUKO_NO
           AND TBL_A.IRAI_NO      = T_NYUSHUKKO.IRAI_NO


        --�V�K�ۑ�(���[�N�e�[�u�����{�f�B�e�[�u��)
        INSERT INTO
               T_ZAIKO
                 SELECT @ZAIKO_NO                           --ZAIKO_NO
                       ,KOBAIHIN_CD                         --KOBAIHIN_CD
                       ,HOKAN_BASHO_KBN                     --HOKAN_BASHO_KBN
                       ,SHIIRE_CD                           --SHIIRE_CD
                       ,MAKER_CD                            --MAKER_CD
                       ,TANKA                               --TANKA
                       ,IRISU                               --IRISU
                       ,IRISU_TANI                          --IRISU_TANI
                       ,NYUKO_SURYO                         --ZAIKO_SURYO
                       ,BARA_TANI                           --BARA_TANI
                       ,CONVERT(VARCHAR(10), GETDATE(),111) --LAST_NYUKO_DATE
                       ,NULL                                --LAST_SHUKKO_DATE
                       ,1
                       ,DBS_CREATE_USER
                       ,DBS_CREATE_DATE
                       ,DBS_UPDATE_USER
                       ,DBS_UPDATE_DATE
                   FROM W_UKEIRE_KENSHU_INPUT
                  WHERE W_USER_ID = @USER_ID
                    AND W_SERIAL  = @SERIAL
                    AND W_ROW     = 1

        --���׃C���t�H���[�V������������
        --�̔����i�̏ꍇ�̓C���t�H���[�V���������ΏۊO
        IF @KOBAI_KBN <> '5'
          BEGIN
            EXEC SP_CREATE_INFO @USER_ID ,@SERIAL ,4
          END

      END

    --�X�V����
    ELSE IF @MODE = 2
      BEGIN

        --����No.�Z�b�g
        SET @NYUKO_NO = @REF_NO

        --�O��o�ɐ������擾
        SET @SURYO = @SURYO - ( SELECT NYUKO_SURYO
                                  FROM T_NYUSHUKKO
                                 WHERE NYUSHUKKO_NO = @NYUKO_NO )

        --���o�Ƀe�[�u���폜
        DELETE
          FROM T_NYUSHUKKO
         WHERE T_NYUSHUKKO.NYUSHUKKO_NO = @NYUKO_NO

        --�X�V(���[�N�e�[�u�����w�b�_�e�[�u��)
        INSERT INTO
               T_NYUSHUKKO
                 SELECT NYUSHUKKO_NO        --NYUSHUKKO_NO
                       ,ZAIKO_NO            --ZAIKO_NO
                       ,1                   --NYUSHUKKO_KBN
                       ,NYURYOKUSHA_CD      --NYURYOKUSHA_CD
                       ,IRAI_NO             --IRAI_NO
                       ,JURI_NO             --JURI_NO
                       ,HOKAN_BASHO_KBN     --HOKAN_BASHO_KBN
                       ,UKEIRE_DATE         --UKEIRE_DATE
                       ,KENSHU_DATE         --KENSHU_DATE
                       ,NYUKO_SURYO         --NYUKO_SURYO
                       ,NULL                --SHUKKO_DATE
                       ,NULL                --SHUKKO_SURYO
                       ,NULL                --SHUKKO_JIYU
                       ,1
                       ,DBS_CREATE_USER
                       ,DBS_CREATE_DATE
                       ,DBS_UPDATE_USER
                       ,DBS_UPDATE_DATE
                   FROM W_UKEIRE_KENSHU_INPUT
                  WHERE W_USER_ID = @USER_ID
                    AND W_SERIAL  = @SERIAL
                    AND W_ROW     = 1

        --�������X�V
        UPDATE T_NYUSHUKKO
           SET T_NYUSHUKKO.KENSHU_DATE = TBL_A.KENSHU_DATE
          FROM T_NYUSHUKKO
         INNER JOIN
               T_NYUSHUKKO AS TBL_A
            ON TBL_A.NYUSHUKKO_NO = @NYUKO_NO
           AND TBL_A.IRAI_NO      = T_NYUSHUKKO.IRAI_NO

        --�݌ɐ��C��
        UPDATE T_ZAIKO
           SET ZAIKO_SURYO     = ZAIKO_SURYO + @SURYO
              ,LAST_NYUKO_DATE = W_UKEIRE_KENSHU_INPUT.UKEIRE_DATE
              ,DBS_UPDATE_USER = W_UKEIRE_KENSHU_INPUT.DBS_UPDATE_USER
              ,DBS_UPDATE_DATE = W_UKEIRE_KENSHU_INPUT.DBS_UPDATE_DATE
          FROM T_ZAIKO
         INNER JOIN
               W_UKEIRE_KENSHU_INPUT
            ON W_UKEIRE_KENSHU_INPUT.ZAIKO_NO = T_ZAIKO.ZAIKO_NO
         WHERE W_USER_ID = @USER_ID
           AND W_SERIAL  = @SERIAL
           AND W_ROW     = 1

      END


    --�폜����
    ELSE IF @MODE = 3
      BEGIN

        --����No.�Z�b�g
        SET @NYUKO_NO = @REF_NO

        --�O����ɐ������擾
        SELECT @KOBAI_NO  = T_IRAI.KOBAI_NO
              ,@KOBAI_SEQ = T_IRAI.KOBAI_SEQ
              ,@IRAI_NO   = T_IRAI.IRAI_NO
              ,@SURYO     = T_NYUSHUKKO.NYUKO_SURYO
          FROM T_NYUSHUKKO
          LEFT JOIN
               T_IRAI
            ON T_IRAI.IRAI_NO = T_NYUSHUKKO.IRAI_NO
         WHERE NYUSHUKKO_NO = @NYUKO_NO

        --�݌ɐ��C��
        UPDATE T_ZAIKO
           SET ZAIKO_SURYO     = ZAIKO_SURYO - @SURYO
              ,DBS_UPDATE_USER = @USER_ID
              ,DBS_UPDATE_DATE = 'DT' + CONVERT(VARCHAR(24),GETDATE(),120)
          FROM T_ZAIKO
         INNER JOIN
               T_NYUSHUKKO
            ON T_NYUSHUKKO.ZAIKO_NO     = T_ZAIKO.ZAIKO_NO
         WHERE T_NYUSHUKKO.NYUSHUKKO_NO = @NYUKO_NO

        --���o�Ƀe�[�u���폜
        DELETE
          FROM T_NYUSHUKKO
         WHERE T_NYUSHUKKO.NYUSHUKKO_NO = @NYUKO_NO

        --���ɍ��v�E�������擾
        SET @NYUKO_TOTAL  = ( SELECT SUM(NYUKO_SURYO)
                                FROM T_NYUSHUKKO
                               WHERE T_NYUSHUKKO.IRAI_NO = @IRAI_NO )
        SET @CHUMON_SURYO = ( SELECT SURYO
                                FROM V_KOBAI_LIST
                               WHERE IRAI_NO = @IRAI_NO )

        --���ɐ���0�ȉ��̏ꍇ�A���������s�ς�
        IF ISNULL(@NYUKO_TOTAL,0) <= 0
          BEGIN
            SET @KOBAI_STS = 3
          END
        --���ɐ���1�ȏ�Œ������ȉ��̏ꍇ�A�ꕔ���׍ς�
        ELSE IF ISNULL(@NYUKO_TOTAL,0) < ISNULL(@CHUMON_SURYO,0)
          BEGIN
            SET @KOBAI_STS = 4
          END
        --��L�ȊO�̏ꍇ�A�ύX���Ȃ�
        ELSE
          BEGIN
            SET @KOBAI_STS = ( SELECT KOBAI_STS
                                 FROM V_KOBAI_LIST
                                WHERE IRAI_NO = @IRAI_NO )
          END

        --�X�e�[�^�X���f
        UPDATE T_KOBAI_B
           SET KOBAI_STS = @KOBAI_STS
--            SET KOBAI_STS = CASE ( SELECT COUNT(*)
--                                     FROM T_NYUSHUKKO
--                                    WHERE T_NYUSHUKKO.IRAI_NO = T_IRAI.IRAI_NO )
--                            WHEN 0 THEN 3
--                            ELSE KOBAI_STS
--                            END
          FROM T_KOBAI_B
         INNER JOIN
               T_IRAI
            ON T_IRAI.KOBAI_NO  = T_KOBAI_B.KOBAI_NO
           AND T_IRAI.KOBAI_SEQ = T_KOBAI_B.KOBAI_SEQ
         WHERE T_IRAI.IRAI_NO   = @IRAI_NO

        --�X�e�[�^�X�ύX����ۑ�(���������s�σX�e�[�^�X�ɖ߂�)
        INSERT INTO
               T_KOBAI_STS_R
        SELECT
               TBL_A.KOBAI_NO
              ,TBL_A.KOBAI_SEQ
              ,CONVERT(VARCHAR(10),GETDATE(),111) + ' ' + CONVERT(VARCHAR(8),GETDATE(),114) + '.4'
              ,TBL_B.AFTER_STS
              ,TBL_A.KOBAI_STS
              ,1
              ,@USER_ID
              ,'DT' + CONVERT(VARCHAR(24),GETDATE(),120)
              ,@USER_ID
              ,'DT' + CONVERT(VARCHAR(24),GETDATE(),120)
          FROM V_KOBAI_LIST AS TBL_A
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
         WHERE TBL_A.KOBAI_NO   =  @KOBAI_NO
           AND TBL_A.KOBAI_SEQ  =  @KOBAI_SEQ
           AND TBL_A.KOBAI_NO   =  TBL_B.KOBAI_NO
           AND TBL_A.KOBAI_SEQ  =  TBL_B.KOBAI_SEQ
           AND TBL_B.AFTER_STS  <> TBL_A.KOBAI_STS

      END

    --���̑�����
    ELSE
      BEGIN

        DELETE
          FROM W_UKEIRE_KENSHU_INPUT
         WHERE W_UKEIRE_KENSHU_INPUT.W_USER_ID = @USER_ID

      END

    --�X�e�[�^�X�X�V����
    IF @MODE IN ( 1,2 )
      BEGIN

        SET @KOBAI_NO  = NULL
        SET @KOBAI_SEQ = NULL

        --�w���\���f�[�^�X�e�[�^�X�X�V
        --�����(��������͍ρ�������>���א���)
        SELECT @KOBAI_NO  = T_KOBAI_B.KOBAI_NO
              ,@KOBAI_SEQ = T_KOBAI_B.KOBAI_SEQ
          FROM T_KOBAI_B
         WHERE EXISTS
               ( SELECT 1 
                   FROM T_NYUSHUKKO
                   LEFT JOIN
                        T_IRAI
                     ON T_IRAI.IRAI_NO = T_NYUSHUKKO.IRAI_NO
                  WHERE T_NYUSHUKKO.NYUSHUKKO_NO           =  @NYUKO_NO
                    AND T_NYUSHUKKO.NYUSHUKKO_KBN          =  1
                    AND ISNULL(T_NYUSHUKKO.UKEIRE_DATE,'') <> ''
--                    AND ISNULL(T_NYUSHUKKO.KENSHU_DATE,'') =  ''
                    AND T_KOBAI_B.SURYO                    >  ( SELECT SUM(NYUKO_SURYO)
                                                                  FROM T_NYUSHUKKO AS TBL_W
                                                                 WHERE TBL_W.IRAI_NO = T_NYUSHUKKO.IRAI_NO
                                                                 GROUP BY
                                                                       IRAI_NO )
                    AND T_IRAI.KOBAI_NO                    =  T_KOBAI_B.KOBAI_NO
                    AND T_IRAI.KOBAI_SEQ                   =  T_KOBAI_B.KOBAI_SEQ )

        IF @KOBAI_NO IS NOT NULL
          BEGIN

            --����σX�e�[�^�X�Z�b�g
            UPDATE T_KOBAI_B
               SET T_KOBAI_B.KOBAI_STS = 4
             WHERE T_KOBAI_B.KOBAI_NO  = @KOBAI_NO
               AND T_KOBAI_B.KOBAI_SEQ = @KOBAI_SEQ

            --�X�e�[�^�X�ύX����ۑ�(����σX�e�[�^�X)
            INSERT INTO
                   T_KOBAI_STS_R
            SELECT
                   TBL_A.KOBAI_NO
                  ,TBL_A.KOBAI_SEQ
                  ,CONVERT(VARCHAR(10),GETDATE(),111) + ' ' + CONVERT(VARCHAR(8),GETDATE(),114) + '.1'
                  ,TBL_B.AFTER_STS
                  ,TBL_A.KOBAI_STS
                  ,1
                  ,@USER_ID
                  ,'DT' + CONVERT(VARCHAR(24),GETDATE(),120)
                  ,@USER_ID
                  ,'DT' + CONVERT(VARCHAR(24),GETDATE(),120)
              FROM V_KOBAI_LIST AS TBL_A
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
             WHERE TBL_A.KOBAI_NO   =  @KOBAI_NO
               AND TBL_A.KOBAI_SEQ  =  @KOBAI_SEQ
               AND TBL_A.KOBAI_NO   =  TBL_B.KOBAI_NO
               AND TBL_A.KOBAI_SEQ  =  TBL_B.KOBAI_SEQ
               AND TBL_B.AFTER_STS  IN ( '1','2','3' )

          END

        SET @KOBAI_NO  = NULL
        SET @KOBAI_SEQ = NULL

        --���׊���(��������͍ρ������������́�������<=���א���)
        SELECT @KOBAI_NO  = T_KOBAI_B.KOBAI_NO
              ,@KOBAI_SEQ = T_KOBAI_B.KOBAI_SEQ
          FROM T_KOBAI_B
         WHERE EXISTS
               ( SELECT 1 
                   FROM T_NYUSHUKKO
                   LEFT JOIN
                        T_IRAI
                     ON T_IRAI.IRAI_NO = T_NYUSHUKKO.IRAI_NO
                  WHERE T_NYUSHUKKO.NYUSHUKKO_NO           =  @NYUKO_NO
                    AND T_NYUSHUKKO.NYUSHUKKO_KBN          =  1
                    AND ISNULL(T_NYUSHUKKO.UKEIRE_DATE,'') <> ''
                    AND ISNULL(T_NYUSHUKKO.KENSHU_DATE,'') =  ''
                    AND T_KOBAI_B.SURYO                    <= ( SELECT SUM(NYUKO_SURYO)
                                                                  FROM T_NYUSHUKKO AS TBL_W
                                                                 WHERE TBL_W.IRAI_NO = T_NYUSHUKKO.IRAI_NO
                                                                 GROUP BY
                                                                       IRAI_NO )
                    AND T_IRAI.KOBAI_NO                    =  T_KOBAI_B.KOBAI_NO
                    AND T_IRAI.KOBAI_SEQ                   =  T_KOBAI_B.KOBAI_SEQ )

        IF @KOBAI_NO IS NOT NULL
          BEGIN

            --���׊����X�e�[�^�X�Z�b�g
            UPDATE T_KOBAI_B
               SET T_KOBAI_B.KOBAI_STS = 5
             WHERE T_KOBAI_B.KOBAI_NO  = @KOBAI_NO
               AND T_KOBAI_B.KOBAI_SEQ = @KOBAI_SEQ

            --�X�e�[�^�X�ύX����ۑ�(���׊����X�e�[�^�X)
            INSERT INTO
                   T_KOBAI_STS_R
            SELECT
                   TBL_A.KOBAI_NO
                  ,TBL_A.KOBAI_SEQ
                  ,CONVERT(VARCHAR(10),GETDATE(),111) + ' ' + CONVERT(VARCHAR(8),GETDATE(),114) + '.2'
                  ,TBL_B.AFTER_STS
                  ,TBL_A.KOBAI_STS
                  ,1
                  ,@USER_ID
                  ,'DT' + CONVERT(VARCHAR(24),GETDATE(),120)
                  ,@USER_ID
                  ,'DT' + CONVERT(VARCHAR(24),GETDATE(),120)
              FROM V_KOBAI_LIST AS TBL_A
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
             WHERE TBL_A.KOBAI_NO   =  @KOBAI_NO
               AND TBL_A.KOBAI_SEQ  =  @KOBAI_SEQ
               AND TBL_A.KOBAI_NO   =  TBL_B.KOBAI_NO
               AND TBL_A.KOBAI_SEQ  =  TBL_B.KOBAI_SEQ
               AND TBL_B.AFTER_STS  IN ( '1','2','3','4' )

          END

        SET @KOBAI_NO  = NULL
        SET @KOBAI_SEQ = NULL

        --������(��������͍ρ����������͍ρ�������<=���א���)
        SELECT @KOBAI_NO  = T_KOBAI_B.KOBAI_NO
              ,@KOBAI_SEQ = T_KOBAI_B.KOBAI_SEQ
          FROM T_KOBAI_B
         WHERE EXISTS
               ( SELECT 1 
                   FROM T_NYUSHUKKO
                   LEFT JOIN
                        T_IRAI
                     ON T_IRAI.IRAI_NO = T_NYUSHUKKO.IRAI_NO
                  WHERE T_NYUSHUKKO.NYUSHUKKO_NO           =  @NYUKO_NO
                    AND T_NYUSHUKKO.NYUSHUKKO_KBN          =  1
                    AND ISNULL(T_NYUSHUKKO.UKEIRE_DATE,'') <> ''
                    AND ISNULL(T_NYUSHUKKO.KENSHU_DATE,'') <> ''
                    AND T_KOBAI_B.SURYO                    <= ( SELECT SUM(NYUKO_SURYO)
                                                                  FROM T_NYUSHUKKO AS TBL_W
                                                                 WHERE TBL_W.IRAI_NO = T_NYUSHUKKO.IRAI_NO
                                                                 GROUP BY
                                                                       IRAI_NO )
                    AND T_IRAI.KOBAI_NO                    =  T_KOBAI_B.KOBAI_NO
                    AND T_IRAI.KOBAI_SEQ                   =  T_KOBAI_B.KOBAI_SEQ )

        IF @KOBAI_NO IS NOT NULL
          BEGIN

            --�����σX�e�[�^�X�Z�b�g
            UPDATE T_KOBAI_B
               SET T_KOBAI_B.KOBAI_STS = 6
             WHERE T_KOBAI_B.KOBAI_NO  = @KOBAI_NO
               AND T_KOBAI_B.KOBAI_SEQ = @KOBAI_SEQ

            --�X�e�[�^�X�ύX����ۑ�(�����σX�e�[�^�X)
            INSERT INTO
                   T_KOBAI_STS_R
            SELECT
                   TBL_A.KOBAI_NO
                  ,TBL_A.KOBAI_SEQ
                  ,CONVERT(VARCHAR(10),GETDATE(),111) + ' ' + CONVERT(VARCHAR(8),GETDATE(),114) + '.3'
                  ,TBL_B.AFTER_STS
                  ,TBL_A.KOBAI_STS
                  ,1
                  ,@USER_ID
                  ,'DT' + CONVERT(VARCHAR(24),GETDATE(),120)
                  ,@USER_ID
                  ,'DT' + CONVERT(VARCHAR(24),GETDATE(),120)
              FROM V_KOBAI_LIST AS TBL_A
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
             WHERE TBL_A.KOBAI_NO   =  @KOBAI_NO
               AND TBL_A.KOBAI_SEQ  =  @KOBAI_SEQ
               AND TBL_A.KOBAI_NO   =  TBL_B.KOBAI_NO
               AND TBL_A.KOBAI_SEQ  =  TBL_B.KOBAI_SEQ
               AND TBL_B.AFTER_STS  IN ( '1','2','3','4','5' )

            --���������C���t�H���[�V������������
            --�w���敪�������̏ꍇ�A�ʒm�𐶐�����
            IF ( SELECT V_KOBAI_LIST.KOBAI_KBN
                   FROM W_UKEIRE_KENSHU_INPUT
                   LEFT JOIN
                        V_KOBAI_LIST
                     ON V_KOBAI_LIST.IRAI_NO = W_UKEIRE_KENSHU_INPUT.IRAI_NO
                  WHERE W_UKEIRE_KENSHU_INPUT.W_USER_ID = @USER_ID
                    AND W_UKEIRE_KENSHU_INPUT.W_SERIAL  = @SERIAL
                    AND W_UKEIRE_KENSHU_INPUT.W_ROW     = 1 ) = 4
            BEGIN
                EXEC SP_CREATE_INFO @USER_ID ,@SERIAL ,3
            END

          END
      END

    --���ʏ���
    --���[�N�e�[�u���N���A
    DELETE
      FROM W_UKEIRE_KENSHU_INPUT
     WHERE W_UKEIRE_KENSHU_INPUT.W_USER_ID = @USER_ID

    --����I��
    INSERT INTO @TBL VALUES( @NYUKO_NO, 0, NULL )

    --�������ʕԋp
    SELECT RESULT_NYUKO_NO, RESULT_CD, RESULT_MESSAGE FROM @TBL

END TRY


-- ��O����
BEGIN CATCH

    --�g�����U�N�V���������[���o�b�N�i�L�����Z���j
    ROLLBACK TRANSACTION SAVE1

    --���[�N�e�[�u���N���A
    DELETE
      FROM W_UKEIRE_KENSHU_INPUT
     WHERE W_UKEIRE_KENSHU_INPUT.W_USER_ID = @USER_ID

    --�ُ�I��
    INSERT INTO @TBL VALUES( 0, ERROR_NUMBER(), ERROR_MESSAGE() )

    --�������ʕԋp
    SELECT RESULT_NYUKO_NO, RESULT_CD, RESULT_MESSAGE FROM @TBL

END CATCH

END


