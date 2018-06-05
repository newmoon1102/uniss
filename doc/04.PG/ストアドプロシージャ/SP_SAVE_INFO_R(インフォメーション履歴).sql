-- DROP PROCEDURE SP_SAVE_INFO_R

CREATE PROCEDURE SP_SAVE_INFO_R
       @USER_ID  NVARCHAR(64)
      ,@SERIAL   NVARCHAR(50)
      ,@MODE     INT

AS
--[���[�h] 0:�Ǎ� / 1:���Ǐ��� / 2:���[�N�e�[�u���폜
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

    --�Ǎ�����
    IF @MODE = 0
      BEGIN

        --���[�N�e�[�u���N���A
        DELETE
          FROM W_INFO_R
         WHERE W_INFO_R.W_USER_ID = @USER_ID

        --�V�K�ۑ�(���[�N�e�[�u���ɑ��݂���C���t�H���[�V�����𗚗��ɃR�s�[)
        INSERT INTO
               W_INFO_R (
                         W_INFO_R.W_USER_ID
                        ,W_INFO_R.W_SERIAL
                        ,W_INFO_R.INFO_NO
                        ,W_INFO_R.W_MODE
                        ,W_INFO_R.SELECT_FLG
                        )
               SELECT 
                      @USER_ID
                     ,@SERIAL
                     ,T_INFO_R.INFO_NO
                     ,1
                     ,'False'
                 FROM T_INFO_R
                WHERE T_INFO_R.NT_TANTO_CD = @USER_ID

      END

    --����(�߂�)����
     ELSE IF @MODE = 1
      BEGIN
      
        --�V�K�ۑ�(���[�N�e�[�u���ɑ��݂���C���t�H���[�V�����𗚗��ɃR�s�[)
        INSERT INTO
               T_INFO
               SELECT *
                 FROM T_INFO_R
                WHERE T_INFO_R.INFO_NO IN ( SELECT W_INFO_R.INFO_NO 
                                              FROM W_INFO_R
                                             WHERE W_INFO_R.W_USER_ID  = @USER_ID
                                               AND W_INFO_R.W_SERIAL   = @SERIAL
                                               AND W_INFO_R.SELECT_FLG = 'True' )

        --�폜
        DELETE
          FROM T_INFO_R
         WHERE T_INFO_R.INFO_NO IN ( SELECT W_INFO_R.INFO_NO 
                                       FROM W_INFO_R
                                      WHERE W_INFO_R.W_USER_ID  = @USER_ID
                                        AND W_INFO_R.W_SERIAL   = @SERIAL 
                                        AND W_INFO_R.SELECT_FLG = 'True' )

        --���[�N�e�[�u���N���A
        DELETE
          FROM W_INFO_R
         WHERE W_INFO_R.W_USER_ID = @USER_ID

     END

    --���[�N�e�[�u���폜����
    ELSE IF @MODE = 2
     BEGIN

            --���[�N�e�[�u���N���A
            DELETE
              FROM W_INFO_R
             WHERE W_INFO_R.W_USER_ID = @USER_ID

     END


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
      FROM W_INFO_R
     WHERE W_INFO_R.W_USER_ID = @USER_ID
       AND W_INFO_R.W_SERIAL  = @SERIAL

    --�ُ�I��
    INSERT INTO @TBL VALUES( ERROR_NUMBER(), ERROR_MESSAGE() )

    --�������ʕԋp
    SELECT RESULT_CD, RESULT_MESSAGE FROM @TBL

END CATCH

END
