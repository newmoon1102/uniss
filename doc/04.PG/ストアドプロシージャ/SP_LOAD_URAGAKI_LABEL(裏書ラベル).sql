--DROP PROCEDURE SP_LOAD_URAGAKI_LABEL

CREATE PROCEDURE SP_LOAD_URAGAKI_LABEL
       @USER_ID  NVARCHAR(64)   /*���[�U�[ID*/
      ,@SERIAL   NVARCHAR(50)   /*�V���A��*/
      ,@MODE     NVARCHAR(1)    /*�������[�h*/
      ,@JOKEN_W  NVARCHAR(MAX)  /*�Ǎ�������*/
AS
/* [���[�h] 0:�Ǎ� / 1:���[�N�e�[�u���폜 / 2:���s�ς݃t���O�Z�b�g */
BEGIN
    /*�߂�l�p�e�[�u���ϐ�*/
    DECLARE @TBL TABLE (
      RESULT_CD       int NOT NULL
     ,RESULT_MESSAGE  NVARCHAR(max)
    )

    /*�Ǎ����� ���[�N�e�[�u���h�m�r�d�q�s�p*/
    DECLARE @INS_SQL AS NVARCHAR(MAX)

    /*�Z�[�u�|�C���g����*/
    SAVE TRANSACTION SAVE1

BEGIN TRY

    /*�Ǎ�����*/
    IF @MODE = 0
      BEGIN

        /*���[�N�e�[�u���N���A*/
        DELETE
          FROM W_URAGAKI_LABEL
         WHERE W_URAGAKI_LABEL.W_USER_ID = @USER_ID

        /*�Ǎ��f�[�^�����[�N�e�[�u���֊i�[*/
        SET @INS_SQL = 'INSERT INTO '
                     + '       W_URAGAKI_LABEL '
                     + 'SELECT ''' + @USER_ID + ''''                                 /* ���[�U�[ID */
                     + '      ,''' + @SERIAL  + ''''                                 /* �V���A�� */
                     + '      ,ROW_NUMBER() OVER (ORDER BY JURI_NO,JURI_EDA_NO,SEQ)' /* �s�ԍ� */
                     + '      ,'   + @MODE                                           /* �������[�h */
                     + '      ,''True'''                                             /* �I���t���O */
                     + '      ,V_URAGAKI_LABEL.*'                                    /* �������x���r���[ */
                     + '      ,1 '                                                   /* DBS�̈� ���R�[�h��� */
                     + '      ,''' + @USER_ID + ''''                                 /* DBS�̈� �쐬���[�U�h�c */
                     + '      ,''DT'' + ' + 'CONVERT(VARCHAR(24),GETDATE(),120)'     /* DBS�̈� �쐬���� */
                     + '      ,''' + @USER_ID + ''''                                 /* DBS�̈� �X�V���[�U�h�c */
                     + '      ,''DT'' + ' + 'CONVERT(VARCHAR(24),GETDATE(),120)'     /* DBS�̈� �X�V���� */
                     + '  FROM V_URAGAKI_LABEL '
                     + @JOKEN_W

        /*���[�N�e�[�u���h�m�r�d�q�s�p�r�p�k���s*/
        EXEC(@INS_SQL)

      END

    --���[�N�e�[�u���폜����
    ELSE IF @MODE = 1
     BEGIN

        --���[�N�e�[�u���N���A
        DELETE
          FROM W_URAGAKI_LABEL
         WHERE W_URAGAKI_LABEL.W_USER_ID = @USER_ID

     END

    --���s�ς݃t���O�Z�b�g����
    ELSE IF @MODE = 2
      BEGIN

        --���s�ς݃t���O�Z�b�g
        UPDATE T_BUN_JUCHU_SHOSAI
           SET
               T_BUN_JUCHU_SHOSAI.URAGAKI_PRINT_FLG = 'True'
          FROM W_URAGAKI_LABEL
         INNER JOIN
               T_BUN_JUCHU_SHOSAI
            ON T_BUN_JUCHU_SHOSAI.JURI_NO = W_URAGAKI_LABEL.JURI_NO
           AND T_BUN_JUCHU_SHOSAI.JURI_EDA_NO = W_URAGAKI_LABEL.JURI_EDA_NO
           AND T_BUN_JUCHU_SHOSAI.SEQ = W_URAGAKI_LABEL.SEQ
         WHERE W_URAGAKI_LABEL.W_USER_ID  = @USER_ID
           AND W_URAGAKI_LABEL.W_SERIAL   = @SERIAL
           AND W_URAGAKI_LABEL.SELECT_FLG = 'True'

      END

END TRY


 /*��O����*/
BEGIN CATCH

    /* �g�����U�N�V���������[���o�b�N�i�L�����Z���j*/
    ROLLBACK TRANSACTION SAVE1

    /*���[�N�e�[�u���N���A*/
    DELETE
      FROM W_URAGAKI_LABEL
     WHERE W_URAGAKI_LABEL.W_USER_ID = @USER_ID

END CATCH

END
