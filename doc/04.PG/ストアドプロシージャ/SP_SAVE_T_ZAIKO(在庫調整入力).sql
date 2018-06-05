
--DROP PROCEDURE SP_SAVE_T_ZAIKO

CREATE PROCEDURE SP_SAVE_T_ZAIKO
       @USER_ID  NVARCHAR(64)
      ,@SERIAL   NVARCHAR(50)
      ,@MODE     INT
      ,@REF_NO   NVARCHAR(10)
AS
--�ۑ��������s
BEGIN
    --�߂�l�p�e�[�u���ϐ�
    DECLARE @TBL TABLE (
      RESULT_ZAIKO_NO NVARCHAR(10)
     ,RESULT_CD int NOT NULL
     ,RESULT_MESSAGE NVARCHAR(max)
    )

    --�Z�[�u�|�C���g����
    SAVE TRANSACTION SAVE1

BEGIN TRY

    --�݌ɒ�������
    IF @MODE IN ( 1,2 )
      BEGIN

            --�݌Ɉ�������
            UPDATE T_ZAIKO
               SET T_ZAIKO.HOKAN_BASHO_KBN = W_ZAIKO_INPUT.HOKAN_BASHO_KBN
                  ,T_ZAIKO.KOBAIHIN_CD     = W_ZAIKO_INPUT.KOBAIHIN_CD
                  ,T_ZAIKO.TANKA           = W_ZAIKO_INPUT.TANKA
                  ,T_ZAIKO.ZAIKO_SURYO     = W_ZAIKO_INPUT.ZAIKO_SURYO
                  ,T_ZAIKO.BARA_TANI       = W_ZAIKO_INPUT.BARA_TANI
                  ,T_ZAIKO.IRISU           = W_ZAIKO_INPUT.IRISU
                  ,T_ZAIKO.IRISU_TANI      = W_ZAIKO_INPUT.IRISU_TANI
                  ,T_ZAIKO.SHIIRE_CD       = W_ZAIKO_INPUT.SHIIRE_CD
                  ,T_ZAIKO.MAKER_CD        = W_ZAIKO_INPUT.MAKER_CD
                  ,T_ZAIKO.DBS_UPDATE_USER = W_ZAIKO_INPUT.DBS_UPDATE_USER
                  ,T_ZAIKO.DBS_UPDATE_DATE = W_ZAIKO_INPUT.DBS_UPDATE_DATE
              FROM T_ZAIKO
             INNER JOIN
                   W_ZAIKO_INPUT
                ON W_ZAIKO_INPUT.ZAIKO_NO = T_ZAIKO.ZAIKO_NO
             WHERE W_USER_ID = @USER_ID
               AND W_SERIAL  = @SERIAL
               AND W_ROW     = 1

      END

    --�폜����
    ELSE IF @MODE = 3
      BEGIN

        --�݌Ƀe�[�u���폜
        DELETE
          FROM T_ZAIKO
         WHERE T_ZAIKO.ZAIKO_NO = @REF_NO

      END

    --���̑�����
    ELSE
      BEGIN

        --���[�N�e�[�u���N���A
        DELETE
          FROM W_ZAIKO_INPUT
         WHERE W_ZAIKO_INPUT.W_USER_ID = @USER_ID

      END

    --���ʏ���
    --���[�N�e�[�u���N���A
    DELETE
      FROM W_ZAIKO_INPUT
     WHERE W_ZAIKO_INPUT.W_USER_ID = @USER_ID

    --����I��
    INSERT INTO @TBL VALUES( @REF_NO, 0, NULL )

    --�������ʕԋp
    SELECT RESULT_ZAIKO_NO, RESULT_CD, RESULT_MESSAGE FROM @TBL

END TRY

-- ��O����
BEGIN CATCH

    --�g�����U�N�V���������[���o�b�N�i�L�����Z���j
    ROLLBACK TRANSACTION SAVE1

    --���[�N�e�[�u���N���A
    DELETE
      FROM W_ZAIKO_INPUT
     WHERE W_ZAIKO_INPUT.W_USER_ID = @USER_ID

    --�ُ�I��
    INSERT INTO @TBL VALUES( 0, ERROR_NUMBER(), ERROR_MESSAGE() )

    --�������ʕԋp
    SELECT RESULT_ZAIKO_NO, RESULT_CD, RESULT_MESSAGE FROM @TBL

END CATCH

END


