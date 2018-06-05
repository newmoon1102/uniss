-- DROP PROCEDURE SP_SAVE_M_MEISHO_H

CREATE PROCEDURE SP_SAVE_M_MEISHO_H
       @USER_ID    NVARCHAR(64)
      ,@SERIAL     NVARCHAR(50)
      ,@MODE       INT
      ,@MEISHO_KBN NVARCHAR(6)
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

    --�ύX�O�S�f�[�^�폜����
    IF @MEISHO_KBN = 'ALLDEL'
      BEGIN
        --�S�f�[�^�폜
        DELETE
          FROM M_MEISHO_H
      END
      
    --�ύX�O�f�[�^�폜����
    ELSE
      BEGIN
        --�ύX�O�f�[�^�폜
        DELETE
          FROM M_MEISHO_H
         WHERE M_MEISHO_H.MEISHO_KBN = @MEISHO_KBN
      END
      
    --�ۑ�(���[�N�e�[�u�����}�X�^)
    INSERT INTO
           M_MEISHO_H(
                       MEISHO_KBN
                      ,MEISHO
                      ,CODE_KETA
                      ,ZOKUSEI
                      ,DATA_KETA
                      ,DBS_STATUS
                      ,DBS_CREATE_USER
                      ,DBS_CREATE_DATE
                      ,DBS_UPDATE_USER
                      ,DBS_UPDATE_DATE
                     )
                SELECT MEISHO_KBN
                      ,MEISHO
                      ,CODE_KETA
                      ,ZOKUSEI
                      ,DATA_KETA
                      ,DBS_STATUS
                      ,DBS_CREATE_USER
                      ,DBS_CREATE_DATE
                      ,DBS_UPDATE_USER
                      ,DBS_UPDATE_DATE
                  FROM W_MEISHO_H 
                 WHERE W_USER_ID = @USER_ID
                   AND W_SERIAL  = @SERIAL

    --���[�N�e�[�u���N���A
    DELETE
      FROM W_MEISHO_H
     WHERE W_MEISHO_H.W_USER_ID = @USER_ID
       AND W_MEISHO_H.W_SERIAL  = @SERIAL

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
      FROM W_MEISHO_H
     WHERE W_MEISHO_H.W_USER_ID = @USER_ID
       AND W_MEISHO_H.W_SERIAL  = @SERIAL

    --�ُ�I��
    INSERT INTO @TBL VALUES( ERROR_NUMBER(), ERROR_MESSAGE() )

    --�������ʕԋp
    SELECT RESULT_CD, RESULT_MESSAGE FROM @TBL

END CATCH

END
