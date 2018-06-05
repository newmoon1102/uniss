
/*DROP PROCEDURE SP_SAVE_M_BUN_SORT*/

CREATE PROCEDURE [dbo].[SP_SAVE_M_BUN_SORT]
       @USER_ID           NVARCHAR(64)
      ,@SERIAL            NVARCHAR(50)
      ,@BUNSEKI_HOHO_CD   NVARCHAR(9)
      ,@FLG               NVARCHAR(5)
      ,@SEQ               INT
      ,@MODE              INT
AS
/*�ۑ��������s*/
BEGIN

   /*�ϐ���`*/
    DECLARE @retVal      INT
    DECLARE @FLG_SAVE    NVARCHAR(5)

    /*�߂�l*/
    DECLARE @TBL TABLE (
      RESULT_CD int NOT NULL
     ,RESULT_MESSAGE NVARCHAR(max)
    )
    
    /*�Z�[�u�|�C���g����*/
    SAVE TRANSACTION SAVE1

BEGIN TRY

    /*�V�K�o�^����*/
    IF @MODE = 1
      BEGIN
      SET @FLG_SAVE = @FLG
      IF  @FLG_SAVE = 'TRUE'
          BEGIN
              UPDATE W_BUN_SORT 
                  SET W_BUN_SORT.DEFAULT_FLG       = 'False' 
               WHERE  W_BUN_SORT.BUNSEKI_HOHO_CD   =  @BUNSEKI_HOHO_CD 
                  AND W_BUN_SORT.SEQ               <> @SEQ
                  
              UPDATE M_BUN_SORT_H 
                  SET M_BUN_SORT_H.DEFAULT_FLG     = 'False' 
               WHERE  M_BUN_SORT_H.BUNSEKI_HOHO_CD =  @BUNSEKI_HOHO_CD 
                  AND M_BUN_SORT_H.SEQ             <> @SEQ
       END

        /*�V�K�ۑ�(���[�N�e�[�u�����w�b�_�[�}�X�^)*/
        INSERT INTO
               M_BUN_SORT_H(
                        BUNSEKI_HOHO_CD
                       ,SEQ
                       ,BUN_SORT_MEI
                       ,DEFAULT_FLG
                       ,DBS_STATUS
                       ,DBS_CREATE_USER
                       ,DBS_CREATE_DATE
                       ,DBS_UPDATE_USER
                       ,DBS_UPDATE_DATE
                      )
                 SELECT BUNSEKI_HOHO_CD
                       ,SEQ
                       ,BUN_SORT_MEI
                       ,@FLG_SAVE
                       ,1
                       ,@USER_ID
                       ,'DT' + CONVERT(VARCHAR(24),GETDATE(),121)
                       ,@USER_ID
                       ,'DT' + CONVERT(VARCHAR(24),GETDATE(),121)
                   FROM W_BUN_SORT
                  WHERE W_BUN_SORT.W_USER_ID = @USER_ID
                    AND W_BUN_SORT.W_SERIAL  = @SERIAL
                     GROUP BY
                        W_BUN_SORT.BUNSEKI_HOHO_CD
                       ,W_BUN_SORT.SEQ
                       ,W_BUN_SORT.BUN_SORT_MEI
                    
         /*�V�K�ۑ�(���[�N�e�[�u�����{�f�B�[�}�X�^)*/
        INSERT INTO
               M_BUN_SORT_B(
                        BUNSEKI_HOHO_CD
                       ,SEQ
                       ,SORT_NO
                       ,BUNSEKI_CD
                       ,DBS_STATUS
                       ,DBS_CREATE_USER
                       ,DBS_CREATE_DATE
                       ,DBS_UPDATE_USER
                       ,DBS_UPDATE_DATE
                      )
                 SELECT BUNSEKI_HOHO_CD
                       ,SEQ
                       ,SORT_NO
                       ,BUNSEKI_CD
                       ,DBS_STATUS
                       ,DBS_CREATE_USER
                       ,DBS_CREATE_DATE
                       ,DBS_UPDATE_USER
                       ,DBS_UPDATE_DATE
                   FROM W_BUN_SORT
                  WHERE W_BUN_SORT.W_USER_ID = @USER_ID
                    AND W_BUN_SORT.W_SERIAL  = @SERIAL
      END
    
    /*�X�V����*/
    ELSE IF @MODE = 2
      BEGIN
        /*�f�t�H���g����*/
        IF @FLG = 'TRUE'
          BEGIN
              UPDATE W_BUN_SORT 
                  SET W_BUN_SORT.DEFAULT_FLG       = 'False' 
               WHERE  W_BUN_SORT.BUNSEKI_HOHO_CD   =  @BUNSEKI_HOHO_CD 
                  AND W_BUN_SORT.SEQ               <> @SEQ
                  
              UPDATE M_BUN_SORT_H 
                  SET M_BUN_SORT_H.DEFAULT_FLG = 'False' 
               WHERE  M_BUN_SORT_H.BUNSEKI_HOHO_CD =  @BUNSEKI_HOHO_CD 
                  AND M_BUN_SORT_H.SEQ <> @SEQ
          END

        /*�ۑ�(���[�N�e�[�u�����w�b�_�[�}�X�^)*/
        UPDATE M_BUN_SORT_H
           SET M_BUN_SORT_H.BUNSEKI_HOHO_CD           = W_BUN_SORT.BUNSEKI_HOHO_CD
              ,M_BUN_SORT_H.SEQ                       = W_BUN_SORT.SEQ
              ,M_BUN_SORT_H.BUN_SORT_MEI              = W_BUN_SORT.BUN_SORT_MEI
              ,M_BUN_SORT_H.DEFAULT_FLG               = W_BUN_SORT.DEFAULT_FLG
              ,M_BUN_SORT_H.DBS_STATUS                = W_BUN_SORT.DBS_STATUS
              ,M_BUN_SORT_H.DBS_UPDATE_USER           = W_BUN_SORT.DBS_UPDATE_USER
              ,M_BUN_SORT_H.DBS_UPDATE_DATE           = W_BUN_SORT.DBS_UPDATE_DATE
                  FROM M_BUN_SORT_H
                  INNER JOIN
                        W_BUN_SORT
                     ON W_USER_ID = @USER_ID
                    AND W_SERIAL  = @SERIAL
                    AND W_BUN_SORT.BUNSEKI_HOHO_CD   = M_BUN_SORT_H.BUNSEKI_HOHO_CD
                    AND W_BUN_SORT.SEQ               = M_BUN_SORT_H.SEQ

        /*�폜(�{�f�B�[�}�X�^)*/
        DELETE M_BUN_SORT_B WHERE NOT EXISTS 
          (SELECT M_BUN_SORT_B.BUNSEKI_HOHO_CD
                 ,M_BUN_SORT_B.BUNSEKI_CD
                 ,M_BUN_SORT_B.SEQ 
               FROM W_BUN_SORT 
           WHERE M_BUN_SORT_B.BUNSEKI_HOHO_CD = W_BUN_SORT.BUNSEKI_HOHO_CD
           AND M_BUN_SORT_B.SEQ               = W_BUN_SORT.SEQ
           AND M_BUN_SORT_B.BUNSEKI_CD        = W_BUN_SORT.BUNSEKI_CD
          )
        AND M_BUN_SORT_B.BUNSEKI_HOHO_CD = @BUNSEKI_HOHO_CD 
        AND M_BUN_SORT_B.SEQ             = @SEQ

        /*�ۑ�(���[�N�e�[�u�����{�f�B�[�}�X�^)*/
        UPDATE M_BUN_SORT_B
           SET M_BUN_SORT_B.BUNSEKI_HOHO_CD           = W_BUN_SORT.BUNSEKI_HOHO_CD
              ,M_BUN_SORT_B.SEQ                       = W_BUN_SORT.SEQ
              ,M_BUN_SORT_B.SORT_NO                   = W_BUN_SORT.SORT_NO
              ,M_BUN_SORT_B.BUNSEKI_CD                = W_BUN_SORT.BUNSEKI_CD
              ,M_BUN_SORT_B.DBS_STATUS                = W_BUN_SORT.DBS_STATUS
              ,M_BUN_SORT_B.DBS_UPDATE_USER           = W_BUN_SORT.DBS_UPDATE_USER
              ,M_BUN_SORT_B.DBS_UPDATE_DATE           = W_BUN_SORT.DBS_UPDATE_DATE
                  FROM M_BUN_SORT_B
                  INNER JOIN
                        W_BUN_SORT
                     ON W_SERIAL  = @SERIAL
                    AND W_BUN_SORT.BUNSEKI_HOHO_CD   = M_BUN_SORT_B.BUNSEKI_HOHO_CD
                    AND W_BUN_SORT.SEQ               = M_BUN_SORT_B.SEQ
                    AND W_BUN_SORT.BUNSEKI_CD        = M_BUN_SORT_B.BUNSEKI_CD
                    
        INSERT INTO
           M_BUN_SORT_B(
              BUNSEKI_HOHO_CD
              ,SEQ
              ,SORT_NO
              ,BUNSEKI_CD
              ,DBS_STATUS
              ,DBS_CREATE_USER
              ,DBS_CREATE_DATE
              ,DBS_UPDATE_USER
              ,DBS_UPDATE_DATE
            )
            SELECT BUNSEKI_HOHO_CD
                 ,SEQ
                 ,SORT_NO
                 ,BUNSEKI_CD
                 ,DBS_STATUS
                 ,DBS_CREATE_USER
                 ,DBS_CREATE_DATE
                 ,DBS_UPDATE_USER
                 ,DBS_UPDATE_DATE
               FROM W_BUN_SORT
              WHERE NOT EXISTS 
                    (SELECT 1
                         FROM M_BUN_SORT_B 
                       WHERE M_BUN_SORT_B.BUNSEKI_HOHO_CD       = W_BUN_SORT.BUNSEKI_HOHO_CD
                             AND M_BUN_SORT_B.SEQ               = W_BUN_SORT.SEQ
                             AND M_BUN_SORT_B.BUNSEKI_CD        = W_BUN_SORT.BUNSEKI_CD
                      )
           AND  W_BUN_SORT.BUNSEKI_HOHO_CD       = @BUNSEKI_HOHO_CD 
           AND W_BUN_SORT.SEQ                    = @SEQ
      END

    /*�폜����*/
    ELSE
      BEGIN

        /*�����f�[�^�폜(�w�b�_�[)*/
        DELETE
          FROM M_BUN_SORT_H
         WHERE M_BUN_SORT_H.BUNSEKI_HOHO_CD = @BUNSEKI_HOHO_CD 
            AND M_BUN_SORT_H.SEQ            = @SEQ

        /*�����f�[�^�폜(�{�f�B�[)*/
        DELETE
          FROM M_BUN_SORT_B
         WHERE M_BUN_SORT_B.BUNSEKI_HOHO_CD = @BUNSEKI_HOHO_CD 
            AND M_BUN_SORT_B.SEQ            = @SEQ

        /*�����f�[�^�폜(���[�N�e�[�u��)*/
        DELETE
          FROM W_BUN_SORT
         WHERE W_BUN_SORT.BUNSEKI_HOHO_CD   = @BUNSEKI_HOHO_CD 
            AND W_BUN_SORT.SEQ               = @SEQ
        END 

    /*����I��*/
    INSERT INTO @TBL VALUES( 0, NULL )

    /*�������ʕԋp*/
    SELECT RESULT_CD, RESULT_MESSAGE FROM @TBL

END TRY


/* ��O����*/
BEGIN CATCH

    /* �g�����U�N�V���������[���o�b�N�i�L�����Z���j*/
    ROLLBACK TRANSACTION SAVE1

    /*�ُ�I��*/
    INSERT INTO @TBL VALUES( ERROR_NUMBER(), ERROR_MESSAGE() )

    /*�������ʕԋp*/
    SELECT RESULT_CD, RESULT_MESSAGE FROM @TBL

END CATCH

END