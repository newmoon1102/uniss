--DROP PROCEDURE SP_SAVE_INFO


CREATE PROCEDURE SP_SAVE_INFO
       @USER_ID  NVARCHAR(64)
      ,@SERIAL   NVARCHAR(50)
      ,@MODE     INT

AS
--�ۑ��������s
BEGIN

--�ϐ���`

    --�߂�l
    DECLARE @TBL TABLE (
      RESULT_CD int NOT NULL
     ,RESULT_MESSAGE NVARCHAR(max)
    )

--�Z�[�u�|�C���g����
    SAVE TRANSACTION SAVE1

BEGIN TRY

    --���Ǐ���
    IF @MODE = 1
      BEGIN
      
        --�V�K�ۑ�(���[�N�e�[�u���ɑ��݂���C���t�H���[�V�����𗚗��ɃR�s�[)
        INSERT INTO
               T_INFO_R
               SELECT *
                 FROM T_INFO
                WHERE T_INFO.INFO_NO IN ( SELECT W_INFO.INFO_NO 
                                            FROM W_INFO
                                           WHERE W_INFO.W_USER_ID = @USER_ID
                                             AND W_INFO.W_SERIAL  = @SERIAL )
        --�폜
        DELETE
          FROM T_INFO
         WHERE T_INFO.INFO_NO IN ( SELECT W_INFO.INFO_NO 
                                     FROM W_INFO
                                    WHERE W_INFO.W_USER_ID = @USER_ID
                                      AND W_INFO.W_SERIAL  = @SERIAL )
      END

    --�S�����Ǐ���
    IF @MODE = 2
      BEGIN
      
        --�V�K�ۑ�(���[�N�e�[�u���ɑ��݂���C���t�H���[�V�����𗚗��ɃR�s�[)
        INSERT INTO
               T_INFO_R
               SELECT *
                 FROM T_INFO
                WHERE T_INFO.NT_TANTO_CD = @USER_ID

        --�폜
        DELETE
          FROM T_INFO
         WHERE T_INFO.NT_TANTO_CD = @USER_ID

      END

    --���ʏ���
    --���[�N�e�[�u���N���A
    DELETE
      FROM W_INFO
     WHERE W_INFO.W_USER_ID = @USER_ID
       AND W_INFO.W_SERIAL  = @SERIAL

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
      FROM W_INFO
     WHERE W_INFO.W_USER_ID = @USER_ID
       AND W_INFO.W_SERIAL  = @SERIAL

    --�ُ�I��
    INSERT INTO @TBL VALUES( ERROR_NUMBER(), ERROR_MESSAGE() )

    --�������ʕԋp
    SELECT RESULT_CD, RESULT_MESSAGE FROM @TBL

END CATCH

END
