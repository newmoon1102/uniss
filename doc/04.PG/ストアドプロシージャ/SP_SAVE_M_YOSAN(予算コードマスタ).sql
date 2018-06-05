--DROP PROCEDURE SP_SAVE_M_YOSAN


CREATE PROCEDURE SP_SAVE_M_YOSAN
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
               M_YOSAN(
                        YOSAN_CD
                       ,YOSAN_MEI
                       ,DBS_STATUS
                       ,DBS_CREATE_USER
                       ,DBS_CREATE_DATE
                       ,DBS_UPDATE_USER
                       ,DBS_UPDATE_DATE
                      )
                 SELECT YOSAN_CD
                       ,YOSAN_MEI
                       ,DBS_STATUS
                       ,DBS_CREATE_USER
                       ,DBS_CREATE_DATE
                       ,DBS_UPDATE_USER
                       ,DBS_UPDATE_DATE
                   FROM W_YOSAN 
                  WHERE W_USER_ID = @USER_ID
                    AND W_SERIAL  = @SERIAL
      END
    
    --�X�V����
    ELSE IF @MODE = 2
      BEGIN
    --�ۑ�(���[�N�e�[�u�����}�X�^)
        UPDATE M_YOSAN
           SET M_YOSAN.YOSAN_CD           = W_YOSAN.YOSAN_CD
              ,M_YOSAN.YOSAN_MEI          = W_YOSAN.YOSAN_MEI
              ,M_YOSAN.DBS_STATUS         = W_YOSAN.DBS_STATUS
              ,M_YOSAN.DBS_UPDATE_USER    = W_YOSAN.DBS_UPDATE_USER
              ,M_YOSAN.DBS_UPDATE_DATE    = W_YOSAN.DBS_UPDATE_DATE
                  FROM M_YOSAN
                  INNER JOIN
                        W_YOSAN
                     ON W_USER_ID = @USER_ID
                    AND W_SERIAL  = @SERIAL
                    AND W_YOSAN.YOSAN_CD   = M_YOSAN.YOSAN_CD
      END

    --�폜����
    ELSE
      BEGIN

        --�����f�[�^�폜
        DELETE
          FROM M_YOSAN
         WHERE M_YOSAN.YOSAN_CD IN ( SELECT W_YOSAN.YOSAN_CD
                                       FROM W_YOSAN
                                      WHERE W_YOSAN.W_USER_ID = @USER_ID
                                        AND W_YOSAN.W_SERIAL  = @SERIAL
                                      GROUP BY
                                            W_YOSAN.YOSAN_CD )
      END

    --���ʏ���
    --���[�N�e�[�u���N���A
    DELETE
      FROM W_YOSAN
     WHERE W_YOSAN.W_USER_ID = @USER_ID
       AND W_YOSAN.W_SERIAL  = @SERIAL

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
      FROM W_YOSAN
     WHERE W_YOSAN.W_USER_ID = @USER_ID
       AND W_YOSAN.W_SERIAL  = @SERIAL

    --�ُ�I��
    INSERT INTO @TBL VALUES( ERROR_NUMBER(), ERROR_MESSAGE() )

    --�������ʕԋp
    SELECT RESULT_CD, RESULT_MESSAGE FROM @TBL

END CATCH

END
