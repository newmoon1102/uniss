
/*DROP PROCEDURE SP_SAVE_M_BUN_SORT*/

CREATE PROCEDURE [dbo].[SP_SAVE_M_BUN_SORT]
       @USER_ID           NVARCHAR(64)
      ,@SERIAL            NVARCHAR(50)
      ,@BUNSEKI_HOHO_CD   NVARCHAR(9)
      ,@FLG               NVARCHAR(5)
      ,@SEQ               INT
      ,@MODE              INT
AS
/*保存処理実行*/
BEGIN

   /*変数定義*/
    DECLARE @retVal      INT
    DECLARE @FLG_SAVE    NVARCHAR(5)

    /*戻り値*/
    DECLARE @TBL TABLE (
      RESULT_CD int NOT NULL
     ,RESULT_MESSAGE NVARCHAR(max)
    )
    
    /*セーブポイント生成*/
    SAVE TRANSACTION SAVE1

BEGIN TRY

    /*新規登録処理*/
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

        /*新規保存(ワークテーブル→ヘッダーマスタ)*/
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
                    
         /*新規保存(ワークテーブル→ボディーマスタ)*/
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
    
    /*更新処理*/
    ELSE IF @MODE = 2
      BEGIN
        /*デフォルト解除*/
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

        /*保存(ワークテーブル→ヘッダーマスタ)*/
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

        /*削除(ボディーマスタ)*/
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

        /*保存(ワークテーブル→ボディーマスタ)*/
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

    /*削除処理*/
    ELSE
      BEGIN

        /*既存データ削除(ヘッダー)*/
        DELETE
          FROM M_BUN_SORT_H
         WHERE M_BUN_SORT_H.BUNSEKI_HOHO_CD = @BUNSEKI_HOHO_CD 
            AND M_BUN_SORT_H.SEQ            = @SEQ

        /*既存データ削除(ボディー)*/
        DELETE
          FROM M_BUN_SORT_B
         WHERE M_BUN_SORT_B.BUNSEKI_HOHO_CD = @BUNSEKI_HOHO_CD 
            AND M_BUN_SORT_B.SEQ            = @SEQ

        /*既存データ削除(ワークテーブル)*/
        DELETE
          FROM W_BUN_SORT
         WHERE W_BUN_SORT.BUNSEKI_HOHO_CD   = @BUNSEKI_HOHO_CD 
            AND W_BUN_SORT.SEQ               = @SEQ
        END 

    /*正常終了*/
    INSERT INTO @TBL VALUES( 0, NULL )

    /*処理結果返却*/
    SELECT RESULT_CD, RESULT_MESSAGE FROM @TBL

END TRY


/* 例外処理*/
BEGIN CATCH

    /* トランザクションをロールバック（キャンセル）*/
    ROLLBACK TRANSACTION SAVE1

    /*異常終了*/
    INSERT INTO @TBL VALUES( ERROR_NUMBER(), ERROR_MESSAGE() )

    /*処理結果返却*/
    SELECT RESULT_CD, RESULT_MESSAGE FROM @TBL

END CATCH

END