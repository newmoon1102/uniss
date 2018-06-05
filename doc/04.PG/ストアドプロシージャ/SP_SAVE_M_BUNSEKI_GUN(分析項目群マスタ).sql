-- DROP PROCEDURE SP_SAVE_M_BUNSEKI_GUN

CREATE PROCEDURE SP_SAVE_M_BUNSEKI_GUN
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
               M_BUNSEKI_GUN_B(
                                BUNSEKI_GUN_CD
                               ,SEQ
                               ,BUNSEKI_CD
                               ,DBS_STATUS
                               ,DBS_CREATE_USER
                               ,DBS_CREATE_DATE
                               ,DBS_UPDATE_USER
                               ,DBS_UPDATE_DATE
                              )
                         SELECT BUNSEKI_GUN_CD
                               ,SEQ
                               ,BUNSEKI_CD
                               ,DBS_STATUS
                               ,DBS_CREATE_USER
                               ,DBS_CREATE_DATE
                               ,DBS_UPDATE_USER
                               ,DBS_UPDATE_DATE
                           FROM W_BUNSEKI_GUN
                          WHERE W_USER_ID = @USER_ID
                            AND W_SERIAL  = @SERIAL
                    
        INSERT INTO
               M_BUNSEKI_GUN_H(
                                BUNSEKI_GUN_CD
                               ,BUNSEKI_GUN_MEI
                               ,DBS_STATUS
                               ,DBS_CREATE_USER
                               ,DBS_CREATE_DATE
                               ,DBS_UPDATE_USER
                               ,DBS_UPDATE_DATE
                              )
                         SELECT BUNSEKI_GUN_CD
                               ,BUNSEKI_GUN_MEI
                               ,DBS_STATUS
                               ,DBS_CREATE_USER
                               ,DBS_CREATE_DATE
                               ,DBS_UPDATE_USER
                               ,DBS_UPDATE_DATE
                           FROM W_BUNSEKI_GUN
                          WHERE W_USER_ID = @USER_ID
                            AND W_SERIAL  = @SERIAL
                            AND SEQ       = '1'
      END
    
    --�X�V����
    ELSE IF @MODE = 2
      BEGIN
        --�����f�[�^�폜
        DELETE
          FROM M_BUNSEKI_GUN_B
         WHERE M_BUNSEKI_GUN_B.BUNSEKI_GUN_CD IN ( SELECT W_BUNSEKI_GUN.BUNSEKI_GUN_CD
                                                     FROM W_BUNSEKI_GUN
                                                    WHERE W_BUNSEKI_GUN.W_USER_ID = @USER_ID
                                                      AND W_BUNSEKI_GUN.W_SERIAL  = @SERIAL
                                                    GROUP BY
                                                          W_BUNSEKI_GUN.BUNSEKI_GUN_CD )

        DELETE
          FROM M_BUNSEKI_GUN_H
         WHERE M_BUNSEKI_GUN_H.BUNSEKI_GUN_CD IN ( SELECT W_BUNSEKI_GUN.BUNSEKI_GUN_CD
                                                     FROM W_BUNSEKI_GUN
                                                    WHERE W_BUNSEKI_GUN.W_USER_ID = @USER_ID
                                                      AND W_BUNSEKI_GUN.W_SERIAL  = @SERIAL
                                                    GROUP BY
                                                          W_BUNSEKI_GUN.BUNSEKI_GUN_CD )

        --�ۑ�(���[�N�e�[�u�����}�X�^)
        INSERT INTO
               M_BUNSEKI_GUN_B(
                                BUNSEKI_GUN_CD
                               ,SEQ
                               ,BUNSEKI_CD
                               ,DBS_STATUS
                               ,DBS_CREATE_USER
                               ,DBS_CREATE_DATE
                               ,DBS_UPDATE_USER
                               ,DBS_UPDATE_DATE
                              )
                         SELECT BUNSEKI_GUN_CD
                               ,SEQ
                               ,BUNSEKI_CD
                               ,DBS_STATUS
                               ,DBS_CREATE_USER
                               ,DBS_CREATE_DATE
                               ,DBS_UPDATE_USER
                               ,DBS_UPDATE_DATE
                           FROM W_BUNSEKI_GUN
                          WHERE W_USER_ID = @USER_ID
                            AND W_SERIAL  = @SERIAL
                            
        INSERT INTO
               M_BUNSEKI_GUN_H(
                                BUNSEKI_GUN_CD
                               ,BUNSEKI_GUN_MEI
                               ,DBS_STATUS
                               ,DBS_CREATE_USER
                               ,DBS_CREATE_DATE
                               ,DBS_UPDATE_USER
                               ,DBS_UPDATE_DATE
                              )
                         SELECT BUNSEKI_GUN_CD
                               ,BUNSEKI_GUN_MEI
                               ,DBS_STATUS
                               ,DBS_CREATE_USER
                               ,DBS_CREATE_DATE
                               ,DBS_UPDATE_USER
                               ,DBS_UPDATE_DATE
                           FROM W_BUNSEKI_GUN
                          WHERE W_USER_ID = @USER_ID
                            AND W_SERIAL  = @SERIAL
                            AND SEQ       ='1'
      END

    --�폜����
    ELSE
      BEGIN

        --�����f�[�^�폜
        DELETE
          FROM M_BUNSEKI_GUN_B
         WHERE M_BUNSEKI_GUN_B.BUNSEKI_GUN_CD IN ( SELECT W_BUNSEKI_GUN.BUNSEKI_GUN_CD
                                                     FROM W_BUNSEKI_GUN
                                                    WHERE W_BUNSEKI_GUN.W_USER_ID = @USER_ID
                                                      AND W_BUNSEKI_GUN.W_SERIAL  = @SERIAL
                                                    GROUP BY
                                                          W_BUNSEKI_GUN.BUNSEKI_GUN_CD )

        DELETE
          FROM M_BUNSEKI_GUN_H
         WHERE M_BUNSEKI_GUN_H.BUNSEKI_GUN_CD IN ( SELECT W_BUNSEKI_GUN.BUNSEKI_GUN_CD
                                                     FROM W_BUNSEKI_GUN
                                                    WHERE W_BUNSEKI_GUN.W_USER_ID = @USER_ID
                                                      AND W_BUNSEKI_GUN.W_SERIAL  = @SERIAL
                                                    GROUP BY
                                                          W_BUNSEKI_GUN.BUNSEKI_GUN_CD )
      END

    --���ʏ���
    --���[�N�e�[�u���N���A
    DELETE
      FROM W_BUNSEKI_GUN
     WHERE W_BUNSEKI_GUN.W_USER_ID = @USER_ID
       AND W_BUNSEKI_GUN.W_SERIAL  = @SERIAL

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
      FROM W_BUNSEKI_GUN
     WHERE W_BUNSEKI_GUN.W_USER_ID = @USER_ID
       AND W_BUNSEKI_GUN.W_SERIAL  = @SERIAL

    --�ُ�I��
    INSERT INTO @TBL VALUES( ERROR_NUMBER(), ERROR_MESSAGE() )

    --�������ʕԋp
    SELECT RESULT_CD, RESULT_MESSAGE FROM @TBL

END CATCH

END
