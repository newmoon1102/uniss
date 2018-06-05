-- DROP PROCEDURE SP_SAVE_M_SHAIN


CREATE PROCEDURE SP_SAVE_M_SHAIN
       @USER_ID  NVARCHAR(64)
      ,@SERIAL   NVARCHAR(50)
      ,@MODE     INT
AS
--�ۑ��������s
BEGIN
    DECLARE @TBL TABLE (
      RESULT_CD int NOT NULL
     ,RESULT_MESSAGE NVARCHAR(max)
    )
    
    --�Z�[�u�|�C���g����
    SAVE TRANSACTION SAVE1

BEGIN TRY

    --�V�K�o�^����
    IF @MODE = 1
      BEGIN
        --�V�K�ۑ�(���[�N�e�[�u�����}�X�^)
        INSERT INTO
               M_SHAIN(
                        SHAIN_CD
                       ,BUSHO_CD
                       ,SHIMEI
                       ,TANTO_MARK_PATH
                       ,MISHIYO_FLG
                       ,DBS_STATUS
                       ,DBS_CREATE_USER
                       ,DBS_CREATE_DATE
                       ,DBS_UPDATE_USER
                       ,DBS_UPDATE_DATE
                      )
                 SELECT SHAIN_CD
                       ,BUSHO_CD
                       ,SHIMEI
                       ,TANTO_MARK_PATH
                       ,MISHIYO_FLG
                       ,DBS_STATUS
                       ,DBS_CREATE_USER
                       ,DBS_CREATE_DATE
                       ,DBS_UPDATE_USER
                       ,DBS_UPDATE_DATE
                   FROM W_SHAIN 
                  WHERE W_USER_ID = @USER_ID
                    AND W_SERIAL  = @SERIAL
      END
    
    --�X�V����
    ELSE IF @MODE = 2
      BEGIN
        --�ۑ�(���[�N�e�[�u�����}�X�^)
         UPDATE M_SHAIN
            SET M_SHAIN.SHAIN_CD         = W_SHAIN.SHAIN_CD
               ,M_SHAIN.BUSHO_CD         = W_SHAIN.BUSHO_CD
               ,M_SHAIN.SHIMEI           = W_SHAIN.SHIMEI
               ,M_SHAIN.TANTO_MARK_PATH  = W_SHAIN.TANTO_MARK_PATH
               ,M_SHAIN.MISHIYO_FLG      = W_SHAIN.MISHIYO_FLG
               ,M_SHAIN.DBS_UPDATE_USER  = W_SHAIN.DBS_UPDATE_USER
               ,M_SHAIN.DBS_UPDATE_DATE  = W_SHAIN.DBS_UPDATE_DATE
           FROM M_SHAIN
          INNER JOIN
                W_SHAIN
             ON W_USER_ID = @USER_ID
            AND W_SERIAL  = @SERIAL
            AND W_SHAIN.SHAIN_CD   = M_SHAIN.SHAIN_CD
      END

    --�폜����
    ELSE
      BEGIN

        --�����f�[�^�폜
        DELETE
          FROM M_SHAIN
         WHERE M_SHAIN.SHAIN_CD IN ( SELECT W_SHAIN.SHAIN_CD
                                       FROM W_SHAIN
                                      WHERE W_SHAIN.W_USER_ID = @USER_ID
                                        AND W_SHAIN.W_SERIAL  = @SERIAL
                                      GROUP BY
                                            W_SHAIN.SHAIN_CD )
      END

    --���ʏ���
    --���[�N�e�[�u���N���A
    DELETE
      FROM W_SHAIN
     WHERE W_SHAIN.W_USER_ID = @USER_ID
       AND W_SHAIN.W_SERIAL  = @SERIAL

    --����I��
    INSERT INTO @TBL VALUES( 0, NULL )

    --�������ʕԋp
    SELECT RESULT_CD, RESULT_MESSAGE FROM @TBL

END TRY


-- ��O����
BEGIN CATCH

    -- �g�����U�N�V���������[���o�b�N�i�L�����Z���j
    ROLLBACK TRANSACTION SAVE1

    --���[�N�e�[�u���N���A
    DELETE
      FROM W_SHAIN
     WHERE W_SHAIN.W_USER_ID = @USER_ID
       AND W_SHAIN.W_SERIAL  = @SERIAL

    --�ُ�I��
    INSERT INTO @TBL VALUES( ERROR_NUMBER(), ERROR_MESSAGE() )

    --�������ʕԋp
    SELECT RESULT_CD, RESULT_MESSAGE FROM @TBL

END CATCH

END
