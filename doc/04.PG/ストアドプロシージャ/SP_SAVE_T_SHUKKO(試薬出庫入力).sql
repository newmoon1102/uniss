
--DROP PROCEDURE SP_SAVE_T_SHUKKO

CREATE PROCEDURE SP_SAVE_T_SHUKKO
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
      RESULT_SHUKKO_NO NVARCHAR(10)
     ,RESULT_CD int NOT NULL
     ,RESULT_MESSAGE NVARCHAR(max)
    )

    --�V�[�P���X
    DECLARE @SEQ AS INT
    --�Ώۏo��No.
    DECLARE @SHUKKO_NO AS NVARCHAR(10)
    --�Ώۍ݌�No.
    DECLARE @ZAIKO_NO AS NVARCHAR(10)
    --�X�V����
    DECLARE @UPDATE_DATE AS NVARCHAR(50)

    --�Z�[�u�|�C���g����
    SAVE TRANSACTION SAVE1

BEGIN TRY

    --�V�K�o�^����
    IF @MODE = 1
      BEGIN

        --�V�[�P���X�擾
        SET @SEQ = NEXT VALUE FOR SEQ_NYUSHUKKO_NO
        --����No.����
        SET @SHUKKO_NO  = ( SELECT CONCAT( 'N', RIGHT('00'+CAST(YEAR(GETDATE()) AS NVARCHAR) ,2) 
                                  ,'-' 
                                  ,RIGHT('00' + CAST(MONTH(GETDATE()) AS NVARCHAR) ,2)
                                  ,RIGHT('0000' + CAST(@SEQ AS NVARCHAR) ,4) ) )

        --�V�K�ۑ�(���[�N�e�[�u�����e�[�u��)
        INSERT INTO
               T_NYUSHUKKO
                 SELECT @SHUKKO_NO                          --NYUSHUKKO_NO
                       ,ZAIKO_NO                            --ZAIKO_NO
                       ,2                                   --NYUSHUKKO_KBN
                       ,NYURYOKUSHA_CD                      --NYURYOKUSHA_CD
                       ,IRAI_NO                             --IRAI_NO
                       ,JURI_NO                             --JURI_NO
                       ,HOKAN_BASHO_KBN                     --HOKAN_BASHO_KBN
                       ,NULL                                --UKEIRE_DATE
                       ,NULL                                --KENSHU_DATE
                       ,NULL                                --NYUKO_SURYO
                       ,SHUKKO_DATE                         --SHUKKO_DATE
                       ,SHUKKO_SURYO                        --SHUKKO_SURYO
                       ,SHUKKO_JIYU                         --SHUKKO_JIYU
                       ,1
                       ,DBS_CREATE_USER
                       ,DBS_CREATE_DATE
                       ,DBS_UPDATE_USER
                       ,DBS_UPDATE_DATE
                   FROM W_SHUKKO_INPUT
                  WHERE W_USER_ID = @USER_ID
                    AND W_SERIAL  = @SERIAL
                    AND W_ROW     = 1

            --�݌Ɉ�������
            UPDATE T_ZAIKO
               SET ZAIKO_SURYO      = ZAIKO_SURYO - @SURYO
                  ,LAST_SHUKKO_DATE = W_SHUKKO_INPUT.SHUKKO_DATE
                  ,DBS_UPDATE_USER  = W_SHUKKO_INPUT.DBS_UPDATE_USER
                  ,DBS_UPDATE_DATE  = W_SHUKKO_INPUT.DBS_UPDATE_DATE
              FROM T_ZAIKO
             INNER JOIN
                   W_SHUKKO_INPUT
                ON W_SHUKKO_INPUT.ZAIKO_NO = T_ZAIKO.ZAIKO_NO
             WHERE W_USER_ID = @USER_ID
               AND W_SERIAL  = @SERIAL
               AND W_ROW     = 1

      END

    --�X�V����
    ELSE IF @MODE = 2
      BEGIN

        --�o��No.�Z�b�g
        SET @SHUKKO_NO = @REF_NO

        --�O��o�ɐ������擾
        SET @SURYO = @SURYO - ( SELECT SHUKKO_SURYO
                                  FROM T_NYUSHUKKO
                                 WHERE NYUSHUKKO_NO = @SHUKKO_NO )

        --���o�Ƀe�[�u���폜
        DELETE
          FROM T_NYUSHUKKO
         WHERE T_NYUSHUKKO.NYUSHUKKO_NO = @SHUKKO_NO

        --�X�V(���[�N�e�[�u�����w�b�_�e�[�u��)
        INSERT INTO
               T_NYUSHUKKO
                 SELECT @SHUKKO_NO                          --NYUSHUKKO_NO
                       ,ZAIKO_NO                            --ZAIKO_NO
                       ,2                                   --NYUSHUKKO_KBN
                       ,NYURYOKUSHA_CD                      --NYURYOKUSHA_CD
                       ,IRAI_NO                             --IRAI_NO
                       ,JURI_NO                             --JURI_NO
                       ,HOKAN_BASHO_KBN                     --HOKAN_BASHO_KBN
                       ,NULL                                --UKEIRE_DATE
                       ,NULL                                --KENSHU_DATE
                       ,NULL                                --NYUKO_SURYO
                       ,SHUKKO_DATE                         --SHUKKO_DATE
                       ,SHUKKO_SURYO                        --SHUKKO_SURYO
                       ,SHUKKO_JIYU                         --SHUKKO_JIYU
                       ,1
                       ,DBS_CREATE_USER
                       ,DBS_CREATE_DATE
                       ,DBS_UPDATE_USER
                       ,DBS_UPDATE_DATE
                   FROM W_SHUKKO_INPUT
                  WHERE W_USER_ID = @USER_ID
                    AND W_SERIAL  = @SERIAL
                    AND W_ROW     = 1

            --�݌ɐ��C��
            UPDATE T_ZAIKO
               SET ZAIKO_SURYO      = ZAIKO_SURYO - @SURYO
                  ,LAST_SHUKKO_DATE = W_SHUKKO_INPUT.SHUKKO_DATE
                  ,DBS_UPDATE_USER  = W_SHUKKO_INPUT.DBS_UPDATE_USER
                  ,DBS_UPDATE_DATE  = W_SHUKKO_INPUT.DBS_UPDATE_DATE
              FROM T_ZAIKO
             INNER JOIN
                   W_SHUKKO_INPUT
                ON W_SHUKKO_INPUT.ZAIKO_NO = T_ZAIKO.ZAIKO_NO
             WHERE W_USER_ID = @USER_ID
               AND W_SERIAL  = @SERIAL
               AND W_ROW     = 1

      END

    --�폜����
    ELSE IF @MODE = 3
      BEGIN

        --�o��No.�Z�b�g
        SET @SHUKKO_NO = @REF_NO

        --�O��o�ɐ������擾
        SET @SURYO = ( SELECT SHUKKO_SURYO
                         FROM T_NYUSHUKKO
                        WHERE NYUSHUKKO_NO = @SHUKKO_NO )

        --�݌ɐ��C��
        UPDATE T_ZAIKO
           SET ZAIKO_SURYO      = ZAIKO_SURYO + @SURYO
              ,DBS_UPDATE_USER  = @USER_ID
              ,DBS_UPDATE_DATE  = 'DT' + CONVERT(VARCHAR(24),GETDATE(),120)
          FROM T_ZAIKO
         INNER JOIN
               T_NYUSHUKKO
            ON T_NYUSHUKKO.ZAIKO_NO = T_ZAIKO.ZAIKO_NO
         WHERE T_NYUSHUKKO.NYUSHUKKO_NO = @SHUKKO_NO

        --���o�Ƀe�[�u���폜
        DELETE
          FROM T_NYUSHUKKO
         WHERE T_NYUSHUKKO.NYUSHUKKO_NO = @SHUKKO_NO

      END

    --���̑�����
    ELSE
      BEGIN

        --���[�N�e�[�u���N���A
        DELETE
          FROM W_SHUKKO_INPUT
         WHERE W_SHUKKO_INPUT.W_USER_ID = @USER_ID

      END

    --���ʏ���
    --���[�N�e�[�u���N���A
    DELETE
      FROM W_SHUKKO_INPUT
     WHERE W_SHUKKO_INPUT.W_USER_ID = @USER_ID

    --����I��
    INSERT INTO @TBL VALUES( @SHUKKO_NO, 0, NULL )

    --�������ʕԋp
    SELECT RESULT_SHUKKO_NO, RESULT_CD, RESULT_MESSAGE FROM @TBL

END TRY


-- ��O����
BEGIN CATCH

    --�g�����U�N�V���������[���o�b�N�i�L�����Z���j
    ROLLBACK TRANSACTION SAVE1

    --���[�N�e�[�u���N���A
    DELETE
      FROM W_SHUKKO_INPUT
     WHERE W_SHUKKO_INPUT.W_USER_ID = @USER_ID

    --�ُ�I��
    INSERT INTO @TBL VALUES( 0, ERROR_NUMBER(), ERROR_MESSAGE() )

    --�������ʕԋp
    SELECT RESULT_SHUKKO_NO, RESULT_CD, RESULT_MESSAGE FROM @TBL

END CATCH

END


