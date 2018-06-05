
--DROP PROCEDURE SP_SAVE_T_URIAGE

CREATE PROCEDURE SP_SAVE_T_URIAGE
       @USER_ID  NVARCHAR(64)
      ,@SERIAL   NVARCHAR(50)
      ,@MODE     INT
      ,@PAGE     INT            --�y�[�WNo./����No.
      ,@REF_NO   NVARCHAR(10)   --�Q��No.
      ,@REF_NO2  NVARCHAR(10)   --�Q��No.2

AS
--�ۑ��������s
--[���[�h] 0:�Ǎ� / 1:�V�K�ۑ� / 2:�X�V / 3:�폜 / 4:�󒍃f�[�^�����ڑ� / 5:�󒍐ڑ��ꊇ�ۑ� /
--         6:�Q�ƍ쐬 / 7:�����f�[�^�擾 / 8:�`�[���s�ϐݒ� / 9:���㌋�� / 10:���㌋������ /
--         11:�Q�ƍ쐬����(����) / 12:����No.�ݒ菈�� /
--         99(ELSE):���[�N�e�[�u���N���A

BEGIN

    --�߂�l�p�e�[�u���ϐ�
    DECLARE @TBL TABLE (
      RESULT_URIAGE_NO NVARCHAR(10)
     ,RESULT_CD INT NOT NULL
     ,RESULT_MESSAGE NVARCHAR(max)
    )

    --�V�[�P���X
    DECLARE @SEQ AS INT

    --�Ώ۔���No.
    DECLARE @URIAGE_NO AS NVARCHAR(10)

    --�Ώێ�No.
    DECLARE @JURI_NO AS NVARCHAR(10)

    --�Ώی���No.
    DECLARE @MITSU_NO AS NVARCHAR(10)

    --�Ώێ󒍋敪
    DECLARE @JUCHU_KBN AS NVARCHAR(10)

    --�`�[�敪
    DECLARE @DEMPYO_KBN AS NVARCHAR(10)

    --�X�e�[�^�X
    DECLARE @STS_CD AS NVARCHAR(9)

    --�X�V���[�U�[�E�X�V����
    DECLARE @UPDATE_DATE AS NVARCHAR(50)
    DECLARE @CREATE_DATE AS NVARCHAR(50)

    --����ŗ�
    DECLARE @TAX_RATE AS NUMERIC(4,3)

    --������v�Z�p
    DECLARE @SEIKYU_CD AS NVARCHAR(10)
    DECLARE @KAISHU_DATE AS NVARCHAR(10)
    DECLARE @KAISHU_MONTH AS INT
    DECLARE @KAISHU_DAY AS INT
    DECLARE @SEIKYUHOHO_KBN AS NVARCHAR(9)

    --�J�[�\������
    --����ꊇ�Ǎ��p�J�[�\��
    DECLARE URIAGE_LOAD_CURSOR CURSOR
        FOR SELECT DISTINCT
                   V_URIAGE_JUCHU_DATA.JURI_NO
              FROM V_URIAGE_JUCHU_DATA
             WHERE V_URIAGE_JUCHU_DATA.W_USER_ID = @USER_ID
             ORDER BY
                   JURI_NO ASC

    --����ꊇ�ۑ��p�J�[�\��
    DECLARE URIAGE_SAVE_CURSOR CURSOR
        FOR SELECT W_URIAGE.W_PAGE
              FROM W_URIAGE
             WHERE W_URIAGE.W_USER_ID = @USER_ID
               AND W_URIAGE.W_ROW     = 1
               AND ISNULL(W_URIAGE.DENKU,'')        <> ''
               AND ISNULL(W_URIAGE.KANJO_KAMOKU,'') <> ''
               AND ISNULL(W_URIAGE.KAISHU_DATE,'')  <> ''
               AND ISNULL(W_URIAGE.SEIKYU_CD,'')    <> ''
               AND W_URIAGE.NOHIN_DATE              <> ''

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
          FROM W_URIAGE
         WHERE W_URIAGE.W_USER_ID = @USER_ID

        DELETE
          FROM W_URIAGE_JUCHU_SELECT
         WHERE W_URIAGE_JUCHU_SELECT.W_USER_ID = @USER_ID

        --�Ǎ�(�e�[�u�������[�N�e�[�u��)
        INSERT INTO
               W_URIAGE
        SELECT
               @USER_ID
              ,@SERIAL
              ,1
              ,T_URIAGE_B.GYO_NO
              ,0
              ,T_URIAGE_H.URIAGE_NO
              ,T_URIAGE_H.DEMPYO_KBN
              ,T_URIAGE_H.RENDO_KBN
              ,T_URIAGE_H.DENKU
              ,T_URIAGE_H.KANJO_KAMOKU
              ,T_URIAGE_H.URIAGE_DATE
              ,T_URIAGE_H.BUSHO_CD
              ,T_URIAGE_H.URIAGE_NYURYOKUSHA_CD
              ,T_URIAGE_H.EIGYO_TANTO_CD
              ,T_URIAGE_H.NYURYOKU_DATE_TIME
              ,T_URIAGE_H.JUCHU_KBN
              ,T_URIAGE_H.JURI_NO
              ,T_URIAGE_H.MITSU_NO
              ,T_URIAGE_H.SAKI_URIAGE_NO
              ,T_URIAGE_H.NOHIN_DATE
              ,T_URIAGE_H.URIAGE_STS
              ,T_URIAGE_H.DOJI_FLG
              ,T_URIAGE_H.SEIKYU_CD
              ,T_URIAGE_H.KAISHU_DATE
              ,T_URIAGE_H.BUNSEKI_HOHO_CD
              ,T_URIAGE_H.TEKIYO
              ,T_URIAGE_H.DEMPYO_SOFU_MEI
              ,T_URIAGE_H.KEISHO
              ,T_URIAGE_H.YUBIN_NO
              ,T_URIAGE_H.ADDRESS_1
              ,T_URIAGE_H.ADDRESS_2
              ,T_URIAGE_H.TEL
              ,T_URIAGE_H.FAX
              ,T_URIAGE_H.SOFU_TANTO
              ,T_URIAGE_H.TEISEI_BIKO
              ,T_URIAGE_H.JUSHO_NO_PRINT_FLG
              ,T_URIAGE_H.TAX_RATE
              ,T_URIAGE_H.NUKI_TOTAL
              ,T_URIAGE_H.TAX
              ,T_URIAGE_H.KOMI_TOTAL
              ,T_URIAGE_H.GENKA_TOTAL
              ,T_URIAGE_H.ARARIEKI
              ,T_URIAGE_H.ARARIRITSU
              ,T_URIAGE_H.SHOKON_NO
              ,T_URIAGE_H.SHOKON_LIST_DATE_TIME
              ,T_URIAGE_B.GYO_NO
              ,T_URIAGE_B.ROW_KBN
              ,T_URIAGE_B.SHOHIN_CD
              ,T_URIAGE_B.SHOHIN_MEI
              ,T_URIAGE_B.URIAGE_SURYO
              ,T_URIAGE_B.URIAGE_SURYO_TANI
              ,T_URIAGE_B.HAMBAI_TANKA
              ,T_URIAGE_B.HAMBAI_KINGAKU
              ,T_URIAGE_B.TEKIYO
              ,T_URIAGE_B.GENTANKA
              ,T_URIAGE_B.GENKA_SURYO
              ,T_URIAGE_B.IRISU_TANI
              ,T_URIAGE_B.SOSU
              ,T_URIAGE_B.BARA_TANI
              ,T_URIAGE_B.GENKA_KINGAKU
              ,T_URIAGE_B.ARARIRITSU
              ,T_URIAGE_B.ARARIEKI
              ,T_URIAGE_B.TEIKA
              ,T_URIAGE_H.DEL_FLG
              ,1
              ,@USER_ID
              ,@UPDATE_DATE
              ,@USER_ID
              ,@UPDATE_DATE
          FROM T_URIAGE_H
          LEFT JOIN
               T_URIAGE_B
            ON T_URIAGE_B.URIAGE_NO = T_URIAGE_H.URIAGE_NO
         WHERE T_URIAGE_H.URIAGE_NO = @REF_NO

        INSERT INTO
               W_URIAGE_JUCHU_SELECT
        SELECT
               @USER_ID
              ,@SERIAL
              ,ROW_NUMBER() OVER (ORDER BY SEQ ASC)
              ,1
              ,JUCHU_KBN
              ,JURI_NO
              ,1
              ,@USER_ID
              ,@UPDATE_DATE
              ,@USER_ID
              ,@UPDATE_DATE
          FROM T_URIAGE_JUCHU_SELECT
         WHERE T_URIAGE_JUCHU_SELECT.URIAGE_NO = @REF_NO

      END

    --�V�K�o�^����(�Ώۃy�[�W�ۑ�)
    ELSE IF @MODE = 1
      BEGIN

        --�V�[�P���X�擾
        SET @SEQ = NEXT VALUE FOR SEQ_URIAGE_NO

        --����No.����
        SET @URIAGE_NO = ( SELECT CONCAT( 'U', RIGHT('00'+CAST(YEAR(GETDATE()) AS NVARCHAR) ,2) 
                                  ,'-' 
                                  ,RIGHT('00'+CAST(MONTH(GETDATE()) AS NVARCHAR) ,2)
                                  ,RIGHT('0000' + CAST(@SEQ AS NVARCHAR) ,4) ) )

        --�V�K�ۑ�(���[�N�e�[�u�����w�b�_�e�[�u��)
        INSERT INTO
               T_URIAGE_H
               SELECT
                      @URIAGE_NO
                     ,DEMPYO_KBN
                     ,RENDO_KBN
                     ,DENKU
                     ,KANJO_KAMOKU
                     ,URIAGE_DATE
                     ,BUSHO_CD
                     ,URIAGE_NYURYOKUSHA_CD
                     ,EIGYO_TANTO_CD
                     ,NYURYOKU_DATE_TIME
                     ,JUCHU_KBN
                     ,JURI_NO
                     ,MITSU_NO
                     ,SAKI_URIAGE_NO
                     ,NOHIN_DATE
                     ,URIAGE_STS
                     ,DOJI_FLG
                     ,SEIKYU_CD
                     ,KAISHU_DATE
                     ,BUNSEKI_HOHO_CD
                     ,TEKIYO_H
                     ,DEMPYO_SOFU_MEI
                     ,KEISHO
                     ,YUBIN_NO
                     ,ADDRESS_1
                     ,ADDRESS_2
                     ,TEL
                     ,FAX
                     ,SOFU_TANTO
                     ,TEISEI_BIKO
                     ,JUSHO_NO_PRINT_FLG
                     ,TAX_RATE
                     ,NUKI_TOTAL
                     ,TAX
                     ,KOMI_TOTAL
                     ,GENKA_TOTAL
                     ,ARARIEKI_H
                     ,ARARIRITSU_H
                     ,SHOKON_NO
                     ,SHOKON_LIST_DATE_TIME
                     ,DEL_FLG
                     ,DBS_STATUS
                     ,DBS_CREATE_USER
                     ,DBS_CREATE_DATE
                     ,DBS_UPDATE_USER
                     ,DBS_UPDATE_DATE
                 FROM W_URIAGE
                WHERE W_USER_ID = @USER_ID
                  AND W_SERIAL  = @SERIAL
                  AND W_PAGE    = @PAGE
                  AND W_ROW     = 1

        --�V�K�ۑ�(���[�N�e�[�u�����{�f�B�e�[�u��)
        INSERT INTO
               T_URIAGE_B
               SELECT
                      @URIAGE_NO
                     ,GYO_NO
                     ,ROW_KBN
                     ,SHOHIN_CD
                     ,SHOHIN_MEI
                     ,URIAGE_SURYO
                     ,URIAGE_SURYO_TANI
                     ,HAMBAI_TANKA
                     ,HAMBAI_KINGAKU
                     ,TEKIYO_B
                     ,GENTANKA
                     ,GENKA_SURYO
                     ,IRISU_TANI
                     ,SOSU
                     ,BARA_TANI
                     ,GENKA_KINGAKU
                     ,ARARIRITSU_B
                     ,ARARIEKI_B
                     ,TEIKA
                     ,DEL_FLG
                     ,DBS_STATUS
                     ,DBS_CREATE_USER
                     ,DBS_CREATE_DATE
                     ,DBS_UPDATE_USER
                     ,DBS_UPDATE_DATE
                 FROM W_URIAGE
                WHERE W_USER_ID = @USER_ID
                  AND W_SERIAL  = @SERIAL
                  AND W_PAGE    = @PAGE

        --�X�V�y�[�W�N���A
        DELETE
          FROM W_URIAGE
         WHERE W_URIAGE.W_USER_ID = @USER_ID
           AND W_URIAGE.W_SERIAL  = @SERIAL
           AND W_URIAGE.W_PAGE    = @PAGE

        --�X�V�y�[�W�ȍ~�̃y�[�W�f�N�������g
        UPDATE W_URIAGE
           SET W_URIAGE.W_PAGE = W_URIAGE.W_PAGE - 1
         WHERE W_URIAGE.W_USER_ID = @USER_ID
           AND W_URIAGE.W_SERIAL  = @SERIAL
           AND W_URIAGE.W_PAGE    > @PAGE

        --�X�V�����ݒ�
        SET @UPDATE_DATE = 'DT' + CONVERT(VARCHAR(24),GETDATE(),120)

        --���㌋���e�[�u�����f
        INSERT INTO
               T_URIAGE_MERGE
        SELECT @URIAGE_NO
              ,ROW_NUMBER() OVER (ORDER BY URIAGE_NO)
              ,URIAGE_NO
              ,1
              ,@USER_ID
              ,@UPDATE_DATE
              ,@USER_ID
              ,@UPDATE_DATE
          FROM W_URIAGE_MERGE
         WHERE W_USER_ID = @USER_ID
           AND W_SERIAL  = @SERIAL
         GROUP BY
               URIAGE_NO

        --���㌋�����[�N�e�[�u���N���A
        DELETE
          FROM W_URIAGE_MERGE
         WHERE W_URIAGE_MERGE.W_USER_ID = @USER_ID
           AND W_URIAGE_MERGE.W_SERIAL  = @SERIAL

        --�����攄��No./�A���s�v�Z�b�g
        UPDATE T_URIAGE_H
           SET T_URIAGE_H.SAKI_URIAGE_NO = @URIAGE_NO
              ,T_URIAGE_H.RENDO_KBN      = 1
         WHERE EXISTS(
               SELECT T_URIAGE_MERGE.MOTO_URIAGE_NO 
                 FROM T_URIAGE_MERGE
                WHERE T_URIAGE_MERGE.URIAGE_NO      = @URIAGE_NO
                  AND T_URIAGE_MERGE.MOTO_URIAGE_NO = T_URIAGE_H.URIAGE_NO
                      )

        --�󒍑I���e�[�u�����f
        INSERT INTO
               T_URIAGE_JUCHU_SELECT
        SELECT @URIAGE_NO                              --URIAGE_NO
              ,ROW_NUMBER() OVER (ORDER BY JURI_NO)    --SEQ
              ,JUCHU_KBN                               --JUCHU_KBN
              ,JURI_NO                                 --JURI_NO
              ,1
              ,@USER_ID
              ,@UPDATE_DATE
              ,@USER_ID
              ,@UPDATE_DATE
          FROM W_URIAGE_JUCHU_SELECT
         WHERE W_USER_ID = @USER_ID
           AND W_SERIAL  = @SERIAL

        --�󒍑I�����[�N�e�[�u���N���A
        DELETE
          FROM W_URIAGE_JUCHU_SELECT
         WHERE W_URIAGE_JUCHU_SELECT.W_USER_ID = @USER_ID
           AND W_URIAGE_JUCHU_SELECT.W_SERIAL  = @SERIAL

        --�`�[�敪�Z�b�g
        SET @STS_CD = ( SELECT URIAGE_STS
                          FROM T_URIAGE_H
                         WHERE T_URIAGE_H.URIAGE_NO = @URIAGE_NO )

        --�`�[���s�ς̏ꍇ�A�󒍍X�V
        IF @STS_CD >= 2
          BEGIN

            UPDATE T_BUN_JUCHU_H
               SET T_BUN_JUCHU_H.DEMPYO_HAKKO_KBN     =  '3'
              FROM T_BUN_JUCHU_H
             INNER JOIN
                   T_URIAGE_JUCHU_SELECT
                ON T_URIAGE_JUCHU_SELECT.JURI_NO      =  T_BUN_JUCHU_H.JURI_NO
             WHERE T_URIAGE_JUCHU_SELECT.URIAGE_NO    =  @URIAGE_NO

            UPDATE T_HAN_JUCHU_H
               SET T_HAN_JUCHU_H.DEMPYO_HAKKO_KBN     =  '3'
              FROM T_HAN_JUCHU_H
             INNER JOIN
                   T_URIAGE_JUCHU_SELECT
                ON T_URIAGE_JUCHU_SELECT.JURI_NO      =  T_HAN_JUCHU_H.JURI_NO
             WHERE T_URIAGE_JUCHU_SELECT.URIAGE_NO    =  @URIAGE_NO

          END

        --����I��
        INSERT INTO @TBL VALUES( @URIAGE_NO, 0, NULL )

      END

    --�X�V����
    ELSE IF @MODE = 2
      BEGIN

         --����No.�Z�b�g
         SET @URIAGE_NO = @REF_NO
--          SET @URIAGE_NO = ( SELECT W_URIAGE.URIAGE_NO
--                               FROM W_URIAGE
--                              WHERE W_URIAGE.W_USER_ID   = @USER_ID
--                                AND W_URIAGE.W_SERIAL    = @SERIAL
--                                AND W_URIAGE.W_PAGE      = 1
--                                AND W_URIAGE.W_ROW       = 1 )

        --�����e�[�u���ۑ�(�w�b�_)
        --�����w�b�_�e�[�u���֑ޔ�
        INSERT INTO
               T_URIAGE_H_R
               SELECT URIAGE_NO
                      --����No.�擾
                     ,( SELECT CASE
                                    WHEN WK_TBL.RIREKI_NO_MAX IS NULL THEN 1
                                    ELSE WK_TBL.RIREKI_NO_MAX + 1
                               END
                          FROM (
                               SELECT MAX(T_URIAGE_H_R.RIREKI_NO) AS RIREKI_NO_MAX
                                 FROM T_URIAGE_H_R
                                WHERE T_URIAGE_H_R.URIAGE_NO = @REF_NO
                               ) AS WK_TBL
                      )
                      --�����敪����
                     ,( SELECT CASE
                                      WHEN COUNT(*) = 0 THEN '�V�K�o�^'
                                      ELSE CASE
                                                  WHEN ( SELECT T_URIAGE_H.DEL_FLG
                                                           FROM T_URIAGE_H
                                                          WHERE T_URIAGE_H.URIAGE_NO = @REF_NO ) = 'True'
                                                  THEN '�폜'
                                           ELSE '�C��'
                                           END
                               END
                          FROM T_URIAGE_H_R
                         WHERE T_URIAGE_H_R.URIAGE_NO = @REF_NO
                      )
                     ,DEMPYO_KBN
                     ,RENDO_KBN
                     ,DENKU
                     ,KANJO_KAMOKU
                     ,URIAGE_DATE
                     ,BUSHO_CD
                     ,URIAGE_NYURYOKUSHA_CD
                     ,EIGYO_TANTO_CD
                     ,NYURYOKU_DATE_TIME
                     ,JUCHU_KBN
                     ,JURI_NO
                     ,MITSU_NO
                     ,SAKI_URIAGE_NO
                     ,NOHIN_DATE
                     ,URIAGE_STS
                     ,DOJI_FLG
                     ,SEIKYU_CD
                     ,KAISHU_DATE
                     ,BUNSEKI_HOHO_CD
                     ,TEKIYO
                     ,DEMPYO_SOFU_MEI
                     ,KEISHO
                     ,YUBIN_NO
                     ,ADDRESS_1
                     ,ADDRESS_2
                     ,TEL
                     ,FAX
                     ,SOFU_TANTO
                     ,TEISEI_BIKO
                     ,JUSHO_NO_PRINT_FLG
                     ,TAX_RATE
                     ,NUKI_TOTAL
                     ,TAX
                     ,KOMI_TOTAL
                     ,GENKA_TOTAL
                     ,ARARIEKI
                     ,ARARIRITSU
                     ,SHOKON_NO
                     ,SHOKON_LIST_DATE_TIME
                     ,DEL_FLG
                     ,DBS_STATUS
                     ,DBS_CREATE_USER
                     ,DBS_CREATE_DATE
                     ,DBS_UPDATE_USER
                     ,DBS_UPDATE_DATE
                 FROM T_URIAGE_H
                WHERE T_URIAGE_H.URIAGE_NO = @REF_NO

        --�����e�[�u���ۑ�(�{�f�B)
        INSERT INTO
               T_URIAGE_B_R
               SELECT URIAGE_NO
                     ,GYO_NO
                     --����No.�擾(�w�b�_�Ɠ�������No.)
                     ,( SELECT CASE
                                    WHEN WK_TBL.RIREKI_NO_MAX IS NULL THEN 1
                                    ELSE WK_TBL.RIREKI_NO_MAX
                               END
                          FROM (
                               SELECT MAX(T_URIAGE_H_R.RIREKI_NO) AS RIREKI_NO_MAX
                                 FROM T_URIAGE_H_R
                                WHERE T_URIAGE_H_R.URIAGE_NO = @REF_NO
                               ) AS WK_TBL
                      )
                     ,ROW_KBN
                     ,SHOHIN_CD
                     ,SHOHIN_MEI
                     ,URIAGE_SURYO
                     ,URIAGE_SURYO_TANI
                     ,HAMBAI_TANKA
                     ,HAMBAI_KINGAKU
                     ,TEKIYO
                     ,GENTANKA
                     ,GENKA_SURYO
                     ,IRISU_TANI
                     ,SOSU
                     ,BARA_TANI
                     ,GENKA_KINGAKU
                     ,ARARIRITSU
                     ,ARARIEKI
                     ,TEIKA
                     ,DEL_FLG
                     ,DBS_STATUS
                     ,DBS_CREATE_USER
                     ,DBS_CREATE_DATE
                     ,DBS_UPDATE_USER
                     ,DBS_UPDATE_DATE
                 FROM T_URIAGE_B
                WHERE T_URIAGE_B.URIAGE_NO = @REF_NO

        --�w�b�_�e�[�u���폜
        DELETE
          FROM T_URIAGE_H
         WHERE T_URIAGE_H.URIAGE_NO = @URIAGE_NO

        --�{�f�B�e�[�u���폜
        DELETE
          FROM T_URIAGE_B
         WHERE T_URIAGE_B.URIAGE_NO = @URIAGE_NO

        --�󒍑I���e�[�u���폜
        DELETE
          FROM T_URIAGE_JUCHU_SELECT
         WHERE T_URIAGE_JUCHU_SELECT.URIAGE_NO = @URIAGE_NO

        --�ۑ�(���[�N�e�[�u�����w�b�_�e�[�u��)
        INSERT INTO
               T_URIAGE_H
               SELECT
                      URIAGE_NO
                     ,DEMPYO_KBN
                     ,RENDO_KBN
                     ,DENKU
                     ,KANJO_KAMOKU
                     ,URIAGE_DATE
                     ,BUSHO_CD
                     ,URIAGE_NYURYOKUSHA_CD
                     ,EIGYO_TANTO_CD
                     ,NYURYOKU_DATE_TIME
                     ,JUCHU_KBN
                     ,JURI_NO
                     ,MITSU_NO
                     ,SAKI_URIAGE_NO
                     ,NOHIN_DATE
                     ,URIAGE_STS
                     ,DOJI_FLG
                     ,SEIKYU_CD
                     ,KAISHU_DATE
                     ,BUNSEKI_HOHO_CD
                     ,TEKIYO_H
                     ,DEMPYO_SOFU_MEI
                     ,KEISHO
                     ,YUBIN_NO
                     ,ADDRESS_1
                     ,ADDRESS_2
                     ,TEL
                     ,FAX
                     ,SOFU_TANTO
                     ,TEISEI_BIKO
                     ,JUSHO_NO_PRINT_FLG
                     ,TAX_RATE
                     ,NUKI_TOTAL
                     ,TAX
                     ,KOMI_TOTAL
                     ,GENKA_TOTAL
                     ,ARARIEKI_H
                     ,ARARIRITSU_H
                     ,SHOKON_NO
                     ,SHOKON_LIST_DATE_TIME
                     ,DEL_FLG
                     ,DBS_STATUS
                     ,DBS_CREATE_USER
                     ,DBS_CREATE_DATE
                     ,DBS_UPDATE_USER
                     ,DBS_UPDATE_DATE
                 FROM W_URIAGE
                WHERE W_USER_ID = @USER_ID
                  AND W_SERIAL  = @SERIAL
                  AND W_PAGE    = 1
                  AND W_ROW     = 1

        --�ۑ�(���[�N�e�[�u�����{�f�B�e�[�u��)
        INSERT INTO
               T_URIAGE_B
               SELECT
                      URIAGE_NO
                     ,GYO_NO
                     ,ROW_KBN
                     ,SHOHIN_CD
                     ,SHOHIN_MEI
                     ,URIAGE_SURYO
                     ,URIAGE_SURYO_TANI
                     ,HAMBAI_TANKA
                     ,HAMBAI_KINGAKU
                     ,TEKIYO_B
                     ,GENTANKA
                     ,GENKA_SURYO
                     ,IRISU_TANI
                     ,SOSU
                     ,BARA_TANI
                     ,GENKA_KINGAKU
                     ,ARARIRITSU_B
                     ,ARARIEKI_B
                     ,TEIKA
                     ,DEL_FLG
                     ,DBS_STATUS
                     ,DBS_CREATE_USER
                     ,DBS_CREATE_DATE
                     ,DBS_UPDATE_USER
                     ,DBS_UPDATE_DATE
                 FROM W_URIAGE
                WHERE W_USER_ID = @USER_ID
                  AND W_SERIAL  = @SERIAL
                  AND W_PAGE    = 1

        --�ۑ�(���[�N�e�[�u�����󒍑I���e�[�u��)
        INSERT INTO
               T_URIAGE_JUCHU_SELECT
        SELECT @URIAGE_NO                              --URIAGE_NO
              ,ROW_NUMBER() OVER (ORDER BY JURI_NO)    --SEQ
              ,JUCHU_KBN                               --JUCHU_KBN
              ,JURI_NO                                 --JURI_NO
              ,1
              ,@USER_ID
              ,DBS_CREATE_DATE
              ,@USER_ID
              ,DBS_UPDATE_DATE
          FROM W_URIAGE_JUCHU_SELECT
         WHERE W_USER_ID = @USER_ID
           AND W_SERIAL  = @SERIAL

        --���[�N�e�[�u���N���A
        DELETE
          FROM W_URIAGE
         WHERE W_USER_ID = @USER_ID
           AND W_SERIAL  = @SERIAL
           AND W_PAGE    = 1

        --�󒍑I�����[�N�e�[�u���N���A
        DELETE
          FROM W_URIAGE_JUCHU_SELECT
         WHERE W_URIAGE_JUCHU_SELECT.W_USER_ID = @USER_ID
           AND W_URIAGE_JUCHU_SELECT.W_SERIAL  = @SERIAL

        --�`�[�敪�Z�b�g
        SET @STS_CD = ( SELECT URIAGE_STS
                          FROM T_URIAGE_H
                         WHERE T_URIAGE_H.URIAGE_NO = @URIAGE_NO )

        --�`�[���s�ς̏ꍇ�A�󒍍X�V
        IF @STS_CD >= 2
          BEGIN

            UPDATE T_BUN_JUCHU_H
               SET T_BUN_JUCHU_H.DEMPYO_HAKKO_KBN     =  '3'
              FROM T_BUN_JUCHU_H
             INNER JOIN
                   T_URIAGE_JUCHU_SELECT
                ON T_URIAGE_JUCHU_SELECT.JURI_NO      =  T_BUN_JUCHU_H.JURI_NO
             WHERE T_URIAGE_JUCHU_SELECT.URIAGE_NO    =  @URIAGE_NO

            UPDATE T_HAN_JUCHU_H
               SET T_HAN_JUCHU_H.DEMPYO_HAKKO_KBN     =  '3'
              FROM T_HAN_JUCHU_H
             INNER JOIN
                   T_URIAGE_JUCHU_SELECT
                ON T_URIAGE_JUCHU_SELECT.JURI_NO      =  T_HAN_JUCHU_H.JURI_NO
             WHERE T_URIAGE_JUCHU_SELECT.URIAGE_NO    =  @URIAGE_NO

          END

        --����I��
        INSERT INTO @TBL VALUES( @URIAGE_NO, 0, NULL )

      END

    --�폜����
    ELSE IF @MODE = 3
      BEGIN

        --�X�V�����ݒ�
        SET @UPDATE_DATE = 'DT' + CONVERT(VARCHAR(24),GETDATE(),120)

        --�����f�[�^�폜(�w�b�_)�t���OTrue
        UPDATE T_URIAGE_H
           SET T_URIAGE_H.DEL_FLG = 'True'
              ,T_URIAGE_H.DBS_CREATE_USER = @USER_ID
              ,T_URIAGE_H.DBS_UPDATE_DATE = @UPDATE_DATE
          FROM T_URIAGE_H
         WHERE T_URIAGE_H.URIAGE_NO = @REF_NO

        --�����f�[�^�폜(�{�f�B)�t���OTrue
        UPDATE T_URIAGE_B
           SET T_URIAGE_B.DEL_FLG = 'True'
              ,T_URIAGE_B.DBS_UPDATE_USER = @USER_ID
              ,T_URIAGE_B.DBS_UPDATE_DATE = @UPDATE_DATE
          FROM T_URIAGE_B
         WHERE T_URIAGE_B.URIAGE_NO = @REF_NO

        --���[�N�e�[�u���N���A
        DELETE
          FROM W_URIAGE
         WHERE W_URIAGE.W_USER_ID = @USER_ID

        --����I��
        INSERT INTO @TBL VALUES( @URIAGE_NO, 0, NULL )

      END

    --�󒍃f�[�^�ڑ�����
    ELSE IF @MODE = 4
      BEGIN

        --���[�N�e�[�u���N���A
        DELETE
          FROM W_URIAGE
         WHERE W_URIAGE.W_USER_ID = @USER_ID

        DELETE
          FROM W_URIAGE_JUCHU_SELECT
         WHERE W_URIAGE_JUCHU_SELECT.W_USER_ID = @USER_ID

        SET @PAGE = 0

        --�J�[�\���I�[�v��
        OPEN URIAGE_LOAD_CURSOR

        FETCH NEXT FROM URIAGE_LOAD_CURSOR INTO @JURI_NO
        WHILE @@FETCH_STATUS = 0
        BEGIN

--             --������v�Z
--             SELECT @KAISHU_MONTH   = M_AITESAKI.KAISHU_MONTH
--                   ,@KAISHU_DAY     = M_AITESAKI.KAISHU_DAY
--                   ,@SEIKYUHOHO_KBN = M_AITESAKI.SEIKYUHOHO_KBN
--               FROM M_AITESAKI
--              WHERE AITE_CD = @SEIKYU_CD
-- 
--             --��������
--             IF ISNULL(@SEIKYUHOHO_KBN,0) = 0
--               BEGIN
--                 --NULL�܂��͓s�x�����̏ꍇ
--                 SET @KAISHU_DATE = CONVERT(VARCHAR(10), GETDATE(),111)
--               END
--             ELSE IF @SEIKYUHOHO_KBN = 31
--               BEGIN
--                 --�������߂̏ꍇ
--                 --����+�����
--                 SET @KAISHU_DATE = CONVERT(VARCHAR(10), DATEADD(MONTH ,@KAISHU_MONTH+1 ,CONCAT(YEAR(GETDATE()),'/',MONTH(GETDATE()),'/',@KAISHU_DAY)),111)
--               END
--             ELSE
--               BEGIN
--                 IF DAY(GETDATE()) > @SEIKYUHOHO_KBN
--                   BEGIN
--                     --�������߂��Ă���ꍇ
--                     --����+�����
--                     SET @KAISHU_DATE = CONVERT(VARCHAR(10), DATEADD(MONTH ,@KAISHU_MONTH+1 ,CONCAT(YEAR(GETDATE()),'/',MONTH(GETDATE()),'/',@KAISHU_DAY)),111)
--                   END
--                 ELSE
--                   BEGIN
--                     --�����O�̏ꍇ
--                     --����+�����
--                     SET @KAISHU_DATE = CONVERT(VARCHAR(10), DATEADD(MONTH ,@KAISHU_MONTH ,CONCAT(YEAR(GETDATE()),'/',MONTH(GETDATE()),'/',@KAISHU_DAY)),111)
--                   END
--               END

            SET @PAGE += 1

            --�Ǎ�(�󒍐ڑ��e�[�u�������[�N�e�[�u��)
            INSERT INTO
                   W_URIAGE
            SELECT
                   V_URIAGE_JUCHU_DATA.W_USER_ID
                  ,V_URIAGE_JUCHU_DATA.W_SERIAL
                  ,@PAGE
                  ,V_URIAGE_JUCHU_DATA.W_ROW
                  ,V_URIAGE_JUCHU_DATA.W_MODE
                  ,V_URIAGE_JUCHU_DATA.URIAGE_NO
                  ,V_URIAGE_JUCHU_DATA.DEMPYO_KBN
                  ,V_URIAGE_JUCHU_DATA.RENDO_KBN
                  ,V_URIAGE_JUCHU_DATA.DENKU
                  ,V_URIAGE_JUCHU_DATA.KANJO_KAMOKU
                  ,V_URIAGE_JUCHU_DATA.URIAGE_DATE
                  ,V_URIAGE_JUCHU_DATA.BUSHO_CD
                  ,V_URIAGE_JUCHU_DATA.URIAGE_NYURYOKUSHA_CD
                  ,V_URIAGE_JUCHU_DATA.EIGYO_TANTO_CD
                  ,NULL
                  ,V_URIAGE_JUCHU_DATA.JUCHU_KBN
                  ,V_URIAGE_JUCHU_DATA.JURI_NO
                  ,V_URIAGE_JUCHU_DATA.MITSU_NO
                  ,V_URIAGE_JUCHU_DATA.SAKI_URIAGE_NO
                  ,V_URIAGE_JUCHU_DATA.NOHIN_DATE
                  ,V_URIAGE_JUCHU_DATA.URIAGE_STS
                  ,V_URIAGE_JUCHU_DATA.DOJI_FLG
                  ,V_URIAGE_JUCHU_DATA.SEIKYU_CD
                  ,CASE
                     WHEN ISNULL(SEIKYUHOHO_KBN,0) = 0 THEN
                          CONVERT(VARCHAR(10), GETDATE(),111)
                     WHEN SEIKYUHOHO_KBN = 31 THEN
                          CASE
                            WHEN KAISHU_DAY = 31 THEN
                                 EOMONTH(CONVERT(VARCHAR(10), DATEADD(MONTH ,KAISHU_MONTH+1 ,CONCAT(YEAR(URIAGE_DATE),'/',MONTH(URIAGE_DATE),'/',1)),111),0)
                            ELSE
                                 CONVERT(VARCHAR(10), DATEADD(MONTH ,KAISHU_MONTH+1 ,CONCAT(YEAR(URIAGE_DATE),'/',MONTH(URIAGE_DATE),'/',KAISHU_DAY)),111)
                          END
                     ELSE
                          CASE
                            WHEN KAISHU_DAY = 31 THEN
                               CASE
                                 WHEN DAY(GETDATE()) > SEIKYUHOHO_KBN THEN
                                      EOMONTH(CONVERT(VARCHAR(10), DATEADD(MONTH ,KAISHU_MONTH+1 ,CONCAT(YEAR(URIAGE_DATE),'/',MONTH(URIAGE_DATE),'/',1)),111),0)
                                 ELSE
                                      EOMONTH(CONVERT(VARCHAR(10), DATEADD(MONTH ,KAISHU_MONTH ,CONCAT(YEAR(URIAGE_DATE),'/',MONTH(URIAGE_DATE),'/',1)),111),0)
                               END
                            ELSE
                               CASE
                                 WHEN DAY(GETDATE()) > SEIKYUHOHO_KBN THEN
                                      CONVERT(VARCHAR(10), DATEADD(MONTH ,KAISHU_MONTH+1 ,CONCAT(YEAR(URIAGE_DATE),'/',MONTH(URIAGE_DATE),'/',KAISHU_DAY)),111)
                                 ELSE
                                      CONVERT(VARCHAR(10), DATEADD(MONTH ,KAISHU_MONTH ,CONCAT(YEAR(URIAGE_DATE),'/',MONTH(URIAGE_DATE),'/',KAISHU_DAY)),111)
                               END
                          END
                   END
                  ,V_URIAGE_JUCHU_DATA.BUNSEKI_HOHO_CD
                  ,V_URIAGE_JUCHU_DATA.TEKIYO_H
                  ,V_URIAGE_JUCHU_DATA.DEMPYO_SOFU_MEI
                  ,V_URIAGE_JUCHU_DATA.KEISHO
                  ,V_URIAGE_JUCHU_DATA.YUBIN_NO
                  ,V_URIAGE_JUCHU_DATA.ADDRESS_1
                  ,V_URIAGE_JUCHU_DATA.ADDRESS_2
                  ,V_URIAGE_JUCHU_DATA.TEL
                  ,V_URIAGE_JUCHU_DATA.FAX
                  ,V_URIAGE_JUCHU_DATA.SOFU_TANTO
                  ,V_URIAGE_JUCHU_DATA.TEISEI_BIKO
                  ,V_URIAGE_JUCHU_DATA.JUSHO_NO_PRINT_FLG
                  ,( SELECT CASE
                            WHEN M_CONTROL.TAX_1_DATE > M_CONTROL.TAX_2_DATE THEN
                                 CASE
                                 WHEN M_CONTROL.TAX_1_DATE > V_URIAGE_JUCHU_DATA.NOHIN_DATE THEN
                                      M_CONTROL.TAX_2
                                 ELSE
                                      M_CONTROL.TAX_1
                                 END
                            ELSE
                                 CASE
                                 WHEN M_CONTROL.TAX_2_DATE > V_URIAGE_JUCHU_DATA.NOHIN_DATE THEN
                                      M_CONTROL.TAX_1
                                 ELSE
                                      M_CONTROL.TAX_2
                                 END
                            END
                       FROM M_CONTROL
                      WHERE M_CONTROL.CTRL_KEY = 1 )
                  ,V_URIAGE_JUCHU_DATA.NUKI_TOTAL
                  ,V_URIAGE_JUCHU_DATA.TAX
                  ,V_URIAGE_JUCHU_DATA.KOMI_TOTAL
                  ,V_URIAGE_JUCHU_DATA.GENKA_TOTAL
                  ,V_URIAGE_JUCHU_DATA.ARARIEKI_H
                  ,V_URIAGE_JUCHU_DATA.ARARIRITSU_H
                  ,V_URIAGE_JUCHU_DATA.SHOKON_NO
                  ,NULL
                  ,V_URIAGE_JUCHU_DATA.GYO_NO
                  ,V_URIAGE_JUCHU_DATA.ROW_KBN
                  ,V_URIAGE_JUCHU_DATA.SHOHIN_CD
                  ,V_URIAGE_JUCHU_DATA.SHOHIN_MEI
                  ,V_URIAGE_JUCHU_DATA.URIAGE_SURYO
                  ,V_URIAGE_JUCHU_DATA.URIAGE_SURYO_TANI
                  ,V_URIAGE_JUCHU_DATA.HAMBAI_TANKA
                  ,V_URIAGE_JUCHU_DATA.HAMBAI_KINGAKU
                  ,V_URIAGE_JUCHU_DATA.TEKIYO_B
                  ,V_URIAGE_JUCHU_DATA.GENTANKA
                  ,V_URIAGE_JUCHU_DATA.GENKA_SURYO
                  ,V_URIAGE_JUCHU_DATA.IRISU_TANI
                  ,V_URIAGE_JUCHU_DATA.SOSU
                  ,V_URIAGE_JUCHU_DATA.BARA_TANI
                  ,V_URIAGE_JUCHU_DATA.GENKA_KINGAKU
                  ,V_URIAGE_JUCHU_DATA.ARARIRITSU_B
                  ,V_URIAGE_JUCHU_DATA.ARARIEKI_B
                  ,V_URIAGE_JUCHU_DATA.TEIKA
                  ,V_URIAGE_JUCHU_DATA.DEL_FLG
                  ,V_URIAGE_JUCHU_DATA.DBS_STATUS
                  ,V_URIAGE_JUCHU_DATA.DBS_CREATE_USER
                  ,V_URIAGE_JUCHU_DATA.DBS_CREATE_DATE
                  ,V_URIAGE_JUCHU_DATA.DBS_UPDATE_USER
                  ,V_URIAGE_JUCHU_DATA.DBS_UPDATE_DATE
              FROM V_URIAGE_JUCHU_DATA
              LEFT JOIN
                   M_AITESAKI
                ON M_AITESAKI.AITE_CD = V_URIAGE_JUCHU_DATA.SEIKYU_CD
             WHERE V_URIAGE_JUCHU_DATA.W_USER_ID = @USER_ID
               AND V_URIAGE_JUCHU_DATA.W_SERIAL  = @SERIAL
               AND V_URIAGE_JUCHU_DATA.JURI_NO   = @JURI_NO


            FETCH NEXT FROM URIAGE_LOAD_CURSOR INTO @JURI_NO

        END

        CLOSE URIAGE_LOAD_CURSOR

        --����I��
        INSERT INTO @TBL VALUES( @URIAGE_NO, 0, NULL )

        --�󒍃f�[�^�������[�N�e�[�u���N���A
        DELETE
          FROM W_URIAGE_JUCHU
         WHERE W_URIAGE_JUCHU.W_USER_ID = @USER_ID

      END


    --�󒍃f�[�^�ڑ��ꊇ�ۑ�����
    ELSE IF @MODE = 5
      BEGIN

        --���͓����擾
        SET @UPDATE_DATE = CONVERT(VARCHAR(10), GETDATE(),111) + ' ' + CONVERT(VARCHAR(8), GETDATE(),114)

        --�J�[�\���I�[�v��
        OPEN URIAGE_SAVE_CURSOR

        FETCH NEXT FROM URIAGE_SAVE_CURSOR INTO @PAGE
        WHILE @@FETCH_STATUS = 0
        BEGIN

            --�V�[�P���X�擾
            SET @SEQ = NEXT VALUE FOR SEQ_URIAGE_NO

            --����No.����
            SET @URIAGE_NO = ( SELECT CONCAT( 'U', RIGHT('00'+CAST(YEAR(GETDATE()) AS NVARCHAR) ,2) 
                                      ,'-' 
                                      ,RIGHT('00'+CAST(MONTH(GETDATE()) AS NVARCHAR) ,2)
                                      ,RIGHT('0000' + CAST(@SEQ AS NVARCHAR) ,4) ) )

            --�V�K�ۑ�(���[�N�e�[�u�����w�b�_�e�[�u��)
            INSERT INTO
                   T_URIAGE_H
                   SELECT
                          @URIAGE_NO
                         ,DEMPYO_KBN
                         ,RENDO_KBN
                         ,DENKU
                         ,KANJO_KAMOKU
                         ,URIAGE_DATE
                         ,BUSHO_CD
                         ,URIAGE_NYURYOKUSHA_CD
                         ,EIGYO_TANTO_CD
                         ,@UPDATE_DATE
                         ,JUCHU_KBN
                         ,JURI_NO
                         ,MITSU_NO
                         ,SAKI_URIAGE_NO
                         ,NOHIN_DATE
                         ,URIAGE_STS
                         ,DOJI_FLG
                         ,SEIKYU_CD
                         ,KAISHU_DATE
                         ,BUNSEKI_HOHO_CD
                         ,TEKIYO_H
                         ,DEMPYO_SOFU_MEI
                         ,KEISHO
                         ,YUBIN_NO
                         ,ADDRESS_1
                         ,ADDRESS_2
                         ,TEL
                         ,FAX
                         ,SOFU_TANTO
                         ,TEISEI_BIKO
                         ,JUSHO_NO_PRINT_FLG
                         ,TAX_RATE
                         ,NUKI_TOTAL
                         ,TAX
                         ,KOMI_TOTAL
                         ,GENKA_TOTAL
                         ,ARARIEKI_H
                         ,ARARIRITSU_H
                         ,SHOKON_NO
                         ,SHOKON_LIST_DATE_TIME
                         ,DEL_FLG
                         ,DBS_STATUS
                         ,DBS_CREATE_USER
                         ,DBS_CREATE_DATE
                         ,DBS_UPDATE_USER
                         ,DBS_UPDATE_DATE
                     FROM W_URIAGE
                    WHERE W_USER_ID = @USER_ID
                      AND W_SERIAL  = @SERIAL
                      AND W_PAGE    = @PAGE
                      AND W_ROW     = 1

            --�V�K�ۑ�(���[�N�e�[�u�����{�f�B�e�[�u��)
            INSERT INTO
                   T_URIAGE_B
                   SELECT
                          @URIAGE_NO
                         ,GYO_NO
                         ,ROW_KBN
                         ,SHOHIN_CD
                         ,SHOHIN_MEI
                         ,URIAGE_SURYO
                         ,URIAGE_SURYO_TANI
                         ,HAMBAI_TANKA
                         ,HAMBAI_KINGAKU
                         ,TEKIYO_B
                         ,GENTANKA
                         ,GENKA_SURYO
                         ,IRISU_TANI
                         ,SOSU
                         ,BARA_TANI
                         ,GENKA_KINGAKU
                         ,ARARIRITSU_B
                         ,ARARIEKI_B
                         ,TEIKA
                         ,DEL_FLG
                         ,DBS_STATUS
                         ,DBS_CREATE_USER
                         ,DBS_CREATE_DATE
                         ,DBS_UPDATE_USER
                         ,DBS_UPDATE_DATE
                     FROM W_URIAGE
                    WHERE W_USER_ID = @USER_ID
                      AND W_SERIAL  = @SERIAL
                      AND W_PAGE    = @PAGE

            --�ԋp�p��No.�Z�b�g
            INSERT INTO @TBL VALUES( @URIAGE_NO, 0, NULL )

            --���[�N�e�[�u���N���A
            DELETE
              FROM W_URIAGE
             WHERE W_URIAGE.W_USER_ID = @USER_ID
               AND W_URIAGE.W_PAGE    = @PAGE

            FETCH NEXT FROM URIAGE_SAVE_CURSOR INTO @PAGE

          END

        CLOSE URIAGE_SAVE_CURSOR

        --�A�ԍăZ�b�g
        UPDATE
               W_URIAGE
           SET W_PAGE = J_ROW_NUM.PAGE_NUM
          FROM W_URIAGE,
               ( SELECT W_URIAGE.JURI_NO                     AS R_JURI_NO
                       ,ROW_NUMBER() OVER (ORDER BY JURI_NO) AS PAGE_NUM
                   FROM W_URIAGE
                   GROUP BY JURI_NO )
               AS J_ROW_NUM
         WHERE W_URIAGE.W_USER_ID  = @USER_ID
           AND W_URIAGE.W_SERIAL   = @SERIAL
           AND J_ROW_NUM.R_JURI_NO = W_URIAGE.JURI_NO

      END

    --�Q�ƍ쐬����
    ELSE IF @MODE = 6
      BEGIN

        --�X�V�����ݒ�
        SET @UPDATE_DATE = 'DT' + CONVERT(VARCHAR(24),GETDATE(),120)

        --���[�N�e�[�u���N���A
        DELETE
          FROM W_URIAGE
         WHERE W_URIAGE.W_USER_ID = @USER_ID

        DELETE
          FROM W_URIAGE_JUCHU_SELECT
         WHERE W_URIAGE_JUCHU_SELECT.W_USER_ID = @USER_ID

        --�Ǎ�(�e�[�u�������[�N�e�[�u��)
        INSERT INTO
               W_URIAGE
        SELECT
               @USER_ID
              ,@SERIAL
              ,1
              ,T_URIAGE_B.GYO_NO
              ,0
              ,NULL
              --�����`�[�͒ʏ�`�[�ɕύX����
              ,CASE
                 WHEN ISNULL(T_URIAGE_H.DEMPYO_KBN,0) = 5 THEN
                      1
                 ELSE
                      T_URIAGE_H.DEMPYO_KBN
                 END
              ,2
              ,T_URIAGE_H.DENKU
              ,T_URIAGE_H.KANJO_KAMOKU
              ,CONVERT(VARCHAR(24),GETDATE(),111)
              ,T_URIAGE_H.BUSHO_CD
              ,@USER_ID
              ,M_AITESAKI.EIGYO_TANTO_CD
              ,NULL
              ,T_URIAGE_H.JUCHU_KBN
              ,NULL                         --T_URIAGE_H.JURI_NO
              ,T_URIAGE_H.MITSU_NO
              ,NULL
              ,NULL
              ,1
              ,T_URIAGE_H.DOJI_FLG
              ,M_AITESAKI.AITE_CD
              ,CASE
                 WHEN ISNULL(SEIKYUHOHO_KBN,0) = 0 THEN
                      CONVERT(VARCHAR(10), GETDATE(),111)
                 WHEN SEIKYUHOHO_KBN = 31 THEN
                      CASE
                        WHEN KAISHU_DAY = 31 THEN
                             EOMONTH(CONVERT(VARCHAR(10), DATEADD(MONTH ,KAISHU_MONTH+1 ,CONCAT(YEAR(GETDATE()),'/',MONTH(GETDATE()),'/',1)),111),0)
                        ELSE
                             CONVERT(VARCHAR(10), DATEADD(MONTH ,KAISHU_MONTH+1 ,CONCAT(YEAR(GETDATE()),'/',MONTH(GETDATE()),'/',KAISHU_DAY)),111)
                      END
                 ELSE
                      CASE
                        WHEN KAISHU_DAY = 31 THEN
                           CASE
                             WHEN DAY(GETDATE()) > SEIKYUHOHO_KBN THEN
                                  EOMONTH(CONVERT(VARCHAR(10), DATEADD(MONTH ,KAISHU_MONTH+1 ,CONCAT(YEAR(GETDATE()),'/',MONTH(GETDATE()),'/',1)),111),0)
                             ELSE
                                  EOMONTH(CONVERT(VARCHAR(10), DATEADD(MONTH ,KAISHU_MONTH ,CONCAT(YEAR(GETDATE()),'/',MONTH(GETDATE()),'/',1)),111),0)
                           END
                        ELSE
                           CASE
                             WHEN DAY(GETDATE()) > SEIKYUHOHO_KBN THEN
                                  CONVERT(VARCHAR(10), DATEADD(MONTH ,KAISHU_MONTH+1 ,CONCAT(YEAR(GETDATE()),'/',MONTH(GETDATE()),'/',KAISHU_DAY)),111)
                             ELSE
                                  CONVERT(VARCHAR(10), DATEADD(MONTH ,KAISHU_MONTH ,CONCAT(YEAR(GETDATE()),'/',MONTH(GETDATE()),'/',KAISHU_DAY)),111)
                           END
                      END
               END
              ,T_URIAGE_H.BUNSEKI_HOHO_CD
              ,T_URIAGE_H.TEKIYO
              ,M_AITESAKI.AITE_MEI
              ,T_URIAGE_H.KEISHO
              ,M_AITESAKI.YUBIN_NO
              ,M_AITESAKI.ADDRESS_1
              ,M_AITESAKI.ADDRESS_2
              ,M_AITESAKI.TEL
              ,M_AITESAKI.FAX
--               ,T_URIAGE_H.DEMPYO_SOFU_MEI
--               ,T_URIAGE_H.KEISHO
--               ,T_URIAGE_H.YUBIN_NO
--               ,T_URIAGE_H.ADDRESS_1
--               ,T_URIAGE_H.ADDRESS_2
--               ,T_URIAGE_H.TEL
--               ,T_URIAGE_H.FAX
              ,T_URIAGE_H.SOFU_TANTO
              ,T_URIAGE_H.TEISEI_BIKO
              ,T_URIAGE_H.JUSHO_NO_PRINT_FLG
              ,( SELECT CASE
                        WHEN M_CONTROL.TAX_1_DATE > M_CONTROL.TAX_2_DATE THEN
                             CASE
                             WHEN M_CONTROL.TAX_1_DATE > NOHIN_DATE THEN
                                  M_CONTROL.TAX_2
                             ELSE
                                  M_CONTROL.TAX_1
                             END
                        ELSE
                             CASE
                             WHEN M_CONTROL.TAX_2_DATE > NOHIN_DATE THEN
                                  M_CONTROL.TAX_1
                             ELSE
                                  M_CONTROL.TAX_2
                             END
                        END
                   FROM M_CONTROL
                  WHERE M_CONTROL.CTRL_KEY = 1 )
              ,T_URIAGE_H.NUKI_TOTAL
              ,T_URIAGE_H.TAX
              ,T_URIAGE_H.KOMI_TOTAL
              ,T_URIAGE_H.GENKA_TOTAL
              ,T_URIAGE_H.ARARIEKI
              ,T_URIAGE_H.ARARIRITSU
              ,NULL
              ,NULL
              ,T_URIAGE_B.GYO_NO
              ,T_URIAGE_B.ROW_KBN
              ,CASE WHEN T_URIAGE_B.ROW_KBN = 1
                    THEN M_SHOHIN.SHOHIN_CD
                    ELSE T_URIAGE_B.SHOHIN_CD
               END
              ,T_URIAGE_B.SHOHIN_MEI
              ,T_URIAGE_B.URIAGE_SURYO
              ,T_URIAGE_B.URIAGE_SURYO_TANI
              ,T_URIAGE_B.HAMBAI_TANKA
              ,T_URIAGE_B.HAMBAI_KINGAKU
              ,T_URIAGE_B.TEKIYO
              ,T_URIAGE_B.GENTANKA
              ,T_URIAGE_B.GENKA_SURYO
              ,T_URIAGE_B.IRISU_TANI
              ,T_URIAGE_B.SOSU
              ,T_URIAGE_B.BARA_TANI
              ,T_URIAGE_B.GENKA_KINGAKU
              ,T_URIAGE_B.ARARIRITSU
              ,T_URIAGE_B.ARARIEKI
              ,T_URIAGE_B.TEIKA
              ,T_URIAGE_H.DEL_FLG
              ,1
              ,@USER_ID
              ,@UPDATE_DATE
              ,@USER_ID
              ,@UPDATE_DATE
          FROM T_URIAGE_H
          LEFT JOIN
               T_URIAGE_B
            ON T_URIAGE_B.URIAGE_NO   =  T_URIAGE_H.URIAGE_NO
          LEFT JOIN
               M_AITESAKI
            ON M_AITESAKI.AITE_CD     =  T_URIAGE_H.SEIKYU_CD
           AND M_AITESAKI.MISHIYO_FLG =  'False'
          LEFT JOIN
               M_SHOHIN
            ON M_SHOHIN.SHOHIN_CD     =  T_URIAGE_B.SHOHIN_CD
           AND M_SHOHIN.MISHIYO_FLG   =  'False'
         WHERE T_URIAGE_H.URIAGE_NO   =  @REF_NO

        --����I��
        INSERT INTO @TBL VALUES( @URIAGE_NO, 0, NULL )

      END


    --�����f�[�^�擾����
    ELSE IF @MODE = 7
      BEGIN

        --�X�V�����ݒ�
        SET @UPDATE_DATE = 'DT' + CONVERT(VARCHAR(24),GETDATE(),120)

        --���[�N�e�[�u���N���A
        DELETE
          FROM W_URIAGE
         WHERE W_URIAGE.W_USER_ID = @USER_ID

        --�Ǎ�(�e�[�u�������[�N�e�[�u��)
        INSERT INTO
               W_URIAGE
        SELECT
               @USER_ID
              ,@SERIAL
              ,1
              ,T_URIAGE_B_R.GYO_NO
              ,0
              ,T_URIAGE_H_R.URIAGE_NO
              ,T_URIAGE_H_R.DEMPYO_KBN
              ,T_URIAGE_H_R.RENDO_KBN
              ,T_URIAGE_H_R.DENKU
              ,T_URIAGE_H_R.KANJO_KAMOKU
              ,T_URIAGE_H_R.URIAGE_DATE
              ,T_URIAGE_H_R.BUSHO_CD
              ,T_URIAGE_H_R.URIAGE_NYURYOKUSHA_CD
              ,T_URIAGE_H_R.EIGYO_TANTO_CD
              ,T_URIAGE_H_R.NYURYOKU_DATE_TIME
              ,T_URIAGE_H_R.JUCHU_KBN
              ,T_URIAGE_H_R.JURI_NO
              ,T_URIAGE_H_R.MITSU_NO
              ,T_URIAGE_H_R.SAKI_URIAGE_NO
              ,T_URIAGE_H_R.NOHIN_DATE
              ,T_URIAGE_H_R.URIAGE_STS
              ,T_URIAGE_H_R.DOJI_FLG
              ,T_URIAGE_H_R.SEIKYU_CD
              ,T_URIAGE_H_R.KAISHU_DATE
              ,T_URIAGE_H_R.BUNSEKI_HOHO_CD
              ,T_URIAGE_H_R.TEKIYO
              ,T_URIAGE_H_R.DEMPYO_SOFU_MEI
              ,T_URIAGE_H_R.KEISHO
              ,T_URIAGE_H_R.YUBIN_NO
              ,T_URIAGE_H_R.ADDRESS_1
              ,T_URIAGE_H_R.ADDRESS_2
              ,T_URIAGE_H_R.TEL
              ,T_URIAGE_H_R.FAX
              ,T_URIAGE_H_R.SOFU_TANTO
              ,T_URIAGE_H_R.TEISEI_BIKO
              ,T_URIAGE_H_R.JUSHO_NO_PRINT_FLG
              ,T_URIAGE_H_R.TAX_RATE
              ,T_URIAGE_H_R.NUKI_TOTAL
              ,T_URIAGE_H_R.TAX
              ,T_URIAGE_H_R.KOMI_TOTAL
              ,T_URIAGE_H_R.GENKA_TOTAL
              ,T_URIAGE_H_R.ARARIEKI
              ,T_URIAGE_H_R.ARARIRITSU
              ,T_URIAGE_H_R.SHOKON_NO
              ,T_URIAGE_H_R.SHOKON_LIST_DATE_TIME
              ,T_URIAGE_B_R.GYO_NO
              ,T_URIAGE_B_R.ROW_KBN
              ,T_URIAGE_B_R.SHOHIN_CD
              ,T_URIAGE_B_R.SHOHIN_MEI
              ,T_URIAGE_B_R.URIAGE_SURYO
              ,T_URIAGE_B_R.URIAGE_SURYO_TANI
              ,T_URIAGE_B_R.HAMBAI_TANKA
              ,T_URIAGE_B_R.HAMBAI_KINGAKU
              ,T_URIAGE_B_R.TEKIYO
              ,T_URIAGE_B_R.GENTANKA
              ,T_URIAGE_B_R.GENKA_SURYO
              ,T_URIAGE_B_R.IRISU_TANI
              ,T_URIAGE_B_R.SOSU
              ,T_URIAGE_B_R.BARA_TANI
              ,T_URIAGE_B_R.GENKA_KINGAKU
              ,T_URIAGE_B_R.ARARIRITSU
              ,T_URIAGE_B_R.ARARIEKI
              ,T_URIAGE_B_R.TEIKA
              ,T_URIAGE_H_R.DEL_FLG
              ,1
              ,@USER_ID
              ,@UPDATE_DATE
              ,@USER_ID
              ,@UPDATE_DATE
          FROM T_URIAGE_H_R
          LEFT JOIN
               T_URIAGE_B_R
            ON T_URIAGE_B_R.URIAGE_NO = T_URIAGE_H_R.URIAGE_NO
           AND T_URIAGE_B_R.RIREKI_NO = T_URIAGE_H_R.RIREKI_NO
         WHERE T_URIAGE_H_R.URIAGE_NO = @REF_NO
           AND T_URIAGE_H_R.RIREKI_NO = @PAGE

        --����I��
        INSERT INTO @TBL VALUES( @URIAGE_NO, 0, NULL )

      END


    --�`�[���s�ϐݒ菈��
    ELSE IF @MODE = 8
      BEGIN

        --��No./�󒍋敪�擾
        SELECT @JURI_NO    = JURI_NO
              ,@JUCHU_KBN  = JUCHU_KBN
              ,@DEMPYO_KBN = DEMPYO_KBN
          FROM T_URIAGE_H
         WHERE URIAGE_NO = @REF_NO

        --�Ώێ󒍂̃X�e�[�^�X��`�[���s�ςɕύX
        IF ISNULL(@JURI_NO,'') <> ''
          BEGIN
            --���͂̏ꍇ
            IF @JUCHU_KBN = 1
              BEGIN
                UPDATE T_BUN_JUCHU_H
                   SET T_BUN_JUCHU_H.DEMPYO_HAKKO_KBN = '3'
                  FROM T_BUN_JUCHU_H
                 WHERE T_BUN_JUCHU_H.JURI_NO = @JURI_NO
              END
            --�̔��̏ꍇ
            ELSE IF @JUCHU_KBN = 2
              BEGIN
                UPDATE T_HAN_JUCHU_H
                   SET T_HAN_JUCHU_H.DEMPYO_HAKKO_KBN = '3'
                  FROM T_HAN_JUCHU_H
                 WHERE T_HAN_JUCHU_H.JURI_NO = @JURI_NO
              END
          END

        --�����`�[�̏ꍇ�A�������󒍂̃X�e�[�^�X��`�[���s�ςɕύX
        IF ISNULL(@DEMPYO_KBN,'') = '5'
          BEGIN

            --���͂̏ꍇ
            UPDATE T_BUN_JUCHU_H
               SET T_BUN_JUCHU_H.DEMPYO_HAKKO_KBN     =  '3'
              FROM T_BUN_JUCHU_H
             INNER JOIN
                   T_URIAGE_H
                ON T_URIAGE_H.JURI_NO                 =  T_BUN_JUCHU_H.JURI_NO
              LEFT JOIN
                   T_URIAGE_MERGE
                ON T_URIAGE_MERGE.MOTO_URIAGE_NO      =  T_URIAGE_H.URIAGE_NO
             WHERE T_URIAGE_MERGE.URIAGE_NO           =  @REF_NO

            --�̔��̏ꍇ
            UPDATE T_HAN_JUCHU_H
               SET T_HAN_JUCHU_H.DEMPYO_HAKKO_KBN     =  '3'
              FROM T_HAN_JUCHU_H
             INNER JOIN
                   T_URIAGE_H
                ON T_URIAGE_H.JURI_NO                 =  T_HAN_JUCHU_H.JURI_NO
              LEFT JOIN
                   T_URIAGE_MERGE
                ON T_URIAGE_MERGE.MOTO_URIAGE_NO      =  T_URIAGE_H.URIAGE_NO
             WHERE T_URIAGE_MERGE.URIAGE_NO           =  @REF_NO

          END

        --�󒍕����I��
        UPDATE T_BUN_JUCHU_H
           SET T_BUN_JUCHU_H.DEMPYO_HAKKO_KBN     =  '3'
          FROM T_BUN_JUCHU_H
         INNER JOIN
               T_URIAGE_JUCHU_SELECT
            ON T_URIAGE_JUCHU_SELECT.JURI_NO      =  T_BUN_JUCHU_H.JURI_NO
         WHERE T_URIAGE_JUCHU_SELECT.URIAGE_NO    =  @REF_NO

        UPDATE T_HAN_JUCHU_H
           SET T_HAN_JUCHU_H.DEMPYO_HAKKO_KBN     =  '3'
          FROM T_HAN_JUCHU_H
         INNER JOIN
               T_URIAGE_JUCHU_SELECT
            ON T_URIAGE_JUCHU_SELECT.JURI_NO      =  T_HAN_JUCHU_H.JURI_NO
         WHERE T_URIAGE_JUCHU_SELECT.URIAGE_NO    =  @REF_NO

        --�Ώ۔���̃X�e�[�^�X�ύX
        SELECT @STS_CD = URIAGE_STS
          FROM T_URIAGE_H
         WHERE URIAGE_NO = @REF_NO

        --�����s�̏ꍇ�A���s�ςɐݒ�
        IF @STS_CD = 1
          BEGIN
            UPDATE T_URIAGE_H
               SET T_URIAGE_H.URIAGE_STS = '2'
              FROM T_URIAGE_H
             WHERE T_URIAGE_H.URIAGE_NO = @REF_NO
          END
--         --���s�ς̏ꍇ�A�Ĕ��s�ςɐݒ�
--         ELSE IF @STS_CD = 2
--           BEGIN
--             UPDATE T_URIAGE_H
--                SET T_URIAGE_H.URIAGE_STS = '3'
--               FROM T_URIAGE_H
--              WHERE T_URIAGE_H.URIAGE_NO = @REF_NO
--           END

        --����I��
        INSERT INTO @TBL VALUES( @REF_NO, 0, NULL )

      END

    --���㌋���J�ڏ���
    ELSE IF @MODE = 9
      BEGIN

        --�X�V�����ݒ�
        SET @UPDATE_DATE = 'DT' + CONVERT(VARCHAR(24),GETDATE(),120)

        --���[�N�e�[�u���N���A
        DELETE
          FROM W_URIAGE
         WHERE W_URIAGE.W_USER_ID = @USER_ID

        --�Ǎ�(�e�[�u�������[�N�e�[�u��)
        INSERT INTO
               W_URIAGE
        SELECT TOP 99
               @USER_ID
              ,@SERIAL
              ,1
              ,ROW_NUMBER() OVER (ORDER BY W_URIAGE_MERGE.W_ROW ASC ,T_URIAGE_B.GYO_NO ASC)
              ,0
              ,NULL                                 --T_URIAGE_H.URIAGE_NO
              ,5                                    --T_URIAGE_H.DEMPYO_KBN
              ,2                                    --T_URIAGE_H.RENDO_KBN
              ,0                                    --T_URIAGE_H.DENKU
              ,T_URIAGE_H.KANJO_KAMOKU              --T_URIAGE_H.KANJO_KAMOKU
              ,T_URIAGE_H.URIAGE_DATE
              ,T_URIAGE_H.BUSHO_CD
              ,@USER_ID                             --T_URIAGE_H.URIAGE_NYURYOKUSHA_CD
              ,T_URIAGE_H.EIGYO_TANTO_CD
              ,NULL                                 --T_URIAGE_H.NYURYOKU_DATE_TIME
              ,NULL                                 --T_URIAGE_H.JUCHU_KBN
              ,NULL                                 --T_URIAGE_H.JURI_NO
              ,NULL                                 --T_URIAGE_H.MITSU_NO
              ,NULL                                 --T_URIAGE_H.SAKI_URIAGE_NO
              ,T_URIAGE_H.NOHIN_DATE
              ,1                                    --T_URIAGE_H.URIAGE_STS
              ,T_URIAGE_H.DOJI_FLG
              ,T_URIAGE_H.SEIKYU_CD
              ,T_URIAGE_H.KAISHU_DATE
              ,T_URIAGE_H.BUNSEKI_HOHO_CD
              ,T_URIAGE_H.TEKIYO
              ,T_URIAGE_H.DEMPYO_SOFU_MEI
              ,T_URIAGE_H.KEISHO
              ,T_URIAGE_H.YUBIN_NO
              ,T_URIAGE_H.ADDRESS_1
              ,T_URIAGE_H.ADDRESS_2
              ,T_URIAGE_H.TEL
              ,T_URIAGE_H.FAX
              ,T_URIAGE_H.SOFU_TANTO
              ,T_URIAGE_H.TEISEI_BIKO
              ,T_URIAGE_H.JUSHO_NO_PRINT_FLG
              ,NULL                                 --T_URIAGE_H.TAX_RATE
              ,NULL                                 --T_URIAGE_H.NUKI_TOTAL
              ,NULL                                 --T_URIAGE_H.TAX
              ,NULL                                 --T_URIAGE_H.KOMI_TOTAL
              ,NULL                                 --T_URIAGE_H.GENKA_TOTAL
              ,NULL                                 --T_URIAGE_H.ARARIEKI
              ,NULL                                 --T_URIAGE_H.ARARIRITSU
              ,NULL                                 --T_URIAGE_H.SHOKON_NO
              ,NULL                                 --T_URIAGE_H.SHOKON_LIST_DATE_TIME
              ,ROW_NUMBER() OVER (ORDER BY W_URIAGE_MERGE.W_ROW ASC ,T_URIAGE_B.GYO_NO ASC)
              ,T_URIAGE_B.ROW_KBN
              ,T_URIAGE_B.SHOHIN_CD
              ,T_URIAGE_B.SHOHIN_MEI
              ,T_URIAGE_B.URIAGE_SURYO
              ,T_URIAGE_B.URIAGE_SURYO_TANI
              ,T_URIAGE_B.HAMBAI_TANKA
              ,T_URIAGE_B.HAMBAI_KINGAKU
              ,T_URIAGE_B.TEKIYO
              ,T_URIAGE_B.GENTANKA
              ,T_URIAGE_B.GENKA_SURYO
              ,T_URIAGE_B.IRISU_TANI
              ,T_URIAGE_B.SOSU
              ,T_URIAGE_B.BARA_TANI
              ,T_URIAGE_B.GENKA_KINGAKU
              ,T_URIAGE_B.ARARIRITSU
              ,T_URIAGE_B.ARARIEKI
              ,T_URIAGE_B.TEIKA
              ,'False'                              --T_URIAGE_H.DEL_FLG
              ,1
              ,@USER_ID
              ,@UPDATE_DATE
              ,@USER_ID
              ,@UPDATE_DATE
          FROM W_URIAGE_MERGE
          LEFT JOIN
               T_URIAGE_H
            ON T_URIAGE_H.URIAGE_NO = W_URIAGE_MERGE.URIAGE_NO
          LEFT JOIN
               T_URIAGE_B
            ON T_URIAGE_B.URIAGE_NO = W_URIAGE_MERGE.URIAGE_NO
         WHERE W_URIAGE_MERGE.W_USER_ID  =  @USER_ID
           AND W_URIAGE_MERGE.W_SERIAL   =  @SERIAL
           AND (  ISNULL(T_URIAGE_B.HAMBAI_KINGAKU,0) <> 0
               OR T_URIAGE_B.ROW_KBN = '2' )
--           AND T_URIAGE_B.HAMBAI_KINGAKU <> 0

      END

    --���㌋����������
    ELSE IF @MODE = 10
      BEGIN

        --���㌋�����e�[�u���폜
        DELETE
          FROM T_URIAGE_MERGE
         WHERE T_URIAGE_MERGE.URIAGE_NO      = @REF_NO
           AND T_URIAGE_MERGE.MOTO_URIAGE_NO = @REF_NO2

        --�����攄��No.����
        UPDATE T_URIAGE_H
           SET T_URIAGE_H.SAKI_URIAGE_NO = ''
          FROM T_URIAGE_H
         WHERE T_URIAGE_H.URIAGE_NO = @REF_NO2

      END


    --�Q�ƍ쐬����(����)
    ELSE IF @MODE = 11
      BEGIN

        --�X�V�����ݒ�
        SET @UPDATE_DATE = 'DT' + CONVERT(VARCHAR(24),GETDATE(),120)

        --���[�N�e�[�u���N���A
        DELETE
          FROM W_URIAGE
         WHERE W_URIAGE.W_USER_ID = @USER_ID

        DELETE
          FROM W_URIAGE_JUCHU_SELECT
         WHERE W_URIAGE_JUCHU_SELECT.W_USER_ID = @USER_ID

        --�Ǎ�(�e�[�u�������[�N�e�[�u��)
        INSERT INTO
               W_URIAGE
        SELECT
               @USER_ID
              ,@SERIAL
              ,1
              ,T_URIAGE_B_R.GYO_NO
              ,0
              ,NULL
              --�����`�[�͒ʏ�`�[�ɕύX����
              ,CASE
                 WHEN ISNULL(T_URIAGE_H_R.DEMPYO_KBN,0) = 5 THEN
                      1
                 ELSE
                      T_URIAGE_H_R.DEMPYO_KBN
                 END
              ,NULL
              ,T_URIAGE_H_R.DENKU
              ,T_URIAGE_H_R.KANJO_KAMOKU
              ,NULL
              ,T_URIAGE_H_R.BUSHO_CD
              ,@USER_ID
              ,M_AITESAKI.EIGYO_TANTO_CD
              ,NULL
              ,T_URIAGE_H_R.JUCHU_KBN
              ,T_URIAGE_H_R.JURI_NO
              ,T_URIAGE_H_R.MITSU_NO
              ,T_URIAGE_H_R.URIAGE_NO
              ,NULL
              ,1
              ,T_URIAGE_H_R.DOJI_FLG
              ,M_AITESAKI.AITE_CD
              ,T_URIAGE_H_R.KAISHU_DATE
              ,T_URIAGE_H_R.BUNSEKI_HOHO_CD
              ,T_URIAGE_H_R.TEKIYO
              ,M_AITESAKI.AITE_MEI
              ,T_URIAGE_H_R.KEISHO
              ,M_AITESAKI.YUBIN_NO
              ,M_AITESAKI.ADDRESS_1
              ,M_AITESAKI.ADDRESS_2
              ,M_AITESAKI.TEL
              ,M_AITESAKI.FAX
              ,T_URIAGE_H_R.SOFU_TANTO
              ,T_URIAGE_H_R.TEISEI_BIKO
              ,T_URIAGE_H_R.JUSHO_NO_PRINT_FLG
              ,NULL
              ,T_URIAGE_H_R.NUKI_TOTAL
              ,T_URIAGE_H_R.TAX
              ,T_URIAGE_H_R.KOMI_TOTAL
              ,T_URIAGE_H_R.GENKA_TOTAL
              ,T_URIAGE_H_R.ARARIEKI
              ,T_URIAGE_H_R.ARARIRITSU
              ,NULL
              ,NULL
              ,T_URIAGE_B_R.GYO_NO
              ,T_URIAGE_B_R.ROW_KBN
              ,CASE WHEN T_URIAGE_B_R.ROW_KBN = 1
                    THEN M_SHOHIN.SHOHIN_CD
                    ELSE T_URIAGE_B_R.SHOHIN_CD
               END
              ,T_URIAGE_B_R.SHOHIN_MEI
              ,T_URIAGE_B_R.URIAGE_SURYO
              ,T_URIAGE_B_R.URIAGE_SURYO_TANI
              ,T_URIAGE_B_R.HAMBAI_TANKA
              ,T_URIAGE_B_R.HAMBAI_KINGAKU
              ,T_URIAGE_B_R.TEKIYO
              ,T_URIAGE_B_R.GENTANKA
              ,T_URIAGE_B_R.GENKA_SURYO
              ,T_URIAGE_B_R.IRISU_TANI
              ,T_URIAGE_B_R.SOSU
              ,T_URIAGE_B_R.BARA_TANI
              ,T_URIAGE_B_R.GENKA_KINGAKU
              ,T_URIAGE_B_R.ARARIRITSU
              ,T_URIAGE_B_R.ARARIEKI
              ,T_URIAGE_B_R.TEIKA
              ,T_URIAGE_H_R.DEL_FLG
              ,1
              ,@USER_ID
              ,@UPDATE_DATE
              ,@USER_ID
              ,@UPDATE_DATE
          FROM T_URIAGE_H_R
          LEFT JOIN
               T_URIAGE_B_R
            ON T_URIAGE_B_R.URIAGE_NO = T_URIAGE_H_R.URIAGE_NO
           AND T_URIAGE_B_R.RIREKI_NO = T_URIAGE_H_R.RIREKI_NO

          LEFT JOIN
               M_AITESAKI
            ON M_AITESAKI.AITE_CD     =  T_URIAGE_H_R.SEIKYU_CD
           AND M_AITESAKI.MISHIYO_FLG =  'False'
          LEFT JOIN
               M_SHOHIN
            ON M_SHOHIN.SHOHIN_CD     =  T_URIAGE_B_R.SHOHIN_CD
           AND M_SHOHIN.MISHIYO_FLG   =  'False'


         WHERE T_URIAGE_H_R.URIAGE_NO = @REF_NO
           AND T_URIAGE_H_R.RIREKI_NO = @PAGE

        --����I��
        INSERT INTO @TBL VALUES( @URIAGE_NO, 0, NULL )

      END

    --����No.�ݒ菈��
    ELSE IF @MODE = 12
      BEGIN

        SET @CREATE_DATE = 'DT'+CONVERT(VARCHAR,GETDATE(),121)
        SET @JURI_NO     = @REF_NO
        SET @MITSU_NO    = @REF_NO2

        IF @PAGE = 1
          BEGIN
            --���͈˗��󒍃X�e�[�^�X�ύX
            UPDATE T_BUN_JUCHU_H
               SET T_BUN_JUCHU_H.MITSU_NO        = @MITSU_NO
                  ,T_BUN_JUCHU_H.DBS_UPDATE_USER = @USER_ID
                  ,T_BUN_JUCHU_H.DBS_UPDATE_DATE = @CREATE_DATE
             WHERE T_BUN_JUCHU_H.JURI_NO         = @REF_NO
          END
        ELSE
          BEGIN
            --�̔����i�󒍃X�e�[�^�X�ύX
            UPDATE T_HAN_JUCHU_H
               SET T_HAN_JUCHU_H.MITSU_NO        = @MITSU_NO
                  ,T_HAN_JUCHU_H.DBS_UPDATE_USER = @USER_ID
                  ,T_HAN_JUCHU_H.DBS_UPDATE_DATE = @CREATE_DATE
             WHERE T_HAN_JUCHU_H.JURI_NO         = @REF_NO
          END
      END

    --���[�N�e�[�u���N���A
    ELSE
      BEGIN

        --���[�N�e�[�u���N���A
        DELETE
          FROM W_URIAGE
         WHERE W_URIAGE.W_USER_ID = @USER_ID

        DELETE
          FROM W_URIAGE_MERGE
         WHERE W_URIAGE_MERGE.W_USER_ID = @USER_ID

        DELETE
          FROM W_URIAGE_JUCHU_SELECT
         WHERE W_URIAGE_JUCHU_SELECT.W_USER_ID = @USER_ID

      END

    --�������ʕԋp
    SELECT RESULT_URIAGE_NO, RESULT_CD, RESULT_MESSAGE FROM @TBL

    DEALLOCATE URIAGE_SAVE_CURSOR
    DEALLOCATE URIAGE_LOAD_CURSOR

END TRY


-- ��O����
BEGIN CATCH

    -- �g�����U�N�V���������[���o�b�N�i�L�����Z���j
    ROLLBACK TRANSACTION SAVE1

    --���[�N�e�[�u���N���A
    DELETE
      FROM W_URIAGE
     WHERE W_URIAGE.W_USER_ID = @USER_ID

    --�ُ�I��
    INSERT INTO @TBL VALUES( 0, ERROR_NUMBER(), ERROR_MESSAGE() )

    --�������ʕԋp
    SELECT RESULT_URIAGE_NO, RESULT_CD, RESULT_MESSAGE FROM @TBL

    DEALLOCATE URIAGE_SAVE_CURSOR
    DEALLOCATE URIAGE_LOAD_CURSOR

END CATCH

END

