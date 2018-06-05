
--DROP PROCEDURE SP_SAVE_T_SHIIRE

CREATE PROCEDURE SP_SAVE_T_SHIIRE
       @USER_ID  NVARCHAR(64)
      ,@SERIAL   NVARCHAR(50)
      ,@MODE     INT
      ,@PAGE     INT            --�y�[�WNo.
      ,@REF_NO   NVARCHAR(10)   --�Q��No.

AS
--�ۑ��������s
--[���[�h] 0:�Ǎ� / 1:�V�K�ۑ� / 2:�X�V / 3:�폜 / 4:�w���f�[�^�����ڑ� / 5:�w���ڑ��ꊇ�ۑ� /
--         6:�Q�ƍ쐬 / 99(ELSE):���[�N�e�[�u���N���A

BEGIN

    --�߂�l�p�e�[�u���ϐ�
    DECLARE @TBL TABLE (
      RESULT_SHIIRE_NO NVARCHAR(10)
     ,RESULT_CD INT NOT NULL
     ,RESULT_MESSAGE NVARCHAR(max)
    )

    --�V�[�P���X
    DECLARE @SEQ AS INT

    --�Ώێd��No.
    DECLARE @SHIIRE_NO AS NVARCHAR(10)

    --�d����(������)
    DECLARE @SHIIRE_DATE AS NVARCHAR(10)

    --�X�V���[�U�[�E�X�V����
    DECLARE @UPDATE_DATE AS NVARCHAR(50)

    --�x�����v�Z�p
    DECLARE @SHIHARAI_MONTH AS INT
    DECLARE @SHIHARAI_DAY AS INT

    --�J�[�\������
    --�d���ꊇ�Ǎ��p�J�[�\��
    DECLARE SHIIRE_LOAD_CURSOR CURSOR
        FOR SELECT DISTINCT
                   V_SHIIRE_KOBAI_DATA.SHIIRE_CD
                  ,V_SHIIRE_KOBAI_DATA.SHIIRE_DATE
              FROM V_SHIIRE_KOBAI_DATA
             WHERE V_SHIIRE_KOBAI_DATA.W_USER_ID = @USER_ID
             ORDER BY
                    SHIIRE_DATE ASC
                   ,SHIIRE_CD   ASC

    --�d���ꊇ�ۑ��p�J�[�\��
    DECLARE SHIIRE_SAVE_CURSOR CURSOR
        FOR
     SELECT W_SHIIRE.W_PAGE
       FROM W_SHIIRE
      WHERE W_SHIIRE.W_USER_ID                        =  @USER_ID
        AND ISNULL(W_SHIIRE.SHIIRE_DATE,'')           <> ''
        AND ISNULL(W_SHIIRE.SHIIRE_KAMOKU,'')         <> ''
        AND ISNULL(W_SHIIRE.DENKU,'')                 <> ''
        AND ISNULL(W_SHIIRE.KOBAI_KBN,'')             <> ''
        AND ISNULL(W_SHIIRE.KANJO_KAMOKU,'')          <> ''
        AND ISNULL(W_SHIIRE.SHIIRE_NYURYOKUSHA_CD,'') <> ''
        AND ISNULL(W_SHIIRE.SHIHARAI_DATE,'')         <> ''
        AND ISNULL(W_SHIIRE.SHIIRE_STS,'')            <> ''
        AND ( SELECT COUNT(*)
                FROM W_SHIIRE AS TBL_W
               WHERE ISNULL(TBL_W.KOBAIHIN_CD,'') = ''
                 AND TBL_W.W_USER_ID = W_SHIIRE.W_USER_ID
                 AND TBL_W.W_SERIAL  = W_SHIIRE.W_SERIAL
                 AND TBL_W.W_PAGE    = W_SHIIRE.W_PAGE    ) =  0
        AND ( SELECT COUNT(*)
                FROM W_SHIIRE AS TBL_W
               WHERE TBL_W.TANKA IS NULL
                 AND TBL_W.W_USER_ID = W_SHIIRE.W_USER_ID
                 AND TBL_W.W_SERIAL  = W_SHIIRE.W_SERIAL
                 AND TBL_W.W_PAGE    = W_SHIIRE.W_PAGE    ) =  0
        AND ( SELECT COUNT(*)
                FROM W_SHIIRE AS TBL_W
               WHERE TBL_W.SURYO IS NULL
                 AND TBL_W.W_USER_ID = W_SHIIRE.W_USER_ID
                 AND TBL_W.W_SERIAL  = W_SHIIRE.W_SERIAL
                 AND TBL_W.W_PAGE    = W_SHIIRE.W_PAGE    ) =  0
      GROUP BY
            W_SHIIRE.W_USER_ID
           ,W_SHIIRE.W_SERIAL
           ,W_SHIIRE.W_PAGE

    --�Ώێd��No.
    DECLARE @SHIIRE_CD AS NVARCHAR(10)

    --�Z�[�u�|�C���g����
    SAVE TRANSACTION SAVE1

BEGIN TRY

    --�Ǎ�����
    IF @MODE = 0
      BEGIN

        --�X�V�����ݒ�
        SET @UPDATE_DATE = 'DT' + CONVERT(VARCHAR(24),GETDATE(),120)

        --���[�N�e�[�u���N���A
        DELETE
          FROM W_SHIIRE
         WHERE W_SHIIRE.W_USER_ID = @USER_ID

        --�Ǎ�(�e�[�u�������[�N�e�[�u��)
        INSERT INTO
               W_SHIIRE
        SELECT
               @USER_ID
              ,@SERIAL
              ,1
              ,T_SHIIRE_B.GYO_NO
              ,0
              ,T_SHIIRE_H.SHIIRE_NO
              ,T_SHIIRE_H.SHIIRE_DATE
              ,T_SHIIRE_H.SHIIRE_KAMOKU
              ,T_SHIIRE_H.DENKU
              ,T_SHIIRE_H.KOBAI_KBN
              ,T_SHIIRE_H.KANJO_KAMOKU
              ,T_SHIIRE_H.SHIIRE_NYURYOKUSHA_CD
              ,T_SHIIRE_H.SHIHARAI_DATE
              ,T_SHIIRE_H.SHIIRE_STS
              ,T_SHIIRE_H.SHIIRE_CD
              ,T_SHIIRE_H.TAX_RATE
              ,T_SHIIRE_H.NUKI_TOTAL
              ,T_SHIIRE_H.TAX
              ,T_SHIIRE_H.KOMI_TOTAL
              ,T_SHIIRE_H.SHOKAN_NO
              ,T_SHIIRE_H.SHOKAN_LINK_DATETIME
              ,T_SHIIRE_B.GYO_NO
              ,T_SHIIRE_B.KOBAIHIN_CD
              ,T_SHIIRE_B.KOBAIHIN_MEI
              ,T_SHIIRE_B.TANKA
              ,T_SHIIRE_B.IRISU
              ,T_SHIIRE_B.IRISU_TANI
              ,T_SHIIRE_B.SURYO
              ,T_SHIIRE_B.BARA_TANI
              ,T_SHIIRE_B.SOSU
              ,T_SHIIRE_B.TOTAL
              ,T_SHIIRE_B.MAKER_CD
              ,T_SHIIRE_B.YOSAN_CD
              ,T_SHIIRE_B.JURI_NO
              ,T_SHIIRE_B.BIKO
              ,T_SHIIRE_B.KOBAI_NO
              ,T_SHIIRE_B.KOBAI_SEQ
              ,T_SHIIRE_H.DEL_FLG
              ,1
              ,T_SHIIRE_H.DBS_CREATE_USER
              ,T_SHIIRE_H.DBS_CREATE_DATE
              ,T_SHIIRE_H.DBS_UPDATE_USER
              ,T_SHIIRE_H.DBS_UPDATE_DATE
          FROM T_SHIIRE_H
          LEFT JOIN
               T_SHIIRE_B
            ON T_SHIIRE_B.SHIIRE_NO = T_SHIIRE_H.SHIIRE_NO
         WHERE T_SHIIRE_H.SHIIRE_NO = @REF_NO

      END

    --�V�K�o�^����(�Ώۃy�[�W�ۑ�)
    ELSE IF @MODE = 1
      BEGIN

        --�V�[�P���X�擾
        SET @SEQ = NEXT VALUE FOR SEQ_SHIIRE_NO

        --�d��No.����
        SET @SHIIRE_NO = ( SELECT CONCAT( 'S', RIGHT('00'+CAST(YEAR(GETDATE()) AS NVARCHAR) ,2) 
                                  ,'-' 
                                  ,RIGHT('00'+CAST(MONTH(GETDATE()) AS NVARCHAR) ,2)
                                  ,RIGHT('0000' + CAST(@SEQ AS NVARCHAR) ,4) ) )

        --�V�K�ۑ�(���[�N�e�[�u�����w�b�_�e�[�u��)
        INSERT INTO
               T_SHIIRE_H
               SELECT
                      @SHIIRE_NO
                     ,SHIIRE_DATE
                     ,SHIIRE_KAMOKU
                     ,DENKU
                     ,KOBAI_KBN
                     ,KANJO_KAMOKU
                     ,SHIIRE_NYURYOKUSHA_CD
                     ,SHIHARAI_DATE
                     ,SHIIRE_STS
                     ,SHIIRE_CD
                     ,TAX_RATE
                     ,NUKI_TOTAL
                     ,TAX
                     ,KOMI_TOTAL
                     ,SHOKAN_NO
                     ,SHOKAN_LINK_DATETIME
                     ,DEL_FLG
                     ,DBS_STATUS
                     ,DBS_CREATE_USER
                     ,DBS_CREATE_DATE
                     ,DBS_UPDATE_USER
                     ,DBS_UPDATE_DATE
                 FROM W_SHIIRE
                WHERE W_USER_ID = @USER_ID
                  AND W_SERIAL  = @SERIAL
                  AND W_PAGE    = @PAGE
                  AND W_ROW     = 1


        --�V�K�ۑ�(���[�N�e�[�u�����{�f�B�e�[�u��)
        INSERT INTO
               T_SHIIRE_B
               SELECT
                      @SHIIRE_NO
                     ,GYO_NO
                     ,KOBAIHIN_CD
                     ,KOBAIHIN_MEI
                     ,TANKA
                     ,IRISU
                     ,IRISU_TANI
                     ,SURYO
                     ,BARA_TANI
                     ,SOSU
                     ,TOTAL
                     ,MAKER_CD
                     ,YOSAN_CD
                     ,JURI_NO
                     ,BIKO
                     ,KOBAI_NO
                     ,KOBAI_SEQ
                     ,DEL_FLG
                     ,DBS_STATUS
                     ,DBS_CREATE_USER
                     ,DBS_CREATE_DATE
                     ,DBS_UPDATE_USER
                     ,DBS_UPDATE_DATE
                 FROM W_SHIIRE
                WHERE W_USER_ID = @USER_ID
                  AND W_SERIAL  = @SERIAL
                  AND W_PAGE    = @PAGE

        --�X�V�y�[�W�N���A
        DELETE
          FROM W_SHIIRE
         WHERE W_SHIIRE.W_USER_ID = @USER_ID
           AND W_SHIIRE.W_SERIAL  = @SERIAL
           AND W_SHIIRE.W_PAGE    = @PAGE

        --�X�V�y�[�W�ȍ~�̃y�[�W�f�N�������g
        UPDATE W_SHIIRE
           SET W_SHIIRE.W_PAGE = W_SHIIRE.W_PAGE - 1
         WHERE W_SHIIRE.W_USER_ID = @USER_ID
           AND W_SHIIRE.W_SERIAL  = @SERIAL
           AND W_SHIIRE.W_PAGE    > @PAGE

        --�d�����z�w���f�[�^���f
        UPDATE T_KOBAI_B
           SET T_KOBAI_B.TANKA = T_SHIIRE_B.TANKA
              ,T_KOBAI_B.TOTAL = CONVERT(NUMERIC(11,2),T_SHIIRE_B.TANKA * T_KOBAI_B.SURYO)
          FROM T_SHIIRE_B
         INNER JOIN
               T_KOBAI_B
            ON T_KOBAI_B.KOBAI_NO  = T_SHIIRE_B.KOBAI_NO
           AND T_KOBAI_B.KOBAI_SEQ = T_SHIIRE_B.KOBAI_SEQ
         WHERE T_SHIIRE_B.SHIIRE_NO = @SHIIRE_NO

        --����I��
        INSERT INTO @TBL VALUES( @SHIIRE_NO, 0, NULL )

      END

    --�X�V����
    ELSE IF @MODE = 2
      BEGIN

         --�d��No.�Z�b�g
         SET @SHIIRE_NO = @REF_NO

        --�w�b�_�e�[�u���폜
        DELETE
          FROM T_SHIIRE_H
         WHERE T_SHIIRE_H.SHIIRE_NO = @SHIIRE_NO

        --�{�f�B�e�[�u���폜
        DELETE
          FROM T_SHIIRE_B
         WHERE T_SHIIRE_B.SHIIRE_NO = @SHIIRE_NO

        --�X�V(���[�N�e�[�u�����w�b�_�e�[�u��)
        INSERT INTO
               T_SHIIRE_H
               SELECT
                      @SHIIRE_NO
                     ,SHIIRE_DATE
                     ,SHIIRE_KAMOKU
                     ,DENKU
                     ,KOBAI_KBN
                     ,KANJO_KAMOKU
                     ,SHIIRE_NYURYOKUSHA_CD
                     ,SHIHARAI_DATE
                     ,SHIIRE_STS
                     ,SHIIRE_CD
                     ,TAX_RATE
                     ,NUKI_TOTAL
                     ,TAX
                     ,KOMI_TOTAL
                     ,SHOKAN_NO
                     ,SHOKAN_LINK_DATETIME
                     ,DEL_FLG
                     ,DBS_STATUS
                     ,DBS_CREATE_USER
                     ,DBS_CREATE_DATE
                     ,DBS_UPDATE_USER
                     ,DBS_UPDATE_DATE
                 FROM W_SHIIRE
                WHERE W_USER_ID = @USER_ID
                  AND W_SERIAL  = @SERIAL
                  AND W_PAGE    = 1
                  AND W_ROW     = 1


        --�X�V(���[�N�e�[�u�����{�f�B�e�[�u��)
        INSERT INTO
               T_SHIIRE_B
               SELECT
                      @SHIIRE_NO
                     ,GYO_NO
                     ,KOBAIHIN_CD
                     ,KOBAIHIN_MEI
                     ,TANKA
                     ,IRISU
                     ,IRISU_TANI
                     ,SURYO
                     ,BARA_TANI
                     ,SOSU
                     ,TOTAL
                     ,MAKER_CD
                     ,YOSAN_CD
                     ,JURI_NO
                     ,BIKO
                     ,KOBAI_NO
                     ,KOBAI_SEQ
                     ,DEL_FLG
                     ,DBS_STATUS
                     ,DBS_CREATE_USER
                     ,DBS_CREATE_DATE
                     ,DBS_UPDATE_USER
                     ,DBS_UPDATE_DATE
                 FROM W_SHIIRE
                WHERE W_USER_ID = @USER_ID
                  AND W_SERIAL  = @SERIAL
                  AND W_PAGE    = 1

        --�X�V�y�[�W�N���A
        DELETE
          FROM W_SHIIRE
         WHERE W_SHIIRE.W_USER_ID = @USER_ID
           AND W_SHIIRE.W_SERIAL  = @SERIAL
           AND W_SHIIRE.W_PAGE    = 1

        --�d�����z�w���f�[�^���f
        UPDATE T_KOBAI_B
           SET T_KOBAI_B.TANKA = T_SHIIRE_B.TANKA
              ,T_KOBAI_B.TOTAL = CONVERT(NUMERIC(11,2),T_SHIIRE_B.TANKA * T_KOBAI_B.SURYO)
          FROM T_SHIIRE_B
         INNER JOIN
               T_KOBAI_B
            ON T_KOBAI_B.KOBAI_NO  = T_SHIIRE_B.KOBAI_NO
           AND T_KOBAI_B.KOBAI_SEQ = T_SHIIRE_B.KOBAI_SEQ
         WHERE T_SHIIRE_B.SHIIRE_NO = @SHIIRE_NO

        --����I��
        INSERT INTO @TBL VALUES( @SHIIRE_NO, 0, NULL )

      END

    --�폜����
    ELSE IF @MODE = 3
      BEGIN

        --�d��No.�Z�b�g
        SET @SHIIRE_NO = @REF_NO

        --�X�V�����ݒ�
        SET @UPDATE_DATE = 'DT' + CONVERT(VARCHAR(24),GETDATE(),120)

        --�����f�[�^�폜(�w�b�_)�t���OTrue
        UPDATE T_SHIIRE_H
           SET T_SHIIRE_H.DEL_FLG = 'True'
              ,T_SHIIRE_H.DBS_CREATE_USER = @USER_ID
              ,T_SHIIRE_H.DBS_UPDATE_DATE = @UPDATE_DATE
          FROM T_SHIIRE_H
         WHERE T_SHIIRE_H.SHIIRE_NO = @SHIIRE_NO

        --�����f�[�^�폜(�{�f�B)�t���OTrue
        UPDATE T_SHIIRE_B
           SET T_SHIIRE_B.DEL_FLG = 'True'
              ,T_SHIIRE_B.DBS_UPDATE_USER = @USER_ID
              ,T_SHIIRE_B.DBS_UPDATE_DATE = @UPDATE_DATE
          FROM T_SHIIRE_B
         WHERE T_SHIIRE_B.SHIIRE_NO = @SHIIRE_NO

        --���[�N�e�[�u���N���A
        DELETE
          FROM W_SHIIRE
         WHERE W_SHIIRE.W_USER_ID = @USER_ID

        --����I��
        INSERT INTO @TBL VALUES( @SHIIRE_NO, 0, NULL )

      END

    --�w���\���f�[�^�ڑ�����
    ELSE IF @MODE = 4
      BEGIN

        --�x�����E�x������ݒ�(����25������)
        SET @SHIHARAI_MONTH = 1
        SET @SHIHARAI_DAY   = 25

        --���[�N�e�[�u���N���A
        DELETE
          FROM W_SHIIRE
         WHERE W_SHIIRE.W_USER_ID = @USER_ID

        SET @PAGE = 0

        --�J�[�\���I�[�v��
        OPEN SHIIRE_LOAD_CURSOR

        FETCH NEXT FROM SHIIRE_LOAD_CURSOR INTO @SHIIRE_CD ,@SHIIRE_DATE
        WHILE @@FETCH_STATUS = 0
        BEGIN

            SET @PAGE += 1

            --�Ǎ�(�w���ڑ��e�[�u�������[�N�e�[�u��)
            INSERT INTO
                   W_SHIIRE
            SELECT
                   V_SHIIRE_KOBAI_DATA.W_USER_ID
                  ,V_SHIIRE_KOBAI_DATA.W_SERIAL
                  ,@PAGE
                  ,V_SHIIRE_KOBAI_DATA.W_ROW
                  ,V_SHIIRE_KOBAI_DATA.W_MODE
                  ,NULL
                  ,V_SHIIRE_KOBAI_DATA.SHIIRE_DATE
                  ,0                                --SHIIRE_KAMOKU
                  ,0                                --DENKU
                  ,V_SHIIRE_KOBAI_DATA.KOBAI_KBN
                  ,NULL                             --KANJO_KAMOKU
                  ,@USER_ID
                  ,CASE
                     WHEN ISNULL(SHIHARAIHOHO_KBN,0) = 0 THEN
                          CONVERT(VARCHAR(10), GETDATE(),111)
                     WHEN SHIHARAIHOHO_KBN = 31 THEN
                          CASE
                            WHEN @SHIHARAI_DAY = 31 THEN
                                 EOMONTH(CONVERT(VARCHAR(10), DATEADD(MONTH ,@SHIHARAI_MONTH+1 ,CONCAT(YEAR(GETDATE()),'/',MONTH(GETDATE()),'/',1)),111),0)
                            ELSE
                                 CONVERT(VARCHAR(10), DATEADD(MONTH ,@SHIHARAI_MONTH+1 ,CONCAT(YEAR(GETDATE()),'/',MONTH(GETDATE()),'/',@SHIHARAI_DAY)),111)
                          END
                     ELSE
                          CASE
                            WHEN @SHIHARAI_DAY = 31 THEN
                               CASE
                                 WHEN DAY(GETDATE()) > SHIHARAIHOHO_KBN THEN
                                      EOMONTH(CONVERT(VARCHAR(10), DATEADD(MONTH ,@SHIHARAI_MONTH+1 ,CONCAT(YEAR(GETDATE()),'/',MONTH(GETDATE()),'/',1)),111),0)
                                 ELSE
                                      EOMONTH(CONVERT(VARCHAR(10), DATEADD(MONTH ,@SHIHARAI_MONTH ,CONCAT(YEAR(GETDATE()),'/',MONTH(GETDATE()),'/',1)),111),0)
                               END
                            ELSE
                               CASE
                                 WHEN DAY(GETDATE()) > SHIHARAIHOHO_KBN THEN
                                      CONVERT(VARCHAR(10), DATEADD(MONTH ,@SHIHARAI_MONTH+1 ,CONCAT(YEAR(GETDATE()),'/',MONTH(GETDATE()),'/',@SHIHARAI_DAY)),111)
                                 ELSE
                                      CONVERT(VARCHAR(10), DATEADD(MONTH ,@SHIHARAI_MONTH ,CONCAT(YEAR(GETDATE()),'/',MONTH(GETDATE()),'/',@SHIHARAI_DAY)),111)
                               END
                          END
                   END
--                   ,CASE
--                      WHEN ISNULL(SHIHARAIHOHO_KBN,0) = 0
--                           THEN CONVERT(VARCHAR(10), GETDATE(),111)
--                      WHEN SHIHARAIHOHO_KBN = 31
--                           THEN CONVERT(VARCHAR(10), DATEADD(MONTH ,@SHIHARAI_MONTH ,CONCAT(YEAR(GETDATE()),'/',MONTH(GETDATE()),'/',@SHIHARAI_DAY)),111)
--                      ELSE
--                           CASE
--                             WHEN DAY(GETDATE()) > SHIHARAIHOHO_KBN
--                                  THEN CONVERT(VARCHAR(10), DATEADD(MONTH ,@SHIHARAI_MONTH+1 ,CONCAT(YEAR(GETDATE()),'/',MONTH(GETDATE()),'/',@SHIHARAI_DAY)),111)
--                             ELSE
--                                  CONVERT(VARCHAR(10), DATEADD(MONTH ,@SHIHARAI_MONTH ,CONCAT(YEAR(GETDATE()),'/',MONTH(GETDATE()),'/',@SHIHARAI_DAY)),111)
--                           END
--                    END
                  ,V_SHIIRE_KOBAI_DATA.SHIIRE_STS
                  ,V_SHIIRE_KOBAI_DATA.SHIIRE_CD
                  ,V_SHIIRE_KOBAI_DATA.TAX_RATE
                  ,V_SHIIRE_KOBAI_DATA.NUKI_TOTAL
                  ,V_SHIIRE_KOBAI_DATA.TAX
                  ,V_SHIIRE_KOBAI_DATA.KOMI_TOTAL
                  ,V_SHIIRE_KOBAI_DATA.SHOKAN_NO
                  ,NULL

                  ,V_SHIIRE_KOBAI_DATA.GYO_NO
                  ,V_SHIIRE_KOBAI_DATA.KOBAIHIN_CD
                  ,V_SHIIRE_KOBAI_DATA.KOBAIHIN_MEI
                  ,V_SHIIRE_KOBAI_DATA.TANKA
                  ,V_SHIIRE_KOBAI_DATA.IRISU
                  ,V_SHIIRE_KOBAI_DATA.IRISU_TANI
                  ,V_SHIIRE_KOBAI_DATA.SURYO
                  ,V_SHIIRE_KOBAI_DATA.BARA_TANI
                  ,V_SHIIRE_KOBAI_DATA.SOSU
                  ,V_SHIIRE_KOBAI_DATA.TOTAL
                  ,V_SHIIRE_KOBAI_DATA.MAKER_CD
                  ,V_SHIIRE_KOBAI_DATA.YOSAN_CD
                  ,V_SHIIRE_KOBAI_DATA.JURI_NO
                  ,V_SHIIRE_KOBAI_DATA.BIKO
                  ,V_SHIIRE_KOBAI_DATA.KOBAI_NO
                  ,V_SHIIRE_KOBAI_DATA.KOBAI_SEQ
                  ,V_SHIIRE_KOBAI_DATA.DEL_FLG
                  ,V_SHIIRE_KOBAI_DATA.DBS_STATUS
                  ,V_SHIIRE_KOBAI_DATA.DBS_CREATE_USER
                  ,V_SHIIRE_KOBAI_DATA.DBS_CREATE_DATE
                  ,V_SHIIRE_KOBAI_DATA.DBS_UPDATE_USER
                  ,V_SHIIRE_KOBAI_DATA.DBS_UPDATE_DATE
              FROM V_SHIIRE_KOBAI_DATA
              LEFT JOIN
                   M_AITESAKI
                ON M_AITESAKI.AITE_CD = V_SHIIRE_KOBAI_DATA.SHIIRE_CD
             WHERE V_SHIIRE_KOBAI_DATA.W_USER_ID   = @USER_ID
               AND V_SHIIRE_KOBAI_DATA.W_SERIAL    = @SERIAL
               AND V_SHIIRE_KOBAI_DATA.SHIIRE_CD   = @SHIIRE_CD
               AND V_SHIIRE_KOBAI_DATA.SHIIRE_DATE = @SHIIRE_DATE

            FETCH NEXT FROM SHIIRE_LOAD_CURSOR INTO @SHIIRE_CD ,@SHIIRE_DATE

        END

        CLOSE SHIIRE_LOAD_CURSOR

        --����I��
        INSERT INTO @TBL VALUES( @SHIIRE_NO, 0, NULL )

        --�w���f�[�^�������[�N�e�[�u���N���A
        DELETE
          FROM W_SHIIRE_KOBAI
         WHERE W_SHIIRE_KOBAI.W_USER_ID = @USER_ID

      END


    --�w���f�[�^�ڑ��ꊇ�ۑ�����
    ELSE IF @MODE = 5
      BEGIN

        --�J�[�\���I�[�v��
        OPEN SHIIRE_SAVE_CURSOR

        FETCH NEXT FROM SHIIRE_SAVE_CURSOR INTO @PAGE
        WHILE @@FETCH_STATUS = 0
        BEGIN

            --�V�[�P���X�擾
            SET @SEQ = NEXT VALUE FOR SEQ_SHIIRE_NO

            --�d��No.����
            SET @SHIIRE_NO = ( SELECT CONCAT( 'S', RIGHT('00'+CAST(YEAR(GETDATE()) AS NVARCHAR) ,2) 
                                      ,'-' 
                                      ,RIGHT('00'+CAST(MONTH(GETDATE()) AS NVARCHAR) ,2)
                                      ,RIGHT('0000' + CAST(@SEQ AS NVARCHAR) ,4) ) )

            --�V�K�ۑ�(���[�N�e�[�u�����w�b�_�e�[�u��)
            INSERT INTO
                   T_SHIIRE_H
                   SELECT
                          @SHIIRE_NO
                         ,SHIIRE_DATE
                         ,SHIIRE_KAMOKU
                         ,DENKU
                         ,KOBAI_KBN
                         ,KANJO_KAMOKU
                         ,SHIIRE_NYURYOKUSHA_CD
                         ,SHIHARAI_DATE
                         ,SHIIRE_STS
                         ,SHIIRE_CD
                         ,TAX_RATE
                         ,NUKI_TOTAL
                         ,TAX
                         ,KOMI_TOTAL
                         ,SHOKAN_NO
                         ,SHOKAN_LINK_DATETIME
                         ,DEL_FLG
                         ,DBS_STATUS
                         ,DBS_CREATE_USER
                         ,DBS_CREATE_DATE
                         ,DBS_UPDATE_USER
                         ,DBS_UPDATE_DATE
                     FROM W_SHIIRE
                    WHERE W_USER_ID = @USER_ID
                      AND W_SERIAL  = @SERIAL
                      AND W_PAGE    = @PAGE
                      AND W_ROW     = 1

            --�V�K�ۑ�(���[�N�e�[�u�����{�f�B�e�[�u��)
            INSERT INTO
                   T_SHIIRE_B
                   SELECT
                          @SHIIRE_NO
                         ,GYO_NO
                         ,KOBAIHIN_CD
                         ,KOBAIHIN_MEI
                         ,TANKA
                         ,IRISU
                         ,IRISU_TANI
                         ,SURYO
                         ,BARA_TANI
                         ,SOSU
                         ,TOTAL
                         ,MAKER_CD
                         ,YOSAN_CD
                         ,JURI_NO
                         ,BIKO
                         ,KOBAI_NO
                         ,KOBAI_SEQ
                         ,DEL_FLG
                         ,DBS_STATUS
                         ,DBS_CREATE_USER
                         ,DBS_CREATE_DATE
                         ,DBS_UPDATE_USER
                         ,DBS_UPDATE_DATE
                     FROM W_SHIIRE
                    WHERE W_USER_ID = @USER_ID
                      AND W_SERIAL  = @SERIAL
                      AND W_PAGE    = @PAGE


            --�ԋp�p��No.�Z�b�g
            INSERT INTO @TBL VALUES( @SHIIRE_NO, 0, NULL )

            --���[�N�e�[�u���N���A
            DELETE
              FROM W_SHIIRE
             WHERE W_SHIIRE.W_USER_ID = @USER_ID
               AND W_SHIIRE.W_PAGE    = @PAGE

            --�d�����z�w���f�[�^���f
            UPDATE T_KOBAI_B
               SET T_KOBAI_B.TANKA = T_SHIIRE_B.TANKA
                  ,T_KOBAI_B.TOTAL = CONVERT(NUMERIC(11,2),T_SHIIRE_B.TANKA * T_KOBAI_B.SURYO)
              FROM T_SHIIRE_B
             INNER JOIN
                   T_KOBAI_B
                ON T_KOBAI_B.KOBAI_NO  = T_SHIIRE_B.KOBAI_NO
               AND T_KOBAI_B.KOBAI_SEQ = T_SHIIRE_B.KOBAI_SEQ
             WHERE T_SHIIRE_B.SHIIRE_NO = @SHIIRE_NO


            FETCH NEXT FROM SHIIRE_SAVE_CURSOR INTO @PAGE

          END

        CLOSE SHIIRE_SAVE_CURSOR

        --�A�ԍăZ�b�g
        UPDATE
               W_SHIIRE
           SET W_PAGE   = J_ROW_NUM.PAGE_NUM
          FROM W_SHIIRE,
               ( SELECT W_SHIIRE.SHIIRE_NO                     AS R_SHIIRE_NO
                       ,ROW_NUMBER() OVER (ORDER BY SHIIRE_NO) AS PAGE_NUM
                   FROM W_SHIIRE
                  GROUP BY SHIIRE_NO )
               AS J_ROW_NUM
         WHERE W_SHIIRE.W_USER_ID    = @USER_ID
           AND W_SHIIRE.W_SERIAL     = @SERIAL
           AND J_ROW_NUM.R_SHIIRE_NO = W_SHIIRE.SHIIRE_NO

      END

    --�Q�ƍ쐬����
    ELSE IF @MODE = 6
      BEGIN

         --�d��No.�Z�b�g
         SET @SHIIRE_NO = @REF_NO

        --�x�����E�x������ݒ�(����25������)
        SET @SHIHARAI_MONTH = 1
        SET @SHIHARAI_DAY   = 25

        --�X�V�����ݒ�
        SET @UPDATE_DATE = 'DT' + CONVERT(VARCHAR(24),GETDATE(),120)

        --���[�N�e�[�u���N���A
        DELETE
          FROM W_SHIIRE
         WHERE W_SHIIRE.W_USER_ID = @USER_ID

        --�Ǎ�(�e�[�u�������[�N�e�[�u��)
        INSERT INTO
               W_SHIIRE
        SELECT
               @USER_ID
              ,@SERIAL
              ,1
              ,T_SHIIRE_B.GYO_NO
              ,0
              ,NULL
              ,CONVERT(VARCHAR(10), GETDATE(),111)
              ,T_SHIIRE_H.SHIIRE_KAMOKU
              ,T_SHIIRE_H.DENKU
              ,T_SHIIRE_H.KOBAI_KBN
              ,T_SHIIRE_H.KANJO_KAMOKU
              ,@USER_ID
              ,CASE
                 WHEN ISNULL(J_SHIIRE.SHIHARAIHOHO_KBN,0) = 0 THEN
                      CONVERT(VARCHAR(10), GETDATE(),111)
                 WHEN J_SHIIRE.SHIHARAIHOHO_KBN = 31 THEN
                      CASE
                        WHEN @SHIHARAI_DAY = 31 THEN
                             EOMONTH(CONVERT(VARCHAR(10), DATEADD(MONTH ,@SHIHARAI_MONTH+1 ,CONCAT(YEAR(GETDATE()),'/',MONTH(GETDATE()),'/',1)),111),0)
                        ELSE
                             CONVERT(VARCHAR(10), DATEADD(MONTH ,@SHIHARAI_MONTH+1 ,CONCAT(YEAR(GETDATE()),'/',MONTH(GETDATE()),'/',@SHIHARAI_DAY)),111)
                      END
                 ELSE
                      CASE
                        WHEN @SHIHARAI_DAY = 31 THEN
                           CASE
                             WHEN DAY(GETDATE()) > J_SHIIRE.SHIHARAIHOHO_KBN THEN
                                  EOMONTH(CONVERT(VARCHAR(10), DATEADD(MONTH ,@SHIHARAI_MONTH+1 ,CONCAT(YEAR(GETDATE()),'/',MONTH(GETDATE()),'/',1)),111),0)
                             ELSE
                                  EOMONTH(CONVERT(VARCHAR(10), DATEADD(MONTH ,@SHIHARAI_MONTH ,CONCAT(YEAR(GETDATE()),'/',MONTH(GETDATE()),'/',1)),111),0)
                           END
                        ELSE
                           CASE
                             WHEN DAY(GETDATE()) > J_SHIIRE.SHIHARAIHOHO_KBN THEN
                                  CONVERT(VARCHAR(10), DATEADD(MONTH ,@SHIHARAI_MONTH+1 ,CONCAT(YEAR(GETDATE()),'/',MONTH(GETDATE()),'/',@SHIHARAI_DAY)),111)
                             ELSE
                                  CONVERT(VARCHAR(10), DATEADD(MONTH ,@SHIHARAI_MONTH ,CONCAT(YEAR(GETDATE()),'/',MONTH(GETDATE()),'/',@SHIHARAI_DAY)),111)
                           END
                      END
               END
              ,1
              ,J_SHIIRE.AITE_CD
              ,( SELECT CASE
                        WHEN M_CONTROL.TAX_1_DATE > M_CONTROL.TAX_2_DATE THEN
                             CASE
                             WHEN M_CONTROL.TAX_1_DATE > CONVERT(VARCHAR(10), GETDATE(),111) THEN
                                  M_CONTROL.TAX_2
                             ELSE
                                  M_CONTROL.TAX_1
                             END
                        ELSE
                             CASE
                             WHEN M_CONTROL.TAX_2_DATE > CONVERT(VARCHAR(10), GETDATE(),111) THEN
                                  M_CONTROL.TAX_1
                             ELSE
                                  M_CONTROL.TAX_2
                             END
                        END
                   FROM M_CONTROL
                  WHERE M_CONTROL.CTRL_KEY = 1 )
              ,T_SHIIRE_H.NUKI_TOTAL
              ,T_SHIIRE_H.TAX
              ,T_SHIIRE_H.KOMI_TOTAL
              ,NULL
              ,NULL
              ,T_SHIIRE_B.GYO_NO
              ,J_KOBAIHIN.SHOHIN_CD
              ,T_SHIIRE_B.KOBAIHIN_MEI
              ,T_SHIIRE_B.TANKA
              ,T_SHIIRE_B.IRISU
              ,T_SHIIRE_B.IRISU_TANI
              ,T_SHIIRE_B.SURYO
              ,T_SHIIRE_B.BARA_TANI
              ,T_SHIIRE_B.SOSU
              ,T_SHIIRE_B.TOTAL
              ,J_MAKER.AITE_CD
              ,T_SHIIRE_B.YOSAN_CD
              ,T_SHIIRE_B.JURI_NO
              ,T_SHIIRE_B.BIKO
              ,NULL                     --T_SHIIRE_B.KOBAI_NO
              ,NULL                     --T_SHIIRE_B.KOBAI_SEQ
              ,T_SHIIRE_H.DEL_FLG
              ,1
              ,T_SHIIRE_H.DBS_CREATE_USER
              ,T_SHIIRE_H.DBS_CREATE_DATE
              ,T_SHIIRE_H.DBS_UPDATE_USER
              ,T_SHIIRE_H.DBS_UPDATE_DATE
          FROM T_SHIIRE_H
          LEFT JOIN
               T_SHIIRE_B
            ON T_SHIIRE_B.SHIIRE_NO   =  T_SHIIRE_H.SHIIRE_NO
          LEFT JOIN
               M_AITESAKI             AS J_SHIIRE
            ON J_SHIIRE.AITE_CD       =  T_SHIIRE_H.SHIIRE_CD
           AND J_SHIIRE.MISHIYO_FLG   =  'False'
          LEFT JOIN
               M_AITESAKI             AS J_MAKER
            ON J_MAKER.AITE_CD        =  T_SHIIRE_B.MAKER_CD
           AND J_MAKER.MISHIYO_FLG    =  'False'
          LEFT JOIN
               M_SHOHIN               AS J_KOBAIHIN
            ON J_KOBAIHIN.SHOHIN_CD   =  T_SHIIRE_B.KOBAIHIN_CD
           AND J_KOBAIHIN.MISHIYO_FLG = 'False'
         WHERE T_SHIIRE_H.SHIIRE_NO   =  @SHIIRE_NO

        --����I��
        INSERT INTO @TBL VALUES( @SHIIRE_NO, 0, NULL )

      END


    --���[�N�e�[�u���N���A
    ELSE
      BEGIN

        --���[�N�e�[�u���N���A
        DELETE
          FROM W_SHIIRE
         WHERE W_SHIIRE.W_USER_ID = @USER_ID

      END

    --�������ʕԋp
    SELECT RESULT_SHIIRE_NO, RESULT_CD, RESULT_MESSAGE FROM @TBL

    DEALLOCATE SHIIRE_SAVE_CURSOR
    DEALLOCATE SHIIRE_LOAD_CURSOR

END TRY


-- ��O����
BEGIN CATCH

    -- �g�����U�N�V���������[���o�b�N�i�L�����Z���j
    ROLLBACK TRANSACTION SAVE1

    --���[�N�e�[�u���N���A
    DELETE
      FROM W_SHIIRE
     WHERE W_SHIIRE.W_USER_ID = @USER_ID

    --�ُ�I��
    INSERT INTO @TBL VALUES( 0, ERROR_NUMBER(), ERROR_MESSAGE() )

    --�������ʕԋp
    SELECT RESULT_SHIIRE_NO, RESULT_CD, RESULT_MESSAGE FROM @TBL

    DEALLOCATE SHIIRE_SAVE_CURSOR
    DEALLOCATE SHIIRE_LOAD_CURSOR

END CATCH

END

