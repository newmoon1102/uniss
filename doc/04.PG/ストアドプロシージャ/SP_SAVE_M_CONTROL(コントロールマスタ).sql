-- DROP PROCEDURE SP_SAVE_M_CONTROL


CREATE PROCEDURE SP_SAVE_M_CONTROL
       @USER_ID    NVARCHAR(64)
      ,@SERIAL     NVARCHAR(50)
      ,@MODE       INT
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
    UPDATE M_CONTROL
       SET M_CONTROL.CTRL_KEY                     = W_CONTROL.CTRL_KEY
          ,M_CONTROL.KAISHA_MARK_PATH             = W_CONTROL.KAISHA_MARK_PATH
          ,M_CONTROL.DAIHYO_MEI                   = W_CONTROL.DAIHYO_MEI
          ,M_CONTROL.TAX_1_DATE                   = W_CONTROL.TAX_1_DATE
          ,M_CONTROL.TAX_1                        = W_CONTROL.TAX_1
          ,M_CONTROL.TAX_2_DATE                   = W_CONTROL.TAX_2_DATE
          ,M_CONTROL.TAX_2                        = W_CONTROL.TAX_2
          ,M_CONTROL.SHOHIN_MASTER_LINK_DATE_TIME = W_CONTROL.SHOHIN_MASTER_LINK_DATE_TIME
          ,M_CONTROL.SEIKYU_MASTER_LINK_DATE_TIME = W_CONTROL.SEIKYU_MASTER_LINK_DATE_TIME
          ,M_CONTROL.SHIIRE_MASTER_LINK_DATE_TIME = W_CONTROL.SHIIRE_MASTER_LINK_DATE_TIME
          ,M_CONTROL.HYOJI_GYO_SU                 = W_CONTROL.HYOJI_GYO_SU
          ,M_CONTROL.COMMON_INFO                  = W_CONTROL.COMMON_INFO
          ,M_CONTROL.DBS_STATUS                   = W_CONTROL.DBS_STATUS
          ,M_CONTROL.DBS_UPDATE_USER              = W_CONTROL.DBS_UPDATE_USER
          ,M_CONTROL.DBS_UPDATE_DATE              = W_CONTROL.DBS_UPDATE_DATE
      FROM M_CONTROL
     INNER JOIN
           W_CONTROL
        ON W_USER_ID            = @USER_ID
       AND W_SERIAL             = @SERIAL
       AND W_CONTROL.CTRL_KEY   = M_CONTROL.CTRL_KEY

    --���ʏ���
    --���[�N�e�[�u���N���A
    DELETE
      FROM W_CONTROL
     WHERE W_CONTROL.W_USER_ID = @USER_ID
       AND W_CONTROL.W_SERIAL  = @SERIAL

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
      FROM W_CONTROL
     WHERE W_CONTROL.W_USER_ID = @USER_ID
       AND W_CONTROL.W_SERIAL  = @SERIAL

    --�ُ�I��
    INSERT INTO @TBL VALUES( ERROR_NUMBER(), ERROR_MESSAGE() )

    --�������ʕԋp
    SELECT RESULT_CD, RESULT_MESSAGE FROM @TBL

END CATCH

END
