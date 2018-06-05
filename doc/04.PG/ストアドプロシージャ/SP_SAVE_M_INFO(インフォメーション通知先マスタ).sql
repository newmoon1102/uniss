-- DROP PROCEDURE SP_SAVE_M_INFO


CREATE PROCEDURE SP_SAVE_M_INFO
       @USER_ID         NVARCHAR(64)
      ,@SERIAL          NVARCHAR(50)
      ,@MODE            INT
      ,@INFO_ID         INT
      ,@NYURYOKUSHA_FLG NVARCHAR(5)
      ,@RED_FLG         NVARCHAR(5)
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

    --�w�b�_�X�V(�������}�X�^)
    UPDATE M_INFO_H
       SET M_INFO_H.NYURYOKUSHA_FLG   = @NYURYOKUSHA_FLG
          ,M_INFO_H.RED_FLG           = @RED_FLG
          ,M_INFO_H.DBS_STATUS        = W_INFO_TUCHI.DBS_STATUS
          ,M_INFO_H.DBS_UPDATE_USER   = W_INFO_TUCHI.DBS_UPDATE_USER
          ,M_INFO_H.DBS_UPDATE_DATE   = W_INFO_TUCHI.DBS_UPDATE_DATE
      FROM M_INFO_H
     INNER JOIN
           W_INFO_TUCHI
        ON W_USER_ID = @USER_ID
       AND W_SERIAL  = @SERIAL
       AND W_INFO_TUCHI.INFO_ID   = M_INFO_H.INFO_ID

    --�ύX�O�f�[�^�폜����
    DELETE
      FROM M_INFO_B
     WHERE M_INFO_B.INFO_ID = @INFO_ID

    --�{�f�B�ۑ�(���[�N�e�[�u�����}�X�^)
    INSERT INTO
           M_INFO_B(
                       INFO_ID
                      ,SEQ
                      ,NT_BUSHO_CD
                      ,NT_TANTO_CD
                      ,DBS_STATUS
                      ,DBS_CREATE_USER
                      ,DBS_CREATE_DATE
                      ,DBS_UPDATE_USER
                      ,DBS_UPDATE_DATE
                     )
                SELECT INFO_ID
                      ,SEQ
                      ,NT_BUSHO_CD
                      ,NT_TANTO_CD
                      ,DBS_STATUS
                      ,DBS_CREATE_USER
                      ,DBS_CREATE_DATE
                      ,DBS_UPDATE_USER
                      ,DBS_UPDATE_DATE
                  FROM W_INFO_TUCHI 
                 WHERE W_USER_ID = @USER_ID
                   AND W_SERIAL  = @SERIAL

    --���[�N�e�[�u���N���A
    DELETE
      FROM W_INFO_TUCHI
     WHERE W_INFO_TUCHI.W_USER_ID = @USER_ID
       AND W_INFO_TUCHI.W_SERIAL  = @SERIAL

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
      FROM W_INFO_TUCHI
     WHERE W_INFO_TUCHI.W_USER_ID = @USER_ID
       AND W_INFO_TUCHI.W_SERIAL  = @SERIAL

    --�ُ�I��
    INSERT INTO @TBL VALUES( ERROR_NUMBER(), ERROR_MESSAGE() )

    --�������ʕԋp
    SELECT RESULT_CD, RESULT_MESSAGE FROM @TBL

END CATCH

END
