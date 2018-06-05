-- DROP PROCEDURE SP_SAVE_M_MEISHO_B


CREATE PROCEDURE SP_SAVE_M_MEISHO_B
       @USER_ID    NVARCHAR(64)
      ,@SERIAL     NVARCHAR(50)
      ,@MODE       INT
      ,@MEISHO_KBN NVARCHAR(4)
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

    --�ύX�O�f�[�^�폜����
    DELETE
      FROM M_MEISHO_B
     WHERE M_MEISHO_B.MEISHO_KBN = @MEISHO_KBN

    --�ۑ�(���[�N�e�[�u�����}�X�^)
    INSERT INTO
           M_MEISHO_B(
                       MEISHO_KBN
                      ,MEISHO_CD
                      ,DATA_1
                      ,DATA_2
                      ,SORT_NO
                      ,MISHIYO_FLG
                      ,DBS_STATUS
                      ,DBS_CREATE_USER
                      ,DBS_CREATE_DATE
                      ,DBS_UPDATE_USER
                      ,DBS_UPDATE_DATE
                     )
                SELECT MEISHO_KBN
                      ,MEISHO_CD
                      ,DATA_1
                      ,DATA_2
                      ,SORT_NO
                      ,MISHIYO_FLG
                      ,DBS_STATUS
                      ,DBS_CREATE_USER
                      ,DBS_CREATE_DATE
                      ,DBS_UPDATE_USER
                      ,DBS_UPDATE_DATE
                  FROM W_MEISHO_B 
                 WHERE W_USER_ID = @USER_ID
                   AND W_SERIAL  = @SERIAL

    --���[�N�e�[�u���N���A
    DELETE
      FROM W_MEISHO_B
     WHERE W_MEISHO_B.W_USER_ID = @USER_ID
       AND W_MEISHO_B.W_SERIAL  = @SERIAL

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
      FROM W_MEISHO_B
     WHERE W_MEISHO_B.W_USER_ID = @USER_ID
       AND W_MEISHO_B.W_SERIAL  = @SERIAL

    --�ُ�I��
    INSERT INTO @TBL VALUES( ERROR_NUMBER(), ERROR_MESSAGE() )

    --�������ʕԋp
    SELECT RESULT_CD, RESULT_MESSAGE FROM @TBL

END CATCH

END
