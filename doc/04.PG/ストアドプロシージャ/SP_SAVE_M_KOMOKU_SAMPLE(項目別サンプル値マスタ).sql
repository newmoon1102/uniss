-- DROP PROCEDURE SP_SAVE_M_KOMOKU_SAMPLE


CREATE PROCEDURE SP_SAVE_M_KOMOKU_SAMPLE
       @USER_ID    NVARCHAR(64)
      ,@SERIAL     NVARCHAR(50)
      ,@MODE       INT
      ,@BUNSEKI_CD NVARCHAR(10)
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

    --�X�V����
    IF @MODE = 2
      BEGIN
        --�ύX�O�f�[�^�폜����
        DELETE
          FROM M_KOMOKU_SAMPLE
         WHERE M_KOMOKU_SAMPLE.BUNSEKI_CD = @BUNSEKI_CD

        --�{�f�B�ۑ�(���[�N�e�[�u�����}�X�^)
        INSERT INTO
               M_KOMOKU_SAMPLE(
                                  BUNSEKI_CD
                                 ,KOBAN
                                 ,MEISHO
                                 ,NYURYOKU
                                 ,KATA
                                 ,ALL_KETA
                                 ,SHOSU_KETA
                                 ,SETTEICHI
                                 ,DBS_STATUS
                                 ,DBS_CREATE_USER
                                 ,DBS_CREATE_DATE
                                 ,DBS_UPDATE_USER
                                 ,DBS_UPDATE_DATE
                                )
                           SELECT BUNSEKI_CD
                                 ,KOBAN
                                 ,MEISHO
                                 ,NYURYOKU
                                 ,KATA
                                 ,ALL_KETA
                                 ,SHOSU_KETA
                                 ,SETTEICHI
                                 ,DBS_STATUS
                                 ,DBS_CREATE_USER
                                 ,DBS_CREATE_DATE
                                 ,DBS_UPDATE_USER
                                 ,DBS_UPDATE_DATE
                             FROM W_KOMOKU_SAMPLE 
                            WHERE W_USER_ID = @USER_ID
                              AND W_SERIAL  = @SERIAL
      END

    --�폜����
    ELSE IF @MODE = 3
      BEGIN
        --�����f�[�^�폜
        DELETE
          FROM M_KOMOKU_SAMPLE
         WHERE M_KOMOKU_SAMPLE.BUNSEKI_CD = @BUNSEKI_CD
      END

    --���ʏ���
    --���[�N�e�[�u���N���A
    DELETE
      FROM W_KOMOKU_SAMPLE
     WHERE W_KOMOKU_SAMPLE.W_USER_ID = @USER_ID
       AND W_KOMOKU_SAMPLE.W_SERIAL  = @SERIAL

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
      FROM W_KOMOKU_SAMPLE
     WHERE W_KOMOKU_SAMPLE.W_USER_ID = @USER_ID
       AND W_KOMOKU_SAMPLE.W_SERIAL  = @SERIAL

    --�ُ�I��
    INSERT INTO @TBL VALUES( ERROR_NUMBER(), ERROR_MESSAGE() )

    --�������ʕԋp
    SELECT RESULT_CD, RESULT_MESSAGE FROM @TBL

END CATCH

END
