--DROP PROCEDURE SP_SAVE_T_HAN_JUCHU

CREATE PROCEDURE SP_SAVE_T_HAN_JUCHU
       @USER_ID  NVARCHAR(64)
      ,@SERIAL   NVARCHAR(50)
      ,@MODE     INT
AS
--�ۑ��������s
BEGIN
    --�߂�l�p�e�[�u���ϐ�
    DECLARE @TBL TABLE (
      RESULT_JURI_NO NVARCHAR(10)
     ,RESULT_CD int NOT NULL
     ,RESULT_MESSAGE NVARCHAR(max)
    )

    --�V�[�P���X
    DECLARE @SEQ AS INT

    --�Ώێ�No.
    DECLARE @JURI_NO AS NVARCHAR(10)
    
    --�Ώی���No.
    DECLARE @MITSU_NO AS NVARCHAR(10)

    --�Ώۍw���\��No.
    DECLARE @KOBAI_NO AS NVARCHAR(10)

    --�X�V���[�U�[�E�X�V����
    DECLARE @UPDATE_USER AS NVARCHAR(max)
    DECLARE @UPDATE_DATE AS NVARCHAR(50)

    --�Z�[�u�|�C���g����
    SAVE TRANSACTION SAVE1

BEGIN TRY

    --�V�K�o�^����
    IF @MODE = 1
      BEGIN

        --�V�[�P���X�擾
        SET @SEQ = NEXT VALUE FOR SEQ_JURI_NO

        --��No.����
        SET @JURI_NO = ( SELECT CONCAT( 'J', RIGHT('00'+CAST(YEAR(GETDATE()) AS NVARCHAR) ,2) 
                                  ,'-' 
                                  ,RIGHT('00'+CAST(MONTH(GETDATE()) AS NVARCHAR) ,2)
                                  ,RIGHT('0000' + CAST(@SEQ AS NVARCHAR) ,4) ) )

        --����No.�擾
        SET @MITSU_NO = ( SELECT MITSU_NO
                            FROM W_HAN_JUCHU
                           WHERE W_USER_ID = @USER_ID
                             AND W_SERIAL  = @SERIAL
                             AND W_ROW     = 1 )

        --�V�K�ۑ�(���[�N�e�[�u�����w�b�_�e�[�u��)
        INSERT INTO
               T_HAN_JUCHU_H
                 SELECT  @JURI_NO
                        ,HAMBAI_STS
                        ,HAMBAI_KBN
                        ,REF_JURI_NO
                        ,NYURYOKU_DATETIME
                        ,NYURYOKUSHA_CD
                        ,MITSU_NO
                        ,JUCHU_DATE
                        ,NOHIN_DATE
                        ,SEIKYU_CD
                        ,SEIKYU_TANTO_MEI
                        ,KENMEI
                        ,EIGYO_TANTO_CD
                        ,HASSO_CD
                        ,HASSO_MEI
                        ,HASSO_YUBIN_NO
                        ,HASSO_ADDRESS_1
                        ,HASSO_ADDRESS_2
                        ,HASSO_TEL
                        ,HASSO_FAX
                        ,HASSO_TANTO_MEI
                        ,MAKER_FLG
                        ,TAX_RATE
                        ,NUKI_TOTAL
                        ,TAX
                        ,KOMI_TOTAL
                        ,GENKA_TOTAL
                        ,ARARIEKI
                        ,ARARIRITSU
                        ,DEMPYO_HAKKO_KBN
                        ,DEL_FLG
                        ,DBS_STATUS
                        ,DBS_CREATE_USER
                        ,DBS_CREATE_DATE
                        ,DBS_UPDATE_USER
                        ,DBS_UPDATE_DATE
                   FROM W_HAN_JUCHU
                  WHERE W_USER_ID = @USER_ID
                    AND W_SERIAL  = @SERIAL
                    AND W_ROW     = 1

        --�V�K�ۑ�(���[�N�e�[�u�����{�f�B�e�[�u��)
        INSERT INTO
               T_HAN_JUCHU_B
                 SELECT @JURI_NO
                       ,GYO_NO
                       ,ROW_KBN
                       ,SHOHIN_CD
                       ,SHOHIN_MEI
                       ,JUCHU_SURYO
                       ,JUCHU_TANI
                       ,HAMBAI_TANKA
                       ,HAMBAI_KINGAKU
                       ,TEKIYO
                       ,GENTANKA
                       ,GENKA_SURYO
                       ,IRISU_TANI
                       ,TOTAL
                       ,BARA_TANI
                       ,GENKA_KINGAKU
                       ,ARARIRITSU
                       ,ARARIEKI
                       ,TEIKA
                       ,SHIIRE_CD
                       ,MAKER_CD
                       ,DEL_FLG
                       ,DBS_STATUS
                       ,DBS_CREATE_USER
                       ,DBS_CREATE_DATE
                       ,DBS_UPDATE_USER
                       ,DBS_UPDATE_DATE
                   FROM W_HAN_JUCHU
                  WHERE W_USER_ID = @USER_ID
                    AND W_SERIAL  = @SERIAL

        --�Ώی��ς̃X�e�[�^�X���󒍍ςɕύX
        IF @MITSU_NO <> ''
          BEGIN
            UPDATE T_MITSU_H
               SET T_MITSU_H.MITSU_STS = '5'
              FROM T_MITSU_H
             WHERE T_MITSU_H.MITSU_NO = @MITSU_NO
          END



        --�w���\���f�[�^��������
        --�w���i��1���ȏ゠��ꍇ���s
        IF ( SELECT COUNT(*)
               FROM W_HAN_JUCHU
               LEFT JOIN
                    M_SHOHIN
                 ON M_SHOHIN.SHOHIN_CD = W_HAN_JUCHU.SHOHIN_CD
              WHERE W_USER_ID             = @USER_ID
                AND W_SERIAL              = @SERIAL
                AND ROW_KBN               = 1
                AND M_SHOHIN.KOBAIHIN_FLG = 'True'
           ) >= 1
          BEGIN

            --�V�[�P���X�擾
            SET @SEQ = NEXT VALUE FOR SEQ_KOBAI_NO

            --�w���\��No.����
            SET @KOBAI_NO = ( SELECT CONCAT( 'K', RIGHT('00'+CAST(YEAR(GETDATE()) AS NVARCHAR) ,2) 
                                    ,'-' 
                                    ,RIGHT('00'+CAST(MONTH(GETDATE()) AS NVARCHAR) ,2)
                                    ,RIGHT('0000' + CAST(@SEQ AS NVARCHAR) ,4) ) )

            --�V�K�ۑ�(���[�N�e�[�u�����w�b�_�e�[�u��)
            INSERT INTO
                   T_KOBAI_H
                     SELECT
                            @KOBAI_NO
                           ,@USER_ID
                           ,CONVERT(VARCHAR(10),GETDATE(),111) + ' ' + CONVERT(VARCHAR(8),GETDATE(),114)
                           ,@JURI_NO
                           ,5                   --KOBAI_KBN(�̔����i)
                           ,TAX_RATE
                           ,NUKI_TOTAL
                           ,TAX
                           ,KOMI_TOTAL
                           ,'False'             --DEL_FLG
                           ,DBS_STATUS
                           ,DBS_CREATE_USER
                           ,DBS_CREATE_DATE
                           ,DBS_UPDATE_USER
                           ,DBS_UPDATE_DATE
                       FROM W_HAN_JUCHU
                      WHERE W_USER_ID = @USER_ID
                        AND W_SERIAL  = @SERIAL
                        AND W_ROW     = 1

            --�V�K�ۑ�(���[�N�e�[�u�����{�f�B�e�[�u��)
            INSERT INTO
                   T_KOBAI_B
                     SELECT
                            @KOBAI_NO
                           ,ROW_NUMBER() OVER (ORDER BY GYO_NO)
                           ,ROW_NUMBER() OVER (ORDER BY GYO_NO)
                           ,1                               --KOBAI_STS
                           ,'False'                         --JOGAI_FLG
                           ,W_HAN_JUCHU.SHOHIN_CD
                           ,W_HAN_JUCHU.SHOHIN_MEI
                           ,ISNULL(W_HAN_JUCHU.GENTANKA,0)
                           ,M_SHOHIN.SHIIRE_IRISU           --IRISU
                           ,M_SHOHIN.SHIIRE_IRISU_TANI
                           ,W_HAN_JUCHU.GENKA_SURYO
                           ,W_HAN_JUCHU.BARA_TANI
                           ,CASE ISNULL(M_SHOHIN.SHIIRE_IRISU,0)
                            WHEN 0 THEN W_HAN_JUCHU.GENKA_SURYO
                            ELSE CAST(M_SHOHIN.SHIIRE_IRISU * W_HAN_JUCHU.GENKA_SURYO AS NUMERIC(7, 2))
                            END                             --SOSU
                           ,CASE ISNULL(W_HAN_JUCHU.GENTANKA,0)
                            WHEN 0 THEN 0
                            ELSE CAST(W_HAN_JUCHU.GENTANKA * W_HAN_JUCHU.GENKA_SURYO AS NUMERIC(11, 2))
                            END                             --TOTAL
                           ,ISNULL(W_HAN_JUCHU.NOHIN_DATE,'') --NOKI
                           ,M_SHOHIN.HOKANBASHO_KBN         --HOKAN_BASHO_KBN
                           ,W_HAN_JUCHU.SHIIRE_CD
                           ,W_HAN_JUCHU.MAKER_CD
                           ,NULL                            --YOSAN_CD
                           ,@JURI_NO                        --JURI_NO
                           ,W_HAN_JUCHU.TEKIYO              --BIKO
                           ,'False'                         --DEL_FLG
                           ,W_HAN_JUCHU.DBS_STATUS
                           ,W_HAN_JUCHU.DBS_CREATE_USER
                           ,W_HAN_JUCHU.DBS_CREATE_DATE
                           ,W_HAN_JUCHU.DBS_UPDATE_USER
                           ,W_HAN_JUCHU.DBS_UPDATE_DATE
                       FROM W_HAN_JUCHU
                       LEFT JOIN
                            M_SHOHIN
                         ON M_SHOHIN.SHOHIN_CD = W_HAN_JUCHU.SHOHIN_CD
                      WHERE W_USER_ID             = @USER_ID
                        AND W_SERIAL              = @SERIAL
                        AND ROW_KBN               = 1
                        AND M_SHOHIN.KOBAIHIN_FLG = 'True'

            --�X�e�[�^�X�ύX����ۑ�(�V�K�쐬)
            --�ύX�����̓X�g�A�h��̃V�X�e������
            INSERT INTO
                   T_KOBAI_STS_R
            SELECT
                   @KOBAI_NO
                  ,ROW_NUMBER() OVER (ORDER BY GYO_NO)
                  ,CONVERT(VARCHAR(10),GETDATE(),111) + ' ' + CONVERT(VARCHAR(8),GETDATE(),114)
                  ,NULL
                  ,1
                  ,1
                  ,W_HAN_JUCHU.DBS_CREATE_USER
                  ,W_HAN_JUCHU.DBS_CREATE_DATE
                  ,W_HAN_JUCHU.DBS_UPDATE_USER
                  ,W_HAN_JUCHU.DBS_UPDATE_DATE
              FROM W_HAN_JUCHU
              LEFT JOIN
                   M_SHOHIN
                ON M_SHOHIN.SHOHIN_CD = W_HAN_JUCHU.SHOHIN_CD
             WHERE W_USER_ID             = @USER_ID
               AND W_SERIAL              = @SERIAL
               AND ROW_KBN               = 1
               AND M_SHOHIN.KOBAIHIN_FLG = 'True'

          END

      END

    --�X�V����
    ELSE IF @MODE = 2
      BEGIN

         --��No.�Z�b�g
         SET @JURI_NO =  ( SELECT W_HAN_JUCHU.JURI_NO
                             FROM W_HAN_JUCHU
                            WHERE W_HAN_JUCHU.W_USER_ID   = @USER_ID
                              AND W_HAN_JUCHU.W_SERIAL    = @SERIAL
                              AND W_HAN_JUCHU.W_ROW       = 1 )

        --����No.�擾
        SET @MITSU_NO = ( SELECT MITSU_NO
                            FROM W_HAN_JUCHU
                           WHERE W_USER_ID = @USER_ID
                             AND W_SERIAL  = @SERIAL
                             AND W_ROW     = 1 )

        --�w�b�_�e�[�u���폜
        DELETE
          FROM T_HAN_JUCHU_H
         WHERE T_HAN_JUCHU_H.JURI_NO = @JURI_NO

        --�{�f�B�e�[�u���폜
        DELETE
          FROM T_HAN_JUCHU_B
         WHERE T_HAN_JUCHU_B.JURI_NO = @JURI_NO

        --�X�V(���[�N�e�[�u�����w�b�_�e�[�u��)
        INSERT INTO
               T_HAN_JUCHU_H
                 SELECT  JURI_NO
                        ,HAMBAI_STS
                        ,HAMBAI_KBN
                        ,REF_JURI_NO
                        ,NYURYOKU_DATETIME
                        ,NYURYOKUSHA_CD
                        ,MITSU_NO
                        ,JUCHU_DATE
                        ,NOHIN_DATE
                        ,SEIKYU_CD
                        ,SEIKYU_TANTO_MEI
                        ,KENMEI
                        ,EIGYO_TANTO_CD
                        ,HASSO_CD
                        ,HASSO_MEI
                        ,HASSO_YUBIN_NO
                        ,HASSO_ADDRESS_1
                        ,HASSO_ADDRESS_2
                        ,HASSO_TEL
                        ,HASSO_FAX
                        ,HASSO_TANTO_MEI
                        ,MAKER_FLG
                        ,TAX_RATE
                        ,NUKI_TOTAL
                        ,TAX
                        ,KOMI_TOTAL
                        ,GENKA_TOTAL
                        ,ARARIEKI
                        ,ARARIRITSU
                        ,DEMPYO_HAKKO_KBN
                        ,DEL_FLG
                        ,DBS_STATUS
                        ,DBS_CREATE_USER
                        ,DBS_CREATE_DATE
                        ,DBS_UPDATE_USER
                        ,DBS_UPDATE_DATE
                   FROM W_HAN_JUCHU
                  WHERE W_USER_ID = @USER_ID
                    AND W_SERIAL  = @SERIAL
                    AND W_ROW     = 1

        --�X�V(���[�N�e�[�u�����{�f�B�e�[�u��)
        INSERT INTO
               T_HAN_JUCHU_B
                 SELECT JURI_NO
                       ,GYO_NO
                       ,ROW_KBN
                       ,SHOHIN_CD
                       ,SHOHIN_MEI
                       ,JUCHU_SURYO
                       ,JUCHU_TANI
                       ,HAMBAI_TANKA
                       ,HAMBAI_KINGAKU
                       ,TEKIYO
                       ,GENTANKA
                       ,GENKA_SURYO
                       ,IRISU_TANI
                       ,TOTAL
                       ,BARA_TANI
                       ,GENKA_KINGAKU
                       ,ARARIRITSU
                       ,ARARIEKI
                       ,TEIKA
                       ,SHIIRE_CD
                       ,MAKER_CD
                       ,DEL_FLG
                       ,DBS_STATUS
                       ,DBS_CREATE_USER
                       ,DBS_CREATE_DATE
                       ,DBS_UPDATE_USER
                       ,DBS_UPDATE_DATE
                   FROM W_HAN_JUCHU
                  WHERE W_USER_ID = @USER_ID
                    AND W_SERIAL  = @SERIAL

        --�Ώی��ς̃X�e�[�^�X���󒍍ςɕύX
        IF @MITSU_NO <> ''
          BEGIN
            UPDATE T_MITSU_H
               SET T_MITSU_H.MITSU_STS = '5'
              FROM T_MITSU_H
             WHERE T_MITSU_H.MITSU_NO = @MITSU_NO
          END

      END

    --�폜����
    ELSE
      BEGIN

         --��No./�X�V���[�U�[/�X�V�����Z�b�g
        SELECT @JURI_NO     = W_HAN_JUCHU.JURI_NO
              ,@UPDATE_USER = W_HAN_JUCHU.DBS_UPDATE_USER
              ,@UPDATE_DATE = W_HAN_JUCHU.DBS_UPDATE_DATE
          FROM W_HAN_JUCHU
         WHERE W_HAN_JUCHU.W_USER_ID   = @USER_ID
           AND W_HAN_JUCHU.W_SERIAL    = @SERIAL
           AND W_HAN_JUCHU.W_ROW       = 1


        --�����f�[�^�폜(�w�b�_)�t���OTrue
        UPDATE T_HAN_JUCHU_H
           SET T_HAN_JUCHU_H.DEL_FLG = 'True'
              ,T_HAN_JUCHU_H.DBS_CREATE_USER = @UPDATE_USER
              ,T_HAN_JUCHU_H.DBS_UPDATE_DATE = @UPDATE_DATE
          FROM T_HAN_JUCHU_H
         WHERE T_HAN_JUCHU_H.JURI_NO = @JURI_NO

        --�����f�[�^�폜(�{�f�B)�t���OTrue
        UPDATE T_HAN_JUCHU_B
           SET T_HAN_JUCHU_B.DEL_FLG = 'True'
              ,T_HAN_JUCHU_B.DBS_UPDATE_USER = @UPDATE_USER
              ,T_HAN_JUCHU_B.DBS_UPDATE_DATE = @UPDATE_DATE
          FROM T_HAN_JUCHU_B
         WHERE T_HAN_JUCHU_B.JURI_NO = @JURI_NO

      END

    --���ʏ���
    --���[�N�e�[�u���N���A
    DELETE
      FROM W_HAN_JUCHU
     WHERE W_HAN_JUCHU.W_USER_ID = @USER_ID
--       AND W_HAN_JUCHU.W_SERIAL  = @SERIAL

    --����I��
    --�w���\��No.�ԋp
    INSERT INTO @TBL VALUES( @JURI_NO, 0, @KOBAI_NO )

    --�������ʕԋp
    SELECT RESULT_JURI_NO, RESULT_CD, RESULT_MESSAGE FROM @TBL

END TRY


-- ��O����
BEGIN CATCH

    -- �g�����U�N�V���������[���o�b�N�i�L�����Z���j
    ROLLBACK TRANSACTION SAVE1

    --���[�N�e�[�u���N���A
    DELETE
      FROM W_HAN_JUCHU
     WHERE W_HAN_JUCHU.W_USER_ID = @USER_ID
--       AND W_HAN_JUCHU.W_SERIAL  = @SERIAL

    --�ُ�I��
    INSERT INTO @TBL VALUES( 0, ERROR_NUMBER(), ERROR_MESSAGE() )

    --�������ʕԋp
    SELECT RESULT_JURI_NO, RESULT_CD, RESULT_MESSAGE FROM @TBL

END CATCH

END

